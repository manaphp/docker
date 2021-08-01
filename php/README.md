## 构建

命令

```bash 
./build.sh php<version>
```

例如构建php7.4

```bahsh
./build.sh php74
```
> 如果网络被墙，请搭建一个http代理服务器，并在构建主机导入环境变量:
> 
> export http_proxy=http://192.168.137.1:1087
> 
> ip与端口根据实际情况填写

## 使用

```yml
version: "3.8"
services:
  test:
    image: manaphp/php74:210801
    volumes:
      - ./:/var/www/html
      - ./etc/php/conf.d:/etc/php/conf.d
      - ./cron.d:/tmp/cron.d
    environment:
      - APP_CRON_ENABLED=1
    network_mode: host
    command: php /var/www/html/index.php
```