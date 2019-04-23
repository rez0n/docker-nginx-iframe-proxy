# docker-nginx-iframe-proxy
Preconfigured nginx image to proxy sites for iframe ([Chromecast-Kiosk](https://github.com/mrothenbuecher/Chromecast-Kiosk), [DashKiosk](https://github.com/vincentbernat/dashkiosk) and other stuff.

nginx build with 
* [set_misc_nginx_module](https://github.com/openresty/set-misc-nginx-module)
* [headers_more_nginx_module](https://github.com/openresty/headers-more-nginx-module)
* http_sub_module

**Run**
```
docker run --name nginx -p 80:80 -d rez0n/nginx-iframe-proxy
```
For more configuring flexibility you can forward config from the host machine like this (edit config in your local fs, then restart container)
```
docker run --name nginx -p 80:80 -v nginx.conf:/etc/nginx/nginx.conf:ro -d rez0n/nginx-iframe-proxy
```
**Usage**

Make requests to http://127.0.0.1/r?uri=
```
<iframe src="http://127.0.0.1/r?uri=https://google.com" width="1500px" height="800px" frameborder="1" ></iframe>
```