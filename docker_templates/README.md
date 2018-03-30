<h1 align="center">Production directory structure template</h1>

1. Required files
+ *app*.js
+ [startDocker.sh](../startDocker.sh)
+ [Dockerfile](./Dockerfile)
+ [docker-compose.yml](./docker-compose.yml)
+ [setUpProduction.yml](./setUpProduction.yml)
+ [production.yml](./production.yml)
+ package.json
+ yarn.lock
___
2. Required folders
+ __nginx/__
    + __certs/__
    + __html/__
    + __vhost/__
    ---
    3. Optional file
    + nginx.conf
___
4. Optional folder
+ __dump/__ (database dump)
___
5. Default NodeJS app directory structure 
+ __data/__ (database data from development)
+ __public/__
    + *.css
    + *.js
    + *.png
    + *.svg
    + sitemap.xml
+ __views/__
    + *.ejs
    + __partials/__
        + *.ejs
+ __models/__
    + *.js
+ __middleware/__
    + index.js
 