# Ch.1 도메인 모델 시작하기

## 도메인 모델 패턴

>> `도메인`이란 소프트웨어로 해결하고자 하는 문제의 영역이다.

### 애플리케이션 영역

일반적인 애플리케이션 아키텍쳐는 `표현`,`응용`, `도메인`,`인프라스트럭쳐` 네개의 영역으로 구성되며, 각각의 구성의 역할은 아래 표와 같다.

|영역|설명|
|:---|:---|
|표현 계층|사용자 요청을 처리(`Controller`) 혹은 정보를 보여준다(`Web/App UI`). 사용자는 외부 시스템이 될 수 도 있다.|
|응용 계층|사용자가 요청한 기능을 실행한다.(`Service`) 도메인 계층을 조합하여 기능을 실행한다.|
|도메인 계층|도메인 규칙을 구현한다|
|인프라스트럭쳐 계층|데이터베이스, Message Queue와 같은 외부 시스템 연동을 처리한다.|

### 개념 모델과 구현 모델

- **`개념 모델`은 문제를 분석한 결과**이다. 
- **처음 부터 도메인을 완벽히 설계하는 것은 불가능**하다. 
- 기능을 추가하고 고도화 하는 과정에서 개발자, 제품 관계자들은 도메인에 대한 성숙도가 올라가고 이를 통해 도메인을 보완하거나 변경하는 일은 발생할 수 있다. 
- **`개념 모델`은 성능, 구현 등을 고려하고 있지 않기에 개념 모델을 실제 코드에 그대로 사용할 수 없다**. 그렇기에 **개념 모델을 구현 가능한 `구현 모델`로 전환하는 과정**을 거치게 된다.

### 도메인 모델 도출

- 도메인을 모델링할 때 기본이 되는것은 `핵심 구성요소`, `규칙`, `기능`을 찾는것이다. 

- 도메인 모델은 완성된 이후에 도메인 전문가, 다른 개발자와 논의를 통해 `문서화` 혹은 `화이트 보드`, `위키` 등을 통해 누구나 쉽게 접근할 수 있도록 공유하는것이 좋다. 

- 도메인을 모델링 할때는 요구사항을 분석한 뒤 세부화를 시키는 방식으로 진행한다. 예를 들어 아래와 같이 요구사항이 있다고 가정한다.

~~~
- 최소 한 종류 이상의 상품을 주문해야한다.
- 한 상품을 한 개 이상 주문할 수 있다.
- 총 주문 금액은 각 상품 구매 가격 합을 모두 더한 금액이다.
- 각 상품의 구매 가격 합은 상품 가격에 구매 개수를 곱한 값이다.
- 주문 할 때 배송지 정보를 반드시 지정해야한다.
- 배송지 정보는 받는사람, 이름, 전화번호, 주소로 구성된다.
- 출고를 하면 배송지를 변경할 수 없다.
- 출고 전에 주문을 취소할 수 있다.
- 고객이 결제를 완료하기 전에는 상품을 준비하지 않는다.
~~~

이제 주어진 요구사항을 세부화 시켜본다.

- 주문 도메인에서 제공해야하는 기능
  - 출고 상태 변경
  - 배송지 변경
  - 주문 취소
  - 결제 상태 변경

  ```typescript
  class Order {
    changeShipped(): void { }
    changeShippingInfo(newShipping: ShippingInfo): void { }
    cancel(): void { }
    completePayment(): void { }
  }

  ```

- 주문 항목
  - 주문 항목에는 구매할 상품의 금액, 구매 개수에 대한 정보가 들어가야한다.

  ```typescript
  class OrderLine {
    private amounts: number;

    constructor(private product: Product,
      private price: number,
      private quantity: number) {
        this.amounts = new Money(this.price.amount * this.quantity)
    }

    private calculateAmounts() {
      this.amounts = this.price * this.quantity
    }

    // Other codes
  }
  ```

- 배송지 정보
  - `이름`, `전화번호`, `받는사람`, `주소`가 들어가야한다.
  ```typescript
  class ShippingInfo {

    constructor(private receiverName: string,
      private receiverPhoneNumber: string,
      private shippingAddress1: string,
      private shippingAddress2: string,
      private shippingZipCode: string
    ) { }

    // Other codes
  }
  ```
- 주문
  - 출고하기 이전에는 주문을 취소할 수 있다.
  - 주문에 귀속되는 주문 항목은 최소 한개가 존재해야한다.
  - 주문 생성시 배송지 정보를 같이 전달해야한다. 전달될때 모든 값이 전달되는지 검증 필요(반드시 지정)
  
  ```typescript
  class Order {
    changeShipped(): void { }
    changeShippingInfo(newShipping: ShippingInfo): void { }
    cancel(): void { }
    completePayment(): void { }


    private _orderLines: Array<OrderLine>
    private _shippingInfo: ShippingInfo

    private get orderLines() {
      return this._orderLines
    }
    private set orderLines(lines: Array<OrderLine>) {
      this._orderLines = lines
    }

    private get shippingInfo() {
      return this._shippingInfo
    }

    private set shippingInfo(info: ShippingInfo) {
      if (!info) {
        throw new Error("Shipping info is not defined")
      }
      this._shippingInfo = info
    }

    constructor(orderLines: Array<OrderLine>, shippingInfo: ShippingInfo) {
      this.orderLines = orderLines;
      this.shippingInfo = shippingInfo;
    }
  }
  ```

## 엔티티와 밸류

