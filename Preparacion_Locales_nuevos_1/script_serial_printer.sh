#!/bin/bash

cd /home/geocom

tar -xzvf sewoo_jpos_release_211115.tar.gz

cp -r /home/geocom/geopos/files /home/geocom/geopos/files_bak

cp /home/geocom/sewoo_jpos_release_211115/jcl.jar /home/geocom/geopos/files/
cp /home/geocom/sewoo_jpos_release_211115/jpos18.jar /home/geocom/geopos/files/
cp /home/geocom/sewoo_jpos_release_211115/jpos18-controls.jar /home/geocom/geopos/files/
cp /home/geocom/sewoo_jpos_release_211115/sewoojpos.jar /home/geocom/geopos/files/
cp /home/geocom/sewoo_jpos_release_211115/xerces.jar /home/geocom/geopos/files/
cp /home/geocom/sewoo_jpos_release_211115/xercesImpl.jar /home/geocom/geopos/files/
cp /home/geocom/sewoo_jpos_release_211115/jai_core.jar /home/geocom/geopos/files/
cp /home/geocom/sewoo_jpos_release_211115/jai_codec.jar /home/geocom/geopos/files/

cp /home/geocom/sewoo_jpos_release_211115/sewoojpos.jar /home/geocom/geopos/files/Sewoo-LKT202USB/sewoojpos-1.0.1.jar

rm -rf sewoo_jpos_release_211115.tar.gz sewoo_jpos_release_211115