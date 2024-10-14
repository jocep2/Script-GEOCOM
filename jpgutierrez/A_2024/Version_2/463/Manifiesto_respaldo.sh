#!/bin/bash
#Realizado Por :Carlos García.
fecha=$(date +%Y-%m-%d-%H-%M-%S)
#Limpio proceso anterior
rm -rf Manifiesto_antes.txt Manifiesto_despues.txt

#Consulto local a trabajar
 
 echo "Escoga Local a Trabajar"
 read -p 'Ingrese Nº de Local:' fcv 
 
 echo "Que desea realizar :"
 
 echo "1 .- Renombrar Manifiesto" 
 echo "2 .- Cambiar Estado al Manifiesto" 

  read -p 'Escoga Opcion: ' OP
  
#importacion clase para jdbc
jisql_classpath=lib/jisql-2.0.11.jar:lib/jopt-simple-3.2.jar:lib/ojdbc-14.jar

function run_query_geopos_central() {

local query=$1
local db_driver=oracle.jdbc.driver.OracleDriver
local db_ip=10.193.20.93
local db_password=geocom2012
local db_user=geopos2cruzverde
local db_sn=pgpos
local db_url="jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=pgpos.ora.difarma.cl)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=pgpos_srv)))"


if [ $# -eq 0 ]
  then
    echo "ERROR. Uso correcto: no se envio la query"
else
java -Xmx512M -XX:MaxPermSize=512m -XX:PermSize=128m -classpath $jisql_classpath com.xigole.util.sql.Jisql -user $db_user -password $db_password -driver $db_driver -cstring $db_url -c \; -query "$query" > aux_$fcv
cat aux_$fcv  | cut -d'|' -f1 |cut -d'-' -f2  > temp_$fcv
sed '1,2 d' temp_$fcv > cajas_$fcv.txt


ipLocal=$(cat cajas_$fcv.txt  | cut -d ',' -f3)
#rm temp
fi
}

  

if [ $OP -eq 1 ]; then


read -p 'ingresar codigo Manifiesto:' manifiesto



#####################################
#Funcion valido.
valido ()
{
if [ $1 -eq 0 ]; then
       echo "SALIDA:OK"
    else
       echo "SALIDA:ERROR"
fi
}
#fecha=$(date +%Y-%m-%d-%H-%M-%S)
 

        ## -------EJECUTO consulta a central --------------------

        # log de consulta a  central"
run_query_geopos_central "select  LOCALID ||','|| NODE || ',' || IPADDRESS from nodes where NODE = 99 and ACTIVE = 1 and LOCALID=$fcv;"
         valido $?
         sleep 2

        ## -------EJECUTO PROCESO EN EL LOCAL --------------------

 ping -q -c1 $ipLocal > /dev/null
if [ $? -eq 0 ]; then
######################################
#obtengo Manifiesto y bultos.
echo "Obtengo Manifiesto y bultos..."

mani=$(mysql -pgeocom --connect-timeout=2 --skip-column-names -h$ipLocal cvinventarios -e "select * from cvmanifiesto where CVManifiestoCodigo=$manifiesto") 
echo "Manifiesto : $manifiesto" >>Manifiesto_antes.txt
echo " "  >>Manifiesto_antes.txt
echo "$mani" >>Manifiesto_antes.txt
echo " " >>Manifiesto_antes.txt
echo "Bultos con manifiesto : $manifiesto" >>Manifiesto_antes.txt 
echo " "  >>Manifiesto_antes.txt
bulto=$(mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "select * from cvbulto where CVManifiestoCodigo=$manifiesto")
echo "$bulto"  >>Manifiesto_antes.txt

#####################################################
#Armo insert obteniendo los datos de cada campo

CVManifiestoCodigo=$(mysql -pgeocom --connect-timeout=2 --skip-column-names -h$ipLocal cvinventarios -e "select CVManifiestoCodigo  from cvmanifiesto where CVManifiestoCodigo=$manifiesto")
CVLocalesId=$(mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "select CVLocalesId  from cvmanifiesto where CVManifiestoCodigo=$manifiesto")
CVManifiestoFechaGeneracion=$(mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "select CVManifiestoFechaGeneracion  from cvmanifiesto where CVManifiestoCodigo=$manifiesto")
CVManifiestoEstado=$(mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "select CVManifiestoEstado from cvmanifiesto where CVManifiestoCodigo=$manifiesto")
CVManifiestoMatriculaTransport=$(mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "select CVManifiestoMatriculaTransport from cvmanifiesto where CVManifiestoCodigo=$manifiesto")
CVManifiestoUtilizadoAutorizac=$(mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "select CVManifiestoUtilizadoAutorizac from cvmanifiesto where CVManifiestoCodigo=$manifiesto")
CVManifiestoTipoRecepcion=$(mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "select CVManifiestoTipoRecepcion from cvmanifiesto where CVManifiestoCodigo=$manifiesto")
CVManifiestoFechaRecepcion=$(mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "select CVManifiestoFechaRecepcion from cvmanifiesto where CVManifiestoCodigo=$manifiesto")
#######################################################
#Renombro manifiesto y Bultos:

mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "INSERT INTO cvinventarios.cvmanifiesto(CVManifiestoCodigo, CVLocalesId, CVManifiestoFechaGeneracion, CVManifiestoEstado, CVManifiestoMatriculaTransport, CVManifiestoUtilizadoAutorizac, CVManifiestoTipoRecepcion, CVManifiestoFechaRecepcion)
VALUES(99$manifiesto, $CVLocalesId, '$CVManifiestoFechaGeneracion', '$CVManifiestoEstado', '$CVManifiestoMatriculaTransport', $CVManifiestoUtilizadoAutorizac , '$CVManifiestoTipoRecepcion', '$CVManifiestoFechaRecepcion')"

mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "update cvbulto set CVManifiestoCodigo=99$manifiesto where CVManifiestoCodigo=$manifiesto"

mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "delete from cvmanifiesto where CVManifiestoCodigo=$manifiesto"


mani=$(mysql -pgeocom --connect-timeout=2 --skip-column-names -h$ipLocal cvinventarios -e "select * from cvmanifiesto where CVManifiestoCodigo=99$manifiesto")
echo "Manifiesto :99$manifiesto" >>Manifiesto_despues.txt
echo " "  >>Manifiesto_despues.txt
echo "$mani" >>Manifiesto_despues.txt
echo " " >>Manifiesto_despues.txt

echo "Bultos con manifiesto :99$manifiesto" >>Manifiesto_despues.txt
echo " "  >>Manifiesto_despues.txt
bulto=$(mysql -pgeocom --connect-timeout=2 --skip-column-names -h$ipLocal cvinventarios -e "select * from cvbulto where CVManifiestoCodigo=99$manifiesto")
echo "$bulto"  >>Manifiesto_despues.txt

echo "Finalizado con Exito, Recuerde subir evidencia a Mantis...."
mv Manifiesto_despues.txt Manifiesto_despues_FCV-$fcv_$fecha.txt
        mv Manifiesto_antes.txt Manifiesto_antes_FCV-$fcv_$fecha.txt


                               else
                                  echo "Local Fuera de Linea"
                               fi
fi

if [ $OP -eq 2 ]; then

 ## -------EJECUTO consulta a central --------------------

        # log de consulta a  central"
run_query_geopos_central "select  LOCALID ||','|| NODE || ',' || IPADDRESS from nodes where NODE = 99 and ACTIVE = 1 and LOCALID=$fcv;"
#         valido $?
         sleep 2


read -p 'Ingresar codigo Manifiesto:' manifiestoest 
echo "Ingrese estado : " 

echo "1 .- pendiente"
echo "2 .- procesado"
echo "3 .- en _proceso" 

read -p 'Escoga Opcion : ' estado

if [ $estado -eq 1 ]; then
    estado1=pendiente
fi

if [ $estado -eq 2 ]; then
    estado1=procesado
fi

if [ $estado -eq 3 ]; then
    estado1=en_proceso
fi

        ## -------EJECUTO PROCESO EN EL LOCAL --------------------


    ping -q -c1 $ipLocal > /dev/null
    if [ $? -eq 0 ]; then
       mani=$(mysql -pgeocom --connect-timeout=2 --skip-column-names -h$ipLocal cvinventarios -e"select * from cvmanifiesto where CVManifiestoCodigo=$manifiestoest")
       echo "Manifiesto : $manifiestoest" >>Manifiesto_antes.txt
       echo " "  >>Manifiesto_antes.txt
       echo "$mani" >>Manifiesto_antes.txt
       echo " " >>Manifiesto_antes.txt

       CVManifiestoEstado=$(mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e"select CVManifiestoEstado from cvmanifiesto where CVManifiestoCodigo=$manifiestoest")

       echo "El estado actual es :$CVManifiestoEstado"

       mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "update cvmanifiesto set CVManifiestoEstado='$estado1' where CVManifiestoCodigo=$manifiestoest"
       
       mani1=$(mysql -pgeocom --connect-timeout=2 --skip-column-names -h$ipLocal cvinventarios -e"select * from cvmanifiesto where CVManifiestoCodigo=$manifiestoest") 
       CVManifiestoEstadodesp=$(mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e"select CVManifiestoEstado from cvmanifiesto where CVManifiestoCodigo=$manifiestoest")

       echo "Manifiesto :$manifiestoest" >>Manifiesto_despues.txt
       echo " "  >>Manifiesto_despues.txt
       echo "$mani1" >>Manifiesto_despues.txt
       echo " " >>Manifiesto_despues.txt
	mv Manifiesto_despues.txt Manifiesto_despues_FCV-$fcv_$fecha.txt
	mv Manifiesto_antes.txt Manifiesto_antes_FCV-$fcv_$fecha.txt 
       echo "Despues del cambio es : $CVManifiestoEstadodesp"

       else
         echo "Local Fuera de Linea"
   fi
fi
rm -rf aux_* cajas_* temp_*
#done
