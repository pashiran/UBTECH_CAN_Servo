# UBTECH CAN 서보 테스트 계획서

## 📋 테스트 개요

**테스트 대상**: UBTECH CAN 프로토콜 서보 (AA 00 00)  
**통신 방식**: CAN 2.0 (500 kbps)  
**테스트 목적**: 프로토콜 검증, 통신 안정성 확인, 명령어 동작 검증  
**작성일**: 2025-11-23

---


### 1.3 배선 가이드

1. **MCP2515 → Arduino 연결**
   - MCP2515 VCC → Arduino 5V
   - MCP2515 GND → Arduino GND
   - MCP2515 CS → Arduino D10
   - MCP2515 SO (MISO) → Arduino D12
   - MCP2515 SI (MOSI) → Arduino D11
   - MCP2515 SCK → Arduino D13
   - MCP2515 INT → Arduino D2

2. **전원 연결**
   - 서보 V+ → 24V 전원 (+)
   - 서보 GND → 24V 전원 (-), Arduino GND (공통 접지)
   - ⚠️ Arduino와 서보는 GND 공통 연결 필수

3. **CAN 버스 연결**
   - MCP2515 CANH → 모든 서보 CANH (병렬 연결)
   - MCP2515 CANL → 모든 서보 CANL (병렬 연결)
   - 버스 양단에 120Ω 터미네이션 저항 연결 (CANH-CANL 사이)

4. **4핀 5264 커넥터 주의사항**
   - 노치(홈) 방향 확인
   - 핀 순서: V+, GND, CANH, CANL

### 1.4 회로 검증 체크리스트

- [ ] 전원 전압 측정 (24V ±1V)
- [ ] Arduino 5V 전압 확인
- [ ] GND 공통 연결 확인
- [ ] CANH, CANL 연결 확인 (단락 없음)
- [ ] 터미네이션 저항 측정 (CANH-CANL 사이 120Ω)
- [ ] 서보 LED 점등 확인 (전원 인가 시)
- [ ] MCP2515 모듈 LED 확인

---

## 🧪 2단계: 통신 기본 테스트

### 2.1 테스트 목표
- CAN 버스 초기화 확인
- 통신 속도 설정 검증 (500 kbps)
- 서보 응답 확인
- 프레임 무결성 검증

### 2.2 테스트 시나리오

#### TEST-C-001: CAN 초기화
- **목적**: MCP2515 모듈 정상 초기화 확인
- **방법**: CAN.begin() 호출 및 반환값 확인
- **예상 결과**: CAN_OK 반환
- **실패 조건**: CAN_FAILINIT 또는 타임아웃

#### TEST-C-002: 서보 발견 (Ping)
- **목적**: 연결된 서보 검색
- **방법**: 정보 읽기 명령(0x01) 브로드캐스트 전송
- **예상 결과**: 각 서보로부터 응답 수신
- **실패 조건**: 타임아웃 (2초 이상 무응답)

#### TEST-C-003: 프레임 검증
- **목적**: 프레임 헤더 및 구조 확인
- **방법**: 수신 데이터 헤더 검사 (AA 00 00)
- **예상 결과**: 모든 프레임이 올바른 헤더 포함
- **실패 조건**: 헤더 불일치
");
 

## ⚙️ 3단계: 명령어 기능 테스트

### 3.1 테스트 목표
- 각 명령어의 정상 동작 확인
- 파라미터 범위 검증
- 에러 처리 확인

### 3.2 테스트 시나리오

#### TEST-C-101: 정보 읽기 (0x01)
- **명령**: `AA 00 00 01 00 00 00 [ID] | 01 00 00 00 00 00 00 00`
- **테스트 케이스**:
  1. 특정 서보(ID=1) 정보 읽기
  2. 브로드캐스트(ID=0) 정보 읽기
  3. 존재하지 않는 ID 조회 (타임아웃 확인)
- **검증**: 위치, HW/SW 버전 정보 파싱

