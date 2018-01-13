#!/bin/bash

function send() 
{
        curl -s \
        -X POST \
        https://api.telegram.org/bot$apiToken/sendMessage \
        -d text="$1" \
        -d chat_id=$chatId
}

TEMPERATURA_MAX_AIGUA=$(curl http://meteo.cat/prediccio/platges/tossa-de-mar-de-la-mar-menuda 2>/dev/null | grep temperatura | sed 's/},{/\n/g' | grep "temperatura_aigua" | awk -F: '{ print $NF }' | sort -n | tail -n1 | cut -f1 -d.)

TEMPERATURA_MAX_EXTERIOR=$(curl http://meteo.cat/prediccio/platges/tossa-de-mar-de-la-mar-menuda 2>/dev/null | grep temperatura | sed 's/},{/\n/g' | grep '"temperatura","valor"' | awk -F: '{ print $NF }' | sort -n | tail -n1 | cut -f1 -d.)

BASEDIRBCK=$(dirname $0)
BASENAMEBCK=$(basename $0)

if [ ! -z "$1" ] && [ -f "$1" ];
then
	. $1 2>/dev/null
else
	if [[ -s "$BASEDIRBCK/${BASENAMEBCK%%.*}.config" ]];
	then
		. $BASEDIRBCK/${BASENAMEBCK%%.*}.config 2>/dev/null
	else
		echo "config file missing"
		exit 1
	fi
fi

if [ "${TEMPERATURA_MAX_EXTERIOR}" -ge "${LLINDAR_TEMPERATURA_BUCEIG}" ];
then
	send "TOTS cap a l'aigua - temperatura maxima exterior: ${TEMPERATURA_MAX_EXTERIOR} - temperatura maxima de l'aigua: ${TEMPERATURA_MAX_AIGUA}"
else
	if [ "${VERBOSE}" -eq 1 ];
	then
		send "no apte per buceig - temperatura maxima exterior: ${TEMPERATURA_MAX_EXTERIOR} - temperatura maxima de l'aigua: ${TEMPERATURA_MAX_AIGUA}"
	fi
fi
