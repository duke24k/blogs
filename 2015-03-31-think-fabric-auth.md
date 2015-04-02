#before using fabric: 보안과 인증을 생각하다.

시스템 자동화 도구를 잘 사용한다는 것은 막강한 도구를 가진다는 것을 의미한다. 이런 훌륭한 검을 통해 스스로 시스템을 망가뜨리는 것도 또한
간단하다. 그렇게 생각하면 잘 사용한다는 것은 엄격하게 사용한다는 것을 의미한다. 엄격한 기준에 따른 사용은 역시 보안일 것이다.

ssh 기반 시스템 자동화 도구인 fabric을 사용하자면 ssh 인증이 곧 보안이다라는 생각이 든다. 크게 인증은 비밀번호 방식이냐 인증키
공유나 둘중에 하나를 선택할 수 있다. 그리고 당연히 LINUX 기반 시스템에서 root 권한으로 실행할 수 있게 해주는 sudoer를 다시
한번 생각해야 한다는 소리도 당연하다.

___

## fabric with password authentication

패스워드를 저장하지 않고 그때 그때 실행하는 경우를 보자. 패스워드를 파일에 저장하는 것은 쉽지만, 보안이란 측면에서는 위험하다.

원격서버를 remote.cloudv.kr, 원격서버에 생성한 사용자 계정을 sshuser라고 하자.

fabfile을 하나 만들어보자. 환경변수에 사용자를 추가하고 비밀번호는 입력으로 받자 그리고 task로 uptime을 등록하면 다음과
간단한 fabfile을 작성할수 있다.



    
    cat fabfile.py
    #!/bin/python
    env.user='sshuser'
    env.password = prompt('PASSWORD:')
    
    def uptime():
        sudo('uptime')


remote.cloudv.kr에 uptime을 실행한다.
    
>    # fab -H remote.cloudv.kr uptime
    

함수 sudo()는 명령어 sudo와 같다. 따라서 시스템의 설정에 따라서 비밀번호를 한번 더 묻는다. 비밀번호 한번더 묻는 것도 속도에
영향을 미치므로 /etc/sudoers 파일에 NOPASSWD 설정을 한다.

    
    echo 'sshuser ALL=NOPASSWD:ALL' >> /etc/sudoers
    

## fabric with key authentication

비밀번호를 묻는 방식을 봤다면 인증키 방식도 해보자.

먼저 ssh key를 rsa 알고리즘으로 생성한다. 여러 prompt가 뜬지만, 엔터만 치고 넘어간다.

    
    $ ssh-keygen -t rsa -b 4096
    

사설키(id_rsa)와 공인키(id_rsa.pub) 가 각각 생성되었다.

    
    ~/.ssh/id_rsa 
    ~/.ssh/id_rsa.pub 
    

원격서버 remote.cloudv.kr의 authorized_keys 파일에 공개키를 추가하자.

    
>    ~/.ssh/id_rsa.pub  ~/.ssh/authorized_keys

키 인증을 하기 위해 다시 fabfile.py를 작성해 보자.

    # cat << 'EOF' > fabfile.py
    #!/usr/bin/python
    
    env.user='sshuser'
    # env.use_ssh_config = True
    env.key_filename = "~/.ssh/id_rsa"
    
    
    def uptime():
        sudo('uptime')
    
    EOF

    

다시 실행하면

    
    fab -H remote.cloudv.kr uptime
    

이제 sudoers 파일을 자세히 보자.

   
    # cat -n /etc/sudoers
    
         1  #
         2  # This file MUST be edited with the 'visudo' command as root.
         3  #
         4  # Please consider adding local content in /etc/sudoers.d/ instead of
         5  # directly modifying this file.
         6  #
         7  # See the man page for details on how to write a sudoers file.
         8  #
         9  Defaults    env_reset
        10  Defaults    mail_badpass
        11  Defaults    secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        12  
        13  # Host alias specification
        14  
        15  # User alias specification
        16  
        17  # Cmnd alias specification
        18  
        19  # User privilege specification
        20  root    ALL=(ALL:ALL) ALL
        21  
        22  # Members of the admin group may gain root privileges
        23  %admin ALL=(ALL) ALL
        24  
        25  # Allow members of group sudo to execute any command
        26  %sudo   ALL=(ALL:ALL) ALL
        27  
        28  # See sudoers(5) for more information on "#include" directives:
        29  
        30  #includedir /etc/sudoers.d
    
    

이것은 바로 PC의  PC mint Linux의 /etc/sudoers 파일이다. 아무런 설정도 안한 디폴트 파일이다. sudoers에서 사용자
권한설정은 각각의 필드가 아래와 같은 의미를 가진다. 

> 사용자 계정 호스트=(사용자 계정:사용자 그룹 ) 명령어

20번째줄의 root의 권한 설정을 보자.

    
 >   20  root    ALL=(ALL:ALL) ALL
    

root 사용자는 ALL 호스트에 대해 ALL 사용자와 ALL 그룹이 ALL 명령어를 실행하는 것을 허락한다.

명령어 필드는 다음과 같이 표현될 수 있다.

    
    ${명령어} := ([NOEXEC|NOPASSWD|PASSWD]:command1,command2,...,command#n)
    
    sshuser ALL=NOEXEC:/usr/bin/less, NOPASSWD:/usr/bin/updatedb, PASSWD:/bin/kill,/sbin/halt
    

최소 권한은 높은 보안수준을 제공해준다. 그만큼 피곤한 서버관리가 될 것이다. 자동화 도구를 사용한다는 것은 당연한 것이다. 일괄적인 높은
보안수준을 구현하기위해 서버 관리자 혼자서 일일히 모든 설치/설정 작업을 한다는 것은 구시대적인 발상일 것이다. 그래서 언제나 배치작업을
한다. 여러대의 서버를 다루는데 좋은 도구들이 많다. puppet이나 chef가 그렇다. 그런데 ruby이다. 이런저런 언어를 잘 다루는
것은 좋은 일이지만, 항상 헷갈리는 경우가 있지 않던가? 

**python을 주로 쓴다면 fabric도 좋은 선택일 것이다. 아직도 여전히 python 2.7에 머물러 있지만 말이다.**



[polldaddy rating="7739789"]