#### TEST-C-102: 운동 제어 (0x03)
- **명령**: `AA 00 00 05 00 00 00 [ID] | 03 [POS_L] [POS_H] [SPD_L] [SPD_H] 00 00 00`
- **테스트 케이스**:
  1. 0도로 이동 (속도 100 deg/s)
  2. 180도로 이동 (속도 150 deg/s)
  3. 360도로 이동 (속도 200 deg/s)
  4. 361도로 이동 (범위 초과 - 에러 예상)
  5. 281 deg/s 속도 (최대값 초과 - 경고 예상)
- **검증**: 서보 실제 움직임, 응답 상태 코드 확인

#### TEST-C-103: ID 수정 (0x07)
- **명령**: 
  - 조회: `AA 00 00 01 00 00 00 [OLD_ID] | 07 00 00 00 00 00 00 00`
  - 변경: `AA 00 00 06 00 00 00 [OLD_ID] | 07 [NEW_ID] [CODE1-4] 00 00`
- **테스트 케이스**:
  1. 고유 코드 조회
  2. ID 1 → 3 변경
  3. ID 3 → 1 복구
  4. 잘못된 고유 코드로 변경 시도 (에러 확인)
- **검증**: 새 ID로 통신 성공 여부

#### TEST-C-104: 잠금 (0x11)
- **명령**: `AA 00 00 01 00 00 00 [ID] | 11 00 00 00 00 00 00 00`
- **테스트 케이스**:
  1. 서보 잠금 실행
  2. 외력 가해 보기 (토크 저항 확인)
- **검증**: 위치 유지, 토크 활성화

#### TEST-C-105: 해제 (0x2F)
- **명령**: `AA 00 00 01 00 00 00 [ID] | 2F 00 00 00 00 00 00 00`
- **테스트 케이스**:
  1. 서보 해제 실행
  2. 수동으로 움직여 보기 (자유 회전 확인)
- **검증**: 토크 제거, 자유 회전

### 3.3 테스트 코드 구조

