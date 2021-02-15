#!/bin/bash
cp ./src/MNote2 ./mnote2/usr/bin/
cp ./src/MNote2.ico ./mnote2/usr/share/icons/hicolor/
ln -s ./src/MNote2 ./mnote2/usr/applications/
dpkg-deb --build mnote2
mv mnote2.deb mnote2-2.8_amd64.deb
cp ./mnote2-2.8_amd64.deb ./bin/