도출한 모델은 `엔티티`와 `밸류`로 구분된다. 이 두개를 제대로 구분해야 도메인을 올바르게 설계, 구현할 수 있다.

### Entity

- `엔티티`는 식별자를 가지며 식별자는 객체마다 고유하여 각 엔티티는 서로 다른 식별자를 가진다.
- `엔티티`의 식별자는 바뀌지 않는다. 생성 후 삭제될때까지 유지된다.
- `엔티티`간의 식별자가 동일하면 동일한 `엔티티`로 판단할 수 있다. (JVM언어 계열에서는 Object super class의 `equals` 혹은 `hashCode`를 활용하지만 Node.js 계열에서는 이와 같은 Super class method가 없으므로 간이 구현)
- `엔티티`의 식별자는 `UUID`, `Nano ID` 혹은 `Auto Increment`(주로 RDB계열의 auto_increment)등과 같이 고유한 값을 부여해줄 수 있는 값으로 지정한다.(당연히 사용자 지정 규칙, 직접 입력등도 가능)

```typescript
class Order {
  // Other codes

  // 식별자
  private orderNumber: string;

  public equals<T extends Object>(instance: T) {
    return instance instanceof Order && instance.orderNumber === this.orderNumber;
  }

}
```

### Value Type

- Value Type은 일반적으로 개념적으로 하나를 표현할 때 사용한다. 조금 쉽게 생각하면 도메인을 이루고 있는 데이터의 단위로 생각할 수 있다.
- 예를 들어 위에서 보았던 `ShippingInfo`의 `receiverName`, `receiverPhoneNumber` 는 결국 `Receiver`라는 하나의 개념으로 표현할 수 있다. 또한 `shippingAddress`, `shippingZipCode` 또한 `Address`라는 하나의 개념으로 표현할 수 있다.
  
  ```typescript
  class ShippingInfo {

    constructor(
      private _receiver: Receiver,
      private _address: Address
    ) { }

  }

  class Receiver {

    get name() {
      return this._name
    }

    get phoneNumber() {
      return this._phoneNumber
    }

    constructor(private _name: string, private _phoneNumber: string) { }
  }

  class Address {

    get address1() {
      return this._address1
    }

    get address2() {
      return this._address2
    }

    get zipCode() {
      return this._zipCode
    }

    constructor(private _address1: string,
      private _address2: string,
      private _zipCode: string) { }
  }

  ```

- `OrerLine`에서 해당 상품 구매의 전체 금액을 의미하는 `amounts` 또한 `Money` 라는 단위로 묶어줄 수 있다. 이를 통해서 단순히 정수 계산이 아닌 돈에 대한 계산(e.g Money의 `add`)과 같이 기능을 추가할 수 있다는 점이다.

  ```typescript
  class OrderLine {
    private amounts: Money;

  constructor(private product: Product,
    private price: Money,
    private quantity: number) {
      this.amounts = new Money(this.price.amount * this.quantity)
  }

  private calculateAmounts() {
    this.amounts = new Money(this.price.amount * this.quantity)
  }


    // Other codes
  }

  class Money {

    get amount() {
      return this._amount
    }

    add(money: number): Money {
      return new Money(this.amount + money)
    }

    constructor(private _amount: number) { }
  }
  ```

#### 밸류 타입은 불변성을 부여하는것이 좋다.

- 밸류타입 일반적으로 불변성을 부여하는것이 좋다.
- 밸류타입의 데이터 변경이 일어나면, `Money` 밸류타입의 `amount`를 변경할때 새로운 `Money` 인스턴스를 반환하는것과 같이 변경된 데이터를 갖는 새로운 밸류 타입을 반환하는것이 좋다.
- 이는 잘못된 객체 참조로 인해 값이 의도치 않게 변경되는것을 방지하기 위함이다.

```typescript
class OrderLine {
  private amounts: Money;

  constructor(private product: Product,
    private price: Money,
    private quantity: number) {
    this.calculateAmounts()
  }

  private calculateAmounts() {
    this.amounts = new Money(this.price.amount * this.quantity)
  }

  printProperties() {
    console.log(`Price: ${this.price.amount} / Quantity: ${this.quantity} / Amount: ${this.amounts.amount}`)
  }

  // Other codes
}

class Money {

  get amount() {
    return this._amount
  }

  set amount(amount: number) {
    this._amount = amount
  }


  add(money: number): Money {
    return new Money(this.amount + money)
  }


  constructor(private _amount: number) { }
}



const price = new Money(1000);
const orderLine = new OrderLine(new Product(), price, 2)
orderLine.printProperties() // Price: 1000 / Quantity: 2 / Amount: 2000
price.amount = 2000
orderLine.printProperties() // Price: 2000 / Quantity: 2 / Amount: 2000 -> Amount가 맞지않다.
```

#### 도메인 모델에 Setter는 되도록 지양할것
- setter를 넣게 되면 도메인 핵심 개념이나 의도를 코드에서 사라지게 한다.(기능의 의미가 선명해지지 않음)
- 또한 setter로 인해 도메인 객체가 완전하지 않은 상태로 생성될 수 있다. 이를 막기 위해서는 생성 시점(생성자)에 필요한것을 모두 전달해주는 방식으로 모델을 설계해야한다.
- setter는 클래스 내부에서 데이터를 변경할 목적으로 정의하되 접근제어자는 `private`으로 지정하여 외부에게는 불변성 성질을 유지하도록 한다.