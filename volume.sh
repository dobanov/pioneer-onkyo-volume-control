#!/bin/bash

DEVICE_IP="device.ip.xx.xx"

if [ -z "$1" ]; then
  echo "Usage: $0 <volume|get>"
  echo "Example to set volume: $0 35"
  echo "Example to get current volume: $0 get"
  exit 1
fi

if [ "$1" == "get" ]; then
  RESPONSE=$(curl -s -X POST \
    -H "Host: ${DEVICE_IP}:8888" \
    -H "SOAPAction: \"urn:schemas-upnp-org:service:RenderingControl:2#GetVolume\"" \
    -H "Content-Type: text/xml; charset=utf-8" \
    --data "<?xml version=\"1.0\"?>
<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
  <s:Body>
    <u:GetVolume xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:2\">
      <InstanceID>0</InstanceID>
      <Channel>Master</Channel>
    </u:GetVolume>
  </s:Body>
</s:Envelope>" \
    http://${DEVICE_IP}:8888/Control/oap/RenderingControl)

  CURRENT_VOLUME=$(echo "$RESPONSE" | grep -oPm1 "(?<=<CurrentVolume>)[^<]+")
  if [ -n "$CURRENT_VOLUME" ]; then
    echo "Current Volume: $CURRENT_VOLUME"
  else
    echo "Failed to retrieve the current volume."
  fi
  exit 0
fi

if [[ "$1" =~ ^[0-9]+$ ]]; then
  VOLUME=$1

  curl -X POST \
       -H "Host: ${DEVICE_IP}:8888" \
       -H "User-Agent: curl" \
       -H "SOAPAction: \"urn:schemas-upnp-org:service:RenderingControl:2#SetVolume\"" \
       -H "Content-Type: text/xml; charset=utf-8" \
       -H "Accept: */*" \
       -H "Accept-Encoding: gzip, deflate, br" \
       --data "<?xml version=\"1.0\"?>
<s:Envelope s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\" xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\">
  <s:Body>
    <u:SetVolume xmlns:u=\"urn:schemas-upnp-org:service:RenderingControl:2\">
      <InstanceID>0</InstanceID>
      <Channel>Master</Channel>
      <DesiredVolume>${VOLUME}</DesiredVolume>
    </u:SetVolume>
  </s:Body>
</s:Envelope>" \
       http://${DEVICE_IP}:8888/Control/oap/RenderingControl > /dev/null 2>&1
  echo "Volume set to $VOLUME"
  exit 0
fi

echo "Invalid argument: $1"
echo "Usage: $0 <volume|get>"
exit 1
