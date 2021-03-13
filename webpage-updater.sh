#!/bin/bash
sleep_time=30
source /home/pi/plants/secrets
cd /home/pi/plants || end
curl -X POST -H 'Content-type: application/json' --data '{"text":"Starting webpage-updater"}' "${slack}"

ipAddress=$(hostname -I)
curl -X POST -H 'Content-type: application/json' --data '{"text":"Garden Computer is at ip: '"${ipAddress}"'"}' "${slack}"
mosquitto_pub -h 192.168.186.244 -t "messages" -m "Garden computer is up"

curl -X POST -H 'Content-type: application/json' --data '{"text":"Updating index.html: http://picam-garden-jesse.s3-website.us-east-2.amazonaws.com/"}' "${slack}"
s3cmd put --acl-public index.html s3://picam-garden-jesse/index.html

curl -X POST -H 'Content-type: application/json' --data '{"text":"Lets make sure the live stream is high res!"}' "${slack}"

curl -X POST -H 'Content-type: application/json' --data '{"text":"Kicking off collect and send to start the kafka pipeline"}' "${slack}"
python3 /home/pi/plants/data/collect-and-send.py &

#adjust res
curl 'http://192.168.186.130/control?var=framesize&val=10' \
  -H 'Connection: keep-alive' \
  -H 'Pragma: no-cache' \
  -H 'Cache-Control: no-cache' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36' \
  -H 'DNT: 1' \
  -H 'Accept: */*' \
  -H 'Referer: http://192.168.186.130/' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  --compressed \
  --insecure


#adjust AEC
curl 'http://192.168.186.130/control?var=aec2&val=1' \
  -H 'Connection: keep-alive' \
  -H 'Pragma: no-cache' \
  -H 'Cache-Control: no-cache' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36' \
  -H 'DNT: 1' \
  -H 'Accept: */*' \
  -H 'Referer: http://192.168.186.130/' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  --compressed \
  --insecure

# adjust brightness
curl 'http://192.168.186.130/control?var=brightness&val=1' \
  -H 'Connection: keep-alive' \
  -H 'Pragma: no-cache' \
  -H 'Cache-Control: no-cache' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36' \
  -H 'DNT: 1' \
  -H 'Accept: */*' \
  -H 'Referer: http://192.168.186.130/' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  --compressed \
  --insecure

#adjust saturation
curl 'http://192.168.186.130/control?var=saturation&val=1' \
  -H 'Connection: keep-alive' \
  -H 'Pragma: no-cache' \
  -H 'Cache-Control: no-cache' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.150 Safari/537.36' \
  -H 'DNT: 1' \
  -H 'Accept: */*' \
  -H 'Referer: http://192.168.186.130/' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  --compressed \
  --insecure



rm -rf timelapse
mkdir timelapse
counter=1000


while true; do
        raspistill -rot 90 -vf -hf  -o raw.jpg
        brightness=$(exiftool raw.jpg | grep Brightness | awk '{printf "%d", $4}')
        echo $brightness
        if [ "$brightness" -gt 1 ]; then
                convert raw.jpg -pointsize 32 -fill white -annotate +400+180 "$(date +"%a %r")"  plants.jpg
                cp plants.jpg "timelapse/image-${counter}.jpg"
                s3cmd put --acl-public plants.jpg s3://picam-garden-jesse/img/plants.jpg
                rm raw.jpg plants.jpg
        fi
        sleep ${sleep_time}
        ((counter=counter+1))
done
