#!/bin/bash
 
tomp4() {
    local mov="$1"
    echo Processing "$mov ..."
    ffmpeg -i "$mov" -vcodec h264 -acodec mp2 "$mov.mp4"
    echo "Waiting to delete the original file: $mov"
    sleep 5
    rm -f "$mov"
    echo Remaining MOV count = $(find . -name "*.mov" | wc -l)
    echo "OK!"
    sleep 5
}
 
export -f tomp4
 
find . -name "*.mov" -type f -exec bash -c 'tomp4 "{}"' \;