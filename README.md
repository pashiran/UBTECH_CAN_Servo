# UBTECH 서보 프로토콜 분석 및 문서화

UBTECH(优必选) 로봇 서보 프로토콜을 체계적으로 분석하고 문서화한 프로젝트입니다.

## 📋 프로젝트 개요

이 프로젝트는 UBTECH사의 로봇 서보 및 제어보드의 통신 프로토콜을 완전히 분석하여, Arduino, 라즈베리파이 등 다양한 마이크로컨트롤러에서 사용할 수 있도록 상세히 문서화하였습니다.

## 🔌 프로토콜 분류

UBTECH 서보 시스템은 **3가지 주요 프로토콜**을 사용합니다:

### 1. CAN 버스 프로토콜 (AA 00 00)
**적용 대상**: 60kg/25kg 대형 서보 (1세대 Cruzr 로봇)
- **문서**: [Protocol_CAN_Bus.md](Documents/Protocol_CAN_Bus.md)
- **프레임 헤더**: `AA 00 00`
- **통신 방식**: CAN 2.0
- **보드 레이트**: 500 kbps
- **특징**: 
  - 12비트 정밀도 (0.09도)
  - 고토크 서보 제어
  - 고유 ID 기반 보안

**주요 명령어**:
| 명령 | 기능 | 응용 |
|------|------|------|
| 0x01 | 정보 읽기 | 위치, 버전 조회 |
| 0x03 | 운동 제어 | 위치/속도 제어 |
| 0x07 | ID 수정 | 서보 ID 변경 |
| 0x11 | 잠금 | 토크 유지 잠금 |
| 0x2F | 해제 | 토크 제거 |

---

### 2. Serial 프로토콜 (FA AF / FC CF)
**적용 대상**: 중소형 서보 (A, B, C Type)
- **문서**: [Protocol_Serial.md](Documents/Protocol_Serial.md)
- **프레임 헤더**: `FA AF` (일반) / `FC CF` (펌웨어)
- **통신 방식**: UART Serial
- **보드 레이트**: 115200 bps
- **특징**:
  - Big-Endian 바이트 순서
  - 각도 범위: 0-240도
  - 오프셋 보정 지원

**주요 명령어**:
| 명령 | 기능 | 프레임 헤더 |
|------|------|------------|
| 0x01 | 각도 회전 | FA AF |
| 0x02 | 각도 읽기 | FA AF |
| 0xCD | ID 수정 | FA AF |
| 0xD2 | 오프셋 설정 | FA AF |
| 0xD4 | 오프셋 읽기 | FA AF |
| 0x01 | 펌웨어 버전 | FC CF |
| 0x02 | 펌웨어 업그레이드 | FC CF |

---

### 3. 제어보드 프로토콜 (A9 9A)
**적용 대상**: UBTECH 로봇 통합 제어보드
- **문서**: [Protocol_Control_Board.md](Documents/Protocol_Control_Board.md)
- **프레임 헤더**: `A9 9A`
- **프레임 종료**: `ED`
- **통신 방식**: UART Serial
- **보드 레이트**: 115200 bps
- **특징**:
  - 다중 서보 동시 제어
  - MP3 재생 통합
  - LED 제어
  - 동작 그룹 관리

**명령어 분류**:

#### MP3 재생 명령
| 명령 | 기능 |
|------|------|
| 0x32 | MP3 정지 |
| 0x33 | 파일 재생 (디렉토리/파일) |
| 0x34 | MP3 폴더 재생 |

#### 동작 제어 명령
| 명령 | 기능 |
|------|------|
| 0x41 | 동작 재생 |
| 0x42 | 반복 재생 |
| 0x4F | 재생 중지 |
| 0x75 | 동작 삭제 |
| 0x84 | 특정 포즈 재생 |
| 0x61 | 동작 헤더 읽기 |
| 0x62 | 동작 데이터 읽기 |

#### 서보 제어 명령
| 명령 | 기능 |
|------|------|
| 0x88 | 서보 조회/이동 |
| 0x89 | ID 수정 |
| 0x21 | 잠금 |
| 0x22 | 해제 |
| 0x11 | 모든 서보 조회 |
| 0x96 | 다중 서보 제어 |

#### LED 제어 명령
| 명령 | 기능 |
|------|------|
| 0x97 | LED 제어 (색상/효과) |

---

## 📚 문서 구조

```
Documents/
├── Protocol_CAN_Bus.md          # CAN 버스 프로토콜 (AA 00 00)
├── Protocol_Serial.md            # Serial 프로토콜 (FA AF/FC CF)
├── Protocol_Control_Board.md     # 제어보드 프로토콜 (A9 9A)
└── CAN_Servo_Protocol_Documents/ # 원본 참고 문서
    ├── 01.서보 제어 보드 명령 V0.85.md
    ├── 02 servo_protocol_en.md
    ├── 03 ubtech_servo_communication.md
    ├── 04 유비테크 서보 프로토콜.md
    ├── 05 UBTECH_SERVO_PROTOCOL_V_2.md
    ├── 07 60kg-servo-protocol.md
    └── 08 ActionTable.md
```

## 🛠️ 하드웨어 호환성

### CAN 버스 서보
- **전원**: 24V 3A 이상
- **인터페이스**: USB to CAN 모듈
- **핀 배치**: V+, GND, CANH, CANL

### Serial 서보
- **전원**: 5V (일반 서보)
- **인터페이스**: UART (TTL 레벨)
- **핀 배치**: V, G, TX, RX

