## 1.1 도메인이란?
도메인이란 소프트웨어로 해결하고자 하는 문제 영역을 말한다.
하나의 도메인은 여러 하위 도메인으로 나뉠 수 있다.


## 1.2 도메인 전문가와 개발자 간 지식 공유
개발자는 고객의 요구사항을 올바르게 이해하는 것이 중요하다.
- 요구사항을 제대로 이해하지 못하면 다시 만들어야하는 코드가 많아짐 (Garbage in, Garbage out)
- 요구사항을 이해하기 위해 어느정도의 도메인지식을 갖춰야함

  
## 1.3 도메인 모델
도메인 모델이란 특정 도메인을 개념적으로 표현한 것이다.
도메인 모델을 보면 모든 내용을 알 수 있는 것은 아니지만 해당 도메인이 어떤 기능을 수행할 수 있는지 도메인을 이해하는데 도움을 준다.

## 1.4 도메인 모델 패턴
애플리케이션의 아키텍처는 위와같은 계층구조를 가진다.

영역	설명
사용자 인터페이스 (표현 계층)	사용자의 요청을 처리하고 응답하는 계층
응용 계층	사용자가 요청한 기능을 싱행하는 계층, 로직을 직접 구현하는 것이 아니라 도메인 계층을 조합해서 기능을 실행한다.
도메인 계층	시스템이 제공할 도메인 규칙을 구현한다.
인프라스트럭처 계층	데이터베이스나 메시징 시스템과 같은 외부 시스템과의 연동을 처리하는 계층
도메인 계층의 도메인의 핵심 규칙을 구현한다.

주문 도메인의 경우 '출고 전에 배송지를 변경할 수 있다'라는 규칙과 '주문 취소는 배송 전에만 할 수 있다'라는 규칙을 구현한 코드가 도메인 계층에 위치하게 된다
이런 도메인 규칙을 객체 지향 기법으로 구현하는 패턴이 도메인 모델 패턴이다
public class Order {
    private OrderState state;
    private ShippingInfo shippinginfo;

    public void changeShippingInfo(ShippingInfo newShippingInfo) {
        if (!state.isShippingChangeable()) {
            throw new IllegalStateException("can't change shipping in " + state);
        }
        this.shippinginfo = newShippingInfo;
    }
    
    // ...
}


public enum OrderState {
    PAYMENT_WAITING {
        public boolean isShippingChangeable() {
            return true;
        }
    },
    PREPARING {
        public boolean isShippingChangeable() {
            return true;
        }
    },
    SHIPPED, DELIVERING, DELIVERY_COMPLETED;

    public boolean isShippingChangeable() {
        return false;
    }
}
위 코드는 주문 도메인의 일부 기능을 도메인 모델 패턴으로 구현했다.

OrderState에는 주문 대기 중이거나 상품 준비 중에는 배송지를 변경할 수 있다는 도메인 규칙을 구현하고 있다.
큰 틀에서 보면 OrderState는 Order에 속한 데이터이므로 배송지 정보 변경 가능 여부를 판단하는 코드를 Order로 이동할 수도 있다.

## 1.5 도메인 모델 도출
코드를 작성하기 위해서는 먼저 도메인을 이해해야한다.
도메인을 모델링 할 때 기본이 되는 작업은 모델을 구성하는 핵심 구성요소, 규칙, 기능을 찾는 것이다. ( 요구사항 분석 )


## 1.6 엔티티와 밸류
도출한 모델은 크게 엔티티와 밸류로 구분할 수 있다.
엔티티와 벨류를 제대로 구분해야 도메인을 올바르게 설계하고 구현할 수 있으므로 이 둘의 차이를 명확하게 이해하는 것이 중요하다.
### 1.6.1 엔티티
엔티티의 가장 큰 특징은 식별자를 갖는다는 것이다.
- 주문 도메인에서 각 주문은 주문번호를 가진다.
엔티티의 식별자는 바뀌지 않고 고유하기 때문에 두 엔티티 객체의 식별자가 같으면 두 엔티티는 같다고 판단할 수 있다.
### 1.6.2 엔티티의 식별자 생성
특정 규칙에 따라 생성
- UUID, Nano ID
- 값을 직접 입력
- 일련번호 사용(시퀀스나 DB의 자동 증가 칼럼 사용)
### 1.6.3 밸류 타입
ShippingInfo 클래스는 받는 사람과 주소에 대한 데이터를 갖고 있다.
밸류 타입은 별도의 식별자가 없고, 객체 자체로 의미를 명확히 표현 가능하게 한다.
예시 - Address, Money 등
OrderLine에서 int타입의 price와 amounts 필드를 사용하는데, 이를 밸류 타입인 Money타입으로 대체하여 의미를 보다 명확하게 표현하고 밸류 타입이 가지고 있는 기능을 이용할 수 있다.

public class OrderLine {
    private Product product; // 주문할 상품
    private int price; // 상품의 가격
    private int quantity; // 구매 개수
    private int amounts; // 구매 가격 합
    ...
}

public class OrderLine {
    private Product product; // 주문할 상품
    private Money price; // 상품의 가격
    private int quantity; // 구매 개수
    private Money amounts; // 구매 가격 합
}
### 1.6.4 엔티티 식별자와 밸류 타입
필드의 의미가 드러나도록 id보다는 orderNo라는 의미가 명확히 드러나는 필드 이름을 사용한다.
### 1.6.5 도메인 모델에 set메서드 넣지 않기
명확한 이유가 있는게 아니라면 setter 사용을 지양하고, 필요한 필드를 모두 포함하여 생성자로 강제하도록 한다.
- 도메인 객체가 불완전한 상태로 사용되는 것을 막을 수 있다.


## 1.7 도메인 용어와 유비쿼터스 언어
도메인에서 사용하는 용어를 코드에 반영하여, 코드만 읽어도 자연스럽게 이해하는 방향으로 가야한다.
- Enum 사용시 STEP1, STEP2와 같이 사용하지 않고 명확하게 READY, PAID 등으로 표현
