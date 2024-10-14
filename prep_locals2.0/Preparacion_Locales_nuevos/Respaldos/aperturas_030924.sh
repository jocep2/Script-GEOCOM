#!/bin/bash
#Realizado Por :Carlos García.
fecha=$(date +%Y-%m-%d-%H-%M-%S)

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
                             
                                              read -p 'Ingrese Nº de Local A Recuperar:' fcv 
 
                                              echo "Que desea realizar :"
                                              echo "1 .-Configurar Servidor"
                                              echo "2 .-Realizar Full" 

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
ipLocal=$(cat cajas_$fcv.txt  | cut -d ',' -f3)


#rm temp
fi
}

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
JbossTmp="cd /home/geocom/jboss-4.2.3.GA/server/default && rm -rf work/*data/*tmp/*;"
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
                echo "VALIDACIÓN DE IDENTIFIER Y PARAMETROS."
                echo ""

                #### CORRO GEOCONFIGURATOR
                #setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $validaGeoconfig

                echo "ALFINAL VALIDAR NRO DEL LOCAL EN SETUP.INI Y PARAMETROS "
                echo ""

                sleep 3
                echo "Se corre geoconfigurator"
                echo ""
               
                setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $Geoconfig
                sleep 6
                echo "Se detienen los servicios"
                #(setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal $updateGeoconfigPrep &> log) &> log
                setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal  $ServicesGEO
fi
fi 
