#!/bin/bash
# Código existente...

echo "Que desea realizar :"
 
echo "1 .- Renombrar Manifiesto" 
echo "2 .- Cambiar Estado al Manifiesto" 
echo "3 .- Realizar Full - Locales OL."
echo "4 .- Bajar video."
echo "5 .- Desbloquear Usuario"
echo "6 .- Comparar ControlImage.txt"

read -p 'Escoga Opcion: ' OP

# Código existente...

if [ $OP -eq 6 ]; then
    read -p 'Ingrese Nº de Local FCV: ' fcv

    # Obtener IP del local
    run_query_geopos_central "select LOCALID ||','|| NODE || ',' || IPADDRESS from nodes where NODE = 99 and ACTIVE = 1 and LOCALID=$fcv;"

    # Verificar conexión
    ping -q -c1 $ipLocal > /dev/null
    if [ $? -eq 0 ]; then
        # Crear archivo temporal en el servidor remoto
        setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "tail -n 5 /home/geocom/ControlImage.txt > /home/geocom/ControlImage_FCV${fcv}.txt"

        # Descargar el archivo temporal
        wget -q "http://$ipLocal:8084/home/geocom/ControlImage_FCV${fcv}.txt" -O "ControlImage_FCV${fcv}.txt"

        # Eliminar archivo temporal del servidor remoto
        setsid ssh -oStrictHostKeyChecking=no -oLogLevel=error -oUserKnownHostsFile=/dev/null root@$ipLocal "rm /home/geocom/ControlImage_FCV${fcv}.txt"
    
        echo "Últimas 5 líneas de ControlImage.txt del FCV$fcv:"
        cat "ControlImage_FCV${fcv}.txt"

        echo "Comparando con ControlImage.txt local:"
        if [ -f "ControlImage.txt" ]; then
            diff -u "ControlImage.txt" "ControlImage_FCV${fcv}.txt"
        else
            echo "El archivo ControlImage.txt no existe en el directorio local."
        fi
    else
        echo "No se pudo conectar al local FCV$fcv"
    fi
fi

# Código existente...