#!/bin/bash
source /home/pi/plants/secrets
curl -X POST -H 'Content-type: application/json' --data '{"text":"Starting Processing of Timelapse for the day"}' ${slack}

cd /home/pi/plants/timelapse/
ls *.jpg > stills.txt
mencoder -nosound -ovc lavc -lavcopts vcodec=mpeg4:aspect=16/9:vbitrate=8000000 -vf scale=1920:1080 -o timelapse.avi -mf type=jpeg:fps=24 mf://@stills.txt

s3cmd mv --acl-public s3://picam-garden-jesse/tl/timelapse-latest.avi  s3://picam-garden-jesse/tl/timelapse-$(date --date="yesterday" +"%Y-%m-%d")
s3cmd put --acl-public timelapse.avi s3://picam-garden-jesse/tl/timelapse-latest.avi
curl -X POST -H 'Content-type: application/json' --data '{"text":"Done with timelapse for the day: https://picam-garden-jesse.s3.us-east-2.amazonaws.com/tl/timelapse-latest.avi"}' ${slack}

