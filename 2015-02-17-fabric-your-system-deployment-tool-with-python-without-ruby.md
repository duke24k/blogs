# python으로 시스템 관리하는 fabric

___
puppet이나 chef solo 모두 자동배포에 특화되어 있다. 그러나, 모두  ruby다. perl을 계승한 ruby가 많은 면에서
시스템 자동화에 강점을 가지고 있지만,  ruby로 할 수 있는 일이 많다해도 , 도구는 될 수 있는대로 꼭 필요한 만큼
있는 것이 낫다. 웬지 이것쓰고 저것쓰고 하면 귀찮지 않는가? Cookbook이나 Reference 또한  많겠지만, python으로 구성된
시스템에서 관리도구를 ruby로 쓰는 것은 또한  다른 귀차뉘즘이 발동한다.
____
이제까지  bash + ssh key 인증으로도 강력하게 관리했지만, 이런이유로  fabric을 보았다.
ubuntu에서 apt-get install fabric 하면 가볍게 설치가 된다.
fab이라는 명령을 실행하면 폴더내에 있는 fabfile.py를 찾아서  실행한다.
옵션 -f  를 이용해 파일을 지정할 수 도 있다.
간단한 예제파일을 복사해서 쉘에 저장하자.

# cat fabfile.py

    
    from fabric.api import *
    
                env.hosts=["localhost"]
                env.user=""
                env.password=""
    
                def hostname_check():
                    run("hostname")
    
                    def command(cmd):
                        run(cmd)
    
                        def sudo_command(cmd):
                            sudo(cmd)
    
                            def install(package):
                                sudo("apt-get -y install %s" % package)
    
                                def local_cmd():
                                    local("echo fabtest >> test.log")
    
                                    @parallel
                                    def pcmd(cmd):
                                        run(cmd)

  아래의 예제를 실행하면서 결과와 함께 소스를 보자.

python 함수명이 task가 되어 실행된다.  함수에 인자를 통해 실행도 가능하고 sudo도 가능하다.

___


fab hostname_check

    
    env.user=""
    [localhost] Executing task 'hostname_check'
    [localhost] run: hostname
    [localhost] out: localhost
    [localhost] out:
    
    Done.
    Disconnecting from localhost... done.
                

fab command:hostname

	[localhost] Executing task 'command'
	[localhost] run: hostname
	[localhost] out: localhost
	
	[localhost] out:
	Done.

	Disconnecting from localhost... done.

fab command:"hostname -I"

	[localhost] Executing task 'command'
	[localhost] run: hostname
	[localhost] out: localhost
	[localhost] out:
	Done.
	Disconnecting from localhost... done.


## fabfile.py에서 @parallel 은 여러개의 host에 동시에 병렬작업을 실행한다.


http://www.fabfile.org

소스예제와 실행결과만으로도 충분히 이해가 될 것이다.



 sudo는 사용자 비밀번호와 루트 비밀번호를 입력하여 명령어를 실행시키는데 fabric에서는 두 비밀번호

가 같아서 sudoers 파일을 수정하고 비밀번호 물지않고 인증하도록  설정하는데 여기서는 생략했다.



python 쓸 일이 없으면 늘지도 않는다. fabric을 통해 python을 배워가는데 자극이 됐으면 하는 바람에 소개한다.


