- docker 
  wget -qO- https://get.docker.com/ | sh 
  docker --help
  sudo docker run hello-world
  sudo docker -d
  sudo apt-get install apparmor
  sudo service docker start
  ps  aux |grep docker
  sudo docker run hello-world
  docker run -it ubuntu bash
  sudo vim /etc/default/grub 
  sudo update-grub
  sudo docker run hello-world
  sudo docker run -it ubuntu bash
  docker run --name ubuntu -P -d nginx
  sudo nano /etc/default/docker 

- ufw
  sudo ufw status
  vim /etc/default/ufw 
  sudo vim /etc/default/ufw 
  sudo ufw reload
  sudo ufw status
  sudo ufw help
  sudo ufw enable
  sudo ufw reload
  sudo ufw allow 2375/tcp



  $ sudo docker pull sktelecom/ubuntu14.10-hdw
  $ bash -c “$(curl -fsSL https://raw.githubusercontent.com/dongjoon-hyun/dockerfiles/master/ubuntu14.10-hdw/run-cluster.sh)”

  $ root@hnn-001-01:~# ./init-spark.sh
  $ root@hnn-001-01:~# ./test-spark.sh
  $ root@hnn-001-01:~# ./init-tajo.sh
  $ root@hnn-001-01:~# /usr/local/tajo/bin/start-tajo.sh
  $ root@hnn-001-01:~# ./test-tajo.sh
  $ root@hnn-001-01:~# ./test-hive.sh
  $ root@hnn-001-01:~# ./run-ipython-notebook.sh
  $ root@hnn-001-01:~# exit
  


