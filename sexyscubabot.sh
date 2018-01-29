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
	if [ "$DRYRUN" -eq 1 ];
	then
		echo "dryruntelegram: ${1}"
	else
	        curl -s \
        	-X POST \
	        https://api.telegram.org/bot${TOKENBOT}/sendMessage \
        	-d text="$1" \
	        -d chat_id=$CHATID
	fi
}

function blockpenis()
{
        if [ ! -z "$1" ];
        then
                TAMANY_PENIS=$(echo "   $1   " | wc -c)
                echo -n " 8"
                for penis_counter in $(seq 1 $((TAMANY_PENIS-5))); do echo -n =; if [ "${DEBUG}" -ne 1 ]; then sleep 0.01; fi; done
                echo D~

                echo "   $1   "

                echo -n " 8"
                for penis_counter in $(seq 1 $((TAMANY_PENIS-5))); do echo -n =; if [ "${DEBUG}" -ne 1 ]; then sleep 0.01; fi; done
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

REALPATH=$(echo "$(cd "$(dirname "$0")"; pwd)/$(basename "$0")")
BASEDIR=$(dirname ${REALPATH})
BASENAME=$(basename ${REALPATH})

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
echo "{" > $DADES_TMP_JSON
echo "${DADES_METEOCAT}" >> $DADES_TMP_JSON
echo '"marcmoyafredolic": true' >> $DADES_TMP_JSON
echo "}" >> $DADES_TMP_JSON
sed 's/dades:/\"dades\":/g' -i $DADES_TMP_JSON

# telegramsend "Reservat curs de traje sec aquest proper cap de setmana amb en Jordi"
# exit 0

# jprats@shuvak:~/git/telegram-scubabot$ cat /tmp/sexyscubabot.hYaa1 | bash inc/JSON.sh  -l | grep "T09"
# ["dades",9,"data"]	"2018-01-28T09:00Z"
# ..18
# ["dades",33,"data"]	"2018-01-29T09:00Z"
# ..42

DADES_METEOCAT_JSON_LEAF="$(cat "${DADES_TMP_JSON}" | bash ${BASEDIR}/inc/JSON.sh -l)"

DIES_COUNT=0
for i in ${DIES_PREVISIO_DISPONIBLES};
do
	MAX_TEMPERATURA="X"
	MIN_TEMPERATURA="X"
	MAX_TEMPERATURA_AIGUA="X"
	MIN_TEMPERATURA_AIGUA="X"
	MAX_ALTURA_ONA="X"
	MIN_ALTURA_ONA="X"
	for j in {9..18};
	do
		let HORA=j+DIES_COUNT*24
  	REF_FILA="$(echo "${DADES_METEOCAT_JSON_LEAF}" | grep "${i}T$(printf "%02d\n" ${HORA})" | cut -f1,2 -d,)"

		# ["dades",34,"data"]	"2018-01-30T10:00Z"
		# ["dades",34,"variables",0,"nom"]	"temperatura"
		# ["dades",34,"variables",0,"valor"]	11.177148437500023
		# ...
		# ["dades",34,"variables",5,"nom"]	"altura_ona"
		# ["dades",34,"variables",5,"valor"]	0.1088627278804779
		# ...
		# ["dades",34,"variables",7,"nom"]	"temperatura_aigua"
		# ["dades",34,"variables",7,"valor"]	13.580942153930664



		REF_FILA_TEMPERATURA="$(echo "${DADES_METEOCAT_JSON_LEAF}" | grep "\\${REF_FILA}" | grep "\"temperatura\"" | cut -f1-4 -d,)"

		TEMPERATURA="$(echo "${DADES_METEOCAT_JSON_LEAF}" | grep "\\${REF_FILA_TEMPERATURA}" | grep "valor" | awk '{ print $NF }')"

		REF_FILA_ALTURA_ONA="$(echo "${DADES_METEOCAT_JSON_LEAF}" | grep "\\${REF_FILA}" | grep "\"altura_ona\"" | cut -f1-4 -d,)"

		ALTURA_ONA="$(echo "${DADES_METEOCAT_JSON_LEAF}" | grep "\\${REF_FILA_ALTURA_ONA}" | grep "valor" | awk '{ print $NF }')"

		REF_FILE_TEMPERATURA_AIGUA="$(echo "${DADES_METEOCAT_JSON_LEAF}" | grep "\\${REF_FILA}" | grep "\"temperatura_aigua\"" | cut -f1-4 -d,)"

		TEMPERATURA_AIGUA="$(echo "${DADES_METEOCAT_JSON_LEAF}" | grep "\\${REF_FILE_TEMPERATURA_AIGUA}" | grep "valor" | awk '{ print $NF }')"
		
		# echo $TEMPERATURA $ALTURA_ONA $TEMPERATURA_AIGUA
		if [ "${MAX_TEMPERATURA}" = "X" ];
		then
			MAX_TEMPERATURA="${TEMPERATURA}"
			MIN_TEMPERATURA="${TEMPERATURA}"
			MAX_TEMPERATURA_AIGUA="${TEMPERATURA_AIGUA}"
			MIN_TEMPERATURA_AIGUA="${TEMPERATURA_AIGUA}"
			MAX_ALTURA_ONA="${ALTURA_ONA}"
			MIN_ALTURA_ONA="${ALTURA_ONA}"
		fi
		if (( $(echo "$TEMPERATURA > $MAX_TEMPERATURA" | bc -l) ));
		then
			MAX_TEMPERATURA="${TEMPERATURA}"
		fi
		if (( $(echo "$TEMPERATURA < $MIN_TEMPERATURA" | bc -l) ));
		then
			MIN_TEMPERATURA="${TEMPERATURA}"
		fi

                if (( $(echo "$TEMPERATURA_AIGUA > $MAX_TEMPERATURA_AIGUA" | bc -l) ));
                then
                        MAX_TEMPERATURA_AIGUA="${TEMPERATURA_AIGUA}"
                fi
                if (( $(echo "$TEMPERATURA_AIGUA < $MIN_TEMPERATURA_AIGUA" | bc -l) ));
                then
                        MIN_TEMPERATURA_AIGUA="${TEMPERATURA_AIGUA}"
                fi

                if (( $(echo "$ALTURA_ONA > $MAX_ALTURA_ONA" | bc -l) ));
                then
                        MAX_ALTURA_ONA="${ALTURA_ONA}"
                fi
                if (( $(echo "$ALTURA_ONA < $MIN_ALTURA_ONA" | bc -l) ));
                then
                        MIN_ALTURA_ONA="${ALTURA_ONA}"
                fi

	done
	#echo altura ona $MAX_ALTURA_ONA $MIN_ALTURA_ONA
	#echo temperatura $MAX_TEMPERATURA $MIN_TEMPERATURA
	#echo temperatura aigua $MAX_TEMPERATURA_AIGUA $MIN_TEMPERATURA_AIGUA
	
	DESCRIPCIO_DIA="exterior max: $(echo ${MAX_TEMPERATURA} | cut -f1 -d.)C min: $(echo ${MIN_TEMPERATURA} | cut -f1 -d.)C; temperatura aigua max: $(echo ${MAX_TEMPERATURA_AIGUA} | cut -f1 -d.)C min: $(echo ${MIN_TEMPERATURA_AIGUA} | cut -f1 -d.)C; altura ona max: $(echo ${MAX_ALTURA_ONA} | grep -Eo "^[0-9]*\\.[0-9]{2}")m min: $(echo ${MIN_ALTURA_ONA} | grep -Eo "^[0-9]*\\.[0-9]{2}")m ($(ona_to_descripcio $MAX_ALTURA_ONA) - $(ona_to_descripcio $MIN_ALTURA_ONA))"

	if (( $(echo "$MAX_ALTURA_ONA < 1.5 " | bc -l) )) && (( $(echo "$MAX_TEMPERATURA >= 20" | bc -l) ));
	then
		# humit: por encima de 15°C
		# semisec: entre 10 °C y 20 °C
		# sec: menys de 10
		if (( $(echo "$MAX_TEMPERATURA_AIGUA < 10 " | bc -l) ));
		then
			MESSAGE="APTE per busseig amb ${i} traje SEC - ${DESCRIPCIO_DIA}"
			SEND=1
		elif (( $(echo "$MAX_TEMPERATURA_AIGUA < 15 " | bc -l) ));
		then
			MESSAGE="APTE per busseig amb ${i} SEMI-SEC - ${DESCRIPCIO_DIA}"
			SEND=1
		else
			MESSAGE="APTE per busseig ${i} SENSE EXCUSES - ${DESCRIPCIO_DIA}"
			SEND=1
		fi
	else
		MESSAGE="sou una colla de fredolics - ${DESCRIPCIO_DIA}"
		SEND=1
	fi
	let DIES_COUNT+1
done

if [ "$SEND" -eq 1 ];
then
	if [ "$DEBUG" -eq 1 ]; then echo "missatge enviat a telegram:"; fi;
	telegramsend "$MESSAGE"
else
	if [ "${VERBOSE}" -eq 1 ];
	then
		if [ "$DEBUG" -eq 1 ]; then echo "missatge enviat a telegram:"; fi;
		telegramsend "$MESSAGE"
	else
		if [ "$DEBUG" -eq 1 ]; then echo "NO ENVIAT a telegram:"; fi;
	fi
fi

if [ "$DEBUG" -eq 1 ]; then echo "$MESSAGE"; fi;

rm -f "${DADES_TMP_JSON}"
