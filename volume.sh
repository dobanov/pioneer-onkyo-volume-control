#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <volume>"
  echo "Example: $0 35"
  exit 1
fi

VOLUME=$1

curl -X POST \
     -H "Host: device.ip.xx.xx:8888" \
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
     http://device.ip.xx.xx:8888/Control/oap/RenderingControl > /dev/null 2>&1
