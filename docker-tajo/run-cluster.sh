#!/bin/bash

# Original URL : https://raw.githubusercontent.com/dongjoon-hyun/dockerfiles/master/ubuntu14.10-hdw/run-cluster.sh
IMG_TAG=ubuntu-14.04/tajo:0.10.0 .
build()
{
  sudo docker build --tag ${IMG_TAG}
}
rmi
{
    sudo docker rmi ${IMG_TAG}
}
install()
{
LINK=""
for i in {1..3}
do
    HOST=hdw-001-0$i
    LINK="$LINK --link=$HOST:$HOST"
    sudo docker run --name=$HOST -h $HOST -p 1001$i:22 -p 1920$i:9200 -d ${IMG_TAG} /root/start.sh
done
}
console()
{
HOST=hnn-001-01
PORT="-p 8088:8088 -p 8888:8888 -p 10000:10000 -p 10010:22 -p 26002:26002 -p 26080:26080 -p 50070:50070"
sudo docker run --name=$HOST -h $HOST $PORT $LINK -it -v /mnt:/mnt  /root/init-nn.sh

}
uninstall()
{
for i in {1..3}
do
    sudo docker rm -f hdw-001-0$i
done
}

case $1 in
    build)
        build
    ;;
    install)
        install
    ;;
    uninstall)
        uninstall
    ;;
    console)
        console
    ;;
    rmi)
    rmi
    ;;
esac