```cpp
/*
 * CAN_Command_Test.ino
 * 
 * 단계 2: CAN 명령어 기능 테스트
 * - 정보 읽기
 * - 운동 제어
 * - ID 변경
 * - 잠금/해제
 */

// ============================================
// 1. 고급 명령 함수
// ============================================

// 정보 읽기 (위치, 버전)
bool readServoInfo(byte servoId, int* position, byte* hwVer, byte* swVer) {
  // TODO: 명령 전송
  // TODO: 응답 수신 및 파싱
  //   위치 = (data[10] << 8) | data[9]  (Little-Endian)
  //   각도 = (위치 * 360) / 4096
  // TODO: HW/SW 버전 추출
  return false;
}

// 위치 이동 명령
bool moveToPosition(byte servoId, int angle, int speed) {
  // TODO: 각도 → 위치 변환 (angle * 4096 / 360)
  // TODO: 속도 범위 확인 (0~280)
  // TODO: Little-Endian으로 변환
  // TODO: 명령 전송
  // TODO: 응답 확인 (상태 코드)
  return false;
}

// 고유 코드 조회
bool getUniqueCode(byte servoId, byte* uniqueCode) {
  // TODO: ID 수정 명령 (파라미터 0으로)
  // TODO: 응답 수신
  // TODO: 고유 코드 추출 (4바이트)
  return false;
}

// ID 변경
bool changeServoId(byte oldId, byte newId, byte* uniqueCode) {
  // TODO: ID 범위 확인 (1~240)
  // TODO: 변경 명령 전송 (고유 코드 포함)
  // TODO: 응답 확인
  // TODO: 새 ID로 통신 테스트
  return false;
}

// 서보 잠금
bool lockServo(byte servoId) {
  // TODO: 잠금 명령 전송
  // TODO: 응답 확인
  return false;
}

// 서보 해제
bool unlockServo(byte servoId) {
  // TODO: 해제 명령 전송
  // TODO: 응답 확인
  return false;
}

// ============================================
// 2. 테스트 함수들
// ============================================

// TEST-C-101: 정보 읽기
void test_read_info() {
  Serial.println("\n[TEST-C-101] 정보 읽기 테스트");
  
  // 테스트 1: 특정 서보 조회
  // TODO: readServoInfo(1, ...) 호출
  // TODO: 결과 출력 (각도, 버전)
  
  // 테스트 2: 브로드캐스트
  // TODO: readServoInfo(0, ...) 호출
  // TODO: 모든 응답 수집
  
  // 테스트 3: 존재하지 않는 ID
  // TODO: readServoInfo(99, ...) 호출
  // TODO: 타임아웃 확인
}

// TEST-C-102: 운동 제어
void test_motion_control() {
  Serial.println("\n[TEST-C-102] 운동 제어 테스트");
  
  // 테스트 1: 0도 이동
  // TODO: moveToPosition(1, 0, 100)
  // TODO: 3초 대기
  // TODO: 위치 확인
  
  // 테스트 2: 180도 이동
  // TODO: moveToPosition(1, 180, 150)
  // TODO: 3초 대기
  
  // 테스트 3: 360도 이동
  // TODO: moveToPosition(1, 360, 200)
  // TODO: 3초 대기
  
  // 테스트 4: 범위 초과 (361도)
  // TODO: moveToPosition(1, 361, 100)
  // TODO: 에러 응답 확인 (0xCC)
  
  // 테스트 5: 속도 초과 (281 deg/s)
  // TODO: moveToPosition(1, 180, 281)
  // TODO: 경고 응답 확인 (0xBB)
}

// TEST-C-103: ID 변경
void test_change_id() {
  Serial.println("\n[TEST-C-103] ID 변경 테스트");
  Serial.println("⚠️ 주의: ID 변경은 신중하게 수행하세요!");
  
  byte uniqueCode[4];
  
  // 테스트 1: 고유 코드 조회
  // TODO: getUniqueCode(1, uniqueCode)
  // TODO: 고유 코드 출력
  
  // 테스트 2: ID 1 → 3 변경
  // TODO: changeServoId(1, 3, uniqueCode)
  // TODO: ID 3으로 통신 확인
  
  delay(2000);
  
  // 테스트 3: ID 3 → 1 복구
  // TODO: getUniqueCode(3, uniqueCode)
  // TODO: changeServoId(3, 1, uniqueCode)
  // TODO: ID 1로 통신 확인
}

// TEST-C-104: 잠금
void test_lock() {
  Serial.println("\n[TEST-C-104] 잠금 테스트");
  
  // TODO: lockServo(1) 호출
  // TODO: 사용자에게 외력 가해볼 것 안내
  // TODO: 10초 대기
  Serial.println("서보를 손으로 움직여 보세요 (토크 저항 확인)");
  delay(10000);
}

// TEST-C-105: 해제
void test_unlock() {
  Serial.println("\n[TEST-C-105] 해제 테스트");
  
  // TODO: unlockServo(1) 호출
  // TODO: 사용자에게 수동 회전 시도 안내
  // TODO: 10초 대기
  Serial.println("서보를 손으로 회전시켜 보세요 (자유 회전 확인)");
  delay(10000);
}

// ============================================
// 3. Setup & Loop
// ============================================

void setup() {
  // TODO: CAN 초기화 (기본 테스트 재사용)
}

void loop() {
  // TODO: 테스트 메뉴 출력
  //   1: TEST-C-101
  //   2: TEST-C-102
  //   3: TEST-C-103
  //   4: TEST-C-104
  //   5: TEST-C-105
  //   0: 전체 실행
}
```

---

## 🔄 4단계: 고급 기능 테스트

### 4.1 테스트 목표
- 다중 서보 동시 제어
- 브로드캐스트 명령 효과 확인
- 통신 속도 및 안정성 측정
- 연속 동작 성능 평가

### 4.2 테스트 시나리오

