# <h1 align="center"><span>(docker-compose) </span>Container Space Program</h1>
## Superseded by https://github.com/JagdCake/ansible.playbooks

### Prerequisites

1. GNU/Linux development environment
    + Node.js
    + PostgreSQL
    + Docker & docker-compose (snap or repo version)
3. CentOS 7 production server

### Checklist

<p>[X]<span> Secure the launch pad (create non-root user, set up SSH) by following <strong><a href="./basic_security.md">basic_security.md</a></strong></span></p>

<p>[X]<span> Set up and secure the control center (update packages, set up firewall, install fail2ban, install docker) by following <strong><a href="./set_up_centos_7.md">set_up_centos_7.md</a></strong></span></p>

<p>[X]<span> Send container to launch pad (copy production branch to server) via <strong><a href="./transfer_files.sh">transfer_files.sh</a></strong></span></p>
<ul>
    <li><p>[X]<span> Update container data (transfer database table to server) via <strong><a href="./transfer_table.sh">transfer_table.sh</a></strong></span></p></li>
</ul>

<p>[X]<span> Launch:</span></p>
<ol>
    <li>https://modeling.jagdcake.com</li>
    <li>RETIRED <span style="text-decoration: line-through">https://dreams.jagdcake.com</span></li>
    <li>RETIRED <span style="text-decoration: line-through">https://request.jagdcake.com</span></li>
</ol>
