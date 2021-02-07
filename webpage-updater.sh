#!/bin/bash
sleep_time=30
source /home/pi/plants/secrets
cd /home/pi/plants || end
curl -X POST -H 'Content-type: application/json' --data '{"text":"Starting webpage-updater"}' ${slack}

curl -X POST -H 'Content-type: application/json' --data '{"text":"Updating index.html: http://picam-garden-jesse.s3-website.us-east-2.amazonaws.com/"}' ${slack}
s3cmd put --acl-public index.html s3://picam-garden-jesse/index.html

rm -rf timelapse
mkdir timelapse 
counter=1000
while true; do
        raspistill -rot 90 -vf -hf  -o raw.jpg
        cp raw.jpg "timelapse/image-${counter}.jpg"
        convert raw.jpg -pointsize 32 -fill white -annotate +220+160 "$(date +"%a %r")"  plants.jpg
        s3cmd put --acl-public plants.jpg s3://picam-garden-jesse/img/plants.jpg
        rm raw.jpg plants.jpg
        sleep ${sleep_time}
        ((counter=counter+1))
done

