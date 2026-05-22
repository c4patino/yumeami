{pkgs, ...}:
pkgs.writeShellScriptBin "generate-ssl-certs" ''
  set -euo pipefail

  usage() {
    echo "Usage: generate-ssl-certs [OPTIONS]"
    echo ""
    echo "Generate SSL certificates using Let's Encrypt or a custom CA."
    echo ""
    echo "OPTIONS:"
    echo "  -d, --domain <domain>    Domain name for the certificate (required)"
    echo "  -e, --email <email>     Email for Let's Encrypt (required if no --ca-path)"
    echo "  -o, --output <dir>      Output directory (default: current directory)"
    echo "  -c, --ca-path <dir>     Path to CA directory (contains ca.crt, ca.key, ca.srl)"
    echo "      --syncthing         Generate Syncthing-style self-signed cert/key (outputs: cert, key)"
    echo "  -b, --bits <bits>       Key bits for CA signing (default: 4096)"
    echo "  -t, --days <days>       Validity days for CA signing (default: 365)"
    echo "  -h, --help              Show this help message"
    exit 1
  }

  domain=""
  email=""
  output="."
  ca_path=""
  syncthing="false"
  bits="4096"
  days="365"

  while [[ $# -gt 0 ]]; do
    case $1 in
      -d|--domain)
        domain="$2"
        shift 2
        ;;
      -e|--email)
        email="$2"
        shift 2
        ;;
      -o|--output)
        output="$2"
        shift 2
        ;;
      -c|--ca-path)
        ca_path="$2"
        shift 2
        ;;
      --syncthing)
        syncthing="true"
        shift
        ;;
      -b|--bits)
        bits="$2"
        shift 2
        ;;
      -t|--days)
        days="$2"
        shift 2
        ;;
      -h|--help)
        usage
        ;;
      *)
        echo "Unknown option: $1"
        usage
        ;;
    esac
  done

  if [[ -z "$domain" ]]; then
    echo "Error: --domain is required"
    usage
  fi

  if [[ "$syncthing" == "true" ]]; then
    key_file="$output/syncthing.key"
    cert_file="$output/syncthing.cert"
  else
    key_file="$output/''${domain}.key"
    cert_file="$output/''${domain}.crt"
    fullchain_file="$output/''${domain}.fullchain.pem"
  fi

  mkdir -p "$output"

  if [[ "$syncthing" == "true" ]]; then
    if [[ -n "$ca_path" ]]; then
      echo "Error: --syncthing cannot be used with --ca-path"
      exit 1
    fi
    if [[ -n "$email" ]]; then
      echo "Error: --syncthing does not use Let's Encrypt; remove --email"
      exit 1
    fi

    # Syncthing-style (minimal):
    # - self-signed
    # - ECDSA P-384
    # - Subject/Issuer: O=Syncthing, CN=<domain>
    # Single OpenSSL invocation (no CSR/extfile/tempdir).
    "${pkgs.openssl}/bin/openssl" req -x509 -new \
      -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 \
      -nodes \
      -keyout "$key_file" \
      -out "$cert_file" \
      -days 7300 \
      -subj "/O=Syncthing/CN=$domain" \
      -addext "basicConstraints=critical,CA:FALSE" \
      -addext "keyUsage=critical,digitalSignature,keyEncipherment" \
      -addext "extendedKeyUsage=serverAuth,clientAuth" \
      -addext "subjectAltName=DNS:$domain"

    chmod 600 "$key_file" 2>/dev/null || true
    chmod 644 "$cert_file" 2>/dev/null || true

    echo "Generated Syncthing SSL certificate"
    echo "  Private Key: $key_file"
    echo "  Certificate: $cert_file"
    exit 0
  fi

  if [[ -n "$ca_path" ]]; then
    tempdir=$(mktemp -d)
    trap "rm -rf $tempdir" EXIT

    "${pkgs.openssl}/bin/openssl" genrsa -out "$tempdir/server.key" "$bits"

    # Wildcard certs must use SANs. Some clients also reject wildcard CNs,
    # so use the apex as CN and put both names in subjectAltName.
    cn="$domain"
    declare -a sans
    if [[ "$domain" == "*."* ]]; then
      apex="''${domain#*.}"
      cn="$apex"
      sans+=("$apex" "$domain")
    else
      sans+=("$domain")
    fi

    extfile="$tempdir/openssl-ext.cnf"
    {
      echo "[v3_req]"
      echo "basicConstraints = critical,CA:FALSE"
      echo "keyUsage = critical,digitalSignature,keyEncipherment"
      echo "extendedKeyUsage = serverAuth,clientAuth"
      echo "subjectAltName = @alt_names"
      echo ""
      echo "[alt_names]"
      i=1
      for name in "''${sans[@]}"; do
        echo "DNS.$i = $name"
        i=$((i + 1))
      done
    } > "$extfile"

    "${pkgs.openssl}/bin/openssl" req -new \
      -key "$tempdir/server.key" \
      -out "$tempdir/server.csr" \
      -subj "/CN=$cn"

    ca_crt="$ca_path/ca.crt"
    ca_key="$ca_path/ca.key"
    ca_srl="$ca_path/ca.srl"

    if [[ ! -f "$ca_crt" || ! -f "$ca_key" ]]; then
      echo "Error: CA files not found in $ca_path"
      exit 1
    fi

    # OpenSSL expects the serial file to contain a valid (hex) integer.
    # An empty file causes `a2i_ASN1_INTEGER:short line`.
    if [[ ! -s "$ca_srl" ]]; then
      echo 01 > "$ca_srl"
    fi

    "${pkgs.openssl}/bin/openssl" x509 -req \
      -in "$tempdir/server.csr" \
      -CA "$ca_crt" \
      -CAkey "$ca_key" \
      -CAserial "$ca_srl" \
      -CAcreateserial \
      -out "$cert_file" \
      -days "$days" \
      -sha256 \
      -extfile "$extfile" \
      -extensions v3_req

    cat "$cert_file" "$ca_crt" > "$fullchain_file"

    mv "$tempdir/server.key" "$key_file"
  else
    if [[ -z "$email" ]]; then
      echo "Error: --email is required for Let's Encrypt"
      usage
    fi

    tmp_certbot_dir=$(mktemp -d)
    trap "rm -rf $tmp_certbot_dir" EXIT

    echo "Using certbot manual DNS (you will be prompted to create TXT records)."
    echo "If you need automation, consider adding a DNS plugin."

    ${pkgs.certbot}/bin/certbot certonly \
      --manual \
      --preferred-challenges dns \
      -d "$domain" \
      --email "$email" \
      --agree-tos \
      --config-dir "$tmp_certbot_dir/config" \
      --work-dir "$tmp_certbot_dir/work" \
      --logs-dir "$tmp_certbot_dir/logs"

    live_dir="$tmp_certbot_dir/config/live/$domain"
    if [[ -d "$live_dir" ]]; then
      cp "$live_dir/privkey.pem" "$key_file"
      cp "$live_dir/fullchain.pem" "$fullchain_file"
      cp "$live_dir/cert.pem" "$cert_file"
    else
      echo "Error: certbot did not create expected live directory: $live_dir"
      exit 1
    fi
  fi

  chmod 600 "$key_file" 2>/dev/null || true
  chmod 644 "$cert_file" "$fullchain_file" 2>/dev/null || true

  echo "Generated SSL certificate for $domain"
  echo "  Private Key: $key_file"
  echo "  Certificate: $cert_file"
  echo "  Fullchain:   $fullchain_file"
''
