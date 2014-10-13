#By: Tedezed
#Python 2.7
#DHCP INFO para isc-dhcp-server en debian

import re
import sys
import commands

def ip_all(metodo):
	#IP RESERVADA
	if metodo == 0:
		info_metodo = "/// INFO-0001: IP reservadas:"
		error_metodo = "ERROR-0001: No se encontro ninguna IP reservada."
		comando = "cat /etc/dhcp/dhcpd.conf"
		ex_1 = 'host.*[\na-zA-Z0-9-_.:; ]*'
		ex_2 = 'hardware ethernet [a-zA-Z0-9:]*'
		rem_ex_2 = 'hardware ethernet '
		ex_3 = 'fixed-address [0-9.]*'
		rem_ex_3 = 'fixed-address '
	#IP CONCEDIDAS
	if metodo == 1:
		info_metodo = "/// INFO-0002: Concesiones de IP:"
		error_metodo = "ERROR-0002: No se encontro ninguna concesion de ip."
		comando = "cat /var/lib/dhcp/dhcpd.leases"
		ex_1 = 'lease [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*.*[\na-zA-Z0-9-_.:;/ ]*'
		ex_2 = ' hardware ethernet [a-zA-Z0-9:]*'
		rem_ex_2 = ' hardware ethernet '
		ex_3 = 'lease [0-9.]*'
		rem_ex_3 = 'lease '

	#EJECUCION DEL METODO
	ip_comand = commands.getoutput(comando)
	list_ip = re.findall(ex_1, ip_comand)
	if list_ip:
		print info_metodo
		contador = 0
		dic_final = {}
		for x in list_ip:
			list_elemento = []
			pc_ip = re.findall(ex_3, x)
			pc_ip = pc_ip[0].replace(rem_ex_3,'')
			pc_mac = re.findall(ex_2, x)
			pc_mac = pc_mac[0].replace(rem_ex_2,'')
			list_elemento.append(pc_ip)
			list_elemento.append(pc_mac)
			dic_final['ip'+str(contador)] = list_elemento
			contador += 1
	else:
		print error_metodo
		dic_final = ""
	print ""
	return dic_final

#INICIO DEL PROGRAMA
print commands.getoutput('clear')			
print """////////////////////////////////////
/	DHCP INFO: By Tedezed	   /
////////////////////////////////////
/    Para Debian isc-dhcp-server   /
////////////////////////////////////
"""
#NUMERO DE PARAMETROS
if len(sys.argv) == 2:
	#CON 1 PARAMETRO
	ip = sys.argv[1]
	print "IP introducida: " + ip
	dic = ip_all(1)
	chek = 0
	for i in dic:
		ip_dic = dic[i][0]
		if ip_dic == ip:
			print "INFO-0003: IP "+ ip +" esta concedida a la mac: " + dic[i][1]
			chek = 1
	if chek == 0 and dic != "":
		print "INFO-0004: La IP "+ ip +" esta libre."
elif len(sys.argv) < 2:
	#CON 0 PARAMETRO
	llave = 0
	while llave < 2:
		dic = ip_all(llave)
		llave += 1
		for i in dic:
			print "IP: " + dic[i][0]
			print "MAC: " + dic[i][1]
			print ""
if len(sys.argv) > 2:
	#CON MAS DE 1 PARAMETRO
	print "ERROR-0003: Parametros fuera de rango."
