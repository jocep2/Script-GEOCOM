#!/bin/bash
#Realizado Por :Carlos García.
fecha=$(date +%Y-%m-%d-%H-%M-%S)
#Limpio proceso anterior
rm -rf Manifiesto_antes.txt Manifiesto_despues.txt

#Consulto local a trabajar
 
  
 echo "Que desea realizar :"
 
 echo "1 .- Renombrar Manifiesto" 
 echo "2 .- Cambiar Estado al Manifiesto" 
 echo "3 .- Realizar Full - Locales OL."
 echo "4 .- Bajar video."

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

localid=$(cat cajas_$fcv.txt  | cut -d ',' -f1  | tr -d '[[:space:]]')
SOP=$(cat cajas_$fcv.txt  | cut -d ',' -f4)
ipLocal=$(cat cajas_$fcv.txt  | cut -d ',' -f3)
#rm temp
fi
}

#---

function run_query_geopos_central_SRV() {

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
java -Xmx512M -XX:MaxPermSize=512m -XX:PermSize=128m -classpath $jisql_classpath com.xigole.util.sql.Jisql -user $db_user -password $db_password -driver $db_driver -cstring $db_url -c \; -query "$query" > aux_$redes

cat aux_$redes | cut -d'|' -f1 |cut -d'-' -f2 > temp_$redes
sed '1,2 d' temp_$redes > servidores.txt

fi
}
#--  

if [ $OP -eq 1 ]; then

echo "Escoga Local a Trabajar"
 read -p 'Ingrese Nº de Local:' fcv 


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

echo "Escoga Local a Trabajar"
read -p 'Ingrese Nº de Local:' fcv 
 
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
#----------------
if [ $OP -eq 3 ]; then

#Consulto local a trabajar
                             
                                              read -p 'Ingrese Nº de Local donde Realizar Dump:' fcv 

        ## -------EJECUTO consulta a central para Obtener IP del Local --------------------

        # consulta a  central"
run_query_geopos_central "select LOCALID ||'-'|| LOCALID ||','|| NODE || ',' || IPADDRESS from nodes where NODE = 99 and ACTIVE = 1 and LOCALID=$fcv;"
     #    valido $?
         sleep 2

        ## -------EJECUTO PROCESO EN EL LOCAL --------------------

USER="root"
PASSWD="difarma2020"
SSH_ASKPASS_SCRIPT=./ssh-askpass-script

cat > ${SSH_ASKPASS_SCRIPT} <<EOF
#!/bin/bash
echo "${PASSWD}"
EOF

chmod 755 ${SSH_ASKPASS_SCRIPT}
export DISPLAY=:0
export SSH_ASKPASS=${SSH_ASKPASS_SCRIPT}

 ping -q -c1 $ipLocal > /dev/null
if [ $? -eq 0 ]; then

echo "Sacamos Dump del local $localid - $ipLocal" 

 setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "cd /home/geocom/UPDATEFILES && mysqldump -h$ipLocal --opt -pgeocom -ER geopos2cruzverde articles barcodes backoffice_schema_version acv acv_products acv_laboratories  acv_bioequivalence  ag_agreements  ag_apls  ag_beneficiaries ag_cards ag_companies ag_cpls ag_credentials ag_doctors ag_factors ag_institution ag_pers_cond ag_plan_cond ag_plan_msg ag_planbiometryconfig ag_planbeneficiaries ag_planquote ag_planquoteinfo ag_planquoteinfo_planquote ag_plans ag_plans_response_code ag_popups ag_pricelist agreements articleselected paymentgroupfiltersdata groupfilters measureconversions measures negative parameter paymentmodes paymentmodesconfiguration paymentmodetypes permissions pharmaceuticalform plans posdocuments postypes prefixes products reasons relateditems relatedarticles rolepermissions roles rounders template_documents unimarctaxes zones cities communes advices adviceproducts active_ingredient compounding_type compounding_type_measure inputmanagers im_response_code genericactiveingredient genericactiveingredientarticle itemcategories categories warningproducts warningquestions warnings > fullNew.sql "

setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "cd /home/geocom/UPDATEFILES && zip fullNew.sql.zip fullNew.sql"
setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "cd /home/geocom/UPDATEFILES && rm -rf fullNew.sql" 

sleep 2

echo "Finaliza Dump con exito!!!"
ipLocalD=$ipLocal
fi

read -p 'Ingrese Nº de Local A volcar Dump:' fcv

 ## -------EJECUTO consulta a central para Obtener IP del Local --------------------

        # consulta a  central"
run_query_geopos_central "select LOCALID ||'-'|| LOCALID ||','|| NODE || ',' || IPADDRESS from nodes where NODE = 99 and ACTIVE = 1 and LOCALID=$fcv;"
         #valido $?
         sleep 2
         url="http://$ipLocalD:8084/UPDATEFILES/fullNew.sql.zip"
         url2=$(echo "$url" | sed 's/ //g')
         echo "$url2"
         echo "Comienza Volcado del Dump hacia el local $fcv - $ipLocal"
         #setsid scp -p -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocalD:/home/geocom/UPDATEFILES/fullNew.sql.zip root@$ipLocal:/home/geocom/UPDATEFILES
         setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/ -oConnectTimeout=20 root@$ipLocal "cd /home/geocom/UPDATEFILES && wget -c $url2"     
         setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "cd /home/geocom/UPDATEFILES && unzip fullNew.sql.zip"
         setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "cd /home/geocom/UPDATEFILES && mysql -uroot -pgeocom -f -h$ipLocal geopos2cruzverde < fullNew.sql"
         setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "cd /home/geocom/UPDATEFILES && rm -rf fullNew.sql.zip"
         setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "cd /home/geocom/UPDATEFILES && rm -rf fullNew.sql"
         
         sleep 2
         echo "Se procede a eliminar fullNew.sql.zip del local Origen del full..."
         setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocalD "cd /home/geocom/UPDATEFILES && rm -rf fullNew.sql.zip"
         
         echo "Volcado realizado con exito!!! ..."
         echo " "
         echo "NO OLVIDAR DE ENVIAR CARGAS A LOS POS...."
         echo " "
fi
rm -rf aux_* cajas_* temp_*
#-------------------
if [ $OP -eq 4 ]; then
                                       echo " 1 .- Bajar Video local"
                                       echo " 2 .- Bajar Video cadena"
                                       
                                       read -p 'Escoga Opcion :' OPP 

if [ $OPP -eq 1 ]; then
 

echo " "

read -p 'Ingrese Nº de Local que desea bajar Video:' fcv

KEY="/root/.ssh/id_dsa.pub"
        if [ ! -f ~/.ssh/id_dsa.pub ];then
                echo "private key not found at $KEY"
                echo "* please create it with "ssh-keygen -t dsa" *"
                echo "* to login to the remote host without a password, don't give the key you create with ssh-keygen a password! *"
                exit
        fi

        ## -------EJECUTO consulta a central para Obtener IP del Local --------------------

        run_query_geopos_central "select LOCALID ||'-'|| LOCALID ||','|| NODE || ',' || IPADDRESS  ||','|| BUSINESSNAME from nodes where NODE = 99 and ACTIVE = 1 and LOCALID=$fcv;"
     
         #sleep 1
         
         echo " "
         echo " Local $localid con sistema operativo $SOP "
         echo " "
         
         if [ $SOP = OL ]; then
             
             
                     USER="root"
                     PASSWD="difarma2020"
                     SSH_ASKPASS_SCRIPT=./ssh-askpass-script-1

                     cat > ${SSH_ASKPASS_SCRIPT} <<EOF
                     #!/bin/bash
                     echo "${PASSWD}"
