#!/bin/bash

function telegramsend_img()
{
  if [ "$DRYRUN" -eq 1 ];
  then
    echo "imatge enviada: ${1}"
  else
    curl -s -X POST "https://api.telegram.org/bot"${TOKENBOT}"/sendPhoto" -F chat_id=${CHATID} -F photo="@${1}"
  fi
}

# http://www.meteo.cat/wpweb/divulgacio/la-prediccio-meteorologica/escales-de-vent-i-mar/escala-douglas/
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
    TEXT="$(echo -e "${1}")"
    curl -s \
  	-X POST \
    https://api.telegram.org/bot${TOKENBOT}/sendMessage \
  	-d text="${TEXT}" \
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

