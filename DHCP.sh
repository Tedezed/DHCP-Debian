#Ejercicio 22
#!/bin/bash
#By Tedezed
#Script para red

idveri=$(id | egrep -o 'uid=0')
if [ "$idveri" != "uid=0" ]
then
	echo "Este script necesita permisos de root"
	echo "Intentalo de nuevo como root"
else
	seedhcp=$(dpkg -l | egrep 'isc-dhcp-server')
	if [ "$seedhcp" == ""  ]
	then
		llave=0
		while [ $llave == 0 ]
		do
			ping -c 1 8.8.8.8
			pingnet=$(echo $?)
			if [ $pingnet == 0 ]
			then
				clear
				echo "Paquete 'isc-dhcp-server' necesario no encontrado"
				read -p "Pulsa para continuar e instalar..."
				apt-get update
				apt-get install isc-dhcp-server
				llave=1
			else
				clear
				echo "ERROR: No se a podido conectar con internet."
				echo "Intentelo de nuevo cuando tenga conecxion"
				read -p "Pulsa para continuar e instalar..."
				clear

			fi
		done
	fi
	direc=$(pwd)
	clear
	echo "----------------------------------------"
	echo "|                                      |"
	echo "|          -Servidor DHCP-             |"
	echo "|                                      |"
	echo "----------------------------------------"
	echo "Iniciando configuracion de Servidor DHCP"
	read -p "Pulsa para continuar e instalar..."
	llave=0
	while [ $llave == 0 ]
	do
		clear
		echo "Interfaces del Sistema: "
		/sbin/ifconfig | egrep -o '^[a-z].......' > log
		cat log
		read -p "Introduce la interfaz que se va a utilizar: " interfz
		for i in $(cat log)
		do
			if [ $interfz == $i ]
			then
				llave=1
			fi
		done

		if [ $llave == 0 ]
		then
			echo 'ERROR: interfaz no encontrada, introduce una interfaz del sistema'
			read -p "Pulsa para continuar e instalar..."
		fi
	done
	llave=0
	while [ $llave == 0 ]
	do
		clear
		read -p "Introduce la IP del servidor (Ej:192.168.0.1): " ipserver
		clear
		read -p "Introduce la red (Ej:192.168.0.0): " ipnet
		clear
		read -p "Introduce la mascara de red (Ej:255.255.255.0): " maskip
		clear
		read -p "Introduce la IP inicial a repartir (Ej:192.168.0.2): " ipini
		clear
		read -p "Introduce la IP final a repartir (Ej:192.168.0.254): " ipfin
		clear
		read -p "Introduce el DNS primario (Ej:8.8.8.8): " dom1
		clear
		read -p "Introduce el DNS secundario (Ej:8.8.4.4): " dom2
		clear
		echo 'Aplicando configuracion a interfaz'
		ifconfig $interfz $ipserver netmask $maskip
		echo 'Resultado de la configuracion:'
		ifconfig $interfz
		read -p "Pulsa para continuar e instalar..."
		clear

		echo 'Aplicando configuracion de servidor'
		echo 'INTERFACES="'$interfz'"' > /etc/default/isc-dhcp-server
		echo "ddns-update-style none;" > /etc/dhcp/dhcpd.conf
		echo 'option domain-name "DHCP.DNS";' >> /etc/dhcp/dhcpd.conf
		echo "option domain-name-servers "$dom1", "$dom2";" >> /etc/dhcp/dhcpd.conf
		echo "default-lease-time 600;" >> /etc/dhcp/dhcpd.conf
		echo "max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf
		echo "authoritative;" >> /etc/dhcp/dhcpd.conf
		echo "log-facility local7;" >> /etc/dhcp/dhcpd.conf
		echo >> /etc/dhcp/dhcpd.conf
		echo "subnet "$ipnet" netmask "$maskip" {" >> /etc/dhcp/dhcpd.conf
		echo "range "$ipini" "$ipfin";" >> /etc/dhcp/dhcpd.conf
		echo "option routers "$ipserver";" >> /etc/dhcp/dhcpd.conf
		echo "}" >> /etc/dhcp/dhcpd.conf

		service isc-dhcp-server restart
		okdhcp=$(echo $?)
		if [ $okdhcp == 0 ]
		then
			llave=1
		fi
		if [ $okdhcp == 1 ]
		then
			clear
			echo 'ERROR: Se a producido un error al al aplicar configuracion DHCP'
			llave1=0
			while [ $llave1 == 0 ]
			do
			read -p "Desea introducir de nuevo la configuracion? (s/n): " respuser
				if [ $respuser == s -o $respuser == n ]
				then
					if [ $respuser == s ]
					then
						llave1=1
					fi
					if [ $respuser == n ]
					then
						llave1=1
						llave=1
					fi
				fi
			done
		fi
	done
		service isc-dhcp-server status
fi
