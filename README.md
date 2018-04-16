# <h1 align="center"><span>(docker-compose) </span>Container Space Program</h1>

### Prerequisites

1. GNU/Linux development environment
    + Node.js, MongoDB
    + Docker & docker-compose (snap or repo version)
3. CentOS 7 production server
---
### Container status check
<ul>
    <li>https://csp.jagdcake.com</li>
</ul>

---
### Checklist

<p>[X]<span> Secure the launch pad (create non-root user, set up SSH) by following <strong><a href="./basicSecurity.md">basicSecurity.md</a></strong></span></p>

<p>[X]<span> Set up and secure the control center (update packages, set up firewall, install fail2ban, install docker) by following <strong><a href="./setUpCentOS7.md">setUpCentOS7.md</a></strong></span></p>

<p>[X]<span> Send container to launch pad (copy production dir to Vultr VPS) via <strong><a href="./transferFiles.sh">transferFiles.sh</a></strong></span></p>

<p>[X]<span> Secure the container (create mongoDB admin user, enable --auth) via <strong><a href="./containerSecurity.sh">containerSecurity.sh</a></strong></span></p>

<p>[X]<span> Start it up ('build' & 'up -d') and do a pre-launch check (check services for any errors) with <strong><a href="./startDocker.sh">startDocker.sh</a></strong> via <strong><a href="./containerSecurity.sh">containerSecurity.sh</a></strong></span></p>

<p>[X]<span> Launch:</span></p>
    <ol>
    <li>https://modeling.jagdcake.com</li>
    <li>https://dreams.jagdcake.com</li>
    </ol>



