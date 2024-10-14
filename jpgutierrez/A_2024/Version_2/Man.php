<?php
// Configuración
$fecha = date('Y-m-d-H-i-s');
$fcv = $_POST['fcv'] ?? '';
$op = $_POST['op'] ?? '';
$manifiesto = $_POST['manifiesto'] ?? '';
$estado1 = '';
$estado = '';
$ipLocal = '';

// Función para ejecutar la consulta a la base de datos central
function runQueryGeoposCentral($query) {
    global $fcv, $ipLocal;
    $classPath = 'lib/jisql-2.0.11.jar:lib/jopt-simple-3.2.jar:lib/ojdbc-14.jar';
    $dbDriver = 'oracle.jdbc.driver.OracleDriver';
    $dbIp = '10.193.20.93';
    $dbPassword = 'geocom2012';
    $dbUser = 'geopos2cruzverde';
    $dbSn = 'pgpos';
    $dbUrl = 'jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=pgpos.ora.difarma.cl)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=pgpos_srv)))';

    if (empty($query)) {
        echo "ERROR. Uso correcto: no se envio la query<br>";
        return;
    }

    $command = "java -Xmx512M -XX:MaxPermSize=512m -XX:PermSize=128m -classpath $classPath com.xigole.util.sql.Jisql -user $dbUser -password $dbPassword -driver $dbDriver -cstring $dbUrl -c \; -query \"$query\"";
    $output = [];
    exec($command, $output);
    
    file_put_contents("aux_$fcv", implode("\n", $output));
    $lines = file("aux_$fcv");
    $filteredLines = array_slice($lines, 2);
    file_put_contents("cajas_$fcv.txt", implode("", $filteredLines));

    $ipLocal = trim(shell_exec("awk -F',' '{print $3}' cajas_$fcv.txt"));
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if ($op == 1) {
        runQueryGeoposCentral("select LOCALID ||','|| NODE || ',' || IPADDRESS from nodes where NODE = 99 and ACTIVE = 1 and LOCALID=$fcv;");

        if (shell_exec("ping -q -c1 $ipLocal > /dev/null")) {
            echo "Obtengo Manifiesto y bultos...<br>";

            $mani = shell_exec("mysql -pgeocom --connect-timeout=2 --skip-column-names -h$ipLocal cvinventarios -e 'select * from cvmanifiesto where CVManifiestoCodigo=$manifiesto'");
            file_put_contents("Manifiesto_antes.txt", "Manifiesto : $manifiesto<br><br>$mani<br><br>Bultos con manifiesto : $manifiesto<br><br>");

            $bulto = shell_exec("mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e 'select * from cvbulto where CVManifiestoCodigo=$manifiesto'");
            file_put_contents("Manifiesto_antes.txt", file_get_contents("Manifiesto_antes.txt") . "$bulto<br>");

            // Armo insert obteniendo los datos de cada campo
            $fields = [
                'CVManifiestoCodigo',
                'CVLocalesId',
                'CVManifiestoFechaGeneracion',
                'CVManifiestoEstado',
                'CVManifiestoMatriculaTransport',
                'CVManifiestoUtilizadoAutorizac',
                'CVManifiestoTipoRecepcion',
                'CVManifiestoFechaRecepcion'
            ];
            $values = [];
            foreach ($fields as $field) {
                $result = shell_exec("mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e 'select $field from cvmanifiesto where CVManifiestoCodigo=$manifiesto'");
                $values[] = trim($result);
            }

            $sql = "INSERT INTO cvinventarios.cvmanifiesto(CVManifiestoCodigo, CVLocalesId, CVManifiestoFechaGeneracion, CVManifiestoEstado, CVManifiestoMatriculaTransport, CVManifiestoUtilizadoAutorizac, CVManifiestoTipoRecepcion, CVManifiestoFechaRecepcion) VALUES (99$manifiesto, $values[1], '$values[2]', '$values[3]', '$values[4]', $values[5], '$values[6]', '$values[7]')";
            shell_exec("mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e \"$sql\"");

            shell_exec("mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e 'update cvbulto set CVManifiestoCodigo=99$manifiesto where CVManifiestoCodigo=$manifiesto'");
            shell_exec("mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e 'delete from cvmanifiesto where CVManifiestoCodigo=$manifiesto'");

            $mani = shell_exec("mysql -pgeocom --connect-timeout=2 --skip-column-names -h$ipLocal cvinventarios -e 'select * from cvmanifiesto where CVManifiestoCodigo=99$manifiesto'");
            file_put_contents("Manifiesto_despues.txt", "Manifiesto :99$manifiesto<br><br>$mani<br><br>Bultos con manifiesto :99$manifiesto<br><br>");

            $bulto = shell_exec("mysql -pgeocom --connect-timeout=2 --skip-column-names -h$ipLocal cvinventarios -e 'select * from cvbulto where CVManifiestoCodigo=99$manifiesto'");
            file_put_contents("Manifiesto_despues.txt", file_get_contents("Manifiesto_despues.txt") . "$bulto<br>");

            echo "Finalizado con Exito, Recuerde subir evidencia a Mantis....<br>";
            rename("Manifiesto_despues.txt", "Manifiesto_despues_FCV-$fcv_$fecha.txt");
            rename("Manifiesto_antes.txt", "Manifiesto_antes_FCV-$fcv_$fecha.txt");
        } else {
            echo "Local Fuera de Linea<br>";
        }
    } elseif ($op == 2) {
        runQueryGeoposCentral("select LOCALID ||','|| NODE || ',' || IPADDRESS from nodes where NODE = 99 and ACTIVE = 1 and LOCALID=$fcv;");

        $manifiestoest = $_POST['manifiestoest'] ?? '';
        $estado = $_POST['estado'] ?? '';

        switch ($estado) {
            case 1:
                $estado1 = 'pendiente';
                break;
            case 2:
                $estado1 = 'procesado';
                break;
            case 3:
                $estado1 = 'en_proceso';
                break;
        }

        if (shell_exec("ping -q -c1 $ipLocal > /dev/null")) {
            $mani = shell_exec("mysql -pgeocom --connect-timeout=2 --skip-column-names -h$ipLocal cvinventarios -e 'select * from cvmanifiesto where CVManifiestoCodigo=$manifiestoest'");
            file_put_contents("Manifiesto_antes.txt", "Manifiesto : $manifiestoest<br><br>$mani<br>");

            $cvManifiestoEstado = trim(shell_exec("mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e 'select CVManifiestoEstado from cvmanifiesto where CVManifiestoCodigo=$manifiestoest'"));
            echo "El estado actual es :$cvManifiestoEstado<br>";

            shell_exec("mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e 'update cvmanifiesto set CVManifiestoEstado=\"$estado1\" where CVManifiestoCodigo=$manifiestoest'");

            $mani1 = shell_exec("mysql -pgeocom --connect-timeout=2 --skip-column-names -h$ipLocal cvinventarios -e 'select * from cvmanifiesto where CVManifiestoCodigo=$manifiestoest'");
            $cvManifiestoEstadodesp = trim(shell_exec("mysql -pgeocom --connect-timeout=2 -N -h$ipLocal cvinventarios -e 'select CVManifiestoEstado from cvmanifiesto where CVManifiestoCodigo=$manifiestoest'"));

            file_put_contents("Manifiesto_despues.txt", "Manifiesto :$manifiestoest<br><br>$mani1<br>");
            echo "Despues del cambio es : $cvManifiestoEstadodesp<br>";

            rename("Manifiesto_despues.txt", "Manifiesto_despues_FCV-$fcv_$fecha.txt");
            rename("Manifiesto_antes.txt", "Manifiesto_antes_FCV-$fcv_$fecha.txt");
        } else {
            echo "Local Fuera de Linea<br>";
        }
    }

    // Limpieza
    array_map('unlink', glob("aux_*"));
    array_map('unlink', glob("cajas_*"));
    array_map('unlink', glob("temp_*"));
} else {
    echo '<form method="post">
            <label for="fcv">Ingrese Nº de Local:</label>
            <input type="text" id="fcv" name="fcv" required><br>
            <label for="op">Que desea realizar:</label><br>
            <input type="radio" id="op1" name="op" value="1" required>
            <label for="op1">Renombrar Manifiesto</label><br>
            <input type="radio" id="op2" name="op" value="2" required>
            <label for="op2">Cambiar Estado al Manifiesto</label><br>
            <input type="submit" value="Ejecutar">
        </form>';
}
?>
