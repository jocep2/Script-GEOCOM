#!/bin/bash
###################################################COMENTARIOS-humildes
#PREPARACIÓN MIGRADOS
#Juan Pablo Gutiérrez A. GEOSOFT 
#Versión de script 1.0

source /app/soporte/usuarios/jpgutierrez/A_2024/01/utils2.sh

log "====/----------------------------------------------------------------------------------------------------\===="
log "===(======================== INICIO DE LA GEOPREPARACIÓN DE LOS LOCALES A MIGRAR =========================)==="
log "====\----------------------------------------------------------------------------------------------------/===="
######=====Variables y lineas de comando Part 1=====######### 
javaPs="ps -fea | grep java" 
sedActiveMq="sed -i 's/10.193.22.192/10.193.22.189/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/activemq.properties;"
sedParameters="sed -i 's/10.193.22.192/10.193.22.189/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/parameters.properties;"

setupPart1="sed -i 's/10.193.22.192/10.193.22.189/g' /home/geocom/InstallScripts/setup.ini;"
setupPart2="sed -i 's/root.PreProd/root.8610/g' /home/geocom/InstallScripts/setup.ini;"

rmStorage="rm -rf /home/geocom/geopos/geopos2server-storage/*;"
rmJbossTmp="cd /home/geocom/jboss-4.2.3.GA/server/default && rm -rf *work/*data/*tmp/*;"
rmjbosslog="rm -rf /home/geocom/jboss-4.2.3.GA/server/default/log/*;"
rmConfigStorage="rm -rf /home/geocom/geoconfigurator/geoconfigurator/clientConfigurator-storage/*;"


updateGeoconfigPrep="sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/geopos/geopos2cruzverde/docs/VersionGEOPosServer.xml alwaysupdate ; sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/backoffice/current/docs/GEOConfigurator_Backoffice.xml alwaysupdate ; sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/cruzverde-central-ws/currentVersion/docs/VersionCruzVerdeCental.xml alwaysupdate ; sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/geopromotion/geopromotion-engine/docs/VersionGEOPromotionServer.xml alwaysupdate ; sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/bio-equivalent-article-processor/current/docs/configurator.xml alwaysupdate ; sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/geoverifier/geoverifier/VersionGEOVerifier.xml alwaysupdate"
stopServicesGEO="service geopos stop;service jboss stop;service geopromotion stop;service activemq stop;service geoVerifier stop"
validaGeoconfig="cat /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties; cat /home/geocom/geoconfigurator/geoconfigurator/cfg/client/activemq.properties; cat /home/geocom/geoconfigurator/geoconfigurator/cfg/client/parameters.properties; cat /home/geocom/InstallScripts/setup.ini"

#En caso de que me pidan correrlos por tipo de apis
#updateVersionGeoPosServer="sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/geopos/geopos2cruzverde/docs/VersionGEOPosServer.xml alwaysupdate ;"
#updateVersionBackoffice="sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/backoffice/current/docs/GEOConfigurator_Backoffice.xml alwaysupdate ;"
#updateVersionCruzVerdeCentral=" sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/cruzverde-central-ws/currentVersion/docs/VersionCruzVerdeCental.xml alwaysupdate;"
#updateVersionGeoPromotion="sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/geopromotion/geopromotion-engine/docs/VersionGEOPromotionServer.xml alwaysupdate;"
#updateVersionBioEquivalentr="sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/bio-equivalent-article-processor/current/docs/configurator.xml alwaysupdate;"
#updateVersionGeoVerifier="sh /home/geocom/geoconfigurator/geoconfigurator/run-commandLineClient.sh /home/geocom/geoverifier/geoverifier/VersionGEOVerifier.xml alwaysupdate;"
llaveSUSE

for line in $(cat servidores.txt);
do
        nroLocal=$(echo $line | cut -d ',' -f1)
        nodoLocal=$(echo $line | cut -d ',' -f2)
        ipLocal=$(echo $line | cut -d ',' -f3 | tail -n1 )

         

        log "LOCAL TRABAJANDO..... $nroLocal"

        ping -c 3 $ipLocal
        if [ $? -ne 0 ]; then
                echo ",,, FCV_$nroLocal, $ipLocal, Local_Sin_ping" >> Final.csv
        else

                so=$(setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null -oConnectTimeout=8 -oServerAliveInterval=120 root@$ipLocal 'lsb_release -i | cut -c 17-20' 2> /dev/null) &>/dev/null
                if [[ -z $so ]] ; then
               
                        llaveOL
                else
                        if [ $so = SUSE ] ; then

                                llaveSUSE
                        else         
                                llaveOL
                        fi
                fi


                trap 'echo "Pipe has broken, but we´re not going to crash and burn!" >&2' PIPE


                ##MATO TODOS LOS PROCESOS REFERENTES A JAVA
                echo ""
   
                validaImagenLocal
                      

        valido $?

        fi

llaveSUSE
done












        





















