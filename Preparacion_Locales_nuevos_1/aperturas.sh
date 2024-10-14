#!/bin/bash
#Realizado Por :Carlos García.
fecha=$(date +%Y-%m-%d-%H:%M:%S)
fecha1=$(date --date='-1 month' +%Y-%m-%d-%H:%M:%S )

#VERIFICO CLAVE PRIVADA
#KEY="/geocom/.ssh/id_dsa.pub"

#VERIFICO CLAVE PRIVADA
KEY="/root/.ssh/id_dsa.pub"
        if [ ! -f ~/.ssh/id_dsa.pub ];then
                echo "private key not found at $KEY"
                echo "* please create it with "ssh-keygen -t dsa" *"
                echo "* to login to the remote host without a password, don't give the key you create with ssh-keygen a password! *"
                exit
        fi


#Consulto local a trabajar
                             
                                              read -p 'Ingrese Nº de Local A Preparar:' fcv 
 
                                              echo "Que desea realizar :"
                                              echo "1 .-Configurar Servidor"
                                              echo "2 .-Realizar Full" 
					                                    echo "3 .-Instalacion Aplicativo POS"
					                                    echo "4 .-Parametrización de POS (monitor.sh,permisos,etc)"

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
java -Xmx512M -XX:MaxPermSize=512m -XX:PermSize=128m -classpath $jisql_classpath com.xigole.util.sql.Jisql -user $db_user -password $db_password -driver $db_driver -cstring $db_url -c \; -query "$query" > aux_$redes
cat aux_$redes  | cut -d'|' -f1 |cut -d'-' -f2  > temp_$redes
sed '1,2 d' temp_$redes > cajas_$fcv.txt

localid=$(cat cajas_$fcv.txt  | cut -d ',' -f1  | tr -d '[[:space:]]')
ipLocal=$(cat cajas_$fcv.txt  | cut -d ',' -f3)


#rm tem
fi
}
#----------------
function run_query_geopos_central_POS() {

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





#cat aux_$fcv  | cut -d'|' -f1 |cut -d'-' -f2  >        --temp_$fcv
#sed '1,2 d' temp_$fcv > servidores.txt

#servidores=$(cat servidores.txt | tr -d '[[:space:]]')
#(cat servidores.txt | tr -d '[[:space:]]') >> servidores.txt

#rm temp
fi
}
#----------------



if [ $OP -eq 1 ]; then

valido ()
{
if [ $1 -eq 0 ]; then
       echo "SALIDA:OK"
    else
       echo "SALIDA:ERROR"
fi
}

        ## -------EJECUTO consulta a central para Obtener IP del Local --------------------

        # consulta a  central"
run_query_geopos_central "select  LOCALID ||','|| NODE || ',' || IPADDRESS from nodes where NODE = 99 and ACTIVE = 1 and LOCALID=$fcv;"
         valido $?
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

echo "Ingrese Cadena del local:"  
echo "1 .-Local Propio"
echo "2 .-Local Franquicia" 

read -p 'Escoga Opcion: ' cadena

if [ $cadena -eq 1 ]; then
   IdentifiePro="sed -i 's/root.PreProd.1000.99/root.8610.$fcv\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties"
   setup2="sed -i 's/root.PreProd/root.8610/g' /home/geocom/InstallScripts/setup.ini;"
  else
   IdentifiePro="sed -i 's/root.PreProd.1000.99/root.franquicias.$fcv\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties"
   setup2="sed -i 's/root.PreProd/root.franquicias/g' /home/geocom/InstallScripts/setup.ini;"
fi


ActiveMq="sed -i 's/10.193.22.192/10.193.22.189/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/activemq.properties;"
Parameters="sed -i 's/10.193.22.192/10.193.22.189/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/parameters.properties;"
#Configuracion del setup.ini
setup1="sed -i 's/10.193.22.192/10.193.22.189/g' /home/geocom/InstallScripts/setup.ini;"
#setup2="sed -i 's/root.PreProd/root.franquicias/g' /home/geocom/InstallScripts/setup.ini;"
setup3="sed -i 's/=1000/=$fcv/g' /home/geocom/InstallScripts/setup.ini"


