before using fabric: 보안과 인증을 생각하다. 

시스템 자동화 도구를 잘 사용한다는 것은 막강한 도구를 가진다는 것을 의미한다. 
이런 훌륭한 검을 통해 스스로 시스템을 망가뜨리는 것도 또한 간단하다. 
그렇게 생각하면 잘 사용한다는 것은 엄격하게 사용한다는 것을 의미한다.
엄격한 기준에 따른 사용은 역시 보안일 것이다. 

ssh 기반 시스템 자동화 도구인 fabric을 사용하자면 ssh 인증이 곧 보안이다라는 생각이 든다.
크게 인증은 비밀번호 방식이냐 인증키 공유나 둘중에 하나를 선택할 수 있다.
그리고 당연히 LINUX 기반 시스템에서 root 권한으로 실행할 수 있게 해주는 sudoer를 
다시 한번 생각해야 한다는 소리도 당연하다.

여러 시나리오를 통해 차근차근 보자. 
패스워드를 저장하지 않고 그때 그때 실행할때 사용한다.
~~~
cat fabfile.py
#!/bin/python

env.password = prompt('PASSWORD:')
def uptime():
    run('uptime')
    ~~~
    위의 코드를 원격에 있는 호스트 lab.cloudv.kr에 실행해보자.
    ~~~
    # fab -H lab.cloudv.kr uptime
    ~~~