### 제어보드
- **전원**: 24V 3A 또는 6S 배터리
- **인터페이스**: UART (TTL 레벨)
- **확장**: WiFi, 블루투스, 적외선, 433MHz

## 💻 예제 코드

각 프로토콜 문서에는 다음 예제 코드가 포함되어 있습니다:
- **Python 예제**: 완전한 클래스 기반 구현
- **Arduino 예제**: UNO 및 Mega2560 호환

### 빠른 시작 - Python

```python
from ubtech_can import UBTechServo

# CAN 버스 서보
servo = UBTechServo()
servo.move_to_angle(servo_id=1, angle=90, speed=150)
```

```python
from ubtech_serial import UBTechServoSerial

# Serial 서보
servo = UBTechServoSerial(port='COM3')
servo.move_to_angle(servo_id=1, angle=90, move_time=100)
```

```python
from ubtech_board import UBTechControlBoard

# 제어보드
board = UBTechControlBoard(port='COM3')
board.action_play(1)
board.servo_multi_move([1,2,3], [90,120,60], 1000)
```

## 🔧 트러블슈팅

각 프로토콜 문서에는 상세한 트러블슈팅 섹션이 포함되어 있습니다:
- 서보 무응답 해결
- 통신 오류 진단
- 각도 보정 방법
- ID 변경 문제
- 하드웨어 배선 확인

## 📊 프로토콜 비교표

| 특성 | CAN 버스 | Serial | 제어보드 |
|------|----------|--------|---------|
| 프레임 헤더 | AA 00 00 | FA AF/FC CF | A9 9A |
| 통신 방식 | CAN 2.0 | UART | UART |
| 속도 | 500 kbps | 115200 bps | 115200 bps |
| 각도 정밀도 | 0.09도 | 1.5도 | 가변 |
| 바이트 순서 | Little-Endian | Big-Endian | 혼합 |
| 다중 제어 | 버스 | 순차 | 동시 |
| 추가 기능 | - | 오프셋 보정 | MP3, LED |

## 🎯 주요 기능

### 모든 프로토콜 공통
- ✅ 서보 위치 제어
- ✅ 각도 읽기
- ✅ ID 변경
- ✅ 잠금/해제

### CAN 버스 프로토콜 전용
- ✅ 고정밀 위치 제어 (12비트)
- ✅ 고유 코드 보안
- ✅ 다중 서보 버스 제어

### Serial 프로토콜 전용
- ✅ 각도 오프셋 보정
- ✅ 펌웨어 업그레이드
- ✅ 잠금 시간 설정

### 제어보드 프로토콜 전용
- ✅ 동작 그룹 재생
- ✅ MP3 재생 제어
- ✅ LED 색상/효과 제어
- ✅ 다중 서보 동시 제어
- ✅ 시교(Teaching) 기능

### 자료 수집 정보

UBTECH 서보 관련 자료는 주로 중국 사이트에서만 확인할 수 있습니다:

- **검색 키워드**: "优必选舵机" (UBTECH = 优必, Robot Servo = 选舵机) 
- **영문 검색**: Google 등에서는 관련 자료가 거의 없음
- **중문 검색**: 바이두(百度) 등 중국 검색엔진에서 자료 확보 가능


## ⚠️ 주의사항

1. **전원 공급**
   - CAN 버스 서보: 24V 3A 이상 필수
   - 불충분한 전원 시 서보 손상 가능

2. **배선**
   - CAN: CANH/CANL 정확히 연결
   - Serial: TX/RX 크로스 연결
   - 극성 확인 필수

3. **ID 관리**
   - 버스에 중복 ID 금지
   - 브로드캐스트 사용 주의

4. **펌웨어 업그레이드**
   - 신중히 진행
   - 전원 끊김 방지

## 📖 사용 가이드

### 1단계: 프로토콜 확인
서보 타입에 맞는 프로토콜 문서 확인:
- 대형 서보(60kg/25kg) → CAN 버스
- 중소형 서보 → Serial
- 제어보드 시스템 → 제어보드

### 2단계: 하드웨어 연결
각 문서의 "하드웨어 연결" 섹션 참조

### 3단계: 예제 코드 실행
Python 또는 Arduino 예제로 테스트

### 4단계: 커스터마이징
프로젝트에 맞게 명령어 조합

## 🤝 기여

이 프로젝트는 오픈소스입니다. 기여를 환영합니다:
- 버그 리포트
- 문서 개선
- 새로운 명령어 발견
- 예제 코드 추가

## 📜 라이센스

이 프로젝트는 학습 및 연구 목적으로만 사용해야 합니다.
상업적 용도로 사용 금지.

## 📞 참고자료

- [UBTECH Robotics 공식 사이트](https://www.ubtrobot.com/)
- 원본 문서: `Documents/CAN_Servo_Protocol_Documents/`

## 🔄 업데이트 이력

- **2025-11-05**: 초기 프로토콜 분석 완료 및 문서화
  - CAN 버스 프로토콜 완전 분석
  - Serial 프로토콜 완전 분석  
  - 제어보드 프로토콜 완전 분석
  - Python/Arduino 예제 코드 작성

---

**개발자**: pashiran  
**문서 버전**: 1.0  
**마지막 업데이트**: 2025-11-05

⚠️ **면책조항**: 본 프로젝트는 참고용으로만 제공됩니다. 사용으로 인한 모든 책임은 사용자에게 있습니다.