#Depuraciones 
Storage="rm -rf /home/geocom/geopos/geopos2server-storage/*;"
JbossTmp="cd /hom::e/geocom/jboss-4.2.3.GA/server/default && rm -rf work/*data/*tmp/*;"
logjboss="rm -rf /home/geocom/jboss-4.2.3.GA/server/default/log/*"
ConfigStorage="rm -rf /home/geocom/geoconfigurator/geoconfigurator/clientConfigurator-storage/*;"

#Variable CORRER GEOCONFIGURATOR
Geoconfig="sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/geopos/geopos2cruzverde/docs/VersionGEOPosServer.xml alwaysupdate ; sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/backoffice/current/docs/GEOConfigurator_Backoffice.xml alwaysupdate ; sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/cruzverde-central-ws/currentVersion/docs/VersionCruzVerdeCental.xml alwaysupdate ; sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/geopromotion/geopromotion-engine/docs/VersionGEOPromotionServer.xml alwaysupdate ; sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/bio-equivalent-article-processor/current/docs/configurator.xml alwaysupdate ; sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/geoverifier/geoverifier/VersionGEOVerifier.xml alwaysupdate"
ServicesGEO="service geopos stop;service jboss stop;service geopromotion stop;service activemq stop;service geoVerifier stop"
validaGeoconfig="cat /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties; cat /home/geocom/geoconfigurator/geoconfigurator/cfg/client/activemq.properties; cat /home/geocom/geoconfigurator/geoconfigurator/cfg/client/parameters.properties; cat /home/geocom/InstallScripts/setup.ini"

                #PARAMETRIZACIÓN DE GEOCONFIGURADOR A PRODUCCIÓN
                (setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $IdentifiePro 2> /dev/null) &>/dev/null
                (setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $ActiveMq 2> /dev/null) &>/dev/null
                (setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $Parameters 2> /dev/null) &>/dev/null
                (setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $setup1 2> /dev/null) &>/dev/null
                (setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $setup2 2> /dev/null) &>/dev/null
                (setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $setup3 2> /dev/null) &>/dev/null

                #BORRADO DE DIRECTORIO
                echo ""
               # echo "Empiezo la depuración"
                echo ""
                sleep 1
                (setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $Storage 2> /dev/null) &>/dev/null
                (setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $JbossTmp 2> /dev/null) &>/dev/null
                (setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $ConfigStorage 2> /dev/null) &>/dev/null
                (setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $logjboss 2> /dev/null) &>/dev/null
                echo ""

                #### CORRO GEOCONFIGURATOR
                #setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $validaGeoconfig

                echo "Realizar Validaciones Previas, como identifier, parameter, activemq, setup.ini "
                echo ""
 # -----------------------------------------------------              
                echo "Se valida que NO exista una instancia del geoconfigurador"

                 CANT=$(ps -ef |grep uy.com.geocom.configurator.client.ClientMain | grep -v grep | wc -l)
                 if [ $CANT -gt 0 ]; then
                    echo "Existe una instancia de GEOConfigurator ejecutandose, Se procede a un kill al proceso"
                    pib=$(setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "pgrep -f geoconfigurator")
                    setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "kill -9 $pib"
                    echo "kill al proceso $pib - geoconfigurador"
                 exit 1
                    else
                    echo "Iniciando GEOConfigurator"
                 
                 fi
                 
                echo ""              
 #------------------------------------------------------------------------                 
                                  
                sleep 2
                echo "Se corre geoconfigurator"
                echo ""
                setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $Geoconfig
                sleep 2
                echo "Se detienen los servicios"
                #(setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $updateGeoconfigPrep &> log) &> log
                #setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal  $ServicesGEO
                
                echo "Se procede con la depuración de la Base de datos"
				
                mysql -h$ipLocal -u root -pgeocom geopos2cruzverde < depuradorBase.sql
                
                sleep 2
                
                if [ $cadena -eq 1 ]; then

                  mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "INSERT INTO cvproveedores(CVProveedoresRUT, CVProveedoresSucursal, CVProveedoresNombre, CVProveedoresDireccion, CVProveedoresCiudad, CVProveedoresGiro, CVProveedoresDigitoVerificador, CVComunasId) VALUES(77722823, 903901, 'SOCOFAR S.A. AGENCIA EN CHILE', 'AV. VICUNA MACKENNA 3350, MACUL', 'SANTIAGO', 'DISTRIBUIDORA DE PRODUCTOS FARMACEUTICOS', '4', 13101)"
                  
                  sleep 2
                  mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "UPDATE geoparamdinamicos SET GeoParamDinamicoValor='77722823' WHERE GeoParamDinamicoCodigo='PROVEEDORDEFAULT'"
                  else 
                 mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "INSERT INTO cvinventarios.cvproveedores(CVProveedoresRUT, CVProveedoresSucursal, CVProveedoresNombre, CVProveedoresDireccion, CVProveedoresCiudad, CVProveedoresGiro, CVProveedoresDigitoVerificador, CVComunasId)
