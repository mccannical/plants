#!/bin/bash 

# gets  brightness value from latest image.
cd /home/pi/plants/timelapse/
exiftool $(ls -t *.jpg | head -1) | grep Brightness | awk '{printf "%f", $4}'
