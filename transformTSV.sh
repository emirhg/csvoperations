#!/bin/bash
# Transform CSV
# Script para seleccionar renglones y columnas de un TSV y realizar transformaciones como Transponer la matriz y/o representarla en un modelo Entidad-Atributo-Relación

while getopts "hts:r:c:v:" optname
  do
    case "$optname" in
      "s")
        SHEETNUM=$OPTARG
        ;;
      "r")
        ROWS="$(echo ${OPTARG}| sed -re 's/,|([[:digit:]])$/\1p;/g' -e's/\-/,/g')"
        ;;
      "c")
        COLS=$OPTARG
        ;;
      "t")
        TRANSPOSE=1
        ;;
      "v")
        PIVOTROW="$(echo $OPTARG | grep -oP "^\K[[:digit:]]+(?=,[[:digit:]]+$)")"
        PIVOTCOL="$(echo $OPTARG | grep -oP "^[[:digit:]]+,\K[[:digit:]]+$")"
        VERTICALTABLE=1
        ;;
      "h")
        echo -e "\t-s NUM\t\tNúmero de la hoja a procesar."
        echo -e "\t-r NUM\t\tRango de filas a procesar, separadas por coma."
        echo -e "\t-c NUM\t\tProcesar solo estas columnas"
        echo -e "\t-t Transponer matriz"
        echo -e "\t-v PIVOTE Transforma los datos a un modelo Entidad-Atributo-Valor (Modelo Vertical) Utilizando PIVOTE cómo la coordenada (FILA,COLUMNA) inicial de los Valores, las columnas a la izquierda representan la entidad y las filas de arriba el atributo. Esta operación es la de última prioridad, por lo que si se utiliza en conjunto con otros operadores el PIVOTE es la coordenada de la matriz resultante de las transformaciones."
        ;;
      "?")
        echo "Opción desconocida $OPTARG"
        ;;
      ":")
        echo "No se proporcionó un argumento para la opción $OPTARG"
        ;;
      *)
      # Should not occur
        echo "Error desconocido al procesar las opciones"
        ;;
    esac
  done

for inputFile; do true; done


OUTPUT="$(xlsx2csv -emp '' -d'tab' -s "${SHEETNUM}" "${inputFile}")";

if [ ! -z "${COLS}" ]; then
   OUTPUT="$(echo "${OUTPUT}"| cut -f "${COLS}")"
fi

if [ ! -z "${ROWS}" ]; then
   OUTPUT="$(echo "${OUTPUT}"| sed -n "${ROWS}")"
fi

if [ ! -z ${TRANSPOSE} ] && [ ${TRANPOSE}==1 ]; then
  OUTPUT="$(echo "${OUTPUT}" | awk 'BEGIN{OFS=FS="\t"}{ for (i=1;i<=NF;i++) BUFFER[NR][i]=gensub(/^\s+|\s+$/,"","g",$i); if (NF>MAXFIELDS) MAXFIELDS=NF} END{for (i=1;i<=MAXFIELDS;i++) {for (j=1;j<=NR;j++) {printf BUFFER[j][i]; if (j<NR) {printf OFS;}}; printf "\n";}}')"
fi


if [ ! -z ${VERTICALTABLE} ] && [ ${VERTICALTABLE}==1 ]; then
  OUTPUT="$(echo "${OUTPUT}" | awk -v PIVOTROW=$PIVOTROW -v PIVOTCOL=$PIVOTCOL 'BEGIN{OFS=FS="\t"} { if (NR<PIVOTROW) { for (j=PIVOTCOL;j<=NF;j++) {HEADER[NR][j+1-PIVOTCOL]= gensub(/^\s+|\s+$/,"","g",$j);}} else {for (j=PIVOTCOL;j<=NF;j++){ for (i=1;i<PIVOTCOL;i++){ printf gensub(/^\s+|\s+$/,"","g",$i); printf OFS;} for (k=1;k<PIVOTROW;k++) {printf HEADER[k][j+1-PIVOTCOL]OFS}; print gensub(/^\s+|\s+$/,"","g",$j)};} }')"
fi


echo "${OUTPUT}"
