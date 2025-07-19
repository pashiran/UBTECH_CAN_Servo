# UBTECH CAN Servo Controller

UBTECH 서보 모터를 CAN 통신으로 제어하는 Arduino 프로젝트입니다.

## 프로젝트 개요

이 프로젝트는 MCP2515 CAN 컨트롤러를 사용하여 UBTECH 서보 모터와 CAN 통신을 수행하는 Arduino 코드입니다. 서보 모터에 명령을 전송하고 응답을 수신하여 모터 상태를 모니터링할 수 있습니다.

## 하드웨어 요구사항

### 주요 구성품
- Arduino 보드 (Uno, Nano 등)
- MCP2515 CAN BUS Shield/모듈
- UBTECH 서보 모터
- CAN 버스 케이블

### 연결도
```
MCP2515 CAN 모듈 -> Arduino
VCC -> 5V
GND -> GND
CS  -> D10 (핀 10)
SO  -> D12 (MISO)
SI  -> D11 (MOSI)
SCK -> D13 (SCK)
INT -> D2  (인터럽트 핀)
```

## 소프트웨어 요구사항

### 필요한 라이브러리
- **mcp_can**: MCP2515 CAN 컨트롤러용 라이브러리
- **SPI**: SPI 통신용 기본 라이브러리

### 라이브러리 설치 방법
1. Arduino IDE에서 `스케치` > `라이브러리 포함` > `라이브러리 관리`
2. "mcp_can" 검색 후 설치
3. SPI 라이브러리는 Arduino IDE에 기본 포함

## 기능 설명

### 주요 기능
- **CAN 통신 초기화**: 1Mbps 속도로 CAN 버스 초기화
- **명령 전송**: 서보 모터에 제어 명령 전송 (ID: 0xAA)
- **응답 수신**: 서보 모터로부터 상태 정보 수신
- **데이터 수집**: 최대 16바이트까지 연속 데이터 수신 가능

### CAN 통신 설정
- **속도**: 1000 kbps (1 Mbps)
- **크리스탈**: 8MHz
- **모드**: MCP_ANY (표준/확장 프레임 모두 수신)

## 사용법

### 1. 하드웨어 연결
위의 연결도를 참조하여 MCP2515 모듈과 Arduino를 연결합니다.

### 2. 코드 업로드
```bash
# Arduino IDE에서 UBTECH_CAN_Servo.ino 파일을 열고 업로드
```

### 3. 시리얼 모니터 확인
- 보드레이트: 115200
- CAN 초기화 상태 및 송수신 데이터 확인 가능

### 4. 예상 출력
```
CAN BUS Shield init ok!
Message sent to ID 0xAA! Waiting for a response...
Received CAN data from ID: 0x??
Data: 09 00 00 00 00 00 00 00
Full received data: 09 00 00 00 00 00 00 00 ...
```

## 코드 구조

### setup() 함수
- 시리얼 통신 초기화 (115200 bps)
- CAN 버스 초기화 및 설정 확인

### loop() 함수
- 서보 모터에 명령 전송 (0x09 명령)
- 응답 데이터 수신 및 처리
- 수신된 전체 데이터 출력
- 1초 대기 후 반복

## 트러블슈팅

### 일반적인 문제점

#### 1. CAN BUS Shield 초기화 실패
```
CAN BUS Shield init fail
Init CAN BUS Shield again
```
**해결방법:**
- MCP2515 모듈 연결 확인
- 전원 공급 상태 확인 (5V)
- SPI 핀 연결 확인

#### 2. 메시지 전송 실패
```
Failed to send message.
```
**해결방법:**
- CAN 버스 터미네이션 저항 확인 (120Ω)
- CAN H/L 케이블 연결 확인
- 서보 모터 전원 및 CAN ID 확인

#### 3. 응답 수신 없음
**해결방법:**
- 서보 모터 ID 설정 확인
- CAN 버스 속도 일치 확인
- 서보 모터 동작 상태 확인

## 개발 노트

### 현재 제한사항
- CAN 프레임당 최대 8바이트 전송 제한
- 16바이트 데이터 전송을 위해서는 다중 프레임 전송 필요

### 향후 개선 계획
- [ ] 다중 프레임 전송 기능 구현
- [ ] 서보 모터 응답 파싱 기능 추가
- [ ] 에러 처리 및 재시도 로직 강화
- [ ] 다중 서보 모터 제어 기능

## 참고 자료

- [MCP2515 데이터시트](https://ww1.microchip.com/downloads/en/DeviceDoc/MCP2515-Family-Data-Sheet-DS20001801J.pdf)
- [mcp_can 라이브러리 GitHub](https://github.com/coryjfowler/MCP_CAN_lib)
- [UBTECH 서보 모터 통신 프로토콜 문서]

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다.

## 기여

버그 리포트나 기능 개선 제안은 이슈로 등록해 주세요.

---

**개발자**: pashiran  
**최종 업데이트**: 2025년 7월