VALUES(77712318, 9999901, 'PROVEFARMA', 'Av. SALTO 4875', 'SANTIAGO', 'DISTRIBUIDORA DE PRODUCTOS FARMACEUTICOS', '7', 13101)"
                
                sleep 2 
                mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "UPDATE cvinventarios.geoparamdinamicos SET GeoParamDinamicoValor='77712318' WHERE GeoParamDinamicoCodigo='PROVEEDORDEFAULT'"

                 sleep 2
                 mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "UPDATE cvinventarios.geoparamdinamicos SET GeoParamDinamicoValor='9999901' WHERE GeoParamDinamicoCodigo='SUCURSALDEFAULT'"             
                
                fi
                mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e "update cvinventarios.geoparamdinamicos set GeoParamDinamicoValor='23:00' where GeoParamDinamicoCodigo='HORALIMITEIMPFLEJES'"
                mysql -pgeocom --connect-timeout=2 -N -h$ipLocal geopos2cruzverde -e "INSERT INTO geopos2cruzverde.localprocess(id, processDate, event, user_, local, sendstate, countableDate, chain, processDateToShow, updated) VALUES(1, '$fecha', 'start_month_process', '1', '$localid', 'X', '$fecha', 10, '$fecha1', '$fecha')"

              
                echo "Se procedera con el reinicio del servidor, No olvidar de enviar Cargas de Item y Pagos"
                sleep 2
                setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "reboot" 
fi
fi 

if [ $OP -eq 2 ]; then

#Consulto local a trabajar
                             
                                              read -p 'Ingrese Nº de Local A Realizar Dump:' fcv 

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
         
         echo "Realizado con exito!!! ..."
         
fi

if [ $OP -eq 3 ]; then

#Consulto local a trabajar
                             
#                                              read -p 'Ingrese Nº de Local : ' fcv 

        ## -------EJECUTO consulta a central para Obtener IP del Local --------------------

        # consulta a  central"
run_query_geopos_central_POS "select LOCALID ||'-'|| LOCALID ||','|| NODE || ',' || IPADDRESS from nodes where NODE <> 99 and ACTIVE = 1 and LOCALID=$fcv;"
         valido $?
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

Echo "Obtengo IP "

ipLocal=$(head -n1 servidores.txt |grep ',' |cut -d ',' -f3 |cut -d '.' -f1-3).110

 ping -q -c1 $ipLocal > /dev/null
if [ $? -eq 0 ]; then

setsid scp -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null servidores.txt root@$ipLocal:/migracionPos/run-process-PROD-Etapa1
setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "cd /migracionPos/run-process-PROD-Etapa1 && sh -x run_process.sh geocom"

echo "Finaliza La instalacion del aplicativo en POS, No olvidar enviar Cargas de Item y Pagos"

fi
fi
if [ $OP -eq 4 ]; then

                                              echo "Indique Modelo de POS :"
                                              echo "1 .-360"
                                              echo "2 .-361" 
					                                    echo "3 .-HS"
					                          
                                              read -p 'Escoga Opcion: ' moni
if [ $moni -eq 1 ]; then	

       monitor1=360

fi										  
if [ $moni -eq 2 ]; then	

	monitor1=361

fi						

if [ $moni -eq 3 ]; then	

	monitor1=362

fi					  
#Monitor1="sed '2 a  xrandr --output $monitor1 --mode 1024x768 --pos 0x0' monitor.sh"
#Monitor2="sed '3 a  xrandr --output $monitor2 --mode 1024x768 --pos 1024x0' monitor.sh"

