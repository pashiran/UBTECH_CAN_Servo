# UBTECH 서보 Serial 통신 프로토콜 (FA AF / FC CF)

> **📝 참고**: 이 문서는 xaobao의 리버스 엔지니어링 분석 결과를 포함합니다.  
> 출처: [xaobao_cheap_bus_servo_hack_record](https://gitee.com/xaobao/cheap_bus_servo_hack_record)

## 문서 개요

이 문서는 UBTECH 서보의 Serial 통신 프로토콜을 상세히 설명합니다. 
xaobao 프로젝트의 리버스 엔지니어링 결과를 바탕으로 다음 내용을 포함합니다:

- **완전한 명령어셋**: FA AF, FC CF 프레임의 모든 명령
- **하드웨어 분석**: ATmega8 기반 서보 내부 구조
- **통신 상세**: 타이밍, 프로토콜, 단일선 버스 방식
- **실전 코드**: Python/Arduino 완전한 예제 코드
- **동작 라이브러리**: 복잡한 서보 동작 관리 구조

## 목차
- [프로토콜 개요](#프로토콜-개요)
- [하드웨어 연결](#하드웨어-연결)
- [통신 설정](#통신-설정)
- [프레임 구조](#프레임-구조)
- [명령어 전체 목록](#명령어-전체-목록)
- [상세 명령어 설명](#상세-명령어-설명)
- [예제 코드](#예제-코드)
- [하드웨어 분석 정보](#하드웨어-분석-정보-xaobao-리버스-엔지니어링)
- [트러블슈팅](#트러블슈팅)

---

## 프로토콜 개요

### 프로토콜 종류
이 프로토콜은 두 가지 프레임 헤더를 사용합니다:

| 프레임 헤더 | 용도 | 종료 바이트 |
|------------|------|------------|
| **FA AF** | 일반 제어 명령 | ED |
| **FC CF** | 펌웨어 관련 명령 | ED |

### 주요 특징
- **통신 방식**: UART (직렬 통신)
- **보드 레이트**: 115200 bps
- **데이터 비트**: 8비트
- **패리티**: None
- **정지 비트**: 1비트
- **흐름 제어**: None
- **바이트 순서**: Big-Endian (상위 바이트 먼저)
- **프레임 길이**: 고정 10바이트
- **응답 타임아웃**: 5-8ms (권장)
- **명령 전송 간격**: 50μs 이상 (권장)

### 적용 대상
- UBTECH 중소형 서보모터
- Serial 통신 기반 서보 제어

---

## 하드웨어 연결

### 핀 연결 (UART 통신)

#### Arduino UNO 연결
| UNO 핀 | 서보 신호 | 설명 |
|--------|----------|------|
| 5V | V | 전원 (5V) |
| GND | G | 접지 |
| D11 (RX) | T | 서보 TX |
| D12 (TX) | R | 서보 RX |

#### Arduino Mega2560 연결
| Mega 핀 | 서보 신호 | 설명 |
|---------|----------|------|
| 5V | V | 전원 (5V) |
| GND | G | 접지 |
| Serial3 RX | T | 서보 TX |
| Serial3 TX | R | 서보 RX |

⚠️ **주의**: TX와 RX는 크로스 연결 (TX ↔ RX)

---

## 통신 설정

### UART 파라미터
```python
# Python Serial 설정 예제
import serial

ser = serial.Serial(
    port='/dev/ttyUSB0',  # 시리얼 포트
    baudrate=115200,       # 보드 레이트
    bytesize=8,            # 데이터 비트
    parity='N',            # 패리티 없음
    stopbits=1,            # 정지 비트
    timeout=1.0            # 타임아웃 (초)
)
```

```cpp
// Arduino 설정 예제
Serial.begin(115200);
```

---

## 프레임 구조

### 명령 패킷 (호스트 → 서보) - FA AF 프레임

| 바이트 | 필드명 | 설명 | 값 범위 |
|--------|--------|------|---------|
| 0 | 프레임 헤더 1 | 고정값 | 0xFA |
| 1 | 프레임 헤더 2 | 고정값 | 0xAF |
| 2 | 서보 ID | 대상 서보 ID | 0-240 (0=전체) |
| 3 | 명령 코드 | 명령 타입 | 0x01, 0x02, 0xCD, 0xD2, 0xD4 |
| 4 | 파라미터 1 상위 | 명령별 파라미터 | 0x00-0xFF |
| 5 | 파라미터 1 하위 | 명령별 파라미터 | 0x00-0xFF |
| 6 | 파라미터 2 상위 | 명령별 파라미터 | 0x00-0xFF |
| 7 | 파라미터 2 하위 | 명령별 파라미터 | 0x00-0xFF |
| 8 | 체크섬 | Byte2~7의 합 하위 | 계산값 |
| 9 | 프레임 종료 | 고정값 | 0xED |

### 명령 패킷 (호스트 → 서보) - FC CF 프레임

| 바이트 | 필드명 | 설명 | 값 범위 |
|--------|--------|------|---------|
| 0 | 프레임 헤더 1 | 고정값 | 0xFC |
| 1 | 프레임 헤더 2 | 고정값 | 0xCF |
| 2 | 서보 ID | 대상 서보 ID | 1-240 |
| 3 | 명령 코드 | 명령 타입 | 0x01, 0x02 |
| 4-7 | 파라미터 | 명령별 파라미터 | 0x00 |
| 8 | 체크섬 | Byte2~7의 합 하위 | 계산값 |
| 9 | 프레임 종료 | 고정값 | 0xED |

### 응답 패킷 (서보 → 호스트)

#### 단일 바이트 응답
일부 명령은 성공 시 단일 바이트만 반환:
```
0xAA + [서보 ID]
```

#### 표준 응답 프레임

| 바이트 | 필드명 | 설명 |
|--------|--------|------|
| 0 | 프레임 헤더 1 | 0xFA 또는 0xFC |
| 1 | 프레임 헤더 2 | 0xAF 또는 0xCF |
| 2 | 서보 ID | 응답한 서보 ID |
| 3 | 명령 코드 | 원래 명령 또는 응답 코드 |
| 4-7 | 응답 데이터 | 명령별 응답 데이터 |
| 8 | 체크섬 | Byte2~7의 합 하위 |
| 9 | 프레임 종료 | 0xED |

### 체크섬 계산

```python
def calculate_checksum(data):
    """Byte2 ~ Byte7의 합계에서 하위 바이트만 추출"""
    checksum = sum(data[2:8]) & 0xFF
    return checksum
```

```cpp
byte calculateChecksum(byte* data) {
    byte sum = 0;
    for(int i = 2; i < 8; i++) {
        sum += data[i];
    }
    return sum & 0xFF;
}
```

---

## 명령어 전체 목록

### FA AF 프레임 명령 (일반 제어)

| 명령 코드 | 명령명 | 기능 | 파라미터 | 응답 형식 |
|-----------|--------|------|----------|-----------|
| 0x01 | 지정 각도 회전 | 각도, 속도, 잠금시간 제어 | 4개 | 단일 바이트 (0xAA+ID) |
| 0x01 (특수) | 강제 정지 | 서보 즉시 정지 및 비활성화 | Byte4=0xFF | 단일 바이트 |
| 0x02 | 각도 읽기 | 현재 각도 조회 | 없음 | 10바이트 프레임 |
| 0xCD | ID 수정 | 서보 ID 변경 | 새 ID | 10바이트 프레임 |
| 0xD2 | 각도 오프셋 설정 | 영점 보정 | 오프셋 값 | 10바이트 프레임 |
| 0xD4 | 각도 오프셋 읽기 | 오프셋 값 조회 | 없음 | 10바이트 프레임 |

### FC CF 프레임 명령 (펌웨어 관련)

| 명령 코드 | 명령명 | 기능 | 파라미터 | 응답 형식 |
|-----------|--------|------|----------|-----------|
| 0x01 | 펌웨어 버전 읽기 | 버전 정보 조회 | 없음 | 10바이트 프레임 |
| 0x02 | 펌웨어 업그레이드 | 부트로더 진입 | 없음 | 10바이트 프레임 |

---

## 상세 명령어 설명

### 1. 지정 각도로 회전 (0x01)

**명령 코드**: 0x01  
**프레임 헤더**: FA AF

#### 송신 프레임
```
FA AF [ID] 01 [ANGLE] [TIME] [LOCK_H] [LOCK_L] [CHK] ED
```

| 필드 | 바이트 | 설명 | 값 범위 |
|------|--------|------|---------|
| 프레임 헤더 | 0-1 | FA AF | 고정 |
| 서보 ID | 2 | 대상 서보 | 0=전체, 1-240 |
| 명령 코드 | 3 | 회전 명령 | 0x01 |
| 목표 각도 | 4 | 각도 값 | 0-240 (도) |
| 동작 시간 | 5 | 이동 시간 | 0-255 (×20ms) |
| 잠금 시간 상위 | 6 | 잠금 시간 MSB | 0-0xFF |
| 잠금 시간 하위 | 7 | 잠금 시간 LSB | 0-0xFF |
| 체크섬 | 8 | 계산값 | - |
| 프레임 종료 | 9 | 고정 | 0xED |

#### 파라미터 상세

**목표 각도 (Byte4)**
- 범위: 0-240도
- 단위: 도 (degree)
- 240도 초과 값은 240도로 제한됨

**동작 시간 (Byte5)**
- 범위: 0-255
- 단위: 20ms
- 실제 시간 = 값 × 20ms
- 0 = 최대 속도로 이동

**잠금 시간 (Byte6-7)**
- 범위: 0-3270 (16비트)
- 단위: 20ms
- 실제 시간 = 값 × 20ms
- 목표 위치 도달 후 해당 시간 동안 강제 위치 유지
- 이 시간 동안 새 명령 무시

#### 응답 형식
성공 시 단일 바이트 응답:
```
0xAA + [서보 ID]
```

예: ID 5번 서보 성공 → `0xAF`

#### 예제

**ID 5 서보를 120도로 2초 동안 이동**
```
FA AF 05 01 78 64 00 00 E2 ED
```
- 목표 각도: 0x78 = 120도
- 동작 시간: 0x64 = 100 → 100×20ms = 2초
- 잠금 시간: 0x0000 = 0초
- 체크섬: 0x05+0x01+0x78+0x64+0x00+0x00 = 0xE2

**ID 3 서보를 90도로 최대 속도로 이동, 1초 잠금**
```
FA AF 03 01 5A 00 00 32 EA ED
```
- 목표 각도: 0x5A = 90도
- 동작 시간: 0x00 = 최대 속도
- 잠금 시간: 0x0032 = 50 → 50×20ms = 1초
- 체크섬: 0x03+0x01+0x5A+0x00+0x00+0x32 = 0x90 → 하위: 0xEA

---

### 2. 강제 회전 정지 (0x01 특수)

**명령 코드**: 0x01 (Byte4=0xFF)  
**프레임 헤더**: FA AF

#### 송신 프레임
```
FA AF [ID] 01 FF 00 00 00 [CHK] ED
```

#### 동작
- 현재 실행 중인 모든 동작 즉시 중지
- 서보 비활성화 (토크 제거)
- 위치 유지 안 됨 (기어 저항만)

#### 예제
```
FA AF 05 01 FF 00 00 00 05 ED
```
- ID 5번 서보 강제 정지

---

### 3. 각도 읽기 (0x02)

**명령 코드**: 0x02  
**프레임 헤더**: FA AF

#### 송신 프레임
```
FA AF [ID] 02 00 00 00 00 [CHK] ED
```

#### 수신 프레임
```
FA AF [ID] [STATUS] [TGT_H] [TGT_L] [ACT_H] [ACT_L] [CHK] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 상태 코드 | 3 | 0xAA=성공, 0xEE=실패 |
| 목표 각도 상위 | 4 | 목표 각도 MSB |
| 목표 각도 하위 | 5 | 목표 각도 LSB |
| 실제 각도 상위 | 6 | 현재 각도 MSB |
| 실제 각도 하위 | 7 | 현재 각도 LSB |

#### 각도 값 해석
```python
target_angle = (byte4 << 8) | byte5
actual_angle = (byte6 << 8) | byte7
```

⚠️ **주의**: 각도 읽기 후 서보는 자동으로 비활성화됩니다.

#### 예제

**송신**:
```
FA AF 03 02 00 00 00 00 05 ED
```

**수신**:
```
FA AF 03 AA 00 5A 00 5A 11 ED
```
- 상태: 0xAA (성공)
- 목표 각도: 0x005A = 90도
- 실제 각도: 0x005A = 90도
- 각도 일치 → 정상

---

### 4. 서보 ID 수정 (0xCD)

**명령 코드**: 0xCD  
**프레임 헤더**: FA AF

#### 송신 프레임
```
FA AF [OLD_ID] CD 00 [NEW_ID] 00 00 [CHK] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 기존 ID | 2 | 현재 서보 ID |
| 명령 코드 | 3 | 0xCD |
| 예약 | 4 | 0x00 |
| 새 ID | 5 | 변경할 ID (1-240) |
| 예약 | 6-7 | 0x00 |

#### 수신 프레임
```
FA AF [NEW_ID] [CMD] 00 [OLD_ID] 00 00 [CHK] ED
```

⚠️ **중요**: 
- ID 변경은 즉시 적용됨
- Byte2는 이미 새 ID로 변경됨
- 브로드캐스트(ID=0) 사용 시 주의 (버스에 서보 1개만 있어야 함)

#### 예제

**ID 5를 ID 10으로 변경**

송신:
```
FA AF 05 CD 00 0A 00 00 D7 ED
```
- 기존 ID: 0x05
- 새 ID: 0x0A
- 체크섬: 0x05+0xCD+0x00+0x0A+0x00+0x00 = 0xD7

수신:
```
FA AF 0A CD 00 05 00 00 D7 ED
```
- 새 ID: 0x0A (이미 변경됨)
- 기존 ID: 0x05 (Byte5)

---

### 5. 각도 오프셋 설정 (0xD2)

**명령 코드**: 0xD2  
**프레임 헤더**: FA AF

#### 송신 프레임
```
FA AF [ID] D2 00 00 [OFFSET_H] [OFFSET_L] [CHK] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 서보 ID | 2 | 대상 서보 |
| 명령 코드 | 3 | 0xD2 |
| 예약 | 4-5 | 0x00 |
| 오프셋 상위 | 6 | 오프셋 MSB (부호 있음) |
| 오프셋 하위 | 7 | 오프셋 LSB |

#### 오프셋 값
- 범위: -90 ~ +90 (16비트 부호 있는 정수)
- 단위: 1/3도
- 각도 범위: -30도 ~ +30도
- 양수: 시계 방향 오프셋
- 음수: 반시계 방향 오프셋

#### 오프셋 계산
```python
# 각도 → 오프셋 값
offset_value = angle_offset * 3

# 음수 처리 (2의 보수)
if offset_value < 0:
    offset_value = 0x10000 + offset_value

offset_h = (offset_value >> 8) & 0xFF
offset_l = offset_value & 0xFF
```

⚠️ **주의**: 
- 전원 재시작 시 오프셋 초기화됨
- ±30도 범위를 초과하지 말 것

#### 수신 프레임
```
FA AF [ID] D2 00 00 00 00 [CHK] ED
```

#### 예제

**ID 3 서보에 +10도 오프셋 설정**
```
FA AF 03 D2 00 00 00 1E E7 ED
```
- 오프셋 값: 10도 × 3 = 30 (0x001E)
- 체크섬: 0x03+0xD2+0x00+0x00+0x00+0x1E = 0xE7

**ID 5 서보에 -5도 오프셋 설정**
```
FA AF 05 D2 00 00 FF F1 C2 ED
```
- 오프셋 값: -5도 × 3 = -15 (0xFFF1, 2의 보수)
- 체크섬: 계산값

---

### 6. 각도 오프셋 읽기 (0xD4)

**명령 코드**: 0xD4  
**프레임 헤더**: FA AF

#### 송신 프레임
```
FA AF [ID] D4 00 00 00 00 [CHK] ED
```

#### 수신 프레임
```
FA AF [ID] D4 XX XX [OFFSET_H] [OFFSET_L] [CHK] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 명령 코드 | 3 | 0xD4 |
| 불확정 | 4-5 | 무시 |
| 오프셋 상위 | 6 | 오프셋 MSB |
| 오프셋 하위 | 7 | 오프셋 LSB |

#### 예제

**송신**:
```
FA AF 03 D4 00 00 00 00 D7 ED
```

**수신**:
```
FA AF 03 D4 XX XX 00 1E XX ED
```
- 오프셋 값: 0x001E = 30 → 10도

---

### 7. 펌웨어 버전 읽기 (0x01)

**명령 코드**: 0x01  
**프레임 헤더**: FC CF

#### 송신 프레임
```
FC CF [ID] 01 00 00 00 00 [CHK] ED
```

⚠️ **주의**: 하나의 서보 ID만 지정 (브로드캐스트 사용 불가)

#### 수신 프레임
```
FC CF [ID] 01 [VER1] [VER2] [VER3] [VER4] [CHK] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 버전 번호 1-4 | 4-7 | 펌웨어 버전 정보 |

#### 예제

**송신**:
```
FC CF 05 01 00 00 00 00 06 ED
```

**수신**:
```
FC CF 05 01 01 02 03 04 10 ED
```
- 버전: 1.2.3.4

---

### 8. 펌웨어 업그레이드 (0x02)

**명령 코드**: 0x02  
**프레임 헤더**: FC CF

#### 송신 프레임
```
FC CF [ID] 02 00 00 00 00 [CHK] ED
```

#### 동작
- 서보가 부트로더로 전환됨
- 펌웨어 다운로드 모드 진입
- 부트로더 프로토콜은 별도 분석 필요

#### 수신 프레임
```
FC CF [ID] 02 XX XX XX XX [CHK] ED
```

⚠️ **경고**: 펌웨어 업그레이드 전 충분히 검토하세요.

---

## 예제 코드

### 기본 통신 함수 (xaobao 기반)

#### Python 기본 통신 함수

```python
import serial
import time

def serial_write_read(ser, send_data, recv_len):
    """명령 전송 및 응답 수신
    
    Args:
        ser: serial.Serial 객체
        send_data: 전송할 바이트 리스트
        recv_len: 수신 예상 바이트 수
    
    Returns:
        수신한 바이트 리스트
    """
    # 50μs 지연 (명령 간 최소 간격)
    time.sleep(0.00005)
    
    # 데이터 전송
    ser.write(bytes(send_data))
    
    # 응답 수신
    recv = []
    while len(recv) < recv_len:
        rbyte = ser.read(1)
        if rbyte == b'':
            print('Timeout')
            break
        recv.append(ord(rbyte))
    
    return recv

def checksum(cmd):
    """체크섬 계산 (Byte2~7의 합)"""
    return sum(cmd[2:8]) & 0xFF

def send_servo_motion(ser, servo_id, angle, move_time, is_absolute=True):
    """서보 각도 명령 전송
    
    Args:
        ser: serial.Serial 객체
        servo_id: 서보 ID (1-240)
        angle: 목표 각도 (0-240도) 또는 상대 각도 (-240~240)
        move_time: 동작 시간 (ms)
        is_absolute: True=절대각도, False=상대각도
    
    Returns:
        0: 성공, 1: 실패
    """
    cmd = [0xFA, 0xAF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xED]
    
    # 상대 각도 모드인 경우 현재 각도 먼저 읽기
    if not is_absolute:
        if angle == 0:
            return 0  # 이동 없음
        
        # 현재 각도 읽기
        cmd[2] = servo_id
        cmd[3] = 0x02  # 각도 읽기
        cmd[4] = 0x00
        cmd[5] = 0x00
        cmd[6] = 0x00
        cmd[7] = 0x00
        cmd[8] = checksum(cmd)
        
        recv = serial_write_read(ser, cmd, 10)
        if len(recv) < 10:
            return 1
        
        current_angle = recv[7]
        angle = current_angle + angle
    
    # 각도 제한
    if angle < 0:
        angle = 0
    elif angle > 240:
        angle = 240
    
    # 각도 설정 명령
    cmd[2] = servo_id
    cmd[3] = 0x01  # 각도 설정
    cmd[4] = angle & 0xFF
    cmd[5] = int(move_time / 20) & 0xFF  # ms를 20ms 단위로 변환
    cmd[6] = 0x00
    cmd[7] = 0x00
    cmd[8] = checksum(cmd)
    
    serial_write_read(ser, cmd, 1)  # 단일 바이트 ACK
    
    return 0
```

#### Arduino 기본 통신 함수

```cpp
// 시리얼 전송 및 수신
void serial_write_read(uint8_t* recv, uint8_t rsz, uint8_t* send, uint8_t ssz)
{
    delayMicroseconds(50);  // 명령 간 최소 지연
    
    // 데이터 전송
    for(uint8_t i = 0; i < ssz; i++)
    {
        Serial.write(send[i]);
        Serial.flush();
    }
    
    // 응답 수신
    Serial.readBytes(recv, rsz);
}

// 체크섬 계산
uint8_t checksum(uint8_t* buf, uint8_t sz)
{
    uint16_t sum = 0;
    for(uint8_t i = 0; i < sz; i++)
        sum += buf[i];
    return (uint8_t)(sum & 0xff);
}

// 서보 각도 명령 전송
int send_servo_motion(uint8_t servo_id, int16_t angle, uint16_t move_time, bool is_absolute)
{
    static uint8_t cmd[10] = {0xFA, 0xAF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xED};
    
    // 상대 각도 모드
    if(!is_absolute)
    {
        if(angle == 0) return 0;  // 이동 없음
        
        // 현재 각도 읽기
        cmd[2] = servo_id;
        cmd[3] = 0x02;  // 각도 읽기
        cmd[4] = 0x00;
        cmd[5] = 0x00;
        cmd[6] = 0x00;
        cmd[7] = 0x00;
        cmd[8] = checksum(&cmd[2], 6);
        
        serial_write_read(cmd, 10, cmd, 10);
        
        int16_t current_angle = cmd[7];
        angle = current_angle + angle;
    }
    
    // 각도 제한
    if(angle < 0) angle = 0;
    if(angle > 240) angle = 240;
    
    // 각도 설정 명령
    cmd[2] = servo_id;
    cmd[3] = 0x01;  // 각도 설정
    cmd[4] = angle & 0xFF;
    cmd[5] = (move_time / 20) & 0xFF;  // ms를 20ms 단위로
    cmd[6] = 0x00;
    cmd[7] = 0x00;
    cmd[8] = checksum(&cmd[2], 6);
    
    serial_write_read(&cmd[3], 1, cmd, 10);  // 단일 바이트 ACK
    
    return 0;
}
```

### 동작 라이브러리 구조 (xaobao 방식)

xaobao 프로젝트에서는 복잡한 서보 동작을 계층적으로 관리하는 구조를 제시합니다:

#### 1. 서보 모션 구조체

```cpp
// 서보 기본 동작 (ServoMotion)
typedef struct {
    int16_t angle;     // 각도 (도 단위)
    int8_t  type;      // 0=절대각도(ABSA), 1=상대각도(RELA)
    int16_t time;      // 동작 시간 (ms)
} ServoMotion;
```

```python
# Python 버전
servo_motion = [angle, type, time]
# angle: 각도 (도)
# type: 0=절대각도, 1=상대각도
# time: 동작 시간 (ms)
```

#### 2. 애니메이션 유닛 구조체

```cpp
// 복합 동작 유닛 (AnimationUnit)
typedef struct {
    int16_t mid;      // 모션 라이브러리 ID
    int16_t delay;    // 다음 동작까지 지연 (ms)
    uint8_t speed;    // 속도 인자 (25-50, 50=100% 속도)
} AnimationUnit;
```

속도 인자 설명:
- `speed = 50`: 표준 속도 (100%)
- `speed = 40`: 80% 속도 (더 빠름)
- `speed = 60`: 120% 속도 (더 느림)
- 실제 시간 = 기본 시간 × speed / 50

#### 3. 모션 라이브러리 (Flash 저장)

```cpp
// 최대 9개 서보의 기본 동작 저장
const ServoMotion motion_lib[][9] PROGMEM = {
    // 동작 0: 모든 서보 0도로
    {{0,0,1000}, {0,0,1000}, {0,0,1000}, {0,0,1000}, {0,0,1000}, 
     {0,0,1000}, {0,0,1000}, {0,0,1000}, {0,0,1000}},
    
    // 동작 1: 1번 서보만 90도로 (+90도 상대 이동)
    {{90,1,1000}, {0,1,0}, {0,1,0}, {0,1,0}, {0,1,0}, 
     {0,1,0}, {0,1,0}, {0,1,0}, {0,1,0}},
    
    // 동작 2: 모든 서보 90도로
    {{90,0,1000}, {90,0,1000}, {90,0,1000}, {90,0,1000}, {90,0,1000}, 
     {90,0,1000}, {90,0,1000}, {90,0,1000}, {90,0,1000}},
    
    // ... 추가 동작들
};
```

#### 4. 애니메이션 시퀀스 (Flash 저장)

```cpp
// 기본 동작을 조합하여 복잡한 시퀀스 생성
const AnimationUnit animation[] PROGMEM = {
    // 초기화: 모든 서보 0도로, 2초 대기, 표준 속도
    {0, 2000, 50},
    
    // 1번 서보 90도, 900ms 대기, 110% 속도
    {1, 900, 45},
    
    // 2번 서보 90도, 900ms 대기, 110% 속도
    {2, 900, 45},
    
    // 모든 서보 180도, 1.5초 대기, 80% 속도
    {3, 1500, 40},
    
    // ... 계속
};
```

#### 5. 애니메이션 실행 함수

```cpp
int animation_start(int mode, ServoObj* servos, int servo_count, 
                    AnimationUnit* anim, int anim_len)
{
    int step = 0;
    ServoMotion motions[9];
    
    do {
        while(step < anim_len)
        {
            // Flash에서 애니메이션 유닛 로드
            AnimationUnit au;
            memcpy_P(&au, &anim[step], sizeof(AnimationUnit));
            
            // Flash에서 해당 모션 로드
            memcpy_P(motions, &motion_lib[au.mid][0], 
                     servo_count * sizeof(ServoMotion));
            
            // 각 서보에 명령 전송
            for(int i = 0; i < servo_count; i++)
            {
                // 속도 보정 적용
                uint32_t adjusted_time = motions[i].time * au.speed / 50;
                
                if(send_servo_motion(servos[i].id, motions[i].angle, 
                                    adjusted_time, motions[i].type))
                {
                    return 1;  // 오류
                }
            }
            
            // 다음 동작까지 대기
            delay(au.delay);
            step++;
        }
        
        step = 0;  // 반복 모드면 처음으로
        
    } while(mode == LOOP_MODE);
    
    return 0;
}
```

#### 6. 사용 예제

```cpp
void setup() {
    Serial.begin(115200);
    
    // 서보 객체 초기화
    ServoObj servos[9] = {
        {1, 0, 0}, {2, 0, 0}, {3, 0, 0},
        {4, 0, 0}, {5, 0, 0}, {6, 0, 0},
        {7, 0, 0}, {8, 0, 0}, {9, 0, 0}
    };
}

void loop() {
    // 애니메이션 실행 (1회만)
    animation_start(ONCE_MODE, servos, 9, 
                   (AnimationUnit*)animation, 
                   sizeof(animation)/sizeof(AnimationUnit));
    
    delay(5000);
}
```

### Python 전체 클래스 예제

```python
import serial
import time

class UBTechServoSerial:
    def __init__(self, port='/dev/ttyUSB0', baudrate=115200):
        """Serial 초기화"""
        self.ser = serial.Serial(
            port=port,
            baudrate=baudrate,
            bytesize=8,
            parity='N',
            stopbits=1,
            timeout=0.008  # 8ms 타임아웃
        )
        time.sleep(0.1)
    
    def calculate_checksum(self, data):
        """체크섬 계산 (Byte2~7)"""
        return sum(data[2:8]) & 0xFF
    
    def send_command(self, cmd_data):
        """명령 전송"""
        # 50μs 지연
        time.sleep(0.00005)
        
        # 체크섬 계산 및 추가
        checksum = self.calculate_checksum(cmd_data)
        cmd_data[8] = checksum
        
        # 전송
        self.ser.write(bytes(cmd_data))
    
    def read_response(self, expected_len=10):
        """응답 읽기"""
        response = self.ser.read(expected_len)
        return list(response) if response else None
    
    def move_to_angle(self, servo_id, angle, move_time=0, lock_time=0):
        """각도로 이동 (절대 각도)
        
        Args:
            servo_id: 서보 ID (1-240, 0=전체)
            angle: 목표 각도 (0-240도)
            move_time: 동작 시간 (0-255, ×20ms, 0=최대속도)
            lock_time: 잠금 시간 (0-3270, ×20ms)
        
        Returns:
            True: 성공, False: 실패
        """
        lock_h = (lock_time >> 8) & 0xFF
        lock_l = lock_time & 0xFF
        
        cmd = [0xFA, 0xAF, servo_id, 0x01, 
               angle, move_time, lock_h, lock_l, 
               0x00, 0xED]
        
        self.send_command(cmd)
        
        # 단일 바이트 응답 확인
        resp = self.ser.read(1)
        if resp:
            expected = 0xAA + servo_id
            return resp[0] == expected
        return False
    
    def move_relative(self, servo_id, angle_delta, move_time=0):
        """상대 각도 이동
        
        Args:
            servo_id: 서보 ID
            angle_delta: 각도 변화량 (-240 ~ +240)
            move_time: 동작 시간 (0-255, ×20ms)
        
        Returns:
            True: 성공, False: 실패
        """
        # 현재 각도 읽기
        current = self.read_angle(servo_id)
        if current is None:
            return False
        
        target_angle = current['actual'] + angle_delta
        
        # 각도 제한
        target_angle = max(0, min(240, target_angle))
        
        return self.move_to_angle(servo_id, target_angle, move_time)
    
    def stop_servo(self, servo_id):
        """서보 강제 정지"""
        cmd = [0xFA, 0xAF, servo_id, 0x01, 
               0xFF, 0x00, 0x00, 0x00, 
               0x00, 0xED]
        
        self.send_command(cmd)
    
    def read_angle(self, servo_id):
        """각도 읽기
        
        Returns:
            {'target': 목표각도, 'actual': 실제각도} 또는 None
        """
        cmd = [0xFA, 0xAF, servo_id, 0x02, 
               0x00, 0x00, 0x00, 0x00, 
               0x00, 0xED]
        
        self.send_command(cmd)
        time.sleep(0.01)
        
        resp = self.read_response(10)
        if resp and len(resp) == 10:
            if resp[0] == 0xFA and resp[1] == 0xAF and resp[3] == 0xAA:
                target = (resp[4] << 8) | resp[5]
                actual = (resp[6] << 8) | resp[7]
                return {'target': target, 'actual': actual}
        
        return None
    
    def change_id(self, old_id, new_id):
        """서보 ID 변경
        
        Returns:
            True: 성공, False: 실패
        """
        cmd = [0xFA, 0xAF, old_id, 0xCD, 
               0x00, new_id, 0x00, 0x00, 
               0x00, 0xED]
        
        self.send_command(cmd)
        time.sleep(0.05)
        
        resp = self.read_response(10)
        if resp and len(resp) == 10:
            return resp[2] == new_id
        
        return False
    
    def set_angle_offset(self, servo_id, offset_degree):
        """각도 오프셋 설정 (-30 ~ +30도)"""
        offset_value = int(offset_degree * 3)
        
        # 음수 처리 (2의 보수)
        if offset_value < 0:
            offset_value = 0x10000 + offset_value
        
        offset_h = (offset_value >> 8) & 0xFF
        offset_l = offset_value & 0xFF
        
        cmd = [0xFA, 0xAF, servo_id, 0xD2, 
               0x00, 0x00, offset_h, offset_l, 
               0x00, 0xED]
        
        self.send_command(cmd)
        time.sleep(0.05)
        
        resp = self.read_response(10)
        return resp is not None
    
    def read_angle_offset(self, servo_id):
        """각도 오프셋 읽기
        
        Returns:
            오프셋 각도 (도) 또는 None
        """
        cmd = [0xFA, 0xAF, servo_id, 0xD4, 
               0x00, 0x00, 0x00, 0x00, 
               0x00, 0xED]
        
        self.send_command(cmd)
        time.sleep(0.05)
        
        resp = self.read_response(10)
        if resp and len(resp) == 10:
            offset_raw = (resp[6] << 8) | resp[7]
            
            # 부호 있는 정수로 변환
            if offset_raw > 0x7FFF:
                offset_raw = offset_raw - 0x10000
            
            return offset_raw / 3.0
        
        return None
    
    def read_firmware_version(self, servo_id):
        """펌웨어 버전 읽기
        
        Returns:
            [v1, v2, v3, v4] 또는 None
        """
        cmd = [0xFC, 0xCF, servo_id, 0x01, 
               0x00, 0x00, 0x00, 0x00, 
               0x00, 0xED]
        
        self.send_command(cmd)
        time.sleep(0.05)
        
        resp = self.read_response(10)
        if resp and len(resp) == 10:
            if resp[0] == 0xFC and resp[1] == 0xCF:
                return resp[4:8]
        
        return None
    
    def close(self):
        """시리얼 포트 닫기"""
        if self.ser.is_open:
            self.ser.close()

# 사용 예제
if __name__ == "__main__":
    servo = UBTechServoSerial('/dev/ttyUSB0')
    
    try:
        print("서보 제어 시작")
        
        # 0도로 이동
        print("0도로 이동")
        servo.move_to_angle(1, 0, 100)
        time.sleep(2)
        
        # 90도로 이동
        print("90도로 이동")
        servo.move_to_angle(1, 90, 100)
        time.sleep(2)
        
        # 상대 각도 이동 (+45도)
        print("상대 +45도 이동")
        servo.move_relative(1, 45, 100)
        time.sleep(2)
        
        # 각도 읽기
        angle_data = servo.read_angle(1)
        if angle_data:
            print(f"목표: {angle_data['target']}도, 실제: {angle_data['actual']}도")
        
        # 오프셋 설정
        print("오프셋 +5도 설정")
        servo.set_angle_offset(1, 5)
        
        # 오프셋 읽기
        offset = servo.read_angle_offset(1)
        if offset is not None:
            print(f"오프셋: {offset}도")
        
        # 펌웨어 버전
        version = servo.read_firmware_version(1)
        if version:
            print(f"펌웨어 버전: {version[0]}.{version[1]}.{version[2]}.{version[3]}")
        
    finally:
        servo.close()
        print("종료")
```

### Arduino 전체 클래스 예제

```cpp
#include <SoftwareSerial.h>

// SoftwareSerial 설정 (RX=11, TX=12)
SoftwareSerial servoSerial(11, 12);

class UBTechServo {
private:
    Stream* serial;
    
    byte calculateChecksum(byte* data) {
        byte sum = 0;
        for(int i = 2; i < 8; i++) {
            sum += data[i];
        }
        return sum & 0xFF;
    }
    
    void sendCommand(byte* cmd) {
        delayMicroseconds(50);  // 명령 간 최소 지연
        
        // 체크섬 계산
        cmd[8] = calculateChecksum(cmd);
        
        // 전송
        for(int i = 0; i < 10; i++) {
            serial->write(cmd[i]);
        }
        serial->flush();
    }
    
    int readResponse(byte* buf, int len) {
        int count = 0;
        unsigned long startTime = millis();
        
        while(count < len && (millis() - startTime) < 50) {
            if(serial->available() > 0) {
                buf[count++] = serial->read();
            }
        }
        
        return count;
    }

public:
    UBTechServo(Stream* s) : serial(s) {}
    
    bool moveToAngle(byte id, byte angle, byte moveTime=0, uint16_t lockTime=0) {
        /**
         * 각도로 이동 (절대 각도)
         * 
         * id: 서보 ID (1-240, 0=전체)
         * angle: 목표 각도 (0-240)
         * moveTime: 동작 시간 (0-255, ×20ms, 0=최대속도)
         * lockTime: 잠금 시간 (0-3270, ×20ms)
         */
        byte lockH = (lockTime >> 8) & 0xFF;
        byte lockL = lockTime & 0xFF;
        
        byte cmd[10] = {0xFA, 0xAF, id, 0x01, 
                        angle, moveTime, lockH, lockL, 
                        0x00, 0xED};
        
        sendCommand(cmd);
        
        // 단일 바이트 응답 확인
        if(serial->available() > 0) {
            byte resp = serial->read();
            byte expected = 0xAA + id;
            return (resp == expected);
        }
        return false;
    }
    
    bool moveRelative(byte id, int16_t angleDelta, byte moveTime=0) {
        /**
         * 상대 각도 이동
         * 
         * id: 서보 ID
         * angleDelta: 각도 변화량 (-240 ~ +240)
         * moveTime: 동작 시간 (0-255, ×20ms)
         */
        // 현재 각도 읽기
        uint16_t target, actual;
        if(!readAngle(id, &target, &actual)) {
            return false;
        }
        
        int16_t newAngle = actual + angleDelta;
        
        // 각도 제한
        if(newAngle < 0) newAngle = 0;
        if(newAngle > 240) newAngle = 240;
        
        return moveToAngle(id, (byte)newAngle, moveTime);
    }
    
    void stopServo(byte id) {
        /**
         * 서보 강제 정지
         */
        byte cmd[10] = {0xFA, 0xAF, id, 0x01, 
                        0xFF, 0x00, 0x00, 0x00, 
                        0x00, 0xED};
        sendCommand(cmd);
    }
    
    bool readAngle(byte id, uint16_t* target, uint16_t* actual) {
        /**
         * 각도 읽기
         * 
         * target: 목표 각도 저장
         * actual: 실제 각도 저장
         * 
         * 반환: 성공 여부
         */
        byte cmd[10] = {0xFA, 0xAF, id, 0x02, 
                        0x00, 0x00, 0x00, 0x00, 
                        0x00, 0xED};
        
        sendCommand(cmd);
        delay(10);
        
        byte resp[10];
        if(readResponse(resp, 10) == 10) {
            if(resp[0] == 0xFA && resp[1] == 0xAF && resp[3] == 0xAA) {
                *target = (resp[4] << 8) | resp[5];
                *actual = (resp[6] << 8) | resp[7];
                return true;
            }
        }
        return false;
    }
    
    bool changeID(byte oldID, byte newID) {
        /**
         * 서보 ID 변경
         */
        byte cmd[10] = {0xFA, 0xAF, oldID, 0xCD, 
                        0x00, newID, 0x00, 0x00, 
                        0x00, 0xED};
        
        sendCommand(cmd);
        delay(50);
        
        byte resp[10];
        if(readResponse(resp, 10) == 10) {
            return (resp[2] == newID);
        }
        return false;
    }
    
    bool setAngleOffset(byte id, int8_t offsetDegree) {
        /**
         * 각도 오프셋 설정 (-30 ~ +30도)
         */
        int16_t offsetValue = offsetDegree * 3;
        
        // 음수 처리 (2의 보수)
        if(offsetValue < 0) {
            offsetValue = 0x10000 + offsetValue;
        }
        
        byte offsetH = (offsetValue >> 8) & 0xFF;
        byte offsetL = offsetValue & 0xFF;
        
        byte cmd[10] = {0xFA, 0xAF, id, 0xD2, 
                        0x00, 0x00, offsetH, offsetL, 
                        0x00, 0xED};
        
        sendCommand(cmd);
        delay(50);
        
        byte resp[10];
        return (readResponse(resp, 10) == 10);
    }
    
    bool readAngleOffset(byte id, float* offsetDegree) {
        /**
         * 각도 오프셋 읽기
         */
        byte cmd[10] = {0xFA, 0xAF, id, 0xD4, 
                        0x00, 0x00, 0x00, 0x00, 
                        0x00, 0xED};
        
        sendCommand(cmd);
        delay(50);
        
        byte resp[10];
        if(readResponse(resp, 10) == 10) {
            int16_t offsetRaw = (resp[6] << 8) | resp[7];
            
            // 부호 있는 정수로 변환
            if(offsetRaw > 0x7FFF) {
                offsetRaw = offsetRaw - 0x10000;
            }
            
            *offsetDegree = offsetRaw / 3.0;
            return true;
        }
        
        return false;
    }
    
    bool readFirmwareVersion(byte id, byte* version) {
        /**
         * 펌웨어 버전 읽기
         * 
         * version: 4바이트 배열
         */
        byte cmd[10] = {0xFC, 0xCF, id, 0x01, 
                        0x00, 0x00, 0x00, 0x00, 
                        0x00, 0xED};
        
        sendCommand(cmd);
        delay(50);
        
        byte resp[10];
        if(readResponse(resp, 10) == 10) {
            if(resp[0] == 0xFC && resp[1] == 0xCF) {
                for(int i = 0; i < 4; i++) {
                    version[i] = resp[4 + i];
                }
                return true;
            }
        }
        
        return false;
    }
};

UBTechServo* servo;

void setup() {
    Serial.begin(115200);
    servoSerial.begin(115200);
    servoSerial.setTimeout(8);  // 8ms 타임아웃
    
    servo = new UBTechServo(&servoSerial);
    
    Serial.println("UBTECH 서보 제어 시작");
    delay(1000);
}

void loop() {
    uint16_t target, actual;
    float offset;
    byte version[4];
    
    // 0도로 이동
    Serial.println("0도로 이동");
    if(servo->moveToAngle(1, 0, 100)) {
        Serial.println("명령 성공");
    }
    delay(2000);
    
    // 90도로 이동
    Serial.println("90도로 이동");
    servo->moveToAngle(1, 90, 100);
    delay(2000);
    
    // 상대 +45도 이동
    Serial.println("상대 +45도 이동");
    servo->moveRelative(1, 45, 100);
    delay(2000);
    
    // 각도 읽기
    if(servo->readAngle(1, &target, &actual)) {
        Serial.print("목표: ");
        Serial.print(target);
        Serial.print("도, 실제: ");
        Serial.print(actual);
        Serial.println("도");
    }
    
    // 오프셋 설정
    Serial.println("오프셋 +5도 설정");
    servo->setAngleOffset(1, 5);
    delay(500);
    
    // 오프셋 읽기
    if(servo->readAngleOffset(1, &offset)) {
        Serial.print("오프셋: ");
        Serial.print(offset);
        Serial.println("도");
    }
    
    // 펌웨어 버전
    if(servo->readFirmwareVersion(1, version)) {
        Serial.print("펌웨어 버전: ");
        Serial.print(version[0]);
        Serial.print(".");
        Serial.print(version[1]);
        Serial.print(".");
        Serial.print(version[2]);
        Serial.print(".");
        Serial.println(version[3]);
    }
    
    delay(5000);
}
```

---

## 하드웨어 분석 정보 (xaobao 리버스 엔지니어링)
            if resp[3] == 0xAA:  # 성공
                target = (resp[4] << 8) | resp[5]
                actual = (resp[6] << 8) | resp[7]
                return {
                    'target': target,
                    'actual': actual,
                    'match': target == actual
                }
        return None
    
    def change_id(self, old_id, new_id):
        """ID 변경"""
        cmd = [0xFA, 0xAF, old_id, 0xCD, 
               0x00, new_id, 0x00, 0x00, 
               0x00, 0xED]
        
        self.send_command(cmd)
        resp = self.read_response(10)
        
        if resp and len(resp) == 10:
            if resp[2] == new_id:
                print(f"ID 변경 성공: {old_id} → {new_id}")
                return True
        return False
    
    def set_angle_offset(self, servo_id, offset_degree):
        """각도 오프셋 설정
        
        Args:
            servo_id: 서보 ID
            offset_degree: 오프셋 각도 (-30 ~ +30도)
        """
        # 각도를 오프셋 값으로 변환
        offset_value = int(offset_degree * 3)
        
        # 음수 처리 (2의 보수)
        if offset_value < 0:
            offset_value = 0x10000 + offset_value
        
        offset_h = (offset_value >> 8) & 0xFF
        offset_l = offset_value & 0xFF
        
        cmd = [0xFA, 0xAF, servo_id, 0xD2, 
               0x00, 0x00, offset_h, offset_l, 
               0x00, 0xED]
        
        self.send_command(cmd)
        resp = self.read_response(10)
        
        if resp:
            print(f"오프셋 설정 완료: {offset_degree}도")
            return True
        return False
    
    def read_angle_offset(self, servo_id):
        """각도 오프셋 읽기"""
        cmd = [0xFA, 0xAF, servo_id, 0xD4, 
               0x00, 0x00, 0x00, 0x00, 
               0x00, 0xED]
        
        self.send_command(cmd)
        resp = self.read_response(10)
        
        if resp and len(resp) == 10:
            offset_value = (resp[6] << 8) | resp[7]
            
            # 음수 처리
            if offset_value > 0x7FFF:
                offset_value = offset_value - 0x10000
            
            offset_degree = offset_value / 3.0
            return offset_degree
        return None
    
    def read_firmware_version(self, servo_id):
        """펌웨어 버전 읽기"""
        cmd = [0xFC, 0xCF, servo_id, 0x01, 
               0x00, 0x00, 0x00, 0x00, 
               0x00, 0xED]
        
        self.send_command(cmd)
        resp = self.read_response(10)
        
        if resp and len(resp) == 10:
            version = f"{resp[4]}.{resp[5]}.{resp[6]}.{resp[7]}"
            return version
        return None
    
    def close(self):
        """시리얼 포트 닫기"""
        if self.ser.is_open:
            self.ser.close()

# 사용 예제
if __name__ == "__main__":
    servo = UBTechServoSerial(port='COM3')  # Windows
    # servo = UBTechServoSerial(port='/dev/ttyUSB0')  # Linux
    
    try:
        # 1. 각도 읽기
        print("현재 각도 읽기...")
        angle_data = servo.read_angle(servo_id=1)
        if angle_data:
            print(f"목표: {angle_data['target']}도")
            print(f"실제: {angle_data['actual']}도")
        
        # 2. 90도로 2초 동안 이동
        print("\n90도로 이동...")
        servo.move_to_angle(servo_id=1, angle=90, move_time=100)
        time.sleep(2.5)
        
        # 3. 180도로 최대 속도 이동
        print("\n180도로 이동...")
        servo.move_to_angle(servo_id=1, angle=180, move_time=0)
        time.sleep(2)
        
        # 4. 오프셋 설정
        print("\n오프셋 +5도 설정...")
        servo.set_angle_offset(servo_id=1, offset_degree=5)
        
        # 5. 오프셋 읽기
        print("\n오프셋 읽기...")
        offset = servo.read_angle_offset(servo_id=1)
        print(f"현재 오프셋: {offset}도")
        
        # 6. 펌웨어 버전 읽기
        print("\n펌웨어 버전 읽기...")
        version = servo.read_firmware_version(servo_id=1)
        print(f"펌웨어 버전: {version}")
        
    finally:
        servo.close()
```

### Arduino 예제

```cpp
#include <SoftwareSerial.h>

// 소프트웨어 시리얼 (UNO의 경우)
SoftwareSerial servoSerial(11, 12); // RX, TX

class UBTechServo {
private:
    Stream* serial;
    
    byte calculateChecksum(byte* data) {
        byte sum = 0;
        for(int i = 2; i < 8; i++) {
            sum += data[i];
        }
        return sum & 0xFF;
    }
    
public:
    UBTechServo(Stream* ser) : serial(ser) {}
    
    void sendCommand(byte* cmd) {
        // 체크섬 계산
        cmd[8] = calculateChecksum(cmd);
        
        // 전송
        serial->write(cmd, 10);
        delay(10);
    }
    
    bool moveToAngle(byte id, byte angle, byte moveTime=0, uint16_t lockTime=0) {
        byte lockH = (lockTime >> 8) & 0xFF;
        byte lockL = lockTime & 0xFF;
        
        byte cmd[10] = {0xFA, 0xAF, id, 0x01, 
                        angle, moveTime, lockH, lockL, 
                        0x00, 0xED};
        
        sendCommand(cmd);
        
        // 응답 확인 (단일 바이트)
        if(serial->available() > 0) {
            byte resp = serial->read();
            byte expected = 0xAA + id;
            return (resp == expected);
        }
        return false;
    }
    
    void stopServo(byte id) {
        byte cmd[10] = {0xFA, 0xAF, id, 0x01, 
                        0xFF, 0x00, 0x00, 0x00, 
                        0x00, 0xED};
        sendCommand(cmd);
    }
    
    bool readAngle(byte id, uint16_t* target, uint16_t* actual) {
        byte cmd[10] = {0xFA, 0xAF, id, 0x02, 
                        0x00, 0x00, 0x00, 0x00, 
                        0x00, 0xED};
        
        sendCommand(cmd);
        delay(50);
        
        if(serial->available() >= 10) {
            byte resp[10];
            serial->readBytes(resp, 10);
            
            if(resp[0] == 0xFA && resp[1] == 0xAF && resp[3] == 0xAA) {
                *target = (resp[4] << 8) | resp[5];
                *actual = (resp[6] << 8) | resp[7];
                return true;
            }
        }
        return false;
    }
    
    bool changeID(byte oldID, byte newID) {
        byte cmd[10] = {0xFA, 0xAF, oldID, 0xCD, 
                        0x00, newID, 0x00, 0x00, 
                        0x00, 0xED};
        
        sendCommand(cmd);
        delay(50);
        
        if(serial->available() >= 10) {
            byte resp[10];
            serial->readBytes(resp, 10);
            
            return (resp[2] == newID);
        }
        return false;
    }
    
    void setAngleOffset(byte id, int8_t offsetDegree) {
        int16_t offsetValue = offsetDegree * 3;
        
        byte offsetH = (offsetValue >> 8) & 0xFF;
        byte offsetL = offsetValue & 0xFF;
        
        byte cmd[10] = {0xFA, 0xAF, id, 0xD2, 
                        0x00, 0x00, offsetH, offsetL, 
                        0x00, 0xED};
        
        sendCommand(cmd);
    }
};

UBTechServo* servo;

void setup() {
    Serial.begin(115200);
    servoSerial.begin(115200);
    
    servo = new UBTechServo(&servoSerial);
    
    Serial.println("UBTECH 서보 제어 시작");
    delay(1000);
}

void loop() {
    // 0도로 이동
    Serial.println("0도로 이동");
    servo->moveToAngle(1, 0, 100);
    delay(2000);
    
    // 90도로 이동
    Serial.println("90도로 이동");
    servo->moveToAngle(1, 90, 100);
    delay(2000);
    
    // 180도로 이동
    Serial.println("180도로 이동");
    servo->moveToAngle(1, 180, 100);
    delay(2000);
    
    // 각도 읽기
    uint16_t target, actual;
    if(servo->readAngle(1, &target, &actual)) {
        Serial.print("목표: ");
        Serial.print(target);
        Serial.print("도, 실제: ");
        Serial.print(actual);
        Serial.println("도");
    }
    
    delay(3000);
}
```

---

---

## 하드웨어 분석 정보 (xaobao 리버스 엔지니어링)

### 서보 내부 구조

#### 주요 하드웨어 컴포넌트
- **MCU**: ATmega8 (8KB Flash)
  - Bootloader: 1KB (상위 주소)
  - 펌웨어: 7KB (하위 주소)
- **모터 드라이버**: A4959xxx 시리즈 (ALLEGRO)
- **통신**: UART 115200 bps, 8N1
- **위치 센서**: 전위차계 (Potentiometer)
- **전원**: 5-7.4V (권장 7.4V)

#### MCU 타이머 설정
- **Timer0**: 시스템 타임베이스
  - 기본 시간 단위: 100μs
  - 300μs 간격 (의도는 200μs, 실제 300μs - 버그)
  - 1.1ms 간격 (의도는 1ms, 실제 1.1ms - 버그)
- **Timer1**: PWM 출력
  - 모드: Fast PWM
  - 주파수: 15KHz
  - 모터 제어용

#### 제어 알고리즘
- **제어 방식**: P 제어 (비례 제어만 사용)
- **적분/미분 없음**: PI/PID 아님
- **가변 P 게인**: 각도 오차에 따라 룩업 테이블로 게인 선택
  - 오차 클수록 → 게인 큼
  - 오차 작을수록 → 게인 작음
- **과포화 제어**: 출력 포화 방지
- **샘플링**: 100μs 간격으로 ADC 샘플링
- **필터링**: 8개 샘플 평균 (이동평균 필터)

#### ISP 프로그래밍 인터페이스
서보 PCB에 6핀 ISP 헤더 존재:
- **MISO, MOSI, SCK, RST, VCC, GND**
- 펌웨어 읽기/쓰기 가능 (퓨즈 비트 잠금 안 됨)
- AVRdude로 HEX 파일 추출 가능
- 부트로더 별도 존재

#### 통신 특성
- **RX 인터럽트**: Rx Complete 인터럽트 사용 (ISR에서 프레임 수신)
- **TX 폴링**: 송신은 폴링 방식으로 ACK 전송
- **프레임 수신**: ISR에서 10바이트 수신 완료 후 처리
- **명령 간 지연**: 최소 50μs 권장

### 일반 총선 통신 방식 (Single Wire Bus)

#### 신호선 구성
- **3선식 인터페이스**: VCC, GND, Signal (TTL 레벨)
- **TX/RX 분시 다중화**: 하나의 신호선에 TX와 RX 공유
- **1:N 구성**: 주기기 1개 + 서보 N개 (최대 240개)
- **반이중 통신**: 동시 송수신 불가

#### 통신 프로토콜
1. **주기기 → 서보**: 명령 프레임 전송 (ID 포함)
2. **모든 서보**: 프레임 수신 대기
3. **해당 서보만**: ID 일치 시 명령 실행
4. **서보 → 주기기**: ACK 또는 응답 프레임 전송
5. **주기기**: 응답 수신 후 다음 명령

#### 신호선 격리 회로 필요
직접 TX/RX 연결 시 문제:
- TX 신호가 즉시 RX로 돌아옴 (에코)
- 해결: 74HC125 등으로 TX/RX 격리 회로 필요

**DIY 통신 보드 구성**:
- CH340 USB-TTL 모듈
- 74HC125 버퍼
- 10KΩ 저항 × 2
- 전원 독립 공급 (서보 전원과 통신 보드 전원 분리, GND 공통)

### 숨겨진 명령 및 기능

#### 부트로더 진입 명령 (FC CF 0x02)
- **명령**: `FC CF [ID] 02 00 00 00 00 [CHK] ED`
- **기능**: 펌웨어에서 부트로더로 점프
- **용도**: 펌웨어 업그레이드
- **주의**: 부트로더 프로토콜은 별도 분석 필요

#### 각도 읽기 후 자동 비활성화
- **명령**: 0x02 (각도 읽기)
- **부작용**: 읽기 완료 후 서보 자동 비활성화됨
- **결과**: 위치 유지 토크 제거
- **주의**: 각도 읽기 후 다시 위치 명령 필요

### 서보 변종 정보 (A/B/C/D 타입)

xaobao에서 발견된 4가지 UBTECH 서보 타입:

| 타입 | 기어 | 토크 | MCU | 드라이버 | 샤프트 |
|------|------|------|-----|----------|--------|
| **A형** | 전부 구리 | ~60kg·cm | ATmega8 | A4959 | 24T |
| **B형** | 강철 | ~20kg·cm | 불명 | 불명 | 특수 |
| **C형** | 전부 구리 | 중형 | 불명 | 불명 | 24T |
| **D형** | 전부 구리 | 소형 | 불명 | 불명 | 25T |

#### 호환성
- **A/C형**: 24T 샤프트 공통 (서보혼 공통 사용 불가 - 특수 규격)
- **B형**: 독자 규격
- **D형**: 25T 표준 (996 서보혼 호환)

#### 전류 소비 (7.4V 기준)
- **A형**: 작동 전류 높음, 스톨 전류 매우 높음
- **B형**: 작동 전류 중간
- **C형**: 작동 전류 중간
- **D형**: 작동 전류 낮음

### 펌웨어 분석 결과

#### 코드 품질
- **중복 코드 많음**: 반복되는 로직 많음
- **전역 변수 남용**: 대부분의 데이터 교환이 전역 변수로 처리
- **함수 파라미터 부재**: 거의 모든 함수가 파라미터 없음
- **상태 머신 미사용**: 플래그 변수로 상태 관리
- **타이밍 버그**: Timer0 카운터 체크 로직 오류

#### 주요 발견 사항
- **소스 컴파일러**: avr-gcc가 아닌 다른 컴파일러 사용 추정 (99% 확신)
- **ISR 중복 사용**: 여러 ISR에서 전역 변수 수정
- **주기 루프 구조**: main loop에서 플래그 폴링으로 동작
- **명령 처리**: UART RX ISR에서 프레임 조립, main에서 처리

### 단일선 버스 통신 테스트 결과
- **최대 보드 레이트**: 1Mbps 이하에서 안정적 동작
- **권장 보드 레이트**: 115200 bps (표준)
- **파형 품질**: 74HC125 버퍼 사용 시 양호
- **최대 서보 개수**: 이론상 240개 (실제는 부하 및 통신 지연 고려)

---

## 트러블슈팅

### 서보가 응답하지 않음

**원인 및 해결책**:

1. **보드 레이트 불일치**
   - 확인: 115200 bps로 설정
   - Arduino: `Serial.begin(115200);`
   - Python: `baudrate=115200`

2. **TX/RX 연결 오류**
   - TX ↔ RX 크로스 연결 확인
   - 배선 재확인

3. **전원 문제**
   - 5V 전원 공급 확인
   - 전류 용량 충분한지 확인

4. **체크섬 오류**
   - 체크섬 계산 로직 확인
   - Byte2~7의 합계 하위 바이트

### 각도가 부정확함

1. **각도 오프셋**
   - 오프셋 읽기로 확인
   - 필요시 오프셋 재설정

2. **기계적 오차**
   - 서보 기어의 백래시
   - 부하가 클 때 정밀도 저하

3. **목표/실제 각도 불일치**
   - 각도 읽기로 확인
   - 두 값이 다르면 제어 오류

### ID 변경 실패

1. **브로드캐스트 사용**
   - 버스에 여러 서보 있으면 실패
   - 서보를 하나씩 연결하여 ID 변경

2. **즉시 적용**
   - ID 변경은 즉시 반영됨
   - 변경 후 새 ID로 통신

### 통신 오류

1. **프레임 손상**
   - 시작: FA AF (일반) 또는 FC CF (펌웨어)
   - 종료: ED
   - 길이: 10바이트 고정

2. **타이밍 문제**
   - 명령 간 충분한 지연 (최소 10ms)
   - 응답 대기 타임아웃 설정

3. **버퍼 오버플로우**
   - 시리얼 버퍼 정기적으로 비우기
   - 불필요한 데이터 제거

---

## 참고사항

### 바이트 순서
- 이 프로토콜은 **Big-Endian** 사용
- 16비트 값: 상위 바이트 먼저, 하위 바이트 나중
- 예: 0x1234 → 전송 시 [0x12, 0x34]

### 각도 범위
- 유효 범위: 0-240도
- 240도 초과 시 자동으로 240도로 제한

### 동작 시간
- 단위: 20ms
- 0 = 최대 속도
- 100 = 2초 (100×20ms)

### 잠금 시간
- 단위: 20ms
- 목표 위치 도달 후 해당 시간 동안 위치 강제 유지
- 이 시간 동안 새 명령 무시

### 오프셋 설정
- 전원 재시작 시 초기화
- 영구 저장 안 됨
- 매번 전원 인가 후 재설정 필요

---

## xaobao 프로젝트 추가 리소스

### DIY 단일선 버스 통신 회로

xaobao 프로젝트에서 제공하는 74HC125 기반 격리 회로:

**필요 부품**:
- CH340 USB-TTL 모듈
- 74HC125 Quad Buffer
- 10KΩ 저항 × 2개
- 만능 기판 (Breadboard 또는 PCB)

**회로도**: `xaobao_cheap_bus_servo_hack_record-ino 파일 참조/doc/one_wire_serial.png` 참조

**특징**:
- TX/RX 에코 문제 해결
- 1Mbps 이하 통신 안정적
- 비용: 5천원 미만

**주의사항**:
1. 서보 전원과 통신 보드 전원 분리 (GND는 공통)
2. 서보 전원은 반드시 독립 공급 (5-7.4V)
3. 통신 보드의 VCC는 서보 전원 사용 금지

### 서보 펌웨어 추출 방법

xaobao는 ISP를 통한 펌웨어 추출에 성공했습니다:

**ISP 핀아웃** (서보 PCB 6핀 헤더):
- MISO, MOSI, SCK, RST, VCC, GND

**추출 명령** (AVRdude):
```bash
avrdude -c usbasp -p m8 -U flash:r:servo_firmware.hex:i
```

**반어셈블 명령**:
```bash
avr-objdump -D -m avr servo_firmware.hex > servo_firmware.s
```

⚠️ **주의**: 
- ISP 연결 시 서보 파손 가능
- 펌웨어 분석은 연구 목적으로만 사용
- 상업적 복제 및 재배포 금지

### 서보 모델 식별 가이드

**외관으로 식별**:
- PCB 뒷면 실크스크린 확인
- 기어 종류 (구리 vs 강철)
- 샤프트 톱니 개수 (24T, 25T 등)

**전류 측정으로 확인**:
- 7.4V 기준 작동 전류 측정
- 스톨 전류 측정 (주의: 단시간만)

**MCU 확인**:
- A형: ATmega8 확인됨
- B/C/D형: 분해 필요

### 리버스 엔지니어링 상세 문서

xaobao 프로젝트의 원본 PDF 문서:
- `UBTECH_protocol_detail.pdf` (중국어)
- `UBTECH_protocol_detail en-US.pdf` (영문)
- `UBTECH_protocol_detail ko.pdf` (한국어)

이 문서들은 어셈블리 코드 분석 결과를 포함합니다.

### 비디오 데모

xaobao의 B站(Bilibili) 데모 영상:
- URL: https://www.bilibili.com/video/av51309465
- 9개 서보 동기화 동작 시연
- 파동 효과, 순차 동작 등

---

## 관련 문서

### 프로토콜 문서
- [CAN 버스 프로토콜](Protocol_CAN_Bus.md) - CAN 통신 기반 서보
- [제어보드 프로토콜 (A9 9A)](Protocol_Control_Board.md) - 로봇 제어보드 프로토콜
- [서보 제어 명령 V0.85](CAN_Servo_Protocol_Documents/01.서보%20제어%20보드%20명령%20V0.85.md)

### 참고 소스
- [RobotControl 라이브러리](../Documents/RobotControl-내부%20ino%20파일%20참조/)
- [xaobao Arduino 예제](../Documents/xaobao_cheap_bus_servo_hack_record-ino%20파일%20참조/)

---

## 크레딧 및 라이선스

### 원 저작물
- **xaobao** - 리버스 엔지니어링 및 회로 설계
- 출처: https://gitee.com/xaobao/cheap_bus_servo_hack_record
- 라이선스: 연구/실험 목적만 사용 가능

### 본 문서
- xaobao의 분석 결과를 재구성 및 한국어 번역
- 추가 명령어셋 정리 및 예제 코드 작성
- Python/Arduino 통합 예제 제공

### 면책조항
⚠️ **중요**:
- 본 문서는 교육 및 연구 목적으로만 제공됩니다
- 상업적 용도로 사용 시 UBTECH의 지적재산권 침해 가능
- 리버스 엔지니어링 결과의 상업적 이용 금지
- 펌웨어 무단 복제 및 재배포 금지
- 서보 개조 시 보증 무효화 및 파손 위험 존재

### 기술 지원
본 문서와 관련된 문의:
- 프로토콜 및 통신 관련 질문 환영
- 상업적 지원 제공 불가
- 펌웨어 파일 공유 불가

---

**문서 버전**: 2.0  
**최종 업데이트**: 2025-11-05  
**적용 대상**: UBTECH Serial 통신 서보모터 (ATmega8 기반)  
**참고 프로젝트**: xaobao cheap_bus_servo_hack_record

---

**End of Document**
