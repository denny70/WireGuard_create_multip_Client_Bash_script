# WireGuard_create_multip_Client_Bash_script

Two Scripts are used to create WireGuard User/Client configure file.

1) It can be used User name List to create WireGuard configure Server and Many Users configure files at One time
1-1) To set up the right variable for 
  - serverPort
  - serverIP
  - clientList
The content of script which need to be modified
#====== need to modify information when you create new config file
severConfigName=wg0
severPort=51825
serverIP=111.222.333.444:$severPort
clientList="client-1 client-2 client-3 client-4"
#======

1-2) run script
~$ ./create_WG_sever_clients.sh
the example will generate Server config file(wg0.conf) and Client config files(client-1.conf client-2.conf client-3.conf client-4.conf)


2) To use this script to add new user at Server Configure file and create new user configure file
~$ create_WG_one_client 10 Denny
  - because WG will have provate IP address. 10.0.0.1, 10.0.0.2 etc..., the "10" is the the last byte of IP, 
    it will update wg0.conf(server file) and create new slient file (wg-10-Denny.conf)