#### TEST-C-201: 다중 서보 개별 제어
- **구성**: 서보 3개 연결 (ID 1, 2, 3)
- **테스트**:
  1. 각 서보 순차 이동 (1→90°, 2→180°, 3→270°)
  2. 각 서보 위치 읽기
  3. 동시 움직임 관찰

#### TEST-C-202: 브로드캐스트 동시 제어
- **명령**: ID=0 (모든 서보)
- **테스트**:
  1. 모든 서보 동시 180도 이동
  2. 모든 서보 동시 0도 복귀
  3. 동기화 정확도 확인

#### TEST-C-203: 통신 속도 측정
- **방법**: 1000회 명령 전송 및 응답 시간 측정
- **측정 항목**:
  - 평균 응답 시간
  - 최대/최소 응답 시간
  - 실패율
  - 초당 명령 처리량

#### TEST-C-204: 연속 동작 안정성
- **시나리오**: 복잡한 동작 시퀀스 반복
- **예시**:
  1. 서보1: 0°→180°→0° 반복 (20회)
  2. 서보2: 90°→270°→90° 반복 (20회)
  3. 서보3: 180° 고정
- **검증**: 명령 누락 없음, 오류율 < 1%

#### TEST-C-205: 부하 테스트
- **방법**: 장시간 연속 동작 (30분)
- **모니터링**:
  - 서보 온도
  - 통신 오류율
  - 응답 지연 증가 여부

### 4.3 테스트 코드 구조