EOF

                     chmod 755 ${SSH_ASKPASS_SCRIPT}
                     export DISPLAY=:0
                     export SSH_ASKPASS=${SSH_ASKPASS_SCRIPT}

            
            else 
            
                     
                     USER="root"
                     PASSWD="cverde2011"
                     SSH_ASKPASS_SCRIPT=./ssh-askpass-script-1

                     cat > ${SSH_ASKPASS_SCRIPT} <<EOF
                     #!/bin/bash
                     echo "${PASSWD}"
EOF

                     chmod 755 ${SSH_ASKPASS_SCRIPT}
                     export DISPLAY=:0
                     export SSH_ASKPASS=${SSH_ASKPASS_SCRIPT}
         fi      
 
                     ping -q -c1 $ipLocal > /dev/null
                     if [ $? -eq 0 ]; then
        
                       setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/ -oConnectTimeout=8 root@$ipLocal "rm -rf /home/geocom/geopos/videos/*.avi && service vlc stop && rm -rf serverVideo.sh" 
                       setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/ -oConnectTimeout=8 root@$ipLocal "rm -rf /home/geocom/geopos/videos/serverVideo.sh"
         
                        echo " "
                        echo " Se Baja el video exitosamente!!! ... "
                        echo " " 
                       else
                          echo "Local Sin Conexion .." 
                     fi         
fi    
if [ $OPP -eq 2 ]; then

KEY="/root/.ssh/id_dsa.pub"
        if [ ! -f ~/.ssh/id_dsa.pub ];then
                echo "private key not found at $KEY"
                echo "* please create it with "ssh-keygen -t dsa" *"
                echo "* to login to the remote host without a password, don't give the key you create with ssh-keygen a password! *"
                exit
        fi

        ## -------EJECUTO consulta a central para Obtener IP del Local --------------------

        run_query_geopos_central_SRV "select LOCALID ||'-'|| LOCALID ||','|| NODE || ',' || IPADDRESS from nodes where ELIMINATED =0 and node = 99  and localid not in (1,8610)  and BUSINESSNAME is null;"
        
         echo "Se procede A bajar video para los locales SuSe "
         cp servidores.txt /app/soporte/usuarios/cagarcia/A_2022/bajo_video
         cd  /app/soporte/usuarios/cagarcia/A_2022/bajo_video/ && rm -rf scripts
         sleep 2
         cd  /app/soporte/usuarios/cagarcia/A_2022/bajo_video/  && sh GeneroScripts.sh
         sleep 3
         cd  /app/soporte/usuarios/cagarcia/A_2022/bajo_video/scripts  && sh Ejecutoscripts.sh
         
         sleep 6
         cd /app/soporte/usuarios/cagarcia/Renombro_Manifiesto/Version_2
         echo " "
         #echo " Local $localid con sistema operativo $SOP "
         #echo " "
         
         ## -------EJECUTO consulta a central para Obtener IP del Locales OL  --------------------
         
         run_query_geopos_central_SRV "select LOCALID ||'-'|| LOCALID ||','|| NODE || ',' || IPADDRESS from nodes where ELIMINATED =0 and node = 99 and localid not in (1,8610) and BUSINESSNAME ='OL';"
 
         cp servidores.txt /app/soporte/usuarios/cagarcia/A_2022/bajo_video/OL 
         cd  /app/soporte/usuarios/cagarcia/A_2022/bajo_video/OL && rm -rf scripts
         sleep 2
         cd  /app/soporte/usuarios/cagarcia/A_2022/bajo_video/OL  && sh GeneroScripts.sh
         sleep 3
         cd  /app/soporte/usuarios/cagarcia/A_2022/bajo_video/OL/scripts  && sh Ejecutoscripts.sh
         
         sleep 6
         cd /app/soporte/usuarios/cagarcia/Renombro_Manifiesto/Version_2
         echo " "
fi      
fi
#done