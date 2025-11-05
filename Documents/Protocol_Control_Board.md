# UBTECH 서보 제어보드 프로토콜 (A9 9A)

## 목차
- [프로토콜 개요](#프로토콜-개요)
- [하드웨어 구성](#하드웨어-구성)
- [통신 설정](#통신-설정)
- [프레임 구조](#프레임-구조)
- [명령어 전체 목록](#명령어-전체-목록)
- [MP3 재생 명령](#mp3-재생-명령)
- [동작 제어 명령](#동작-제어-명령)
- [서보 제어 명령](#서보-제어-명령)
- [LED 제어 명령](#led-제어-명령)
- [액션 데이터 구조](#액션-데이터-구조)
- [예제 코드](#예제-코드)
- [트러블슈팅](#트러블슈팅)

---

## 프로토콜 개요

### 프로토콜 특징
- **프레임 헤더**: `A9 9A`
- **프레임 종료**: `ED`
- **통신 방식**: UART Serial
- **보드 레이트**: 115200 bps
- **가변 길이 프레임**: 데이터 길이 필드로 프레임 크기 결정

### 적용 대상
- UBTECH 로봇 제어보드
- 다중 서보 통합 제어 시스템
- MP3, LED, 동작 그룹 통합 제어

### 제어보드 주요 기능
1. **다중 서보 제어**: 여러 서보를 동시에 제어
2. **동작 그룹 관리**: 미리 정의된 동작 시퀀스 재생
3. **MP3 재생**: SD 카드의 음성 파일 재생
4. **LED 제어**: 로봇 팔 LED 제어
5. **시교(Teaching)**: 실시간 동작 기록 및 재생

---

## 하드웨어 구성

### 제어보드 사양
- **전원**: 24V 3A 권장
- **대체 전원**: 6S 리튬 배터리 팩
- **통신 포트**: UART (TTL 레벨)
- **확장**: WiFi, 블루투스, 적외선, 433MHz 지원

### 연결 방법

#### Arduino UNO 연결
```
UNO     제어보드
5V   →  V (5V 신호 레벨)
GND  →  G
D11  →  R (제어보드 RX)
D12  →  T (제어보드 TX)
```

#### Arduino Mega2560 연결
```
Mega         제어보드
5V        →  V
GND       →  G
Serial3TX →  R
Serial3RX →  T
```

#### 라즈베리파이 연결
- USB to Serial 케이블 사용
- 포트: `/dev/ttyUSB0` (기본)

---

## 통신 설정

### UART 파라미터
| 파라미터 | 값 |
|----------|-----|
| 보드 레이트 | 115200 bps |
| 데이터 비트 | 8 |
| 패리티 | None |
| 정지 비트 | 1 |
| 흐름 제어 | None |

---

## 프레임 구조

### 기본 명령 프레임

```
A9 9A [LEN] [CMD] [DATA...] [SUM] ED
```

| 필드 | 크기 | 설명 |
|------|------|------|
| 헤더 | 2바이트 | 0xA9 0x9A (고정) |
| 길이 | 1바이트 | 체크섬 포함 데이터 길이 |
| 명령 | 1바이트 | 명령 코드 |
| 데이터 | 가변 | 명령별 파라미터 |
| 체크섬 | 1바이트 | 길이~데이터의 합 (하위 바이트) |
| 종료 | 1바이트 | 0xED (고정) |

### 프레임 크기 계산
```
전체 크기 = 4 + [LEN] 바이트
최소 크기 = 6 바이트 (A9 9A 02 {CMD} {SUM} ED)
```

### 체크섬 계산
```python
def calculate_checksum(data):
    """LEN, CMD, DATA 필드의 합계 (하위 바이트만)"""
    # data = [LEN, CMD, param1, param2, ...]
    return sum(data) & 0xFF
```

---

## 명령어 전체 목록

### MP3 재생 명령

| 명령 코드 | 명령명 | 기능 | 데이터 길이 | 파라미터 |
|-----------|--------|------|------------|----------|
| 0x32 | MP3 정지 | MP3 재생 중지 | 2 | 없음 |
| 0x33 | 파일 재생 | 디렉토리/파일 재생 | 4 | DIR, FILE |
| 0x34 | MP3 파일 재생 | MP3 폴더 파일 재생 | 3 | FILE_NUM |

### 동작 제어 명령

| 명령 코드 | 명령명 | 기능 | 데이터 길이 | 파라미터 |
|-----------|--------|------|------------|----------|
| 0x41 | 동작 재생 | 동작 그룹 재생 | 3 | ACTION_ID |
| 0x42 | 반복 재생 | 동작 그룹 반복 재생 | 4 | ACTION_ID, COUNT |
| 0x4F | 재생 중지 | 동작 재생 중지 | 2 | 없음 |
| 0x75 | 동작 삭제 | 동작 그룹 삭제 | 3 | ACTION_ID |
| 0x84 | 특정 동작 재생 | 동작 그룹의 특정 포즈 재생 | 5 | ACTION_ID, POSE_ID |
| 0x61 | 동작 헤더 읽기 | 동작 그룹 이름 읽기 | 3 | ACTION_ID |
| 0x62 | 동작 데이터 읽기 | 특정 포즈 데이터 읽기 | 5 | ACTION_ID, POSE_ID |

### 서보 제어 명령

| 명령 코드 | 명령명 | 기능 | 데이터 길이 | 파라미터 |
|-----------|--------|------|------------|----------|
| 0x88 | 서보 조회/이동 | 서보 상태 조회 또는 이동 | 5 또는 9 | ID, SUB_CMD, ... |
| 0x89 | ID 수정 | 서보 ID 변경 | 5 | OLD_ID, NEW_ID |
| 0x21 | 잠금 | 서보 잠금 | 3 | SERVO_ID |
| 0x22 | 해제 | 서보 해제 | 3 | SERVO_ID |
| 0x11 | 모든 서보 조회 | 버스의 모든 서보 조회 | 2 | 없음 |
| 0x96 | 다중 서보 제어 | 여러 서보 동시 제어 | 가변 | COUNT, IDs, ANGLEs, TIME |

### LED 제어 명령

| 명령 코드 | 명령명 | 기능 | 데이터 길이 | 파라미터 |
|-----------|--------|------|------------|----------|
| 0x97 | LED 제어 | 로봇 팔 LED 제어 | 7 | ID, LED_MODE |

---

## MP3 재생 명령

### 1. MP3 정지 (0x32)

**기능**: 현재 재생 중인 MP3 중지

#### 명령 프레임
```
A9 9A 02 32 34 ED
```

| 바이트 | 값 | 설명 |
|--------|-----|------|
| 0-1 | A9 9A | 프레임 헤더 |
| 2 | 0x02 | 데이터 길이 |
| 3 | 0x32 | MP3 정지 명령 |
| 4 | 0x34 | 체크섬 (0x02+0x32) |
| 5 | 0xED | 프레임 종료 |

---

### 2. 파일 재생 (0x33)

**기능**: SD 카드의 특정 디렉토리에서 파일 재생

#### 명령 프레임
```
A9 9A 04 33 [DIR] [FILE] [SUM] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 길이 | 2 | 0x04 |
| 명령 | 3 | 0x33 |
| 디렉토리 | 4 | 01-99 |
| 파일 번호 | 5 | 001-255 |
| 체크섬 | 6 | 계산값 |

#### 예제

**SD 카드 /01/003.mp3 재생**
```
A9 9A 04 33 01 03 3B ED
```
- 디렉토리: 0x01
- 파일: 0x03 (003.mp3)
- 체크섬: 0x04+0x33+0x01+0x03 = 0x3B

**SD 카드 /02/010.mp3 재생**
```
A9 9A 04 33 02 0A 43 ED
```

---

### 3. MP3 파일 재생 (0x34)

**기능**: SD 카드의 /MP3/ 디렉토리에서 파일 재생

#### 명령 프레임
```
A9 9A 03 34 [FILE] [SUM] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 길이 | 2 | 0x03 |
| 명령 | 3 | 0x34 |
| 파일 번호 | 4 | 001-255 |
| 체크섬 | 5 | 계산값 |

#### 예제

**SD 카드 /MP3/001.mp3 재생**
```
A9 9A 03 34 01 38 ED
```
- 파일: 0x01 (001.mp3)

**SD 카드 /MP3/255.mp3 재생**
```
A9 9A 03 34 FF 36 ED
```
- 파일: 0xFF (255.mp3)

---

## 동작 제어 명령

### 1. 동작 재생 (0x41)

**기능**: 저장된 동작 그룹 재생

#### 명령 프레임
```
A9 9A 03 41 [ACTION_ID] [SUM] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 길이 | 2 | 0x03 |
| 명령 | 3 | 0x41 |
| 동작 ID | 4 | 1-255 |
| 체크섬 | 5 | 계산값 |

#### 예제

**동작 그룹 1 재생**
```
A9 9A 03 41 01 45 ED
```

**동작 그룹 3 재생**
```
A9 9A 03 41 03 47 ED
```

---

### 2. 반복 재생 (0x42)

**기능**: 동작 그룹을 지정된 횟수만큼 반복 재생

#### 명령 프레임
```
A9 9A 04 42 [ACTION_ID] [COUNT] [SUM] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 길이 | 2 | 0x04 |
| 명령 | 3 | 0x42 |
| 동작 ID | 4 | 1-255 |
| 반복 횟수 | 5 | 1-255, 0xFF=무한 |
| 체크섬 | 6 | 계산값 |

#### 예제

**동작 그룹 1을 2회 반복**
```
A9 9A 04 42 01 02 49 ED
```

**동작 그룹 5를 무한 반복**
```
A9 9A 04 42 05 FF 4A ED
```

---

### 3. 재생 중지 (0x4F)

**기능**: 동작 그룹 재생 중지

#### 명령 프레임
```
A9 9A 02 4F 51 ED
```

---

### 4. 동작 파일 삭제 (0x75)

**기능**: 저장된 동작 그룹 삭제

#### 명령 프레임
```
A9 9A 03 75 [ACTION_ID] [SUM] ED
```

#### 예제

**동작 그룹 6 삭제**
```
A9 9A 03 75 06 7E ED
```

---

### 5. 특정 동작 재생 (0x84)

**기능**: 동작 그룹의 특정 포즈만 재생

#### 명령 프레임
```
A9 9A 05 84 [ACTION_ID] 00 [POSE_ID] [SUM] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 길이 | 2 | 0x05 |
| 명령 | 3 | 0x84 |
| 동작 ID | 4 | 동작 그룹 번호 |
| 예약 | 5 | 0x00 |
| 포즈 ID | 6 | 동작 내 포즈 번호 |
| 체크섬 | 7 | 계산값 |

#### 예제

**동작 그룹 3의 첫 번째 포즈 재생**
```
A9 9A 05 84 03 00 01 8D ED
```
- 동작 ID: 0x03
- 포즈 ID: 0x01

**동작 그룹 6의 5번째 포즈 재생**
```
A9 9A 05 84 06 00 05 94 ED
```

---

### 6. 동작 헤더 읽기 (0x61)

**기능**: 동작 그룹 이름 및 메타데이터 읽기

#### 명령 프레임
```
A9 9A 03 61 [ACTION_ID] [SUM] ED
```

#### 예제
```
A9 9A 03 61 06 6A ED
```
- 동작 그룹 6의 헤더 정보 읽기

---

### 7. 동작 데이터 읽기 (0x62)

**기능**: 특정 포즈의 상세 데이터 읽기

#### 명령 프레임
```
A9 9A 05 62 [ACTION_ID] 00 [POSE_ID] [SUM] ED
```

#### 예제

**동작 그룹 2의 첫 번째 포즈 데이터 읽기**
```
A9 9A 05 62 02 00 01 6A ED
```

---

## 서보 제어 명령

### 1. 서보 조회 (0x88 + 0x02)

**기능**: 특정 서보의 상태 조회

#### 명령 프레임
```
A9 9A 05 88 03 [ID] 02 [SUM] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 길이 | 2 | 0x05 |
| 명령 | 3 | 0x88 |
| 파라미터 길이 | 4 | 0x03 |
| 서보 ID | 5 | 대상 서보 ID |
| 서브 명령 | 6 | 0x02 (조회) |
| 체크섬 | 7 | 계산값 |

#### 예제
```
A9 9A 05 88 03 00 02 92 ED
```
- 서보 ID 0 (또는 특정 ID) 조회

---

### 2. 서보 이동 (0x88 + 0x01)

**기능**: 서보를 지정된 각도로 이동

#### 명령 프레임
```
A9 9A 09 88 06 [ID] 01 [ANGLE_L] [ANGLE_H] [TIME_L] [TIME_H] [SUM] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 길이 | 2 | 0x09 |
| 명령 | 3 | 0x88 |
| 파라미터 길이 | 4 | 0x06 |
| 서보 ID | 5 | 대상 서보 ID |
| 서브 명령 | 6 | 0x01 (이동) |
| 각도 하위 | 7 | 각도 LSB |
| 각도 상위 | 8 | 각도 MSB |
| 시간 하위 | 9 | 이동 시간 LSB (ms) |
| 시간 상위 | 10 | 이동 시간 MSB (ms) |
| 체크섬 | 11 | 계산값 |

#### 각도 계산
```
각도 값 = (각도 / 240) × 256
예: 90도 → (90/240)×256 = 96 (0x60)
예: 180도 → (180/240)×256 = 192 (0xC0)
```

#### 예제

**2번 서보를 90도로 1000ms 동안 이동**
```
A9 9A 09 88 06 02 01 5A 00 E8 03 DF ED
```
- 서보 ID: 0x02
- 각도: 0x005A = 90 (실제 각도 계산 필요)
- 시간: 0x03E8 = 1000ms

**2번 서보를 180도로 1000ms 동안 이동**
```
A9 9A 09 88 06 02 01 B4 00 E8 03 39 ED
```
- 각도: 0x00B4 = 180

---

### 3. ID 수정 (0x89)

**기능**: 서보 ID 변경

#### 명령 프레임
```
A9 9A 05 89 03 [OLD_ID] [NEW_ID] [SUM] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 길이 | 2 | 0x05 |
| 명령 | 3 | 0x89 |
| 파라미터 길이 | 4 | 0x03 |
| 기존 ID | 5 | 현재 서보 ID |
| 새 ID | 6 | 변경할 ID |
| 체크섬 | 7 | 계산값 |

#### 예제

**1번 서보를 2번으로 변경**
```
A9 9A 05 89 03 01 02 94 ED
```

---

### 4. 잠금 (0x21)

**기능**: 서보 잠금 (토크 유지)

#### 명령 프레임
```
A9 9A 03 21 [ID] [SUM] ED
```

#### 예제
```
A9 9A 03 21 02 26 ED
```
- 2번 서보 잠금

---

### 5. 해제 (0x22)

**기능**: 서보 해제 (토크 제거)

#### 명령 프레임
```
A9 9A 03 22 [ID] [SUM] ED
```

#### 예제
```
A9 9A 03 22 02 27 ED
```
- 2번 서보 해제

---

### 6. 0도 설정 (0x88 + 0x0A)

**기능**: 서보의 영점(0도) 설정

#### 명령 프레임
```
A9 9A 07 88 04 [ID] 0A 00 00 [SUM] ED
```

#### 예제
```
A9 9A 07 88 04 02 0A 00 00 9F ED
```
- 2번 서보 영점 설정

---

### 7. 모든 서보 조회 (0x11)

**기능**: CAN 버스의 모든 서보 각도 조회

#### 명령 프레임
```
A9 9A 02 11 13 ED
```

#### 응답 프레임
```
A9 9A 08 11 FF 00 B6 01 FF 00 CE ED
```
- 서보 수에 따라 동적으로 응답 크기 변경
- 각 서보: [ID] [ANGLE_L] [ANGLE_H]

---

### 8. 다중 서보 제어 (0x96)

**기능**: 여러 서보를 동시에 제어

#### 명령 프레임 (가변 길이)
```
A9 9A [LEN] 96 [PARAM_LEN] [COUNT] [ID1] [ID2] ... [ANGLE1_L] [ANGLE1_H] ... [TIME_L] [TIME_H] [SUM] ED
```

| 필드 | 설명 |
|------|------|
| LEN | 전체 데이터 길이 |
| PARAM_LEN | 파라미터 길이 |
| COUNT | 서보 개수 |
| ID1~IDn | 서보 ID 목록 |
| ANGLE1~ANGLEn | 각 서보의 목표 각도 (Little-Endian) |
| TIME | 이동 시간 (Little-Endian, ms) |

#### 예제

**1개 서보 제어 (3번 서보 → 90도)**
```
A9 9A 09 96 06 01 03 5A 00 E8 03 EE ED
```
- 서보 개수: 0x01
- ID: 0x03
- 각도: 0x005A
- 시간: 0x03E8 = 1000ms

**2개 서보 제어 (2번, 3번 → 90도)**
```
A9 9A 0C 96 09 02 02 03 5A 00 5A 00 E8 03 51 ED
```
- 서보 개수: 0x02
- ID: 0x02, 0x03
- 각도: 모두 0x005A
- 시간: 0x03E8 = 1000ms

**5개 서보 제어**
```
A9 9A 15 96 12 05 02 03 04 05 0E 5A 00 5A 00 5A 00 5A 00 5A 00 E8 03 8B ED
```
- 서보 개수: 0x05
- ID: 2, 3, 4, 5, 14 (0x0E)
- 각도: 모두 0x005A (90도)
- 시간: 0x03E8 = 1000ms

---

## LED 제어 명령

### LED 제어 (0x97)

**기능**: 로봇 팔 LED 제어

#### 명령 프레임
```
A9 9A 07 97 03 [LED_ID] 07 [LED_MODE] 00 [SUM] ED
```

| 필드 | 바이트 | 설명 |
|------|--------|------|
| 길이 | 2 | 0x07 |
| 명령 | 3 | 0x97 |
| 파라미터 길이 | 4 | 0x03 |
| LED ID | 5 | 0x6E=오른손, 0x6F=왼손 |
| 서브 명령 | 6 | 0x07 (고정) |
| LED 모드 | 7 | 색상 및 효과 코드 |
| 예약 | 8 | 0x00 |

### LED 모드 코드

| 코드 | 색상/효과 |
|------|-----------|
| 0xA0 | LED 끄기 |
| 0xA1 | 파란색 상시 점등 |
| 0xA2 | 빨간색 깜박임 → 상시 점등 |
| 0xA3 | 노란색 깜박임 |
| 0xA4 | 녹색 깜박임 |
| 0xA5 | 흰색 상시 점등 |
| 0xA6 | 녹색 깜박임 (느림) |
| 0xA7 | LED 끄기 |
| 0xA8 | 흰색 깜박임 (느림) |
| 0xA9 | 노란색 깜박임 (느림) |
| 0xAA | 빨간색 깜박임 (느림) |
| 0xAD | 파란색 상시 점등 |
| 0xAE | 녹색 상시 점등 |

### 예제

**왼손 LED 흰색 깜박임**
```
A9 9A 07 97 03 6F 07 A5 00 97 ED
```
- LED ID: 0x6F (왼손)
- 모드: 0xA5 (흰색 깜박임)

**오른손 LED 빨간색 깜박임**
```
A9 9A 07 97 03 6E 07 A2 00 B8 ED
```
- LED ID: 0x6E (오른손)
- 모드: 0xA2 (빨간색 깜박임)

---

## 액션 데이터 구조

### 액션 헤더 (60바이트)

```
A9 9A 38 61 [ACTION_ID] 00 [NAME...] [LEN] [STEPS] 00 [TIME...] [SERVO_CNT...] [RESERVED...] [SUM] ED
```

| 오프셋 | 크기 | 필드 | 설명 |
|--------|------|------|------|
| 0-1 | 2 | 헤더 | 0xA9 0x9A |
| 2 | 1 | 길이 | 0x38 (56바이트) |
| 3 | 1 | 명령 | 0x61 |
| 4 | 1 | 액션 ID | 동작 그룹 번호 |
| 5 | 1 | 예약 | 0x00 |
| 6-25 | 20 | 이름 | 액션 이름 (ASCII, 0으로 패딩) |
| 26 | 1 | 종료 | 0x00 |
| 27 | 1 | 이름 길이 | 실제 이름 길이 |
| 28 | 1 | 스텝 수 | 포즈 개수 |
| 29 | 1 | 예약 | 0x00 |
| 30-33 | 4 | 총 시간 | 실행 시간 (ms, 32bit) |
| 34-35 | 2 | 서보 수 | 대상 서보 개수 |
| 36-57 | 22 | 예약 | 0x00 |
| 58 | 1 | 체크섬 | 계산값 |
| 59 | 1 | 종료 | 0xED |

---

### 포즈 데이터 (60바이트, 최대 32개 서보)

```
A9 9A 38 62 [ACTION_ID] [SEQ] [ENABLED] [S_TIME...] [W_TIME...] [ANGLES...] [LED...] [HEAD] [MP3...] [RESERVED...] [SUM] ED
```

| 오프셋 | 크기 | 필드 | 설명 |
|--------|------|------|------|
| 0-1 | 2 | 헤더 | 0xA9 0x9A |
| 2 | 1 | 길이 | 0x38 (56바이트) |
| 3 | 1 | 명령 | 0x62 |
| 4 | 1 | 액션 ID | 동작 그룹 번호 |
| 5 | 1 | 순서 | 포즈 순서 번호 |
| 6 | 1 | 활성화 | 0x01=활성, 0x00=비활성 |
| 7-8 | 2 | 서보 시간 | 서보 동작 시간 (ms) |
| 9-10 | 2 | 대기 시간 | 다음 포즈까지 대기 (ms) |
| 11-42 | 32 | 각도 | 32개 서보 각도 (각 1바이트) |
| 43-50 | 8 | LED 플래그 | LED 제어 플래그 |
| 51 | 1 | 헤드라이트 | 0xFF=동작 없음 |
| 52 | 1 | MP3 디렉토리 | 0xFF=동작 없음 |
| 53 | 1 | MP3 파일 | 0x00=정지, 0xFF=동작 없음 |
| 54 | 1 | MP3 볼륨 | 0xFF=변경 없음 |
| 55-57 | 3 | 예약 | 0x00 |
| 58 | 1 | 체크섬 | 계산값 |
| 59 | 1 | 종료 | 0xED |

---

## 예제 코드

### Python 예제

```python
import serial
import time

class UBTechControlBoard:
    def __init__(self, port='/dev/ttyUSB0', baudrate=115200):
        """제어보드 초기화"""
        self.ser = serial.Serial(
            port=port,
            baudrate=baudrate,
            timeout=1.0
        )
        time.sleep(0.1)
    
    def calculate_checksum(self, data):
        """체크섬 계산"""
        return sum(data) & 0xFF
    
    def send_command(self, cmd_data):
        """명령 전송"""
        # 프레임 구성
        frame = [0xA9, 0x9A] + cmd_data
        
        # 체크섬 계산
        checksum = self.calculate_checksum(cmd_data)
        frame.append(checksum)
        frame.append(0xED)
        
        # 전송
        self.ser.write(bytes(frame))
        time.sleep(0.01)
    
    # ===== MP3 명령 =====
    
    def mp3_stop(self):
        """MP3 정지"""
        self.send_command([0x02, 0x32])
    
    def mp3_play_file(self, directory, file_num):
        """파일 재생
        Args:
            directory: 디렉토리 번호 (1-99)
            file_num: 파일 번호 (1-255)
        """
        self.send_command([0x04, 0x33, directory, file_num])
    
    def mp3_play(self, file_num):
        """MP3 폴더 파일 재생
        Args:
            file_num: 파일 번호 (1-255)
        """
        self.send_command([0x03, 0x34, file_num])
    
    # ===== 동작 명령 =====
    
    def action_play(self, action_id):
        """동작 그룹 재생
        Args:
            action_id: 동작 ID (1-255)
        """
        self.send_command([0x03, 0x41, action_id])
    
    def action_repeat(self, action_id, count=0xFF):
        """동작 그룹 반복 재생
        Args:
            action_id: 동작 ID
            count: 반복 횟수 (0xFF=무한)
        """
        self.send_command([0x04, 0x42, action_id, count])
    
    def action_stop(self):
        """동작 재생 중지"""
        self.send_command([0x02, 0x4F])
    
    def action_delete(self, action_id):
        """동작 그룹 삭제
        Args:
            action_id: 삭제할 동작 ID
        """
        self.send_command([0x03, 0x75, action_id])
    
    def action_play_pose(self, action_id, pose_id):
        """특정 포즈 재생
        Args:
            action_id: 동작 ID
            pose_id: 포즈 ID
        """
        self.send_command([0x05, 0x84, action_id, 0x00, pose_id])
    
    # ===== 서보 명령 =====
    
    def servo_query(self, servo_id):
        """서보 조회
        Args:
            servo_id: 서보 ID
        """
        self.send_command([0x05, 0x88, 0x03, servo_id, 0x02])
    
    def servo_move(self, servo_id, angle, move_time=1000):
        """서보 이동
        Args:
            servo_id: 서보 ID
            angle: 목표 각도 (0-240)
            move_time: 이동 시간 (ms)
        """
        angle_l = angle & 0xFF
        angle_h = (angle >> 8) & 0xFF
        time_l = move_time & 0xFF
        time_h = (move_time >> 8) & 0xFF
        
        self.send_command([0x09, 0x88, 0x06, servo_id, 0x01, 
                          angle_l, angle_h, time_l, time_h])
    
    def servo_change_id(self, old_id, new_id):
        """서보 ID 변경
        Args:
            old_id: 기존 ID
            new_id: 새 ID
        """
        self.send_command([0x05, 0x89, 0x03, old_id, new_id])
    
    def servo_lock(self, servo_id):
        """서보 잠금"""
        self.send_command([0x03, 0x21, servo_id])
    
    def servo_unlock(self, servo_id):
        """서보 해제"""
        self.send_command([0x03, 0x22, servo_id])
    
    def servo_query_all(self):
        """모든 서보 조회"""
        self.send_command([0x02, 0x11])
    
    def servo_multi_move(self, servos, angles, move_time=1000):
        """다중 서보 제어
        Args:
            servos: 서보 ID 리스트 [1, 2, 3, ...]
            angles: 각도 리스트 [90, 180, 45, ...]
            move_time: 이동 시간 (ms)
        """
        count = len(servos)
        param_len = 1 + count + count*2 + 2
        
        # 데이터 구성
        data = [param_len + 1, 0x96, param_len, count]
        data.extend(servos)
        
        # 각도 추가 (Little-Endian)
        for angle in angles:
            data.append(angle & 0xFF)
            data.append((angle >> 8) & 0xFF)
        
        # 시간 추가 (Little-Endian)
        data.append(move_time & 0xFF)
        data.append((move_time >> 8) & 0xFF)
        
        self.send_command(data)
    
    # ===== LED 명령 =====
    
    def led_control(self, led_id, mode):
        """LED 제어
        Args:
            led_id: 0x6E=오른손, 0x6F=왼손
            mode: LED 모드 (0xA0-0xAE)
        """
        self.send_command([0x07, 0x97, 0x03, led_id, 0x07, mode, 0x00])
    
    def led_left_hand(self, mode):
        """왼손 LED 제어"""
        self.led_control(0x6F, mode)
    
    def led_right_hand(self, mode):
        """오른손 LED 제어"""
        self.led_control(0x6E, mode)
    
    def close(self):
        """시리얼 포트 닫기"""
        if self.ser.is_open:
            self.ser.close()

# LED 모드 상수
class LEDMode:
    OFF = 0xA0
    BLUE_ON = 0xA1
    RED_BLINK = 0xA2
    YELLOW_BLINK = 0xA3
    GREEN_BLINK = 0xA4
    WHITE_ON = 0xA5
    GREEN_SLOW = 0xA6
    WHITE_SLOW = 0xA8
    YELLOW_SLOW = 0xA9
    RED_SLOW = 0xAA

# 사용 예제
if __name__ == "__main__":
    board = UBTechControlBoard(port='COM3')  # Windows
    # board = UBTechControlBoard(port='/dev/ttyUSB0')  # Linux
    
    try:
        # 1. MP3 재생
        print("MP3 001 재생")
        board.mp3_play(1)
        time.sleep(3)
        
        # 2. 동작 그룹 재생
        print("동작 그룹 1 재생")
        board.action_play(1)
        time.sleep(5)
        
        # 3. 단일 서보 제어
        print("서보 2번을 90도로 이동")
        board.servo_move(servo_id=2, angle=90, move_time=2000)
        time.sleep(2.5)
        
        # 4. 다중 서보 제어
        print("서보 2, 3, 4번을 동시에 이동")
        board.servo_multi_move(
            servos=[2, 3, 4],
            angles=[90, 120, 60],
            move_time=1000
        )
        time.sleep(2)
        
        # 5. LED 제어
        print("왼손 LED 흰색 점등")
        board.led_left_hand(LEDMode.WHITE_ON)
        time.sleep(2)
        
        print("오른손 LED 빨간색 깜박임")
        board.led_right_hand(LEDMode.RED_BLINK)
        time.sleep(2)
        
    finally:
        board.close()
```

### Arduino 예제

```cpp
#include <SoftwareSerial.h>

SoftwareSerial boardSerial(11, 12); // RX, TX

class UBTechBoard {
private:
    Stream* serial;
    
    byte calculateChecksum(byte* data, int len) {
        byte sum = 0;
        for(int i = 0; i < len; i++) {
            sum += data[i];
        }
        return sum & 0xFF;
    }
    
public:
    UBTechBoard(Stream* ser) : serial(ser) {}
    
    void sendCommand(byte* data, int len) {
        // 프레임 구성
        serial->write(0xA9);
        serial->write(0x9A);
        serial->write(data, len);
        
        // 체크섬
        byte checksum = calculateChecksum(data, len);
        serial->write(checksum);
        
        // 종료
        serial->write(0xED);
        delay(10);
    }
    
    // MP3 명령
    void mp3Stop() {
        byte cmd[] = {0x02, 0x32};
        sendCommand(cmd, 2);
    }
    
    void mp3Play(byte fileNum) {
        byte cmd[] = {0x03, 0x34, fileNum};
        sendCommand(cmd, 3);
    }
    
    // 동작 명령
    void actionPlay(byte actionID) {
        byte cmd[] = {0x03, 0x41, actionID};
        sendCommand(cmd, 3);
    }
    
    void actionStop() {
        byte cmd[] = {0x02, 0x4F};
        sendCommand(cmd, 2);
    }
    
    // 서보 명령
    void servoMove(byte id, byte angle, uint16_t time) {
        byte angleL = angle & 0xFF;
        byte angleH = (angle >> 8) & 0xFF;
        byte timeL = time & 0xFF;
        byte timeH = (time >> 8) & 0xFF;
        
        byte cmd[] = {0x09, 0x88, 0x06, id, 0x01, 
                      angleL, angleH, timeL, timeH};
        sendCommand(cmd, 9);
    }
    
    void servoLock(byte id) {
        byte cmd[] = {0x03, 0x21, id};
        sendCommand(cmd, 3);
    }
    
    void servoUnlock(byte id) {
        byte cmd[] = {0x03, 0x22, id};
        sendCommand(cmd, 3);
    }
    
    // LED 명령
    void ledControl(byte ledID, byte mode) {
        byte cmd[] = {0x07, 0x97, 0x03, ledID, 0x07, mode, 0x00};
        sendCommand(cmd, 7);
    }
};

UBTechBoard* board;

void setup() {
    Serial.begin(115200);
    boardSerial.begin(115200);
    
    board = new UBTechBoard(&boardSerial);
    
    Serial.println("제어보드 초기화 완료");
    delay(1000);
}

void loop() {
    // 동작 그룹 1 재생
    Serial.println("동작 1 재생");
    board->actionPlay(1);
    delay(5000);
    
    // 서보 제어
    Serial.println("서보 2번 이동");
    board->servoMove(2, 90, 1000);
    delay(2000);
    
    // LED 제어
    Serial.println("LED 제어");
    board->ledControl(0x6F, 0xA5); // 왼손 흰색
    delay(2000);
    
    delay(5000);
}
```

---

## 트러블슈팅

### 명령이 실행되지 않음

1. **프레임 구조 확인**
   - 헤더: A9 9A
   - 종료: ED
   - 체크섬 계산 정확성

2. **데이터 길이**
   - LEN 필드가 실제 데이터와 일치하는지 확인
   - 체크섬 포함 길이

3. **보드 레이트**
   - 115200 bps 확인

### 서보가 이상하게 동작함

1. **각도 계산**
   - 제어보드 프로토콜의 각도 인코딩 확인
   - 0-240 범위

2. **시간 값**
   - Little-Endian 확인
   - ms 단위

### 동작 그룹 재생 안 됨

1. **동작 그룹 존재 확인**
   - SD 카드에 동작 파일 저장 여부
   - 동작 ID 확인

2. **파일 형식**
   - 액션 데이터 구조 확인
   - 헤더 및 포즈 데이터 형식

### MP3 재생 안 됨

1. **SD 카드**
   - 정상 삽입 확인
   - 디렉토리 구조 확인 (/01/, /MP3/)

2. **파일 이름**
   - 001.mp3, 002.mp3 형식
   - 숫자 3자리

---

## 관련 문서
- [CAN 버스 프로토콜](Protocol_CAN_Bus.md)
- [Serial 프로토콜 (FA AF/FC CF)](Protocol_Serial.md)
- [하드웨어 배선 가이드](Hardware_Wiring.md)

---

**문서 버전**: 1.0  
**최종 업데이트**: 2025-11-05  
**적용 대상**: UBTECH 로봇 제어보드 (A9 9A 프로토콜)

⚠️ **면책조항**: 본 문서는 학습 및 교류 목적으로만 사용하며, 상업적 용도는 금지합니다.