```cpp
/*
 * CAN_Advanced_Test.ino
 * 
 * 단계 3: 고급 기능 테스트
 * - 다중 서보 제어
 * - 브로드캐스트
 * - 성능 측정
 * - 안정성 검증
 */

// ============================================
// 1. 다중 서보 관리
// ============================================
#define MAX_SERVOS 10

struct ServoInfo {
  byte id;
  int position;
  byte hwVersion;
  byte swVersion;
  bool online;
  unsigned long lastResponse;
};

ServoInfo servos[MAX_SERVOS];
int servoCount = 0;

// ============================================
// 2. 서보 스캔 함수
// ============================================

// 연결된 서보 자동 검색
int scanServos() {
  Serial.println("서보 스캔 중...");
  servoCount = 0;
  
  // TODO: ID 1~240 순차 스캔
  // TODO: 각 ID에 정보 읽기 명령 전송
  // TODO: 응답 있는 서보 servos[] 배열에 저장
  // TODO: 발견된 서보 정보 출력
  
  Serial.print("총 ");
  Serial.print(servoCount);
  Serial.println("개 서보 발견");
  
  return servoCount;
}

// ============================================
// 3. 브로드캐스트 함수
// ============================================

// 모든 서보 동시 이동
void broadcastMove(int angle, int speed) {
  Serial.print("브로드캐스트: 모든 서보 → ");
  Serial.print(angle);
  Serial.println("도");
  
  // TODO: ID=0으로 이동 명령 전송
  // TODO: 응답 없음 (브로드캐스트 특성)
  // TODO: 이동 시간 기반 대기
}

// ============================================
// 4. 성능 측정 함수
// ============================================

struct PerformanceStats {
  unsigned long totalTime;
  unsigned long minTime;
  unsigned long maxTime;
  int successCount;
  int failCount;
  float avgTime;
  float commandsPerSec;
};

// 통신 속도 측정
PerformanceStats measurePerformance(byte servoId, int iterations) {
  PerformanceStats stats = {0};
  stats.minTime = 999999;
  stats.maxTime = 0;
  
  Serial.print("성능 측정 시작 (");
  Serial.print(iterations);
  Serial.println("회)...");
  
  // TODO: iterations 회 반복
  //   시작 시간 기록
  //   정보 읽기 명령 전송
  //   응답 대기
  //   종료 시간 기록
  //   시간 차이 계산 및 통계 갱신
  
  // TODO: 통계 계산
  //   평균 시간 = 총 시간 / 성공 횟수
  //   초당 명령 = 1000 / 평균 시간
  
  return stats;
}

// ============================================
// 5. 테스트 함수들
// ============================================

// TEST-C-201: 다중 서보 개별 제어
void test_multi_servo_control() {
  Serial.println("\n[TEST-C-201] 다중 서보 제어");
  
  if (servoCount < 2) {
    Serial.println("⚠️ 최소 2개 이상의 서보 필요");
    return;
  }
  
  // TODO: 각 서보를 다른 각도로 이동
  //   Servo 1 → 60도
  //   Servo 2 → 120도
  //   Servo 3 → 180도 (있는 경우)
  
  delay(3000);
  
  // TODO: 각 서보 위치 읽기 및 출력
  // TODO: 목표 각도와 실제 각도 비교
}

// TEST-C-202: 브로드캐스트 테스트
void test_broadcast() {
  Serial.println("\n[TEST-C-202] 브로드캐스트 테스트");
  
  // 테스트 1: 모두 180도
  broadcastMove(180, 150);
  delay(3000);
  
  // TODO: 각 서보 위치 확인
  
  // 테스트 2: 모두 0도
  broadcastMove(0, 150);
  delay(3000);
  
  // TODO: 각 서보 위치 확인
  
  // 테스트 3: 모두 90도
  broadcastMove(90, 150);
  delay(3000);
}

// TEST-C-203: 통신 속도 측정
void test_communication_speed() {
  Serial.println("\n[TEST-C-203] 통신 속도 측정");
  
  if (servoCount == 0) {
    Serial.println("⚠️ 서보가 연결되지 않음");
    return;
  }
  
  // TODO: measurePerformance() 호출 (1000회)
  // TODO: 결과 출력
  //   평균 응답 시간: XX ms
  //   최소/최대: XX ms / XX ms
  //   초당 처리량: XX cmd/s
  //   성공률: XX %
}

// TEST-C-204: 연속 동작 안정성
void test_continuous_motion() {
  Serial.println("\n[TEST-C-204] 연속 동작 테스트");
  
  const int cycles = 20;
  int errorCount = 0;
  
  Serial.print("총 ");
  Serial.print(cycles);
  Serial.println("회 반복 동작...");
  
  for (int i = 0; i < cycles; i++) {
    Serial.print("사이클 ");
    Serial.print(i + 1);
    Serial.print("/");
    Serial.println(cycles);
    
    // TODO: 서보 1: 0도 이동
    // TODO: 서보 2: 90도 이동 (있는 경우)
    delay(1000);
    
    // TODO: 서보 1: 180도 이동
    // TODO: 서보 2: 270도 이동
    delay(1000);
    
    // TODO: 위치 확인 (오류 카운트)
  }
  
  Serial.print("총 오류: ");
  Serial.print(errorCount);
  Serial.print(" / ");
  Serial.println(cycles * 2);
  
  float errorRate = (errorCount * 100.0) / (cycles * 2);
  Serial.print("오류율: ");
  Serial.print(errorRate, 2);
  Serial.println("%");
}

// TEST-C-205: 부하 테스트
void test_load_test() {
  Serial.println("\n[TEST-C-205] 부하 테스트 (30분)");
  Serial.println("⚠️ 장시간 테스트 - 서보 온도 주의!");
  
  unsigned long startTime = millis();
  unsigned long duration = 30L * 60L * 1000L; // 30분
  int cycleCount = 0;
  int errorCount = 0;
  
  // TODO: 30분간 반복
  //   현재 시간 출력
  //   서보 동작
  //   오류 확인
  //   10초 대기
  
  // TODO: 최종 통계 출력
}

// ============================================
// 6. Setup & Loop
// ============================================

void setup() {
  Serial.begin(115200);
  
  // TODO: CAN 초기화
  
  // 서보 자동 검색
  scanServos();
  
  if (servoCount == 0) {
    Serial.println("⚠️ 서보를 찾을 수 없습니다!");
    Serial.println("배선 및 전원을 확인하세요.");
    while (1) delay(1000);
  }
}

void loop() {
  Serial.println("\n=== 고급 테스트 메뉴 ===");
  Serial.println("1. TEST-C-201: 다중 서보 제어");
  Serial.println("2. TEST-C-202: 브로드캐스트");
  Serial.println("3. TEST-C-203: 통신 속도");
  Serial.println("4. TEST-C-204: 연속 동작");
  Serial.println("5. TEST-C-205: 부하 테스트");
  Serial.println("9. 서보 재스캔");
  Serial.println("0. 전체 실행");
  
  // TODO: 사용자 입력 처리
}
```

