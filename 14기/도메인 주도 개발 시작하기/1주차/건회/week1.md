# 1. 도메인 모델 시작하기

## 1.1 도메인이란?

- 소프트웨어로 해결하고자 하는 **문제 영역**
- 도메인은 다시 하위 도메인으로 나눌 수 있음

## 1.2 도메인 전문가와 개발자 간 지식 공유

- 요구사항을 올바르게 이해
- 적절한 수준의 도메인 지식
- 전문가와 직접 소통
- Garbage in, Garbage out
  - 도메인 전문가라고 해서 항상 올바른 요구사항을 주는 것은 아님
  - 적절한 소통을 통해 진짜 요구사항을 캐치하는 것이 중요

## 1.3 도메인 모델

### 객체 기반 모델

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/b37baec8-5431-4238-9930-efa28805953f/fb300782-4131-414e-a21f-ee81d8aacf69/Untitled.png)

### 상태 다이어그램을 통한 모델링

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/b37baec8-5431-4238-9930-efa28805953f/b62ad74e-763b-4b93-b651-3fd9fbaaaea7/Untitled.png)

- UML 이외에도 그래프, 수학 공식 등을 이용하여 도메인 모델 설계 가능(표현 방식보다는 잘 나타내는 것이 중요)

### 도메인 모델

- 도메인 자체를 잘 이해하기 위한 개념 모델
- 기술에 맞는 별도 구현 모델이 따로 필요
- 개념/구현 모델은 다르지만 구현 모델이 개념 모델을 따르도록 하라 수 있음
- 하위 도메인에 따라 각 도메인의 의미도 달라질 수 있음
  - → 하위 도메인 별로 별도의 모델 필요

## 1.4 도메인 모델 패턴

- 처음에는 전체 윤곽을 잡고 구현 과정에서 점진적으로 개념 모델 → 구현 모델로 발전 시켜나가야함

## 1.5 도메인 모델 추출

## 1.6 엔티티와 밸류

### 엔티티

- 식별자
  - uuid, 특정 규칙, 일련번호(ai 컬럼) 등등
- 식별자 기준으로 equals, hashCode 메소드

### 밸류

- 불변으로 구현

---

- 단순 set 코드 → 도메인 지식이 코드에서 사라지게 됌
- 도메인 객체가 불완전한 상태로 사용되는 것을 막으려면, 생성 시점에 필요한 것을 전달해야함

## 1.7 도메인 용어와 유비쿼터스 언어

# 2. 아키텍처 개요

## 2.1 네 개의 영역

### Presentation(표현)

- 응용 레이어에 데이터 가공 및 전달
- 응용 레이어에서 데이터 받아 리턴

### Application(응용)

- 로직 직접 수행 X
- 도메인 모델에 로직 수행 위임

### Domain(도메인)

- 도메인 모델 구현
  - 모메인의 핵심 로직 구현

### Infrastucture(인프라)

- DB 연동, Message Queue, STMP, HTTP 등등
- 논리적 개념보다는 실제 구현

## 2.2 계층 구조 아키텍처

- 레이어드 아키텍처
  - 표현 → 응용 → 도메인 → 인프로
  - 역방향 의존성 X
  - 인프라 계층에 응용, 도메인 계층들이 의존성이 생기게 됌 → DIP로 해결

## 2.3 DIP

- 고수준 모듈이 제대로 동작시키기 위해서는 저수준 모듈들을 사용해야함
- 고수준 → 저수준 의 의존관계가 생기면서 구현 변경이나 테스트가 어려워짐
- 추상화된 Interface를 통해 고수준 ← 저수준의 의존관계를 갖도록 함
  ![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/b37baec8-5431-4238-9930-efa28805953f/c56bd204-0b80-44b8-9ce2-73588a100fcc/Untitled.png)
- 인프라 레이어의 실제 구현에 의존하지 않기 때문에 대역 객체를 통해 테스트도 가능
- DIP란 단순한 인퍼페이스와 구현의 분리가 아님
- 고수준 모듈이 저수준 모듈에 의존하지 않도록 하기 위함이기 때문에 **저수준 모듈에서 인터페이스를 추출하면 안됌**
  ![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/b37baec8-5431-4238-9930-efa28805953f/9f1f0291-eb4f-47ef-b881-892b72006651/Untitled.png)
- 무조건 DIP를 적용할 필요는 없음
- 추상화 대상이 잘 떠오르지 않는다면 DIP 이점을 얻는 수준에서의 적용 범위를 고민해보자

## 2.4 도메인 영역의 주요 구성요소

### 도메인 영역 구성 요소

- 엔티티
  - 고유 식별자 가짐(주문, 회원, 상품…)
  - 데이터와 함께 관련 기능도 제공
- 밸류
  - 고유 식별자 X
  - 개념적인 하나의 값(주소, 금액…)
- 애거리거트
  - 연관된 엔티티와 밸류 객체를 개념적으로 묶은 것
  - 주문 애그리거트 - Orde엔티티, OrderLine밸류, Orderer밸류
- 레포지토리
  - 도메인 모델의 영속성 처리
- 도메인 서비스
  - 특정 엔티티에 속하지 않은 도메인 로직 제공
  - 도메인 로직이 여러 엔티티와 밸류를 필요로 할 때 도메인 서비스에서 로직 구현

**엔티티**

- 도메인 모델의 엔티티와 DB 모델의 엔티티는 **다름**
- 모데인 모델의 엔티티는 데이터와 함께 도메인 기능을 제공하는 객체
- 도메인 관점에서 기능을 구현 & 캡슐화
- 두 개 이상의 데이터가 개념정으로 하나인 경우 밸류 타입을 이용해 표현 가능
  - RDBMS는 밸류 타입을 표현하기 힘들기 때문에 별도 테이블로 저장하게 됌

**밸류**

- 불변으로 구현
- 교체하게 될 경우 값이 아니라 새로운 객체를 만들어서 변경

**애그리거트**

- 도메인 모델이 복잡해질수록 국소적인 엔티티와 밸류에 집중하게 될 수 있음
- 개별 객체가 아니라 큰 틀에서 모델을 볼 수 있어야함
- 관련된 객체끼리 군집 단위로 묶은 애그리거트가 전체 구조를 이해하는 데 도움을 줌
- 루트 엔티티
  - 군집에 속한 객체를 관리하는 엔티티
  - 애그리거트에 속해있는 엔티티와 VO를 통해 애그리거트가 구현해야할 기능 제공
  - 애그리거트를 사용하는 코드 - 루트가 제공하는 기능을 통해 간접적으로 다른 엔티티나 VO에 접근
  - 애그리거트 내부 구현을 숨겨서 애그리거트 단위로 캡슐화하는 효과

**레포지토리**

- 물리적인 저장소에 도메인 객체를 보관하기 위한 모델
- 구현을 위한 도메인 모델(엔티티/밸류는 요구사항에서 도출되는 도메인 모델
- 레포지토리를 통해 도메인 객체를 구한 후 도메인 객체의 기능을 실행하게 됌
- 도메인 객체를 영속화하는데 필요한 기능을 추상화

## 2.5 요청 처리 흐름

![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/b37baec8-5431-4238-9930-efa28805953f/48778232-ac7e-45f3-b4cd-68a71b52e8c2/Untitled.png)

## 2.6 인프라스트럭처 개요

- 표현, 응용, 도메인 영역 지원
- 구현의 편리함은 DIP의 장점만큼 중요하기 때문에 적절한 트레이드 오프는 괜찮다

## 2.7 모듈 구성

- 한 패키지 안에 10~15개 미만으로 타입 개수를 유지 → 넘으면 분리 시도
