#### Update packages 
    yum check-update
    sudo yum update
___
#### Extra packages
    sudo yum install epel-release -y
___
#### UFW 
    sudo yum install ufw
    sudo ufw enable
___
#### UFW SSH
    sudo ufw allow from <static IP> to any port 22
    sudo ufw delete SSH
___
#### fail2ban
    sudo yum install fail2ban
    sudo systemctl start fail2ban
    sudo systemctl enable fail2ban
___
#### fail2ban config   
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    nano /etc/fail2ban/jail.local
        Uncomment 
            "#[sshd]
             #enabled = true"
        "backend = systemd" 
        "bantime = 604800" # 7 days
        "maxretry = 2"
        "ignore ip = 127.0.0.1/8 <static IP>"  
    sudo fail2ban-client reload
___
#### docker / docker-compose
    sudo yum install docker
    sudo yum install docker-compose
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo chown <username> /var/run/docker.sock # prevents 'docker-compose' permission error
___
##### Sources:
https://linuxconfig.org/how-to-install-and-use-ufw-firewall-on-linux

http://www.the-lazy-dev.com/en/install-fail2ban-with-docker/

https://linode.com/docs/security/using-fail2ban-for-security/
