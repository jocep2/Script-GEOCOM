#!/bin/bash
#FUNCIONES

#
#
#956 pro
#612fra
#786pro0
#777pro
#135pro
#
#
#3
#
#
#
#
#
#
#f
#
#, utiliza la
#
#
#

#ohola
#
#
#Crea Log

function validaImagenLocal()
{
        ping -q -c1 $ipLocal > /dev/null
        if [ $? -eq 0 ]; then
            echo "Validando imagen del local..."
            # Obtener el hostname completo y extraer el número de local
            hostname=$(setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "hostname -f")
            local_number=$(echo $hostname | grep -oP '(?<=fcv)\d+')
            
            # Obtener las últimas 5 líneas del archivo ControlImage.txt
            controlImage=$(setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "tail -n 5 /home/geocom/ControlImage.txt")
            
            # Guardar el resultado en un archivo local para cada local del ciclo
            echo "$controlImage" > "ControlImage_${local_number}_$fecha.txt"
            
            echo "Las últimas 5 líneas de ControlImage.txt han sido guardadas en ControlImage_${local_number}_$fecha.txt"
        else
            echo "Local Fuera de Linea"
        fi


}

function log ()
{
        log_date=$(date +%Y-%m-%d-%H-%M);
        echo "$log_date - $1"
        echo "$log_date - $1" >> $(basename "$0" ".sh").log
}


function proIdentifier() 
{
        setupLocal="$nroLocal"
        setupPart3="sed -i 's/=1000/=${setupLocal}/g' /home/geocom/InstallScripts/setup.ini"
        #######
        if [[ ${#nroLocal} -eq 4 ]]; then
            echo "El número de local tiene 4 caracteres."
            #sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.8610.9\\${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties;"
            sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.8610.9${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties"
            # Verifica si setupLocal tiene exactamente 3 caracteres 
        elif [[ ${#nroLocal} -eq 3 ]]; then
            echo "El número de local tiene 3 caracteres."
            #sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.8610.90\\${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties;"
            sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.8610.90${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties"
        else
            echo "El número de local tiene 2 caracteres."
            #sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.8610.900\\${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties;"
            sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.8610.900${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties"
        fi

}

function fraIdenfier() 
{
        setupLocal="$nroLocal"
        setupPart3="sed -i 's/=1000/=${setupLocal}/g' /home/geocom/InstallScripts/setup.ini"
        #######
        if [[ ${#nroLocal} -eq 4 ]]; then
            echo "El número de local tiene 4 caracteres."
            #sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.8610.9\\${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties;"
            sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.franquicias.9${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties"
            # Verifica si setupLocal tiene exactamente 3 caracteres 
        elif [[ ${#nroLocal} -eq 3 ]]; then
            echo "El número de local tiene 3 caracteres."
            #sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.8610.90\\${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties;"
            sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.franquicias.90${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties"
        else
            echo "El número de local tiene 2 caracteres."
            #sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.8610.900\\${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties;"
            sedIdentifiePro="sed -i 's/root.PreProd.1000.99/root.fraqnuicias.900${setupLocal}\\.99/g' /home/geocom/geoconfigurator/geoconfigurator/cfg/client/identifier.properties"
        fi

}


valido ()
{
if [ $1 -eq 0 ]; then
       log "SALIDA: OK"
        echo "SALIDA: " >> OK
    else
       log "SALIDA:ERROR"
        echo "SALIDA: " >> ERROR
fi
}

#Ejecuto comando
runCommand ()
{
    local ip=$1
    local comm=$2
    setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null -oConnectTimeout=8 $USER@$ip "$comm"
}

#Variables llave promotion fcv ambiente pre y prod
function llaveSUSE ()
{
        #VERIFICO CLAVE PRIVADA
        KEY="/root/.ssh/id_dsa.pub"
        if [ ! -f ~/.ssh/id_dsa.pub ];then
                echo "private key not found at $KEY"
                echo "* please create it with "ssh-keygen -t dsa" *"
                echo "* to login to the remote host without a password, don't give the key you create with ssh-keygen a password! *"
                exit
        fi
        USER="root"
        PASSWD="cverde2011"
        SSH_ASKPASS_SCRIPT=./ssh-askpass-script
        cat > ${SSH_ASKPASS_SCRIPT} <<EOF
#!/bin/bash
echo "${PASSWD}"
EOF
        chmod 755 ${SSH_ASKPASS_SCRIPT}
        export DISPLAY=:0
        export SSH_ASKPASS=${SSH_ASKPASS_SCRIPT}
}

#Variables llave promotion mco ambiente pre y prod
function llaveOL ()
{
        #VERIFICO CLAVE PRIVADA
        KEY="/root/.ssh/id_dsa.pub"
        #EL SIGUIENTE IF VALIDA SI SE ENCUENTRA LA CLAVE PUBLICA EN EL DIRECTORIO, si no mandara un mensaje para generar contraseña
        if [ ! -f ~/.ssh/id_dsa.pub ];then
                echo "private key not found at $KEY"
                echo "* please create it with "ssh-keygen -t dsa" *"
                echo "* to login to the remote host without a password, don't give the key you create with ssh-keygen a password! *"
                exit
        fi
        #crea las siguientes variables y genera unscript temporal, 
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
}



#FIN FUNCIONES
