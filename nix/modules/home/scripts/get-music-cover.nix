{pkgs, ...}:
pkgs.writeShellScriptBin "get-music-cover" ''
  COVER_PATH="/tmp/eww/cache_directory"
  cd $COVER_PATH

  IMGPATH="$COVER_PATH/music_cover.png"

  playerctl -F metadata mpris:artUrl 2>/dev/null | while read -r COVER_URL; do
      if [[ "$COVER_URL" = https* ]]; then
          FILENAME=$(basename "$COVER_URL")
          FILEPATH="$COVER_PATH/$FILENAME"

          if [ ! -e "$FILEPATH" ]; then
              wget -N "$COVER_URL" -o /dev/null

              NUM_IMAGES=$(ls -1 "$COVER_PATH"/* | wc -l)

              if [ "$NUM_IMAGES" -gt 10 ]; then
                  OLDEST_IMAGE=$(ls -1t "$COVER_PATH"/* | tail -1)
                  rm "$OLDEST_IMAGE"
              fi
          fi

          rm "$IMGPATH"
          sleep 1
          ln -s "$FILENAME" "$IMGPATH"

          echo "$IMG_PATH"
      elif [ "$COVER_URL" = "" ]; then
          echo ""
      else
          echo "$COVER_URL"
      fi
  done
''
