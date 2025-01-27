{pkgs, ...}:
pkgs.writeShellScriptBin "format-drive" ''
  if [  "$#" -ne 2 ]; then
      echo "[ERROR] Usage: format-drive <drive-name> <filesystem>"
      echo "[INFO]: <filesystem> can either be 'ntfs' or 'ext4'"
      exit 1
  fi

  DRIVE=$1
  FILESYSTEM=$2

  echo "[INFO] Starting format process for drive: $DRIVE"

  if ! lsblk | grep -q $DRIVE; then
      echo "[ERROR] Device $DRIVE not found"
      exit 1
  fi
  echo "[INFO] Drive $DRIVE found"

  echo "[INFO] Performing full disk format (overwriting with zeros) on /dev/$DRIVE"
  sudo dd if=/dev/zero of=/dev/$DRIVE bs=1M status=progress
  echo "[INFO] Successfully overwrote /dev/$DRIVE with zeros"

  echo "[INFO] Create partition table on /dev/$DRIVE"
  sudo ${pkgs.parted}/bin/parted /dev/$DRIVE --script mklabel gpt
  if [ $? -ne 0 ]; then
      echo "[ERROR] Failed to create partition table on /dev/$DRIVE"
      exit 1
  fi
  echo "[INFO] Successfully created partition table on /dev/$DRIVE"

  echo "[INFO] Creating primary partition on /dev/$DRIVE"
  sudo ${pkgs.parted}/bin/parted -a optimal /dev/$DRIVE --script mkpart primary 0% 100%
  if [ $? -ne 0 ]; then
      echo "[ERROR] Failed to create partition on /dev/$DRIVE"
      exit 1
  fi
  echo "[INFO] Successfully created partition on /dev/$DRIVE"

  if [[ "$DRIVE" =~ nvme ]]; then
      PARTITION="''${DRIVE}p1"
  else
      PARTITION="''${DRIVE}1"
  fi

  if [ "$FILESYSTEM" == "ntfs" ]; then
      echo "[INFO] Formatting partition $PARTITION with NTFS"
      sudo ${pkgs.ntfs3g}/bin/mkfs.ntfs -f /dev/$PARTITION
      if [ $? -ne 0 ]; then
          echo "[ERROR] Failed to format partition $PARTITION with NTFS"
          exit 1
      fi
      echo "[INFO] Successfully formatted partition $PARTITION with NTFS"
  elif [ "$FILESYSTEM" == "ext4" ]; then
      echo "[INFO] Formatting partition $PARTITION with EXT4"
      sudo ${pkgs.e2fsprogs}/bin/mkfs.ext4 /dev/$PARTITION
      if [ $? -ne 0 ]; then
          echo "[ERROR] Failed to format partition $PARTITION with EXT4"
          exit 1
      fi
      echo "[INFO] Successfully formatted partition $PARTITION with EXT4"
  else
      echo "[ERROR] Invalid filesystem type specified. Use 'ntfs' or 'ext4'."
      exit 1
  fi

  echo "[INFO] Format process completed successfully"
''
