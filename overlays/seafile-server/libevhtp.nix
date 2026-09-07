{
  lib,
  gcc13Stdenv,
  fetchFromGitHub,
  cmake,
  libevent,
}:
gcc13Stdenv.mkDerivation {
  pname = "libevhtp";
  version = "unstable-2021-04-28";

  src = fetchFromGitHub {
    owner = "haiwen";
    repo = "libevhtp";
    rev = "18c649203f009ef1d77d6f8301eba09af3777adf";
    hash = "sha256-LcZu46NxY7rJNMNqo3/x7SMGExL7OTjvXxI5KjyTwOU=";
  };

  nativeBuildInputs = [cmake];

  buildInputs = [libevent];

  postPatch = ''
    sed -i 's/-Werror//g' CMakeLists.txt
    find . -name CMakeLists.txt -exec sed -i 's/-Werror//g' {} +
  '';

  cmakeFlags = [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DEVHTP_DISABLE_SSL=ON"
    "-DEVHTP_BUILD_SHARED=ON"
  ];

  meta = with lib; {
    description = "Create extremely-fast and secure embedded HTTP servers with ease";
    homepage = "https://github.com/criticalstack/libevhtp";
    license = licenses.bsd3;
  };
}
