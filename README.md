# docker-cacti
Cacti Docker Image (get it [here](https://hub.docker.com/r/mvkvl/cacti/))

## General Info
- based on [bitnami/minideb](https://hub.docker.com/r/bitnami/minideb/)
- size is only 367 Mb

## Database Configuration
This image needs to connect to database. Any Mariadb/MySQL image/server is acceptable,
but perhaps some additional setup will be needed. To keep thing simple, just use
[mvkvl/mariadb](https://hub.docker.com/r/mvkvl/mariadb/) docker image as a part of docker-compose deployment (see example below).

## Admin User
For scripts to be able to perform needed operation on database MySQL / Mariadb
user with full administrative access should be configured with following environment
variables:

- MYSQL_ROOT_USER
- MYSQL_ROOT_PASSWORD

## Database (Re)Initialization
On the first run Cacti database is being created and populated with initial data.

## Environment Variables
Environment Variables can be passed to container with following methods:
- docker command ( *-e* switch )
- docker-compose file ( *environment* section )
- as a variable from attached volume ( `host-env-dir:/opt/env:ro` ), here every file is named as EV and contains the value for given EV (see example on [GitHib](https://github.com/mvkvl/docker-mariadb))
- as a docker secret ( only *mysql_root_user*, *mysql_root_password*, *mysql_user* and *mysql_password* secrets are supported )
- */opt/scripts/env.sh* script sources all scripts from */opt/env* directory; here you can also set any needed environment variables or perform any additional initialization steps

Supported environment variables are:
- TZ
- MYSQL_ROOT_USER
- MYSQL_ROOT_PASSWORD
- MYSQL_DATABASE
- MYSQL_USER
- MYSQL_PASSWORD
- MYSQL_HOST
- DB_STARTUP_TIMEOUT [if cacti needs to wait for database to get ready]

## Example Docker Compose File
This is an example docker-compose file:

```
version: '3.1'

services:

  db:
    container_name: mariadb
    hostname: mariadb
    image: mvkvl/mariadb
    environment:
      TZ: Asia/Tokyo
      MYSQL_ROOT_USER: admin
      MYSQL_ROOT_PASSWORD: admin
    volumes:
        - ./container/mariadb/conf:/etc/mysql/conf.d:ro
        - ./container/mariadb/data:/var/lib/mysql
        - ./container/mariadb/env:/opt/env
    ports:
      - '3306:3306'
    stdin_open: true
    tty: true

  cacti:
    container_name: cacti
    hostname: cacti
    image: mvkvl/cacti
    environment:
      TZ: Asia/Tokyo
      MYSQL_ROOT_USER: admin
      MYSQL_ROOT_PASSWORD: admin
      MYSQL_DATABASE: cacti
      MYSQL_USER: cacti
      MYSQL_PASSWORD: cacti
      MYSQL_HOST: db
      DB_STARTUP_TIMEOUT: 60
    volumes:
      - ./container/cacti/env:/opt/env
      - ./container/cacti/rra:/opt/cacti/rra
    ports:
      - "8080:80"
    depends_on:
      - db
    stdin_open: true
    tty: true
```
