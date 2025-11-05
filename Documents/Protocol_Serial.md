# UBTECH 서보 Serial 통신 프로토콜 (FA AF / FC CF)

## 목차
- [프로토콜 개요](#프로토콜-개요)
- [하드웨어 연결](#하드웨어-연결)
- [통신 설정](#통신-설정)
- [프레임 구조](#프레임-구조)
- [명령어 전체 목록](#명령어-전체-목록)
- [상세 명령어 설명](#상세-명령어-설명)
- [예제 코드](#예제-코드)
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

### Python 예제

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
            timeout=1.0
        )
        time.sleep(0.1)
    
    def calculate_checksum(self, data):
        """체크섬 계산 (Byte2~7)"""
        return sum(data[2:8]) & 0xFF
    
    def send_command(self, cmd_data):
        """명령 전송"""
        # 체크섬 계산 및 추가
        checksum = self.calculate_checksum(cmd_data)
        cmd_data[8] = checksum
        
        # 전송
        self.ser.write(bytes(cmd_data))
        time.sleep(0.01)
    
    def read_response(self, expected_len=10):
        """응답 읽기"""
        response = self.ser.read(expected_len)
        return list(response) if response else None
    
    def move_to_angle(self, servo_id, angle, move_time=0, lock_time=0):
        """각도로 이동
        
        Args:
            servo_id: 서보 ID (1-240, 0=전체)
            angle: 목표 각도 (0-240도)
            move_time: 동작 시간 (0-255, ×20ms, 0=최대속도)
            lock_time: 잠금 시간 (0-3270, ×20ms)
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
            if resp[0] == expected:
                print(f"서보 {servo_id}: 이동 명령 성공")
                return True
        return False
    
    def stop_servo(self, servo_id):
        """서보 강제 정지"""
        cmd = [0xFA, 0xAF, servo_id, 0x01, 
               0xFF, 0x00, 0x00, 0x00, 
               0x00, 0xED]
        self.send_command(cmd)
    
    def read_angle(self, servo_id):
        """각도 읽기"""
        cmd = [0xFA, 0xAF, servo_id, 0x02, 
               0x00, 0x00, 0x00, 0x00, 
               0x00, 0xED]
        
        self.send_command(cmd)
        resp = self.read_response(10)
        
        if resp and len(resp) == 10:
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

## 관련 문서
- [CAN 버스 프로토콜](Protocol_CAN_Bus.md)
- [제어보드 프로토콜 (A9 9A)](Protocol_Control_Board.md)
- [하드웨어 배선 가이드](Hardware_Wiring.md)

---

**문서 버전**: 1.0  
**최종 업데이트**: 2025-11-05  
**적용 대상**: UBTECH Serial 통신 서보모터

⚠️ **면책조항**: 본 문서는 참고용으로만 제공됩니다. 상업적 용도로 사용 금지.
