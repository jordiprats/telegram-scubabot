#!/bin/bash

function getwebcamtossaframelist()
{
  FRAME_LIST=$(curl http://www.infotossa.com/es/multimedia/cams 2>&1 | grep "/webcam/" | sed 's/<img/\n/g' | grep -Eo 'src="[^"]+"' | cut -f2 -d\")
}

function getwebcamtossaGIF()
{
  FRAMES_DIR="$(mktemp -d /tmp/frames.webcam.tossa.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX)"

  getwebcamtossaframelist

  COUNT=0
  for i in $(echo "${FRAME_LIST}");
  do
    let COUNT=COUNT+1
    wget "http://www.infotossa.com/${i}" -O "${FRAMES_DIR}/"$(printf "%05d" $COUNT)".jpg" >/dev/null 2>&1
    telegram_uploading
  done

  convert -delay 4 -loop 0 ${FRAMES_DIR}/*.jpg "${FRAMES_DIR}/webcam.gif"
  telegram_uploading
}

function cleanupwebcamtossa()
{
  rm -fr ${FRAMES_DIR}
}

