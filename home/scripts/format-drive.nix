{ pkgs, ... }: pkgs.writeShellScriptBin  "format-drive" ''
    if [  "$#" -ne 1 ]; then
        echo "[ERROR] Usage: format-drive <drive-name>"
        exit 1
    fi

    DRIVE=$1

    echo "[INFO] Starting format process for drive: $DRIVE"

    if ! lsblk | grep -q $DRIVE; then
        echo "[ERROR] Device $DRIVE not found"
        exit 1
    fi
    echo "[INFO] Drive $DRIVE found"

    echo "[INFO] Performing full disk format (overwriting with zeros) on /dev/$DRIVE"
    sudo dd if=/dev/zero of=/dev/$DRIVE bs=1M status=progress
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to overwrite /dev/$DRIVE with zeros"
        exit 1 
    fi
    echo "[INFO] Successfully overwrote /dev/$DRIVE with zeros"

    echo "[INFO] Create partition table on /dev/$DRIVE"
    sudo ${pkgs.parted}/bin/parted /dev/$DRIVE --script mklabel gpt
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to create partition table on /dev/$DRIVE"
        exit 1
    fi
    echo "[INFO] Successfully created partition table on /dev/$DRIVE"

    echo "[INFO] Create NTFS partition on /dev/$DRIVE"
    sudo ${pkgs.parted}/bin/parted -a optimal /dev/$DRIVE --script mkpart primary ntfs 0% 100%
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to create NTFS partition on /dev/$DRIVE"
        exit 1
    fi
    echo "[INFO] Successfully created NTFS partition on /dev/$DRIVE"

    if [[ "$DRIVE" =~ nvme ]]; then
        PARTITION="''${DRIVE}p1"
    else
        PARTITION="''${DRIVE}1"
    fi
    echo "[INFO] Formatting partition $PARTITION with NTFS"


    echo "[INFO] Formatting partition $PARTITION with NTFS"
    sudo ${pkgs.ntfs3g}/bin/mkfs.ntfs -f /dev/$PARTITION
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to format partition $PARTITION with NTFS"
        exit 1
    fi
    echo "[INFO] Successfully formatted partition $PARTITION with NTFS"

    echo "[INFO] Format process completed successfully"
''

