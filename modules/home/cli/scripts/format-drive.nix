{pkgs, ...}:
pkgs.writeShellScriptBin "format-drive" ''
  set -euo pipefail

  MODE="soft"

  DRIVE=""
  FS=""

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --mode)
        MODE="$2"
        shift 2
        ;;
      -*)
        echo "[ ERROR ]: Unknown flag: $1"
        exit 1
        ;;
      *)
        if [ -z $DRIVE ]; then
          DRIVE="$1"
        elif [ -z "$FS" ]; then
          FS="$1"
        else
          echo "[ ERROR ] Too many arguments"
        fi
        shift
        ;;
    esac
  done

  if [ -z "$DRIVE" ] || [ -z "$FS" ]; then
    echo "[ ERROR ] Usage: format-drive [--mode soft|full] <drive> <filesystem>"
    echo "[ INFO ] Filesystems: ntfs | ext4 | fat32"
    exit 1
  fi

  DEV="/dev/$DRIVE"
  if [ ! -b "$DEV" ]; then
    echo "[ ERROR ] Device $DEV not found or not a block device"
    exit 1
  fi

  echo "[ INFO ] Target: $DEV"
  echo "[ INFO ] Mode: $MODE (default: soft)"

  echo "[ WARN ] This will erase data on $DEV"
  read -r -p "Type YES to continue: " CONFIRM
  [ "$CONFIRM" = "YES" ] || exit 0

  echo "[ INFO ] Unmounting partitions..."
  umount "''${DEV}"* 2>/dev/null || true

  if [ "$MODE" = "full" ]; then
    echo "[ INFO ] FULL WIPE: overwriting entire disk with zeros..."
    sudo dd if=/dev/zero of="$DEV" bs=4M status=progress conv=fsync || true
  elif [ "$MODE" = "soft" ]; then
    echo "[ INFO ] SOFT WIPE: clearing filesystem signatures..."
    sudo wipefs -a "$DEV"
  else
    echo "[ ERROR ] Invalid mode: $MODE (use soft or full)"
    exit 1
  fi

  echo "[ INFO ] Creating GPT partition table..."
  sudo ${pkgs.parted}/bin/parted -s "$DEV" mklabel gpt

  case "$FS" in
    fat32)
      PART_TYPE="fat32"
      PART_FLAGS="msftdata"
      ;;
    ntfs)
      PART_TYPE="ntfs"
      PART_FLAGS="msftdata"
      ;;
    ext4)
      PART_TYPE="ext4"
      PART_FLAGS=""
      ;;
    *)
      echo "[ ERROR ] Unsupported filesystem: $FS"
      exit 1
      ;;
  esac

  echo "[ INFO ] Creating partition..."
  sudo ${pkgs.parted}/bin/parted -s "$DEV" mkpart primary "$PART_TYPE" 1MiB 100%
  if [ -n "$PART_FLAGS" ]; then
    sudo ${pkgs.parted}/bin/parted -s "$DEV" set 1 "$PART_FLAGS" on
  fi

  PARTITION=$(lsblk -lnpo NAME "$DEV" | tail -n 1)
  echo "[ INFO ] Partition: $PARTITION"

  sudo ${pkgs.parted}/bin/partprobe "$DEV"

  case "$FS" in
    ntfs)
      sudo ${pkgs.ntfs3g}/bin/mkfs.ntfs -f "$PARTITION"
      ;;
    ext4)
      sudo ${pkgs.e2fsprogs}/bin/mkfs.ext4 -F "$PARTITION"
      ;;
    fat32)
      sudo ${pkgs.dosfstools}/bin/mkfs.vfat -F 32 "$PARTITION"
      ;;
    *)
      echo "[ ERROR ] Unsupported filesystem: $FS"
      exit 1
      ;;
  esac

  echo "[ INFO ] Done successfully"
''
