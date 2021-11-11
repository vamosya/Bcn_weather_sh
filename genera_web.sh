#!/bin/bash

#Declaración de variables
url="https://analisi.transparenciacatalunya.cat/resource/uy6k-2s8r.json"
fecha=$(date -d "yesterday" +%Y-%m-%dT00:00:00.000)
municipio=$1
contaminante=$2
query="SELECT municipi, h01, h02, h03, h04, h05, h06, h07, h08, h09, h10, h11, h12, h13, h14, h15, h16, h17, h18, h19, h20, h21, h22, h23, h24 WHERE municipi='${municipio}' AND contaminant='${contaminante}' AND data='${fecha}'"

#Obtención y filtrado

curl -G "https://analisi.transparenciacatalunya.cat/resource/uy6k-2s8r.json" --data-urlencode "\$query=$query" -o temporal1.json

jq . temporal1.json > temporal2.json

cat temporal2.json | sed -n '4,26p' > temporal1.json

cut -c 7- temporal1.json | sed 's/": "/ /g' | sed 's/,//' | sed 's/"//' | sed 's/ /,/g' > temporal2.json

media=$(awk -F, '{suma+=$2} END {print suma/NR}' temporal2.json)

#Genera el html

echo "<html>"
echo "<body>"
echo "Muestro la contaminación de $contaminante en $municipio del día $(date -d "yesterday" +%d-%m-%Y)" 
echo "<table border>"

input="temporal2.json"
i=1
while IFS= read -r linea
do
	hora=$(echo $linea | cut -d "," -f1)
	dato=$(echo $linea | cut -d "," -f2)
	echo "<tr><td>$hora</td><td>$dato</td></tr>"
done < "$input"

echo "</table>"
echo "La media de contaminacion de $contaminante del dia en $municipio fue $media"
echo "</body>"
echo "</html>"
