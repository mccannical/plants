#!/bin/bash
echo Gather secrets
source /home/pi/secrets
echo move home
cd /home/pi/plants || end


echo updating index.html...
s3cmd put index.html s3://picam-garden-jesse/index.html
s3cmd setacl --acl-public --recursive s3://picam-garden-jesse/index.html
echo "website http://picam-garden-jesse.s3-website.us-east-2.amazonaws.com/"
mkdir timelapse 
counter=1000
while true; do
        echo taking picture ${counter}
        ((counter=counter+1))
        raspistill -w 1024 -h 768 -o raw.jpg
        cp raw.jpg "timelapse/image-${counter}.jpg"
        convert raw.jpg -pointsize 74 -fill white -annotate +100+100 "$(date +"%a %r")"  plants.jpg
        s3cmd put plants.jpg s3://picam-garden-jesse/img/plants.jpg
        s3cmd setacl --acl-public --recursive s3://picam-garden-jesse/img
        rm raw.jpg plants.jpg
        sleep 1
done

