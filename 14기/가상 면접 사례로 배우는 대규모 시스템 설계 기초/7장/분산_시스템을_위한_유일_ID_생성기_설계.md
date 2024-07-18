# 7장. 분산 시스템을 위한 유일 ID 생성기 설계

## 1단계. 문제 이해 및 설계 범위 확정

면접관에게 질문을 통해 설계방향을 결정해야 한다.

모호한 부분에 대해 질문해 구체적인 요구사항을 이끌어낼 것

> 💡 이번 문제에서 만족해야 할 요구사항 목록
>
> - ID는 유일해야 한다
> - ID는 숫자로만 구성
> - ID는 64비트로 표현가능한 값
> - ID는 발급 날짜에 따라 정렬 가능해야 함
> - 초당 10,000개의 ID를 생성할 수 있어야 함

## 2단계. 개략적 설계안 제시 및 동의 구하기

분산 시스템에서 unique한 ID를 만드는 여러가지 방법 소개

### 1. 다중 마스터 복제 (multi-master replication)

- 각 DB 서버의 `auto_increment` 기능을 활용
  - 1씩 증가시키는 것이 아니라, k만큼 증가 (k = 현재 사용중인 DB 서버 수)

![](https://velog.velcdn.com/images/dbwogml15/post/80fd1729-880c-48be-bb7d-70fd286bf557/image.png)

- 위 예시에 따르면, 어떤 서버가 만들 다음 ID = 이전 ID + 2
- 장점
  - 규모 확장성 문제를 어느정도 해결 가능
    - DB 서버 수를 늘려서, 초당 생산 가능한 ID 수를 증가시킬 수 있기 때문
- 단점, 한계점
  - 여러 데이터 센터에 걸쳐 규모를 늘리기 어렵다.
  - ID의 유일성은 보장되지만, 시간의 흐름에 맞추어 커지도록 보장할 수 없다.
    - 생성 시간순으로 정렬이 불가하다.
    - 왜?
      k = 2인 위의 예시에서
      - 서버 1에서 생성되는 ID : 1, 3, 5…
      - 서버 2에서 생성되는 ID : 2, 4, 6…
      - ID생성 요청이 서버 1,2 순서대로 번갈아서 전달되는 것을 보장할 수 없기 때문
  - DB서버를 추가/삭제할 때 문제없이 동작하도록 만들기 어렵다.

### 2. UUID (Universally Unique Identifier)

- UUID란
  - 컴퓨터 시스템에 저장되는 정보를 유일하게 식별하기 위한 128비트 짜리 수
- 충돌 가능성이 지극히 낮다
  중복 UUID가 1개 생길 확률을 50%까지 끌어올리려면
  초당 10억개의 UUID를 100년동안 만들어야 한다.
- 서버 간 조율이 필요하지 않다. 독립적으로 생성 가능
- 장점
  - 단순하게 생성 가능, 서버간 동기화도 필요 없음
  - 각 서버가 독립적으로 ID 생성하기 때문에 규모 확장도 쉬움
- 단점
  - ID가 128비트로 길다.
    - 이번 장에서 다루는 문제의 요구사항은 64비트이다
  - ID를 생성된 시간순으로 정렬할 수 없다.
  - ID에 숫자가 아닌 값이 포함될 수 있다.
- 추가 자료
  - v8까지 있고, 버전별로 특징이 다름
  - v4가 제일 범용적으로 사용되는 것 같음
  - 다들 어떤걸 써봤는지 ?!
    [UUID(Universally Unique Identifier) | 토스페이먼츠 개발자센터](https://docs.tosspayments.com/resources/glossary/uuid)
    [Which UUID version to use?](https://stackoverflow.com/questions/20342058/which-uuid-version-to-use)

### 3. 티켓 서버 (ticket server)

- `auto_increment` 기능을 갖춘 DB 서버 (=티켓서버)를 중앙 집중형으로 하나만 사용하는 방식

![](https://daeakin.github.io//images/large-system/ticket-server.png)

- 장점
  - 유일성이 보장되고 + 오직 숫자로만 구성된 ID를 쉽게 만들 수 있음
  - 구현하기 쉬움
  - 중소 규모 애플리케이션에 적합
- 단점
  - 티켓서버가 SPOF(Single-Point-of-Failure)가 됨
    - 티켓서버에 장애가 발생하면, 모든 관련 시스템이 영향을 받게됨
    - 이를 피하기 위해 티켓서버를 여러대 사용하면, 데이터 동기화와 같은 새로운 문제 발생

### 4. 트위터 스노플레이크 접근법 (twitter snowflake)

위의 방식 중에, 모든 요구사항을 만족하는 방식은 없었다. 따라서 트위터의 스노플레이크 접근법을 사용할 것

- 이 방식은 분할정복(divide and conquer) 전략을 사용
  - 생성해야 할 ID를 여러 섹션으로 분할

![](https://velog.velcdn.com/images/bjo6300/post/4277b11a-20e3-4214-b785-5754ecdcf8aa/image.png)

- 5개의 섹션으로 분할
  - `sign bit` (1bit) : 음수와 양수를 구별하는데 사용
  - `timestamp` (41bit) : 기원 시각(epoch) 이후로 몇 밀리초가 경과했는지를 나타냄
  - `데이터센터 ID` (5bit) : 2^5=32개의 데이터센터를 지원
  - `서버 ID` (5bit) : 데이터 센터 당 2^5=32개의 서버 사용 가능
  - `일련번호(sequence)` (12bit) : 각 서버에서는 ID를 생성할 때마다 이 일련번호를 1만큼 증가킴
    - 이 값은 1밀리초가 경과할 때마다 0으로 초기화
    - 동일 서버에서 1밀리초당 몇개의 id를 생성할 수 있는가 2^12
- 추가 자료
  - Snowflake 발표 블로그, 깃허브
    - 트위터에서는 알고리즘만 공개, 사람들이 이 알고리즘을 이용해 각 언어별로 라이브러리 만들어 제공
      [Announcing Snowflake](https://blog.x.com/engineering/en_us/a/2010/announcing-snowflake)
      [GitHub - twitter-archive/snowflake: Snowflake is a network service for generating unique ID numbers at high scale with some simple guarantees.](https://github.com/twitter-archive/snowflake?tab=readme-ov-file)
  - npm 라이브러리 중 가장 다운로드 수 많은 것
    [npm: nodejs-snowflake](https://www.npmjs.com/package/nodejs-snowflake)

## 3단계. 상세 설계

2단계에서 다양한 기술적 선택지를 살펴보았다. 트위터 스노플레이크 접근법을 선택하여 상세한 설계를 진행해보자.

- 5개의 섹션 중에서,
  - 데이터센터 ID, 서버 ID는 시스템이 시작할 때 결정, 일반적으로 운영중에 변경되지 않음
  - 타임스탬프, 일련번호 : ID생성기가 돌고 있는 중에 만들어지는 값

### 타임스탬프

- 가장 중요한 41비트를 차지함
- 시간이 지날수록 큰 값 → ID를 시간순으로 정렬할 수 있게 됨

![](https://velog.velcdn.com/images/bjo6300/post/5fda4819-15f3-4dc4-9112-074528a9e252/image.png)

- 위 방식으로 추출하면 어떤 UTC 시각도 41비트 타임스탬프 값으로 변환 가능
- 41비트로 표현할 수 있는 최댓값 = 2^41 = 2199023255551 ms
  - 대략 69년
  - 따라서, 이 ID 생성기는 69년동안만 정상 작동
  - 기원시각(epoch)를 현재시각과 가깝게 해 overflow 발생 시점을 늦춰놓은 것
  - 69년 후에는 기원시각을 바꾸거나, ID체계를 다른 것으로 바꿔야 함

### 일련번호

- 12비트 = 2^12 = 4096개
- 같은 ms 당 하나 이상의 ID를 만들어 낸 경우에 0보다 큰 값
- 즉, 같은 ms에 4096개의 ID를 만들어낼 수 있음
  - 1s= 1000ms, 초당 4096000 개의 ID를 생성 가능

## 4단계. 마무리

설계 진행 후, 시간이 남았을 경우 면접관과 추가로 논의할 수 있는 사항들

- 시계 동기화 (Clock synchronization)
  - 이번 설계에서 우리는, ID생성 서버들이 전부 같은 시계를 사용한다고 가정
  - 하지만, 상황에 따라 그렇지 않을 수 있다.
    - 무슨 상황인거죠..?
  - NTP (Network Time Protocol)은 이 문제를 해결하는 가장 보편적 수단
- 각 섹션의 길이 최적화
  - 동시성이 낮고, 수명이 긴 애플리케이션이라면
  - 일련번호 섹션의 길이를 줄이고, 타임스탬프절의 길이를 늘리는 것이 효과적일 수 있음
- 고가용성 (high availability)
  - ID생성기는 필수 불가결 컴포넌트, 따라서 아주 높은 가용성을 제공해야 할 것
