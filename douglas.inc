#!/bin/bash

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
