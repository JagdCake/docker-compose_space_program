# <h1 align="center"><span style="font-size:0.7rem; vertical-align:middle">(docker-compose)</span>Container Space Program</h1>

<p><input type="checkbox"><span>Secure the launch pad (create non-root user, set up SSH, disable password auth, set up firewall, install fail2ban) via <strong>basicSecurity.sh</strong></span></p>

<p><input type="checkbox"><span>Send container to launch pad (copy production dir to Vultr VPS) via <strong>transferFiles.sh</strong></span></p>

<p><input type="checkbox"><span>Secure the container (create mongoDB admin user, enable --auth, create environment variables) via <strong>containerSecurity.sh</strong></span></p>

<p><input type="checkbox" checked><span>Start it up ('build' & 'up -d') via <strong>startDocker.sh</strong></span></p>

<p><input type="checkbox"><span>Pre-launch check ('Let's encrypt', uncomment CSP) via <strong>moreSecurity.sh</strong></span></p>

<p><input type="checkbox"><span>Launch (https://modeling.jagdcake.com/) via <strong>startDocker.sh</strong> (hopefully improved)</span></p>



