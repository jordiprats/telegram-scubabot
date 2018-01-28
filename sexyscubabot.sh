#!/bin/bash

function ona_to_descripcio()
{
#    if (0 === a) return 50;
#    if (0 < a && 0.1 >= a) return 51;
#    if (0.1 < a && 0.5 >= a) return 52;
#    if (0.5 < a && 1.25 >= a) return 53;
#    if (1.25 < a && 2.5 >= a) return 54;
#    if (2.5 < a && 4 >= a) return 55;
#    if (4 < a && 6 >= a) return 56;
#    if (6 < a && 9 >= a) return 57;
#    if (9 < a && 14 >= a) return 58;
#    if (14 < a) return 59
	if (( $(echo "$1 > 14" | bc -l) )); then
		echo "mar enorme";
	elif (( $(echo "$1 > 9" | bc -l) )); then
		echo "mar molt alta";
	elif (( $(echo "$1 > 6" | bc -l) )); then
		echo "mar desfeta"
	elif (( $(echo "$1 > 4" | bc -l) )); then
		echo "mar brava"
	elif (( $(echo "$1 > 2.5" | bc -l) )); then
		echo "maregassa"
	elif (( $(echo "$1 > 1.25" | bc -l) )); then
		echo "maror"
	elif (( $(echo "$1 > 0.5" | bc -l) )); then
		echo "marejol"
	elif (( $(echo "$1 > 0.1" | bc -l) )); then
		echo "mar arrissada"
	else
		echo "mar plana";
	fi
}

function telegramsend()
{
        curl -s \
        -X POST \
        https://api.telegram.org/bot${TOKENBOT}/sendMessage \
        -d text="$1" \
        -d chat_id=$CHATID
}

function blockpenis()
{
        if [ ! -z "$1" ];
        then
                TAMANY_PENIS=$(echo "   $1   " | wc -c)
                echo -n " 8"
                for penis_counter in $(seq 1 $((TAMANY_PENIS-5))); do echo -n =; sleep 0.01; done
                echo D~

                echo "   $1   "

                echo -n " 8"
                for penis_counter in $(seq 1 $((TAMANY_PENIS-5))); do echo -n =; sleep 0.01; done
                echo D~

        fi
}

function penis()
{
	if [ ! -z "$1" ];
	then
		echo "   $1   "
		TAMANY_PENIS=$(echo "   $1   " | wc -c)
                echo -n " 8"
                for penis_counter in $(seq 1 $((TAMANY_PENIS-5))); do echo -n =; sleep 0.01; done
                echo D~

	else
		echo -n 8
		for penis_counter in $(seq 1 1$(echo $RANDOM | grep -Eo "^[0-9]")); do echo -n =; sleep 0.01; done
		echo D~~~
	fi
}

function separador()
{
	echo -ne ' 8'
	for i in $(seq 1 $(($(tput cols)-8))); do echo -ne =; sleep 0.005; done
	echo 'D~~~ '
}

DADES_METEOCAT=$(curl 'http://meteo.cat/prediccio/platges/tossa-de-mar-de-la-mar-menuda' -H 'Host: meteo.cat' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:57.0) Gecko/20100101 Firefox/57.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.7,ca;q=0.3' --compressed -H 'Referer: http://meteo.cat/prediccio/platges' -H 'Cookie: mapy=41.708829850084335; mapx=2.8837480524089187; mapz=13; __cfduid=d17675a8f06226ee4ddcf89d41ed087d71505470052; _ga=GA1.2.1382788571.1505470053; _gid=GA1.2.2132722468.1516034966' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Cache-Control: max-age=0' 2>/dev/null | grep "dades: \[")

TEMPERATURA_MAX_AIGUA=$(echo $DADES_METEOCAT | grep temperatura | sed 's/},{/\n/g' | grep "temperatura_aigua" | awk -F: '{ print $NF }' | sort -n | tail -n1 | cut -f1 -d.)

TEMPERATURA_MAX_EXTERIOR=$(echo $DADES_METEOCAT | grep temperatura | sed 's/},{/\n/g' | grep '"temperatura","valor"' | awk -F: '{ print $NF }' | sort -n | tail -n1 | cut -f1 -d.)

ALTURA_ONES_PREVISIO=$(echo $DADES_METEOCAT | sed 's/}]},/\n/g' | cut -f1,12,13 -d, | sed 's/[{}]//g')

DIES_PREVISIO_DISPONIBLES=$(echo $DADES_METEOCAT | sed 's/}]},/\n/g' | awk -F\" '{ print $4 }' | cut -f1 -dT | sort |uniq)



BASEDIR=$(dirname $0)
BASENAME=$(basename $0)

if [ ! -z "$1" ] && [ -f "$1" ];
then
	. $1 2>/dev/null
else
	if [[ -s "$BASEDIR/${BASENAME%%.*}.config" ]];
	then
		. $BASEDIR/${BASENAME%%.*}.config 2>/dev/null
	else
		echo "config file missing"
		exit 1
	fi
fi

ABOUTME=`curl -s "https://api.telegram.org/bot${TOKENBOT}/getMe"`
if [[ "$ABOUTME" =~ \"ok\"\:true\, ]];
then
	if [[ "$ABOUTME" =~ \"username\"\:\"([^\"]+)\" ]];
	then
		MYUSERNAME=${BASH_REMATCH[1]}
	fi

	if [[ "$ABOUTME" =~ \"first_name\"\:\"([^\"]+)\" ]];
	then
		MYFIRSTNAME=${BASH_REMATCH[1]}
	fi

	if [[ "$ABOUTME" =~ \"id\"\:([0-9\-]+), ]];
	then
		BOTID=${BASH_REMATCH[1]};
	fi

	if [ "$DEBUG" -eq 1 ]; then blockpenis "@${MYUSERNAME} - ${MYFIRSTNAME} - botid: ${BOTID}"; fi;
else
	blockpenis "Error: wrong token";
	exit 1;
fi

DADES_TMP_JSON=$(mktemp /tmp/sexyscubabot.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX)
echo "${DADES_METEOCAT}" > $DADES_TMP_JSON

if [ "${TEMPERATURA_MAX_EXTERIOR}" -ge "${LLINDAR_TEMPERATURA_BUCEIG}" ];
then
	MESSAGE="APTE per busseig - temperatura maxima exterior: ${TEMPERATURA_MAX_EXTERIOR} - temperatura maxima de l'aigua: ${TEMPERATURA_MAX_AIGUA}"
	SEND=1
else
	MESSAGE="no apte per busseig - temperatura maxima exterior: ${TEMPERATURA_MAX_EXTERIOR} - temperatura maxima de l'aigua: ${TEMPERATURA_MAX_AIGUA}"
	SEND=0
fi

if [ "$SEND" -eq 1 ];
then
	if [ "$DEBUG" -eq 1 ]; then echo "missatge enviat a telegram:"; fi;
	telegramsend $MESSAGE
else
	if [ "${VERBOSE}" -eq 1 ];
	then
		if [ "$DEBUG" -eq 1 ]; then echo "missatge enviat a telegram:"; fi;
		telegramsend $MESSAGE
	else
		if [ "$DEBUG" -eq 1 ]; then echo "NO ENVIAT a telegram:"; fi;
	fi
fi

if [ "$DEBUG" -eq 1 ]; then echo "$MESSAGE"; fi;

#rm -f "${DADES_TMP_JSON}"