---

## 📊 5단계: 통합 테스트 및 리포트

### 5.1 테스트 매트릭스

| 테스트 ID | 테스트 항목 | 우선순위 | 예상 시간 | 상태 |
|-----------|------------|---------|----------|------|
| TEST-C-001 | CAN 초기화 | 높음 | 5분 | ⬜ |
| TEST-C-002 | 서보 발견 | 높음 | 10분 | ⬜ |
| TEST-C-003 | 프레임 검증 | 높음 | 10분 | ⬜ |
| TEST-C-101 | 정보 읽기 | 높음 | 15분 | ⬜ |
| TEST-C-102 | 운동 제어 | 높음 | 20분 | ⬜ |
| TEST-C-103 | ID 수정 | 중간 | 15분 | ⬜ |
| TEST-C-104 | 잠금 | 중간 | 10분 | ⬜ |
| TEST-C-105 | 해제 | 중간 | 10분 | ⬜ |
| TEST-C-201 | 다중 서보 | 높음 | 20분 | ⬜ |
| TEST-C-202 | 브로드캐스트 | 중간 | 15분 | ⬜ |
| TEST-C-203 | 통신 속도 | 중간 | 30분 | ⬜ |
| TEST-C-204 | 연속 동작 | 높음 | 25분 | ⬜ |
| TEST-C-205 | 부하 테스트 | 낮음 | 30분 | ⬜ |

**총 예상 시간**: 약 3.5시간

### 5.2 자동화 테스트 스크립트

