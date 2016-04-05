## Build

`make build`

```
docker build --no-cache -t cromark/uaa:3.2.1 --rm .
```

## Start postgres

Postgres must be started *prior* to UAA

```
docker run -d \
           -p 15432:5432 \
           -e POSTGRES_PASS="mypass" \
           --name postgres \
           tutum/postgresql
```


## configuration

in able to run locally see **uaa.env** for variables

```
# docker run -d --name=uaa --env-file=uaa.env -p 80:8080 uaa:3.2.1
DB_ENV_DB=postgres
DB_ENV_PASS=mypass
DB_ENV_USER=postgres
DB_PORT_5432_TCP_ADDR=192.168.99.100
DB_PORT_5432_TCP_PORT=15432
LOGIN_CONFIG_URL=https://gist.githubusercontent.com/cromark/f4a7799d437d4a2e7d06/raw/ab7de41faffffa6eb0ce706fb45bb7406e2d8ae3/login.yml
UAA_CONFIG_URL=https://gist.githubusercontent.com/cromark/e018c8546d7f13eee72f/raw/dc3b796044bdc863609d97ae5efb1d08d2b8ec20/uaa2.yml

```
## start uaa

This command will start UAA as a daemon and serve up requests on port 80

`docker run -d --name=uaa --env-file=uaa.env -p 80:8080 cromark/uaa:3.2.1`

### Alternative

Use localized configuration (see [uaa-config](uaa-config) project)

#### Start configuration container ***first***

`docker run -d -p 9000:80 --name uaa-config-local uaa-config`

`IP=$(docker-machine ip dev)`

```
docker run -d \
           --name=uaa \
	   --env-file=uaa.env \
	   -e LOGIN_CONFIG_URL=http://$IP:9000/login.yml  \
	   -e UAA_CONFIG_URL=http://$IP:9000/uaa.yml \
	   -p 80:8080 \
	   cromark/uaa:3.2.1
```

## access

`open http://uaa.192.168.99.100.xip.io`

## local testing

`uaac target http://uaa.192.168.99.100.xip.io`

`uaac token client get resource-server -s s3cret`

`uaac token decode`

`export bearer="Bearer $(uaac context resource-server | grep access | cut -d':' -f2)"`

`curl -s -H "Authorization: $bearer"  --url "http://uaa.192.168.99.100.xip.io/Users" | jq -r .resources[].userName | sort`

## verify profile properties

get the jwt token

optional for docker-machine instance

`export UAA_ENDPOINT=http://uaa.$(docker-machine ip dev).xip.io`

`./uaa-test.sh`

## signing key

fetch from the **uaa.env** configurtion file

`curl -s $(grep 'UAA_CONFIG_URL=' uaa.env | cut -d'=' -f2) | grep signing-key: | cut -d':' -f2`
