# <h1 align="center"><span>(docker-compose) </span>Container Space Program</h1>
<p>[ ]<span> Secure the launch pad (create non-root user, set up SSH, disable password auth, set up firewall, install fail2ban) via <strong>basicSecurity.sh</strong></span></p>

<p>[X]<span> Send container to launch pad (copy production dir to Vultr VPS) via <strong>transferFiles.sh</strong></span></p>

<p>[X] <span>Secure the container (create mongoDB admin user, enable --auth) via <strong>containerSecurity.sh</strong></span></p>

<p>[X]<span> Start it up ('build' & 'up -d') and do a pre-launch check (check services for any errors) with <strong>startDocker.sh</strong> via <strong>containerSecurity.sh</strong></span></p>

<p>[ ]<span> Launch https://modeling.jagdcake.com</span></p>



