#!/bin/bash

function telegramsend()
{
  if [ "$DRYRUN" -eq 1 ];
  then
    echo "dryruntelegram: ${1}"
  else
    TEXT="$(echo -e "${1}")"
    curl -s -X POST "https://api.telegram.org/bot${TOKENBOT}/sendMessage" -d text="${TEXT}" -d chat_id=$CHATID -dparse_mode=markdown
  fi
}

function telegramsend_document()
{
  if [ "$DRYRUN" -eq 1 ];
  then
    echo "imatge enviada: ${1}"
  else
    curl -s -X POST "https://api.telegram.org/bot"${TOKENBOT}"/sendDocument" -F chat_id=${CHATID} -F document="@${1}"
  fi
}


function telegramsend_img()
{
  if [ "$DRYRUN" -eq 1 ];
  then
    echo "imatge enviada: ${1}"
  else
    curl -s -X POST "https://api.telegram.org/bot"${TOKENBOT}"/sendPhoto" -F chat_id=${CHATID} -F photo="@${1}"
  fi
}

function telegram_uploading()
{
  if [ "$DRYRUN" -eq 1 ];
  then
    echo "typing..."
  else
    curl -s -X POST "https://api.telegram.org/bot"${TOKENBOT}"/sendChatAction" -F chat_id=${CHATID} -F action=upload_document
  fi
}
