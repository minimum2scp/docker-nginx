# docker-nginx

Rebuild [nginx.org mainline package](http://nginx.org/en/linux_packages.html) with

- Debian jessie, sid
- [ngx\_mruby](https://github.com/matsumoto-r/ngx_mruby) as dynamic module

| directory         | image                               | OS             | features |
|:---               |:---                                 |:---            |:---      |
| jessie-ngx\_mruby | minimum2scp/nginx:jessie-ngx\_mruby | Debian jessie  | ngx\_mruby |
| sid               | minimum2scp/nginx:sid               | Debian sid     | njs |
| sid-ngx\_mruby    | minimum2scp/nginx:sid-ngx\_mruby    | Debian sid     | ngx\_mruby |

## Build

```shell
cd direcotry
docker build -t <image-name> .
```

or

```shell
docker-compose build <directory-name>
```

## Copy binary packages from image

```shell
./copy-packages.sh <image_name> /dest/path/to/extract/
```

