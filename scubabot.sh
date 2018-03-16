#!/bin/bash

export LC_ALL="en_US"

shopt -s nocasematch

function getprevisio()
{
  set -x 
  DADES_METEOCAT=$(curl 'http://meteo.cat/prediccio/platges/tossa-de-mar-de-la-mar-menuda' -H 'Host: meteo.cat' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:57.0) Gecko/20100101 Firefox/57.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.7,ca;q=0.3' --compressed -H 'Referer: http://meteo.cat/prediccio/platges' -H 'Cookie: mapy=41.708829850084335; mapx=2.8837480524089187; mapz=13; __cfduid=d17675a8f06226ee4ddcf89d41ed087d71505470052; _ga=GA1.2.1382788571.1505470053; _gid=GA1.2.2132722468.1516034966' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Cache-Control: max-age=0' 2>/dev/null | grep "dades: \[")

  DADES_TMP_JSON=$(mktemp /tmp/sexyscubabot.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX)
  echo "{" > $DADES_TMP_JSON
  echo "${DADES_METEOCAT}" >> $DADES_TMP_JSON
  echo '"marcmoyafredolic": true' >> $DADES_TMP_JSON
  echo "}" >> $DADES_TMP_JSON
  sed 's/dades:/\"dades\":/g' -i $DADES_TMP_JSON

  DADES_METEOCAT_JSON_LEAF="$(cat "${DADES_TMP_JSON}" | bash ${BASEDIR}/inc/JSON.sh -l)"

  DIES_PREVISIO_DISPONIBLES=$(echo $DADES_METEOCAT | sed 's/}]},/\n/g' | awk -F\" '{ print $4 }' | cut -f1 -dT | sort |uniq)

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

      # ["dades",34,"data"] "2018-01-30T10:00Z"
      # ["dades",34,"variables",0,"nom"]  "temperatura"
      # ["dades",34,"variables",0,"valor"]  11.177148437500023
      # ...
      # ["dades",34,"variables",5,"nom"]  "altura_ona"
      # ["dades",34,"variables",5,"valor"]  0.1088627278804779
      # ...
      # ["dades",34,"variables",7,"nom"]  "temperatura_aigua"
      # ["dades",34,"variables",7,"valor"]  13.580942153930664

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

  DESCRIPCIO_DIA="*temperatura exterior*\nmax: $(echo ${MAX_TEMPERATURA} | grep -Eo "^[0-9]+\.?[0-9]?")C\nmin: $(echo ${MIN_TEMPERATURA} | grep -Eo "^[0-9]+\.?[0-9]?")C\n\n*temperatura aigua*\nmax: $(echo ${MAX_TEMPERATURA_AIGUA} | grep -Eo "^[0-9]+\.?[0-9]?")C\nmin: $(echo ${MIN_TEMPERATURA_AIGUA} | grep -Eo "^[0-9]+\.?[0-9]?")C\n\n*altura ona*\nmax: $(echo ${MAX_ALTURA_ONA} | grep -Eo "^[0-9]*\\.[0-9]{2}")m ($(ona_to_descripcio $MAX_ALTURA_ONA))\nmin: $(echo ${MIN_ALTURA_ONA} | grep -Eo "^[0-9]*\\.[0-9]{2}")m ($(ona_to_descripcio $MIN_ALTURA_ONA))"

  # regla del marc
  if (( $(echo "$MAX_ALTURA_ONA < 1.5 " | bc -l) )) && (( $(echo "$MAX_TEMPERATURA >= 20" | bc -l) ));
  then
    # humit: entre 12 i 20
    # semisec: entre 10 °C i 20 °C
    # sec: menys de 10
    if (( $(echo "$MAX_TEMPERATURA_AIGUA < 10 " | bc -l) ));
    then
      MESSAGE="${i} - APTE per busseig amb SEC\n${DESCRIPCIO_DIA}"
      SEND=1
    elif (( $(echo "$MAX_TEMPERATURA_AIGUA < 12 " | bc -l) ));
    then
      MESSAGE="${i} - APTE per busseig amb SEMI-SEC\n\n${DESCRIPCIO_DIA}"
      SEND=1
    else
      MESSAGE="${i} - APTE per busseig SENSE EXCUSES\n\n${DESCRIPCIO_DIA}"
      SEND=1
    fi
  else
    if (( $(echo "$MAX_ALTURA_ONA < 1.5 " | bc -l) ));
    then
      MESSAGE="${i} - sou una colla de FREDOLICS\n\n${DESCRIPCIO_DIA}"
      SEND=1
    else
      MESSAGE="${i} - nomes son unes quantes onades de res\n\n${DESCRIPCIO_DIA}"
      SEND=1
    fi
  fi

  TODAY_TS="$(date -d "$(date +%Y-%m-%d)" +%s)"
  ITEM_TS="$(date -d "${i}" +%s)"

  #dades atrasades
  if [ "${ITEM_TS}" -lt "${TODAY_TS}" ];
  then
    SEND=0
  fi

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


  let DIES_COUNT+1
done


  rm ${DADES_TMP_JSON}
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

REALPATH=$(echo "$(cd "$(dirname "$0")"; pwd)/$(basename "$0")")
BASEDIR=$(dirname ${REALPATH})
BASENAME=$(basename ${REALPATH})

source $BASEDIR/telegramsend.inc
source $BASEDIR/douglas.inc
source $BASEDIR/webcamtossa.inc

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



while true; 
do
  MSGOUTPUT=$(curl -s "https://api.telegram.org/bot${TOKENBOT}/getUpdates" | bash "${BASEDIR}/inc/JSON.sh" -b);
  echo -e "${MSGOUTPUT}" | while read -r line ;
  do
    # ["result",7,"update_id"]  773630262
    # ["result",7,"message","message_id"] 73
    # ["result",7,"message","from","id"]  13906317
    # ["result",7,"message","from","is_bot"]  false
    # ["result",7,"message","from","first_name"]  "Jordi"
    # ["result",7,"message","from","language_code"] "en-ES"
    # ["result",7,"message","chat","id"]  13906317
    # ["result",7,"message","chat","first_name"]  "Jordi"
    # ["result",7,"message","chat","type"]  "private"
    # ["result",7,"message","date"] 1219732163
    # ["result",7,"message","text"] "/start"

    if [[ "$line" =~ ^\[\"result\"\,[0-9]+\,\"message\"\,\"message\_id\"\][[:space:]]+([0-9]+) ]];
    then
      MSGID=${BASH_REMATCH[1]};
      mkdir -p "${BASEDIR}/.msg/${MSGID}"
    fi

    if [[ "$line" =~ ^\[\"result\"\,[0-9]+\,\"message\"\,\"chat\"\,\"id\"\][[:space:]]+([0-9\-]+)$ ]];
    then
      CHATID=${BASH_REMATCH[1]};
      echo "${CHATID}" > "${BASEDIR}/.msg/${MSGID}/chatid"
    fi

    if [[ "$line" =~ ^\[\"result\"\,[0-9]+\,\"message\"\,\"from\"\,\"id\"\][[:space:]]+([0-9]+)$ ]];
    then
      FROMID=${BASH_REMATCH[1]};
      echo "${FROMID}" > "${BASEDIR}/.msg/${MSGID}/fromid"
    fi

    if [[ "$line" =~ ^\[\"result\"\,[0-9]+\,\"message\"\,\"from\"\,\"first_name\"\][[:space:]]+\"([^\"]+)\"$ ]];
    then
      FROM_NAME=${BASH_REMATCH[1]};
      echo "${FROM_NAME}" > "${BASEDIR}/.msg/${MSGID}/from_name"
    fi


    if [[ "$line" =~ ^\[\"result\"\,[0-9]+\,\"message\"\,\"text\"\][[:space:]]+\"(.+)\"$ ]];
    then
      TEXT=${BASH_REMATCH[1]};
      echo "${TEXT}" > "${BASEDIR}/.msg/${MSGID}/text"
      if [ -e "${BASEDIR}/.msg/${MSGID}/response" ];
      then
        if [ "${DEBUG}" -eq 1 ];
        then
          echo "old msg ${MSGID}, skipping"
        fi
      else
        echo "${MSGID} from ${FROMID} chat ${CHATID} text: ${TEXT}"
        if [[ "${TEXT}" =~ "/start" ]];
        then
          mkdir -p "${BASEDIR}/.db/"
          if [ "${DEBUG}" -eq 1 ];
          then
            echo ${CHATID} > "${BASEDIR}/.db/${FROMID}"
          fi
          telegramsend "subscripcio habilitada per usuari ${FROM_NAME}(${FROMID}) al chat ${CHATID}"
        fi

        if [[ "${TEXT}" =~ "/stop" ]];
        then
          telegramsend "per aturarlo primer has de fer /start"
        fi

        if [[ "${TEXT}" =~ "/previsio" ]];
        then
          getprevisio
        fi

        if [[ "${TEXT}" =~ "/colorsprofunditat" ]];
        then
          telegramsend_img "${BASEDIR}/img/colors_profunditat.jpg"
        fi

        if [[ "${TEXT}" =~ "rm " ]];
        then
          telegramsend_img "${BASEDIR}/img/fuck_off.jpg"
        fi

        if [[ "${TEXT}" =~ "/recomanaciotraje" ]];
        then
          telegramsend "*shorty*: entre 20C i 30C\n*humit*: entre 12C i 20C\n*semisec*: entre 10C i 20C\n*sec*: menys de 10C"
        fi

        if [[ "${TEXT}" =~ "/webcam" ]];
        then
          telegram_uploading
          getwebcamtossaGIF
          telegramsend_document "${FRAMES_DIR}/webcam.gif"
          cleanupwebcamtossa
        fi

        if [[ "${TEXT}" =~ "/temperaturaanualaigua" ]];
        then
          telegramsend_img "${BASEDIR}/img/temperatura_aigua_tossa_anual.png"
        fi

        if [[ "${TEXT}" =~ "/getsource" ]];
        then
          telegramsend "https://github.com/jordiprats/telegram-scubabot"
        fi

        if [[ "${TEXT}" =~ "/tincansies" ]];
        then
          TEMP_IMG=$(mktemp /tmp/ansiesimg.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX)

          wget "$(echo "https:$(curl https://www.instagram.com/explore/tags/scubadiving/ 2>/dev/null | sed 's/},/\n/g' | grep 'edge_liked_by' | awk -F: '$5>50 { print $3,$5 }' | shuf | tail -n1 | cut -f1 -d\")")" -O $TEMP_IMG

          telegramsend_img "${TEMP_IMG}"

          rm $TEMP_IMG
        fi

        echo > "${BASEDIR}/.msg/${MSGID}/response"
      fi
    fi
  done
  RANDOM_SLEEP="$(echo "$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM" | grep -Eo "[0-3]" | head -n1)"
  RANDOM_SLEEP=${RANDOM_SLEEP-1}
  echo sleep ${RANDOM_SLEEP}
  sleep "${RANDOM_SLEEP}"
done
