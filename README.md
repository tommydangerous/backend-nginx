## Nginx Server

#### Run Nginx container and link other containers
```
$ docker build -t nginx .
$ docker run -d -p 80:80 --link [container_name]:[variable] --name nginx nginx
```

#### Docker Hub
```
$ docker pull dangerous/docker-backend-nginx
```
