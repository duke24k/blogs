Openstack에서는 DNS를 어떻게 다룰까하는 호기심에서 자료를 찾기 시작했다. 


# DNS as a service on the Openstack

손쉽게 Desinate와 Mointer 라는 프로젝트를 찾을수 있었다.
Desinate는 openstack에서 2104년 6월 선정한 incubating project이다. cli와 rest api, 그리고 nova, neutron, keystone과 통합하여 multi-tenant dns를 지원한다.
Moinker는 그 전신으로 2012년 Kiall Mac Innes 가 시작했고, 그가 HP로 옮긴뒤 2013년 오픈스택서밋 포틀랜드에서 HP Cloud Team에서 프로젝트를 선보였다.
이후 랙스페이스,이베이,레드햇, eNovace 및 몇몇 다른 사람들의 노력으로 성장했다.

DNS as a service에 대한 고민은 Moinker라는 프로젝트가 openstack community에 던져주었고,
이를 기반으로 Desinate라는 프로젝트를 인큐베이팅하고 있다.

# Installing the desinate in Ubuntu 12.04

    $ apt-get install python-pip python-virtualenv
    $ apt-get install rabbitmq-server
    $ apt-get build-dep python-lxml

    $ git clone https://github.com/stackforge/designate.git
    $ cd designate

    $ virtualenv --no-site-packages .venv
    $ . .venv/bin/activate

    $ pip install -r requirements.txt -r test-requirements.txt
    $ python setup.py develop

    $ cd etc/designate

    $ ls *.sample | while read f; do cp $f $(echo $f | sed "s/.sample$//g"); done

    $DEBIAN_FRONTEND=noninteractive apt-get install pdns-server pdns-backend-sqlite3
    #Update path to SQLite database to /root/designate/powerdns.sqlite or wherever your top level designate directory resides

    $ editor /etc/powerdns/pdns.d/pdns.local.gsqlite3

    #Change the corresponding line in the config file to mirror:
    gsqlite3-database=/root/designate/pdns.sqlite

    #Restart PowerDNS:
    $ service pdns restart

    $ echo "designate ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/90-designate
    $ sudo chmod 0440 /etc/sudoers.d/90-designate 

    $ mkdir /var/log/designate

    $ editor designate.conf

[Sample Configuration](https://gist.github.com/TimSimmons/6596014)

    # Initialize and sync the Designate database:
    $ designate-manage database-init
    $ designate-manage database-sync

    #Initialize and sync the PowerDNS database:

    $ designate-manage powerdns database-init
    $ designate-manage powerdns database-sync

    #Restart PowerDNS or bind9
    $ service pdns restart

    #Start the central service:
    $ designate-central

    $ designate-central

    $ cd root/designate
    #Make sure your virtualenv is sourced 
    $ . .venv/bin/activate

    $ cd etc/designate

    # Start the API Service

    $ designate-api
    #You may have to run root/designate/bin/designate-api

    $ wget http://ipecho.net/plain -O - -q ; echo

# Reference
[RESTFUL API SPEC](https://designate.readthedocs.org/en/latest/rest.html) 
[designate-gaining-momentum-as-openstack-dns-as-a-service](http://www.rackspace.com/blog/designate-gaining-momentum-as-openstack-dns-as-a-service/)
[helion dns as a service](http://docs.hpcloud.com/helion/openstack/1.1/install/dnsaas/)
[Openstack Wiki's desinate](https://wiki.openstack.org/wiki/Designate)



