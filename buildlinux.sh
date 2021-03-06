#!/bin/bash
ARQUITETURA=$(uname -m)
case $(uname -m) in
	i386) 	ARQUITETURA="i386";;
	i686) 	ARQUITETURA="i386";;
	x86_64)	ARQUITETURA="amd64";;
	arm) 	ARQUITETURA="arm";;
esac

echo $ARQUITETURA

if [ $ARQUITETURA = 'amd64' ]; 
then
	echo "AMD64 Script"
	echo "Preparando binarios"
	cp ./src/MNote2 ./mnote2/usr/bin/mnote2
	chmod 777 ./mnote2/usr/bin/mnote2
	cp ./src/MNote2.png ./mnote2/usr/share/icons/hicolor/mnote2.png
	cp ./mnote2.desktop_arm ./mnote2/usr/share/applications/mnote2.desktop
	#ln -s /usr/bin/MNote2 ./mnote2/usr/share/applications/mnote2
	echo "Empacotando"
	dpkg-deb --build mnote2
	echo "Movendo para pasta repositorio"
	mv mnote2.deb mnote2-2.9_amd64.deb
	cp ./mnote2-2.9_amd64.deb ./bin/
	exit 1;
fi

if [ $ARQUITETURA = 'i686' ];
then
	echo "i686 Script"
	echo "Preparando binarios"
	cp ./src/MNote2 ./mnote2/usr/bin/mnote2
	chmod 777 ./mnote2/usr/bin/mnote2
	cp ./src/MNote2.png ./mnote2/usr/share/icons/hicolor/mnote2.png
	cp ./mnote2.desktop_arm ./mnote2/usr/share/applications/mnote2.desktop
	#ln -s /usr/bin/MNote2 ./mnote2/usr/share/applications/mnote2
	echo "Empacotando"
	dpkg-deb --build mnote2
	echo "Movendo para pasta repositorio"
	mv mnote2.deb mnote2-2.9_i686.deb
	cp ./mnote2-2.9_i686.deb ./bin/
	exit 1;
fi

if [ $ARQUITETURA = 'i386' ];
then
	echo "i386 Script"
	echo "Preparando binarios"
	cp ./src/MNote2 ./mnote2/usr/bin/mnote2
	chmod 777 ./mnote2/usr/bin/mnote2
	cp ./src/MNote2.png ./mnote2/usr/share/icons/hicolor/mnote2.png
	cp ./mnote2.desktop_arm ./mnote2/usr/share/applications/mnote2.desktop
	#ln -s /usr/bin/MNote2 ./mnote2/usr/share/applications/mnote2
	echo "Empacotando"
	dpkg-deb --build mnote2
	echo "Movendo para pasta repositorio"
	mv mnote2.deb mnote2-2.9_i386.deb
	cp ./mnote2-2.9_i386.deb ./bin/
	exit 1;
fi

if [ $ARQUITETURA =  'armv7l' ]; then
	echo "ARM Script"
	echo "Preparando binarios"
	cp ./src/MNote2 ./mnote2/usr/bin/mnote2
	chmod 777 ./mnote2/usr/bin/mnote2
	#ln -s /usr/bin/MNote2 ./mnote2/usr/bin/mnote2
	cp ./src/MNote2.png ./mnote2/usr/share/icons/hicolor/mnote2.png
	cp ./mnote2.desktop_arm ./mnote2/usr/share/applications/mnote2.desktop
	echo "Empacotando"
	dpkg-deb --build mnote2
	echo "Movendo para pasta repositorio"
	mv mnote2.deb mnote2-2.9_arm.deb
	cp ./mnote2-2.9_arm.deb ./bin/	
	exit 1;
fi