for line in $(cat servidores.txt);
do
        nroLocal=$(echo $line | cut -d ',' -f1)
        nodoLocal=$(echo $line | cut -d ',' -f2)
        ipNodo=$(echo $line | cut -d ',' -f3)

        echo "$nroLocal,nodoLocal"
        log "LOCAL: $nroLocal, POS: $nodoLocal, IP: $ipNodo"

    ping -q -c1 $ipNodo
    if [ $? -eq 0 ] ; then
    ## -------EJECUTO PROCESO EN POS --------------------
                log "$LOGFECHA -> LOCAL:$nroLocal - POS: $nodoLocal"
                #ssh-keygen -R ipNodo
                USER="geocom"
                PASSWD="geocom"
                SSH_ASKPASS_SCRIPT=$(pwd)/$(basename "$0" ".sh")ssh-askpass-script
                cat > ${SSH_ASKPASS_SCRIPT} <<EOF
#!/bin/bash
echo "${PASSWD}"
EOF
                chmod 755 ${SSH_ASKPASS_SCRIPT}
                export DISPLAY=:0
                export SSH_ASKPASS=${SSH_ASKPASS_SCRIPT}
				
		setsid scp -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null librxtxParallel.so librxtxSerial.so geocom@$ipNodo:/usr/java/jdk1.8.0_291/jre/lib/amd64/
                setsid scp -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null script_serial_printer.sh sewoo_jpos_release_211115.tar.gz geocom@$ipNodo:/home/geocom
                
                if [ $monitor1 -eq 360 ]; then
                     setsid ssh  -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null geocom@$ipNodo "cd /home/geocom && rm -rf monitor.sh"
                     setsid scp -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null monitor_360.sh geocom@$ipNodo:/home/geocom 
                     setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null geocom@$ipNodo "cd /home/geocom && mv  monitor_360.sh monitor.sh"
                fi
                if [ $monitor1 -eq 361 ]; then
                     setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null geocom@$ipNodo "cd /home/geocom && rm -rf monitor.sh"
                     setsid scp -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null monitor_361.sh geocom@$ipNodo:/home/geocom
                     setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null geocom@$ipNodo "cd /home/geocom && mv  monitor_361.sh monitor.sh"
                fi
                if [ $monitor1 -eq 362 ]; then
                     setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null geocom@$ipNodo "cd /home/geocom && rm -rf monitor.sh"
                     setsid scp -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null monitor_hs.sh geocom@$ipNodo:/home/geocom
                     setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null geocom@$ipNodo "cd /home/geocom && mv  monitor_hs.sh monitor.sh"
                fi
                     setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null geocom@$ipNodo "cd /home/geocom && sh script_serial_printer.sh"
                 #sleep 2 
                  #   mysql -uroot -pgeocom -f -h$ipNodo geopos2cruzverde < sql.sql   
#-------		
                USER1="soportegeo"
                PASSWD1="mmLLas.,17"
                SSH_ASKPASS_SCRIPT=$(pwd)/$(basename "$0" ".sh")ssh-askpass-script
                cat > ${SSH_ASKPASS_SCRIPT} <<EOF
#!/bin/bash
echo "${PASSWD1}"
EOF
                chmod 755 ${SSH_ASKPASS_SCRIPT}
                export DISPLAY=:0
                export SSH_ASKPASS=${SSH_ASKPASS_SCRIPT}

setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/ -oConnectTimeout=20 $USER1@$ipNodo "cd /home/geocom && chown -R geocom:users /home/geocom/*"
#setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/ -oConnectTimeout=20 $USER1@$ipNodo 'sudo chown -R geocom:users /home/geocom/*'

sleep 2

setsid ssh  -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null geocom@$ipNodo "cd /home/geocom/geopos/geopos2cruzverde && sh shutdown.sh"
#------------                
                
   else
                echo "POS fuera de linea"
   fi
done
echo "===============Los POS se estan reiniciando, una vez que suban No olviar de Validar Configuraciones (monitor.sh,librerias pinpad,etc)================" 
rm aux_$nroLocal
fi
