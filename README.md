# Chat-bot(GPT) Project

## 기간
2024.01.02 ~ 2024.01.26

## 개요
OpenAI의 ChatGPT를 사용하여, 사용자에 대한 질문을 챗봇이 답변해주는 앱.

## 사용 기술
`Combine`, `UIKit`, `CoreData`, `XCTest`

## 구현 영상
| 채팅 목록 | 채팅 내역 | 프롬프트 |
| ----------- | --------- | -------- |
| 채팅 목록에서 채팅방 생성하는 짤 | 채팅을 보내고 답변이 오는 짤 | 프롬프트를 설정하고 채팅을 다시 보내는 짤 |

## 객체의 역할
### Application
| 이름 | 타입 | 역할 |
| ---- | ---- | ---- |
| AppEnviroment | `struct` | 자주 쓰이는 타입을 인스턴스화 하여 정적 프로퍼티로 저장하는 컨테이너

### Data
| 이름 | 타입 | 역할 |
| ---- | ---- | ---- |
| DataDecoderable | `protocol` | 데이터를 디코딩하기 위한 프로토콜(추후에 JSON 디코딩 말고 다른 방식도 생길 수 있다고 가정.)
| JSONDecoder | `extension` | DataDecoderable을 채택하고 `try self.decode(_, from: _)`를 통해 내부 구현함.
| DataEncoderable | `protocol` | 데이터를 인코딩하기 위한 프로토콜(추후에 JSON 인코딩 말고 다른 방식도 생길 수 있다고 가정.)
| JSONEnecoder | `extension` | DataDecoderable을 채택하고 `try self.encode(_)`를 통해 내부 구현함.

### Network
| 이름 | 타입 | 역할 |
| ---- | ---- | ---- |
| HTTPPublishable | `protocol` | `URLRequest`를 받아, AnyPublisher로 반환하기 위한 프로토콜
| URLSession | `extension` | `HTTPPublisherable`을 채택하여 `dataTaskPublisher(for: _)`를 활용하여 `AnyPublisher`를 반환.
| HTTPRequestable | `protocol` | EndPoint를 담기 위한 프로토콜
| HTTPServicable | `protocol` | data를 디코딩 및 인코딩하여 서버와 통신하기 위한 프로토콜 |
| GPTHTTPService | `final class` | HTTPServicable을 채택한 클래스 |

#### Diagram

### Repository
| 이름 | 타입 | 역할 |
| ---- | ---- | ---- |
| CoreDataRepository | `final class` | `NSPersistantContainer`를 관리하기 위한 객체 |
| ChatRoomRepositable | `protocol` | 채팅방의 CRUD를 관리하기 위한 프로토콜
| CoreDataChatRoomRepository | `final class` | CoreDataRepository를 활용하여 로컬 저장소에 채팅방을 CRUD를 하기 위한 객체

#### Diagram

## Trouble Shooting
### 재사용 가능한 뷰 모델, ViewModel의 추상화

### Unit Test

## PR List
[STEP 1 PR](https://github.com/tasty-code/ios-chat-bot/pull/4)

[STEP 2 PR](https://github.com/tasty-code/ios-chat-bot/pull/17)

[STEP 3 PR](https://github.com/tasty-code/ios-chat-bot/pull/19)

[STEP 4 PR](https://github.com/tasty-code/ios-chat-bot/pull/24)

[STEP 5 PR](https://github.com/tasty-code/ios-chat-bot/pull/28)