```cpp
/*
 * CAN_Full_Test_Suite.ino
 * 
 * 통합 테스트 스위트
 * - 모든 테스트 자동 실행
 * - 결과 리포트 생성
 */

// ============================================
// 테스트 결과 구조체
// ============================================
struct TestResult {
  const char* testId;
  const char* testName;
  bool passed;
  unsigned long executionTime;
  const char* errorMsg;
};

TestResult testResults[20];
int testCount = 0;

// ============================================
// 테스트 실행 및 기록
// ============================================
void runTest(const char* id, const char* name, bool (*testFunc)()) {
  Serial.print("\n실행 중: ");
  Serial.println(name);
  
  unsigned long startTime = millis();
  bool result = testFunc();
  unsigned long endTime = millis();
  
  testResults[testCount].testId = id;
  testResults[testCount].testName = name;
  testResults[testCount].passed = result;
  testResults[testCount].executionTime = endTime - startTime;
  testResults[testCount].errorMsg = result ? "" : "실패";
  
  testCount++;
  
  Serial.print(result ? "[PASS] " : "[FAIL] ");
  Serial.print(name);
  Serial.print(" (");
  Serial.print(endTime - startTime);
  Serial.println("ms)");
}

// ============================================
// 전체 테스트 실행
// ============================================
void runAllTests() {
  Serial.println("\n=====================================");
  Serial.println(" UBTECH CAN 서보 전체 테스트 시작");
  Serial.println("=====================================");
  
  testCount = 0;
  unsigned long totalStart = millis();
  
  // 단계 1: 기본 통신
  Serial.println("\n--- 1단계: 기본 통신 ---");
  // TODO: runTest("C-001", "CAN 초기화", test_can_init);
  // TODO: runTest("C-002", "서보 발견", test_servo_discovery);
  // TODO: runTest("C-003", "프레임 검증", test_frame_validation);
  
  // 단계 2: 명령어 기능
  Serial.println("\n--- 2단계: 명령어 기능 ---");
  // TODO: runTest("C-101", "정보 읽기", test_read_info);
  // TODO: runTest("C-102", "운동 제어", test_motion_control);
  // TODO: runTest("C-103", "ID 수정", test_change_id);
  // TODO: runTest("C-104", "잠금", test_lock);
  // TODO: runTest("C-105", "해제", test_unlock);
  
  // 단계 3: 고급 기능
  Serial.println("\n--- 3단계: 고급 기능 ---");
  // TODO: runTest("C-201", "다중 서보", test_multi_servo_control);
  // TODO: runTest("C-202", "브로드캐스트", test_broadcast);
  // TODO: runTest("C-203", "통신 속도", test_communication_speed);
  // TODO: runTest("C-204", "연속 동작", test_continuous_motion);
  
  unsigned long totalEnd = millis();
  
  // 리포트 생성
  generateReport(totalEnd - totalStart);
}

// ============================================
// 리포트 생성
// ============================================
void generateReport(unsigned long totalTime) {
  Serial.println("\n\n=====================================");
  Serial.println(" UBTECH CAN 서보 테스트 리포트");
  Serial.println("=====================================");
  
  Serial.print("테스트 일시: ");
  Serial.println(__DATE__ " " __TIME__);
  
  Serial.println("\n테스트 환경:");
  Serial.println("  - 컨트롤러: Arduino Mega 2560");
  Serial.println("  - CAN 모듈: MCP2515 (8MHz)");
  Serial.println("  - CAN 속도: 500 kbps");
  Serial.print("  - 서보 개수: ");
  Serial.println(servoCount);
  
  // 통계
  int passCount = 0;
  int failCount = 0;
  
  for (int i = 0; i < testCount; i++) {
    if (testResults[i].passed) passCount++;
    else failCount++;
  }
  
  Serial.println("\n-------------------------------------");
  Serial.println("테스트 결과 요약");
  Serial.println("-------------------------------------");
  Serial.print("총 테스트: ");
  Serial.println(testCount);
  Serial.print("통과: ");
  Serial.println(passCount);
  Serial.print("실패: ");
  Serial.println(failCount);
  Serial.print("통과율: ");
  Serial.print((passCount * 100.0) / testCount, 2);
  Serial.println("%");
  
  Serial.println("\n-------------------------------------");
  Serial.println("상세 결과");
  Serial.println("-------------------------------------");
  
  for (int i = 0; i < testCount; i++) {
    Serial.print(testResults[i].passed ? "[PASS] " : "[FAIL] ");
    Serial.print(testResults[i].testId);
    Serial.print(": ");
    Serial.print(testResults[i].testName);
    Serial.print(" (");
    Serial.print(testResults[i].executionTime);
    Serial.println("ms)");
    
    if (!testResults[i].passed) {
      Serial.print("  → 오류: ");
      Serial.println(testResults[i].errorMsg);
    }
  }
  
  Serial.println("\n-------------------------------------");
  Serial.println("권장사항");
  Serial.println("-------------------------------------");
  
  if (failCount > 0) {
    Serial.println("1. 실패한 테스트 재실행");
    Serial.println("2. 배선 및 전원 재확인");
    Serial.println("3. 서보 펌웨어 버전 확인");
  } else {
    Serial.println("모든 테스트 통과!");
    Serial.println("서보가 정상 동작합니다.");
  }
  
  Serial.print("\n총 실행 시간: ");
  Serial.print(totalTime / 1000);
  Serial.println("초");
  
  Serial.println("\n=====================================\n");
}
```

---

## 🔧 트러블슈팅 가이드

### 문제 1: CAN 초기화 실패
**증상**: `CAN.begin()` 반환값이 `CAN_FAILINIT`  
**원인**:
- MCP2515 모듈 불량
- SPI 배선 오류
- 크리스탈 주파수 불일치

