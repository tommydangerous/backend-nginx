## Nginx Server

#### Run Nginx container and link other containers
```
$ docker build -t nginx .
$ docker run -d -p 80:80 --name nginx dangerous/nginx
```

#### Docker Hub
```
$ docker pull dangerous/nginx
```
