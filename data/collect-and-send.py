#!/usr/bin/python3
# gathers temp, humidity and brightness value from latest picture and publishes to google pubsub

import time
import subprocess
import board
import busio
from adafruit_htu21d import HTU21D
from google.cloud import pubsub_v1

def sendtoPS(topic_id, data):
    project_id = "garden-304819"
    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(project_id, topic_id)

    # Data must be a bytestring
    data = "{}".format(data)
    data = data.encode("utf-8")
    # When you publish a message, the client returns a future.
    future = publisher.publish(topic_path, data)
    
# Create library object using our Bus I2C port
i2c = busio.I2C(board.SCL, board.SDA)
sensor = HTU21D(i2c)

while True:
    sendtoPS("humidity", sensor.relative_humidity)
    sendtoPS("temp", sensor.temperature)
    bright = subprocess.run(['/home/pi/plants/data/get_bright_raw.sh'], stdout=subprocess.PIPE).stdout.decode('utf-8')
    sendtoPS("brightness", bright)
    print("Humidity: %0.1f \nTemperature: %0.1f C \n Brightness: %s" % sensor.relative_humidity, sensor.temperature, bright)