**해결**:
1. SPI 배선 재확인 (CS, MOSI, MISO, SCK)
2. MCP2515 전원 확인 (5V)
3. 크리스탈 주파수 확인 (8MHz/16MHz)
4. `MCP_8MHZ` 또는 `MCP_16MHZ` 설정 변경

### 문제 2: 서보 무응답
**증상**: 명령 전송 후 응답 없음  
**원인**:
- 전원 부족 (24V 미공급)
- CAN 배선 오류 (CANH/CANL)
- 터미네이션 저항 누락
- 서보 고장

**해결**:
1. 24V 전원 전압 측정
2. CANH, CANL 배선 확인
3. 터미네이션 저항 설치 (120Ω × 2)
4. GND 공통 연결 확인
5. 다른 서보로 교체 테스트

### 문제 3: 프레임 오류
**증상**: 수신 프레임 헤더가 `AA 00 00`이 아님  
**원인**:
- CAN 속도 불일치
- 전기적 노이즈
- 버스 종단 미처리

**해결**:
1. CAN 속도 500kbps 확인
2. 터미네이션 저항 확인
3. 배선 길이 최소화
4. 차폐 케이블 사용

### 문제 4: 움직임 부정확
**증상**: 명령한 각도와 실제 각도 차이  
**원인**:
- Little-Endian 변환 오류
- 각도 계산 오류
- 기계적 간섭

**해결**:
1. 바이트 순서 확인 (하위→상위)
2. 계산식 확인: `pos = (angle * 4096) / 360`
3. 기계적 장애물 제거
4. 정보 읽기로 실제 위치 확인

### 문제 5: ID 변경 실패
**증상**: ID 변경 후 통신 불가  
**원인**:
- 잘못된 고유 코드
- 변경 후 대기 시간 부족
- 전원 재시작 필요

**해결**:
1. 고유 코드 정확히 조회
2. ID 변경 후 2초 대기
3. 서보 전원 재시작
4. 브로드캐스트로 재확인

### 문제 6: 과열
**증상**: 서보 온도 상승, 성능 저하  
**원인**:
- 1세대 vs 2세대 차이
- 과부하
- 연속 동작

**해결**:
1. 1세대 서보 사용 (발열 적음)
2. 동작 간 휴식 시간 확보
3. 냉각 시스템 추가
4. 부하 감소

---

## 📝 체크리스트

### 테스트 시작 전
- [ ] 모든 부품 준비 완료
- [ ] 회로도 확인
- [ ] 24V 전원 전압 확인
- [ ] MCP2515 배선 확인
- [ ] 터미네이션 저항 설치
- [ ] Arduino 펌웨어 업로드
- [ ] Serial 모니터 115200 bps 설정
- [ ] GND 공통 연결 확인

### 테스트 진행 중
- [ ] 각 테스트 결과 기록
- [ ] 실패 시 로그 저장
- [ ] 이상 동작 시 즉시 전원 차단
- [ ] 서보 온도 수시 확인
- [ ] 비정상 소음 주의

### 테스트 완료 후
- [ ] 전체 테스트 리포트 작성
- [ ] 발견된 문제점 문서화
- [ ] 코드 정리 및 주석 추가
- [ ] 프로토콜 문서 업데이트
- [ ] 다음 단계 계획 수립

---

## 📚 참고 자료

- [Protocol_CAN_Bus.md](Protocol_CAN_Bus.md) - CAN 프로토콜 상세 문서
- [MCP2515 데이터시트](https://ww1.microchip.com/downloads/en/DeviceDoc/MCP2515-Family-Data-Sheet-DS20001801J.pdf)
- [mcp_can 라이브러리](https://github.com/coryjfowler/MCP_CAN_lib)
- CAN 2.0 규격 문서

---

## 🔄 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| 1.0 | 2025-11-23 | 최초 작성 |

---

**작성자**: pashiran  
**버전**: 1.0  
**작성일**: 2025-11-23  
**최종 업데이트**: 2025-11-23
