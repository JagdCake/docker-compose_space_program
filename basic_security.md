#### Create new user
	ssh root@<server IP> useradd <username>
	ssh root@<server IP> passwd <username>
___
#### Set up root privileges
	ssh root@<server IP> gpasswd -a <username> wheel
___
#### Set up SSH 
	ssh-keygen # generate key pair IF you don't have one
	ssh-copy-id <username>@<server IP> # install the public key 
___
#### Configure SSH
	nano /etc/ssh/sshd_config
		Uncomment "#PermitRootLogin yes" and Change it to "PermitRootLogin no"
		Add line: "AllowUsers <username>"
	sudo service sshd restart OR sudo systemctl reload sshd
___
##### Sources:
https://www.digitalocean.com/community/tutorials/initial-server-setup-with-centos-7

https://wiki.centos.org/HowTos/Network/SecuringSSH
