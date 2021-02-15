#!/bin/bash
cp ./src/MNote2 ./mnote2/usr/bin/
dpkg-deb --build mnote2
mv mnote2.deb mnote2-2.8_amd64.deb
cp ./mnote2-2.8_amd64.deb ./bin/

