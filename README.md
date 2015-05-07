Docker Logstash Forwarder
=========================

Docker image for [Logstash
Forwarder](https://github.com/elasticsearch/logstash-forwarder), formerly known
as _lumberjack_.

Prerequisites
-------------

In order to use this image, you MUST [create an SSL
certificate](https://github.com/elasticsearch/logstash-forwarder#generating-an-ssl-certificate),
and [configure Logstash
Forwarder](https://github.com/elasticsearch/logstash-forwarder#configuring)
using a `config.json` file. This configuration file MUST be named `config.json`
and MUST be located in `/etc/logstash-forwarder`.

### SSL Certificate

If you want to generate self-signed SSL certificates and use an IP address
rather than a DNS record to point to your `logstash` server(s), then you SHOULD
use this
[lc-tlscert](https://github.com/driskell/log-courier/blob/develop/src/lc-tlscert/lc-tlscert.go)
tool:

```
$ wget https://raw.githubusercontent.com/driskell/log-courier/develop/src/lc-tlscert/lc-tlscert.go
$ go run lc-tlscert.go
```

Copy the generated `selfsigned.{crt,key}` files to the `logstash-forwarder`
server **and** to the `logstash` server.

### Logstash Forwarder Configuration

Below is a basic configuration for Logstash Forwarder:

``` json
{
    "network": {
        "servers": [ "logstash.example.org:5043" ],
        "ssl certificate": "/etc/ssl/selfsigned.crt",
        "ssl key": "/etc/ssl/selfsigned.key",
        "ssl ca": "/etc/ssl/selfsigned.crt"
    },
    "files": [
        {
            "paths":  [ "/var/log/nginx/access.log" ],
            "fields": { "type": "nginx-access" }
        }
    ]
}
```

Usage
-----

Let's say your `selfsigned.{crt,key}` files are located in
`/path/to/your/ssl/files`, and your `config.json` file is in
`/path/to/your/config/file`.

You can start forwarding nginx logs to your `logstash` server by running the
following command:

```
$ docker run \
    --volume /path/to/your/ssl/files:/etc/ssl \
    --volume /path/to/your/config/file:/etc/logstash-forwarder \
    --volume /var/log/nginx:/var/log/nginx \
    willdurand/logstash-forwarder
```

However, this solution is not satisfying as you have to mount a `host` directory
as a volume. A better approach would be to use a _data-only container_ with a
`/var/log/nginx` volume:

```
$ docker run \
    --volume /path/to/your/ssl/files:/etc/ssl \
    --volume /path/to/your/config/file:/etc/logstash-forwarder \
    --volume-from logs \
    willdurand/logstash-forwarder
```

## Using Docker Compose

``` yaml
logstashforwarder:
  image: willdurand/logstash-forwarder
  volumes:
    - /path/to/your/ssl/files:/etc/ssl
    - /path/to/your/config/file:/etc/logstash-forwarder
  volumes_from:
    - logs

logs:
  image: busybox
  volumes:
    - /var/log/nginx
```


Extend It
---------

One of the Docker best practices is to avoid mapping a host folder to a
container volume. Instead of specifying a volume, it is recommended to use this
image as base image and configure your own image.
