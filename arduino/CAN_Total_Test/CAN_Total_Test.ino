/*
 * UBTECH CAN Servo - Comprehensive Automated Test Program
 * 
 * VERSION: 3.0.0
 * Date: 2025-11-30
 * 
 * 변경 이력:
 * v3.0.0 (2025-11-30)
 *   - 전면 재작성: 체크리스트 기반 자동화 테스트
 *   - 순차적 테스트: 정보 읽기 → 이동 → 피드백 확인 → 속도 변경 → 가속도 확인
 *   - 모터 자체 기능 활용: 위치 확인, 회전 확인, 상태 확인
 *   - 체크리스트 순서대로 명령어 테스트
 * 
 * 테스트 시퀀스:
 *   1. 서보 탐색 (0x01)
 *   2. 기본 정보 읽기 (0x01, 0x09, 0x29, 0x0F)
 *   3. 각도 이동 테스트 (0x03, 0x15)
 *   4. 속도 변경 테스트 (다양한 속도로 이동)
 *   5. 가속도 확인 (0x25)
 *   6. 증분 회전 테스트 (0x13)
 *   7. 연속 회전 테스트 (0x17, 0x3B)
 *   8. 주기적 피드백 테스트 (0x19)
 *   9. 설정 명령 테스트 (0x23 가속도 설정)
 *   10. 결과 요약
 * 
 * 배선:
 *   MCP2515 VCC  -> Arduino 5V
 *   MCP2515 GND  -> Arduino GND
 *   MCP2515 CS   -> Arduino D10
 *   MCP2515 MISO -> Arduino D12
 *   MCP2515 MOSI -> Arduino D11
 *   MCP2515 SCK  -> Arduino D13
 *   MCP2515 INT  -> Arduino D2
 * 
 * 크리스탈: 16 MHz
 */

#include <mcp_can.h>
#include <SPI.h>

// ============================================
// 핀 설정
// ============================================
#define CAN_CS_PIN 10
#define CAN_INT_PIN 2

// MCP2515 객체 생성
MCP_CAN CAN(CAN_CS_PIN);

// ============================================
// 전역 변수
// ============================================
byte testServoID = 0;        // 테스트 대상 서보 ID
int currentPosition = 0;     // 현재 위치 (0-4095)
byte hwVersion = 0;          // HW 버전
byte swVersion = 0;          // SW 버전
int zeroPoint = 0;           // 영점 값
byte acceleration = 0;       // 가속도 값

// 테스트 결과 추적
int testsPassed = 0;
int testsFailed = 0;
int testsSkipped = 0;

// ============================================
// 함수 선언
// ============================================
// 초기화
void initializeCAN();
bool findServo();

// 정보 읽기 명령 (0x01, 0x09, 0x29, 0x0F, 0x25)
bool cmdReadInfo(byte servoID, int* pos, byte* hw, byte* sw);
bool cmdReadID(byte servoID, byte* id);
bool cmdReadVersion(byte servoID, byte* hw, byte* sw);
bool cmdReadZeroPoint(byte servoID, int* zero);
bool cmdReadAcceleration(byte servoID, byte* accel);

// 이동 명령 (0x03, 0x15)
bool cmdMoveToAngle1(byte servoID, int position, int speed);
bool cmdMoveToAngle2(byte servoID, int position, int speed);

// 증분/연속 회전 명령 (0x13, 0x17, 0x3B)
bool cmdIncrementalRotation(byte servoID, int increment);
bool cmdContinuousRotation1(byte servoID, int speed);
bool cmdContinuousRotation2(byte servoID, int speed);
bool cmdStopRotation(byte servoID);

// 피드백 명령 (0x19)
bool cmdPeriodicFeedback(byte servoID, bool enable);
bool readPeriodicFeedback(int* pos, int* spd, int* curr, byte* state);

// 설정 명령 (0x23)
bool cmdSetAcceleration(byte servoID, byte accel);

// 유틸리티
void sendTwoFrameCommand(unsigned long canId, byte cmd, byte* data, int dataLen);
bool waitForResponse(byte expectedCmd, byte* response, int* responseLen, unsigned long timeout);
float positionToAngle(int position);
int angleToPosition(float angle);
void printTestHeader(const char* testName);
void printTestResult(bool passed, const char* details);
void printSeparator();
byte extractServoIDFromCANID(unsigned long canId);

// 테스트 함수
void runAutomatedTests();
void testBasicInfo();
void testAngleMovement();
void testSpeedVariation();
void testAccelerationReading();
void testIncrementalRotation();
void testContinuousRotation();
void testPeriodicFeedback();
void testAccelerationSetting();
void printTestSummary();

// ============================================
// 초기화
// ============================================
void setup() {
  Serial.begin(115200);
  while (!Serial) delay(10);
  
  delay(500);
  Serial.flush();
  
  Serial.println(F("\n========================================"));
  Serial.println(F("UBTECH CAN Servo"));
  Serial.println(F("Comprehensive Automated Test v3.0"));
  Serial.println(F("========================================\n"));
  
  // CAN 초기화
  initializeCAN();
  
  // 서보 찾기
  Serial.println(F("\n[STEP 1] Servo Discovery"));
  printSeparator();
  if (!findServo()) {
    Serial.println(F("\nERROR: No servo found!"));
    Serial.println(F("Check connections and power, then reset Arduino."));
    while (1) delay(1000);
  }
  
  Serial.print(F("\nServo ID "));
  Serial.print(testServoID);
  Serial.println(F(" detected. Starting automated test...\n"));
  delay(2000);
  
  // 자동 테스트 실행
  runAutomatedTests();
  
  // 결과 요약
  printTestSummary();
  
  Serial.println(F("\n========================================"));
  Serial.println(F("Test Complete"));
  Serial.println(F("========================================"));
  Serial.println(F("\nPress 'R' to restart tests"));
}

// ============================================
// 메인 루프
// ============================================
void loop() {
  // 사용자 입력 확인
  if (Serial.available() > 0) {
    char input = Serial.read();
    
    if (input == 'R' || input == 'r') {
      Serial.println(F("\n\nRestarting tests...\n"));
      delay(500);
      
      // 테스트 카운터 초기화
      testsPassed = 0;
      testsFailed = 0;
      testsSkipped = 0;
      
      // 테스트 재실행
      runAutomatedTests();
      printTestSummary();
      
      Serial.println(F("\nPress 'R' to restart tests"));
    }
  }
  
  delay(100);
}

// ============================================
// 자동 테스트 실행
// ============================================
void runAutomatedTests() {
  // 테스트 2: 기본 정보 읽기
  testBasicInfo();
  delay(1000);
  
  // 테스트 3: 각도 이동 테스트 (0x03)
  testAngleMovement();
  delay(1000);
  
  // 테스트 4: 속도 변경 테스트
  testSpeedVariation();
  delay(1000);
  
  // 테스트 5: 가속도 확인
  testAccelerationReading();
  delay(1000);
  
  // 테스트 6: 증분 회전 테스트
  testIncrementalRotation();
  delay(1000);
  
  // 테스트 7: 연속 회전 테스트
  testContinuousRotation();
  delay(1000);
  
  // 테스트 8: 주기적 피드백 테스트
  testPeriodicFeedback();
  delay(1000);
  
  // 테스트 9: 가속도 설정 테스트
  testAccelerationSetting();
  delay(1000);
}

// ============================================
// 테스트 2: 기본 정보 읽기
// ============================================
void testBasicInfo() {
  Serial.println(F("\n[STEP 2] Basic Information Reading"));
  printSeparator();
  
  // 0x01: 정보 읽기
  printTestHeader("0x01: Read Info");
  int pos;
  byte hw, sw;
  if (cmdReadInfo(testServoID, &pos, &hw, &sw)) {
    currentPosition = pos;
    hwVersion = hw;
    swVersion = sw;
    
    char details[80];
    sprintf(details, "Pos=%d (%.1f°), HW=0x%02X, SW=0x%02X", 
            pos, positionToAngle(pos), hw, sw);
    printTestResult(true, details);
    testsPassed++;
  } else {
    printTestResult(false, "No response");
    testsFailed++;
  }
  
  // 0x09: ID 읽기
  printTestHeader("0x09: Read ID");
  byte id;
  if (cmdReadID(testServoID, &id)) {
    char details[40];
    sprintf(details, "ID=%d", id);
    printTestResult(true, details);
    testsPassed++;
  } else {
    printTestResult(false, "No response");
    testsFailed++;
  }
  
  // 0x29: 버전 읽기
  printTestHeader("0x29: Read Version");
  if (cmdReadVersion(testServoID, &hw, &sw)) {
    char details[60];
    sprintf(details, "HW=0x%02X, SW=0x%02X", hw, sw);
    printTestResult(true, details);
    testsPassed++;
  } else {
    printTestResult(false, "No response");
    testsFailed++;
  }
  
  // 0x0F: 영점 읽기
  printTestHeader("0x0F: Read Zero Point");
  if (cmdReadZeroPoint(testServoID, &zeroPoint)) {
    char details[60];
    sprintf(details, "Zero=%d (%.1f°)", zeroPoint, positionToAngle(zeroPoint));
    printTestResult(true, details);
    testsPassed++;
  } else {
    printTestResult(false, "No response");
    testsFailed++;
  }
}

// ============================================
// 테스트 3: 각도 이동
// ============================================
void testAngleMovement() {
  Serial.println(F("\n[STEP 3] Angle Movement Test (0x03)"));
  printSeparator();
  
  // 이동 전 위치 읽기
  printTestHeader("Read initial position");
  int initialPos;
  byte dummy1, dummy2;
  if (cmdReadInfo(testServoID, &initialPos, &dummy1, &dummy2)) {
    char details[40];
    sprintf(details, "Start: %d (%.1f°)", initialPos, positionToAngle(initialPos));
    printTestResult(true, details);
    testsPassed++;
  } else {
    printTestResult(false, "Failed to read position");
    testsFailed++;
    return;
  }
  
  // 90도로 이동
  printTestHeader("Move to 90°");
  int targetPos90 = angleToPosition(90.0);
  if (cmdMoveToAngle1(testServoID, targetPos90, 100)) {
    printTestResult(true, "Command sent, waiting...");
    delay(2000);  // 이동 완료 대기
    
    // 이동 후 위치 확인
    int finalPos;
    if (cmdReadInfo(testServoID, &finalPos, &dummy1, &dummy2)) {
      int error = abs(finalPos - targetPos90);
      char details[60];
      sprintf(details, "Final: %d (%.1f°), Error: %d units", 
              finalPos, positionToAngle(finalPos), error);
      
      if (error < 50) {  // 5도 이내 오차 허용
        printTestResult(true, details);
        testsPassed++;
      } else {
        printTestResult(false, details);
        testsFailed++;
      }
    } else {
      printTestResult(false, "Failed to verify position");
      testsFailed++;
    }
  } else {
    printTestResult(false, "No response");
    testsFailed++;
  }
  
  // 180도로 이동
  printTestHeader("Move to 180°");
  int targetPos180 = angleToPosition(180.0);
  if (cmdMoveToAngle1(testServoID, targetPos180, 100)) {
    printTestResult(true, "Command sent, waiting...");
    delay(2000);
    
    int finalPos;
    if (cmdReadInfo(testServoID, &finalPos, &dummy1, &dummy2)) {
      int error = abs(finalPos - targetPos180);
      char details[60];
      sprintf(details, "Final: %d (%.1f°), Error: %d units", 
              finalPos, positionToAngle(finalPos), error);
      
      if (error < 50) {
        printTestResult(true, details);
        testsPassed++;
      } else {
        printTestResult(false, details);
        testsFailed++;
      }
    } else {
      printTestResult(false, "Failed to verify position");
      testsFailed++;
    }
  } else {
    printTestResult(false, "No response");
    testsFailed++;
  }
}

// ============================================
// 테스트 4: 속도 변경
// ============================================
void testSpeedVariation() {
  Serial.println(F("\n[STEP 4] Speed Variation Test"));
  printSeparator();
  
  int speeds[] = {50, 100, 200};  // deg/s
  int startPos = angleToPosition(0.0);
  int endPos = angleToPosition(180.0);
  
  for (int i = 0; i < 3; i++) {
    char testName[40];
    sprintf(testName, "Move 0°→180° @ %d deg/s", speeds[i]);
    printTestHeader(testName);
    
    // 시작 위치로 이동 (빠른 속도)
    cmdMoveToAngle1(testServoID, startPos, 200);
    delay(2000);
    
    // 측정 시작
    unsigned long startTime = millis();
    
    if (cmdMoveToAngle1(testServoID, endPos, speeds[i])) {
      // 이동 완료까지 대기
      delay(4000);
      
      unsigned long duration = millis() - startTime;
      
      char details[60];
      sprintf(details, "Time: %lu ms (%.1f s)", duration, duration / 1000.0);
      printTestResult(true, details);
      testsPassed++;
    } else {
      printTestResult(false, "No response");
      testsFailed++;
    }
    
    delay(500);
  }
}

// ============================================
// 테스트 5: 가속도 읽기
// ============================================
void testAccelerationReading() {
  Serial.println(F("\n[STEP 5] Acceleration Reading Test"));
  printSeparator();
  
  printTestHeader("0x25: Read Acceleration");
  if (cmdReadAcceleration(testServoID, &acceleration)) {
    char details[40];
    sprintf(details, "Acceleration=%d", acceleration);
    printTestResult(true, details);
    testsPassed++;
  } else {
    printTestResult(false, "No response");
    testsFailed++;
  }
}

// ============================================
// 테스트 6: 증분 회전
// ============================================
void testIncrementalRotation() {
  Serial.println(F("\n[STEP 6] Incremental Rotation Test (0x13)"));
  printSeparator();
  
  int rotations[] = {1, 2, -1};  // 1회전, 2회전, -1회전
  
  for (int i = 0; i < 3; i++) {
    char testName[40];
    sprintf(testName, "Rotate %d revolution(s)", rotations[i]);
    printTestHeader(testName);
    
    // 회전 전 위치
    int posBefore;
    byte dummy1, dummy2;
    cmdReadInfo(testServoID, &posBefore, &dummy1, &dummy2);
    
    // 증분 회전 명령 (4096 units = 1 rotation)
    int increment = rotations[i] * 4096;
    
    if (cmdIncrementalRotation(testServoID, increment)) {
      printTestResult(true, "Command sent, rotating...");
      delay(3000);  // 회전 완료 대기
      
      // 회전 후 위치
      int posAfter;
      if (cmdReadInfo(testServoID, &posAfter, &dummy1, &dummy2)) {
        int actualRotation = posAfter - posBefore;
        char details[80];
        sprintf(details, "Before: %d, After: %d, Delta: %d (%.1f rev)", 
                posBefore, posAfter, actualRotation, actualRotation / 4096.0);
        printTestResult(true, details);
        testsPassed++;
      } else {
        printTestResult(false, "Failed to verify position");
        testsFailed++;
      }
    } else {
      printTestResult(false, "No response");
      testsFailed++;
    }
    
    delay(1000);
  }
}

// ============================================
// 테스트 7: 연속 회전
// ============================================
void testContinuousRotation() {
  Serial.println(F("\n[STEP 7] Continuous Rotation Test"));
  printSeparator();
  
  // 0x17: 연속 회전 1 (시계방향)
  printTestHeader("0x17: Continuous Rotation CW");
  if (cmdContinuousRotation1(testServoID, 100)) {  // 100 deg/s
    printTestResult(true, "Rotating CW, wait 2s...");
    delay(2000);
    
    // 정지
    if (cmdStopRotation(testServoID)) {
      printTestResult(true, "Stopped");
      testsPassed++;
    } else {
      printTestResult(false, "Failed to stop");
      testsFailed++;
    }
  } else {
    printTestResult(false, "No response");
    testsFailed++;
  }
  
  delay(1000);
  
  // 0x3B: 연속 회전 2 (반시계방향)
  printTestHeader("0x3B: Continuous Rotation CCW");
  if (cmdContinuousRotation2(testServoID, -100)) {  // -100 deg/s
    printTestResult(true, "Rotating CCW, wait 2s...");
    delay(2000);
    
    if (cmdStopRotation(testServoID)) {
      printTestResult(true, "Stopped");
      testsPassed++;
    } else {
      printTestResult(false, "Failed to stop");
      testsFailed++;
    }
  } else {
    printTestResult(false, "No response");
    testsFailed++;
  }
}

// ============================================
// 테스트 8: 주기적 피드백
// ============================================
void testPeriodicFeedback() {
  Serial.println(F("\n[STEP 8] Periodic Feedback Test (0x19)"));
  printSeparator();
  
  printTestHeader("Enable periodic feedback");
  if (cmdPeriodicFeedback(testServoID, true)) {
    printTestResult(true, "Enabled, collecting data...");
    
    // 피드백 데이터 수집 (5초)
    int sampleCount = 0;
    unsigned long startTime = millis();
    
    while (millis() - startTime < 5000 && sampleCount < 10) {
      int pos, spd, curr;
      byte state;
      
      if (readPeriodicFeedback(&pos, &spd, &curr, &state)) {
        sampleCount++;
        char details[80];
        sprintf(details, "Sample %d: Pos=%d, Spd=%d, Curr=%d, State=0x%02X", 
                sampleCount, pos, spd, curr, state);
        Serial.print(F("  "));
        Serial.println(details);
      }
      delay(500);
    }
    
    // 비활성화
    if (cmdPeriodicFeedback(testServoID, false)) {
      char details[40];
      sprintf(details, "Disabled, Samples: %d", sampleCount);
      printTestResult(true, details);
      testsPassed++;
    } else {
      printTestResult(false, "Failed to disable");
      testsFailed++;
    }
  } else {
    printTestResult(false, "Failed to enable");
    testsFailed++;
  }
}

// ============================================
// 테스트 9: 가속도 설정
// ============================================
void testAccelerationSetting() {
  Serial.println(F("\n[STEP 9] Acceleration Setting Test (0x23)"));
  printSeparator();
  
  byte testAccel = 50;
  
  printTestHeader("0x23: Set Acceleration");
  if (cmdSetAcceleration(testServoID, testAccel)) {
    char details[40];
    sprintf(details, "Set to %d", testAccel);
    printTestResult(true, details);
    
    delay(500);
    
    // 읽기로 확인
    byte readAccel;
    if (cmdReadAcceleration(testServoID, &readAccel)) {
      char verifyDetails[60];
      sprintf(verifyDetails, "Verify: %d (Match: %s)", 
              readAccel, (readAccel == testAccel) ? "YES" : "NO");
      
      if (readAccel == testAccel) {
        printTestResult(true, verifyDetails);
        testsPassed++;
      } else {
        printTestResult(false, verifyDetails);
        testsFailed++;
      }
    } else {
      printTestResult(false, "Failed to verify");
      testsFailed++;
    }
  } else {
    printTestResult(false, "No response");
    testsFailed++;
  }
}

// ============================================
// 테스트 결과 요약
// ============================================
void printTestSummary() {
  Serial.println(F("\n========================================"));
  Serial.println(F("TEST SUMMARY"));
  Serial.println(F("========================================"));
  
  Serial.print(F("Passed:  "));
  Serial.println(testsPassed);
  
  Serial.print(F("Failed:  "));
  Serial.println(testsFailed);
  
  Serial.print(F("Skipped: "));
  Serial.println(testsSkipped);
  
  Serial.print(F("Total:   "));
  Serial.println(testsPassed + testsFailed + testsSkipped);
  
  int passRate = 0;
  if (testsPassed + testsFailed > 0) {
    passRate = (testsPassed * 100) / (testsPassed + testsFailed);
  }
  
  Serial.print(F("Pass Rate: "));
  Serial.print(passRate);
  Serial.println(F("%"));
  
  Serial.println(F("========================================"));
}

// ============================================
// CAN 초기화
// ============================================
void initializeCAN() {
  Serial.println(F("Initializing CAN Bus..."));
  Serial.println(F("  Speed: 1 Mbps"));
  Serial.println(F("  Crystal: 16 MHz"));
  
  if (CAN.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ) != CAN_OK) {
    Serial.println(F("\nERROR: CAN initialization failed!"));
    Serial.println(F("Check:"));
    Serial.println(F("  1. Wiring (CS, MOSI, MISO, SCK)"));
    Serial.println(F("  2. 5V power to MCP2515"));
    Serial.println(F("  3. SPI connections"));
    while (1) delay(1000);
  }
  
  if (CAN.setMode(MCP_NORMAL) != MCP2515_OK) {
    Serial.println(F("\nERROR: Failed to set NORMAL mode!"));
    while (1) delay(1000);
  }
  
  Serial.println(F("  OK!\n"));
}

// ============================================
// 서보 찾기
// ============================================
bool findServo() {
  Serial.println(F("Broadcasting discovery command..."));
  
  // 브로드캐스트 명령 (ID=0xFF)
  byte data[7] = {0};
  sendTwoFrameCommand(0x00, 0x01, data, 0);
  
  Serial.println(F("Waiting for responses (3 seconds)...\n"));
  
  unsigned long startTime = millis();
  while (millis() - startTime < 3000) {
    if (CAN.checkReceive() == CAN_MSGAVAIL) {
      unsigned long canId;
      byte len = 0;
      byte buf[8];
      
      CAN.readMsgBuf(&canId, &len, buf);
      
      // 응답 코드 확인 (0x02 = 정보 읽기 응답)
      if (buf[0] == 0x02 && len >= 5) {
        testServoID = extractServoIDFromCANID(canId);
        currentPosition = buf[1] | (buf[2] << 8);
        hwVersion = buf[3];
        swVersion = buf[4];
        
        Serial.print(F("Found Servo ID: "));
        Serial.println(testServoID);
        Serial.print(F("  Position: "));
        Serial.print(currentPosition);
        Serial.print(F(" ("));
        Serial.print(positionToAngle(currentPosition), 1);
        Serial.println(F("°)"));
        Serial.print(F("  HW Ver: 0x"));
        Serial.println(hwVersion, HEX);
        Serial.print(F("  SW Ver: 0x"));
        Serial.println(swVersion, HEX);
        
        return true;
      }
    }
    delay(10);
  }
  
  return false;
}

// ============================================
// 명령 함수 구현
// ============================================

// 0x01: 정보 읽기
bool cmdReadInfo(byte servoID, int* pos, byte* hw, byte* sw) {
  byte data[7] = {0};
  sendTwoFrameCommand(0x00, 0x01, data, 0);
  
  byte response[8];
  int responseLen;
  
  if (waitForResponse(0x02, response, &responseLen, 2000)) {
    if (responseLen >= 5) {
      *pos = response[1] | (response[2] << 8);
      *hw = response[3];
      *sw = response[4];
      return true;
    }
  }
  return false;
}

// 0x09: ID 읽기
bool cmdReadID(byte servoID, byte* id) {
  byte data[7] = {0};
  sendTwoFrameCommand(0x00, 0x09, data, 0);
  
  byte response[8];
  int responseLen;
  
  if (waitForResponse(0x0A, response, &responseLen, 2000)) {
    if (responseLen >= 2) {
      *id = response[1];
      return true;
    }
  }
  return false;
}

// 0x29: 버전 읽기
bool cmdReadVersion(byte servoID, byte* hw, byte* sw) {
  byte data[7] = {0};
  sendTwoFrameCommand(0x00, 0x29, data, 0);
  
  byte response[8];
  int responseLen;
  
  if (waitForResponse(0x2A, response, &responseLen, 2000)) {
    if (responseLen >= 3) {
      *hw = response[1];
      *sw = response[2];
      return true;
    }
  }
  return false;
}

// 0x0F: 영점 읽기
bool cmdReadZeroPoint(byte servoID, int* zero) {
  byte data[7] = {0};
  sendTwoFrameCommand(0x00, 0x0F, data, 0);
  
  byte response[8];
  int responseLen;
  
  if (waitForResponse(0x10, response, &responseLen, 2000)) {
    if (responseLen >= 3) {
      *zero = response[1] | (response[2] << 8);
      return true;
    }
  }
  return false;
}

// 0x25: 가속도 읽기
bool cmdReadAcceleration(byte servoID, byte* accel) {
  byte data[7] = {0};
  sendTwoFrameCommand(0x00, 0x25, data, 0);
  
  byte response[8];
  int responseLen;
  
  if (waitForResponse(0x26, response, &responseLen, 2000)) {
    if (responseLen >= 2) {
      *accel = response[1];
      return true;
    }
  }
  return false;
}

// 0x03: 각도1로 이동
bool cmdMoveToAngle1(byte servoID, int position, int speed) {
  byte data[4];
  data[0] = position & 0xFF;
  data[1] = (position >> 8) & 0xFF;
  data[2] = speed & 0xFF;
  data[3] = (speed >> 8) & 0xFF;
  
  sendTwoFrameCommand(0x00, 0x03, data, 4);
  
  byte response[8];
  int responseLen;
  
  return waitForResponse(0x04, response, &responseLen, 2000);
}

// 0x15: 각도2로 이동
bool cmdMoveToAngle2(byte servoID, int position, int speed) {
  byte data[4];
  data[0] = position & 0xFF;
  data[1] = (position >> 8) & 0xFF;
  data[2] = speed & 0xFF;
  data[3] = (speed >> 8) & 0xFF;
  
  sendTwoFrameCommand(0x00, 0x15, data, 4);
  
  byte response[8];
  int responseLen;
  
  return waitForResponse(0x16, response, &responseLen, 2000);
}

// 0x13: 증분 회전
bool cmdIncrementalRotation(byte servoID, int increment) {
  byte data[2];
  data[0] = increment & 0xFF;
  data[1] = (increment >> 8) & 0xFF;
  
  sendTwoFrameCommand(0x00, 0x13, data, 2);
  
  byte response[8];
  int responseLen;
  
  return waitForResponse(0x14, response, &responseLen, 2000);
}

// 0x17: 연속 회전 1
bool cmdContinuousRotation1(byte servoID, int speed) {
  byte data[2];
  data[0] = speed & 0xFF;
  data[1] = (speed >> 8) & 0xFF;
  
  sendTwoFrameCommand(0x00, 0x17, data, 2);
  
  byte response[8];
  int responseLen;
  
  return waitForResponse(0x18, response, &responseLen, 2000);
}

// 0x3B: 연속 회전 2
bool cmdContinuousRotation2(byte servoID, int speed) {
  byte data[2];
  data[0] = speed & 0xFF;
  data[1] = (speed >> 8) & 0xFF;
  
  sendTwoFrameCommand(0x00, 0x3B, data, 2);
  
  byte response[8];
  int responseLen;
  
  return waitForResponse(0x3C, response, &responseLen, 2000);
}

// 회전 정지 (속도 0으로 연속 회전)
bool cmdStopRotation(byte servoID) {
  return cmdContinuousRotation1(servoID, 0);
}

// 0x19: 주기적 피드백
bool cmdPeriodicFeedback(byte servoID, bool enable) {
  byte data[1];
  data[0] = enable ? 0x01 : 0x00;
  
  sendTwoFrameCommand(0x00, 0x19, data, 1);
  
  byte response[8];
  int responseLen;
  
  return waitForResponse(0x1A, response, &responseLen, 2000);
}

// 주기적 피드백 데이터 읽기
bool readPeriodicFeedback(int* pos, int* spd, int* curr, byte* state) {
  if (CAN.checkReceive() == CAN_MSGAVAIL) {
    unsigned long canId;
    byte len = 0;
    byte buf[8];
    
    CAN.readMsgBuf(&canId, &len, buf);
    
    // 피드백 응답 확인 (0x1A)
    if (buf[0] == 0x1A && len >= 7) {
      *pos = buf[1] | (buf[2] << 8);
      *spd = buf[3] | (buf[4] << 8);
      *curr = buf[5];
      *state = buf[6];
      return true;
    }
  }
  return false;
}

// 0x23: 가속도 설정
bool cmdSetAcceleration(byte servoID, byte accel) {
  byte data[1];
  data[0] = accel;
  
  sendTwoFrameCommand(0x00, 0x23, data, 1);
  
  byte response[8];
  int responseLen;
  
  return waitForResponse(0x24, response, &responseLen, 2000);
}

// ============================================
// 유틸리티 함수
// ============================================

// 2-프레임 명령 전송
void sendTwoFrameCommand(unsigned long canId, byte cmd, byte* data, int dataLen) {
  byte frame1[8] = {0xAA, 0x00, 0x00, (byte)(dataLen + 1), 0x00, 0x00, 0x00, testServoID};
  byte frame2[8] = {cmd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
  
  // 데이터 복사
  for (int i = 0; i < dataLen && i < 7; i++) {
    frame2[i + 1] = data[i];
  }
  
  // 버퍼 비우기
  while (CAN.checkReceive() == CAN_MSGAVAIL) {
    unsigned long dummyId;
    byte dummyLen;
    byte dummyBuf[8];
    CAN.readMsgBuf(&dummyId, &dummyLen, dummyBuf);
  }
  
  CAN.sendMsgBuf(canId, 0, 8, frame1);
  delay(10);
  CAN.sendMsgBuf(canId, 0, 8, frame2);
  delay(10);
}

// 응답 대기
bool waitForResponse(byte expectedCmd, byte* response, int* responseLen, unsigned long timeout) {
  unsigned long startTime = millis();
  
  while (millis() - startTime < timeout) {
    if (CAN.checkReceive() == CAN_MSGAVAIL) {
      unsigned long canId;
      byte len = 0;
      byte buf[8];
      
      CAN.readMsgBuf(&canId, &len, buf);
      
      // 응답 코드 확인
      if (buf[0] == expectedCmd) {
        for (int i = 0; i < len; i++) {
          response[i] = buf[i];
        }
        *responseLen = len;
        return true;
      }
    }
    delay(1);
  }
  
  return false;
}

// 위치를 각도로 변환
float positionToAngle(int position) {
  return (position * 360.0) / 4096.0;
}

// 각도를 위치로 변환
int angleToPosition(float angle) {
  return (int)((angle * 4096.0) / 360.0);
}

// CAN ID에서 서보 ID 추출
byte extractServoIDFromCANID(unsigned long canId) {
  return (byte)(canId & 0xFF);
}

// 테스트 헤더 출력
void printTestHeader(const char* testName) {
  Serial.print(F("\n  [TEST] "));
  Serial.println(testName);
}

// 테스트 결과 출력
void printTestResult(bool passed, const char* details) {
  Serial.print(F("    "));
  if (passed) {
    Serial.print(F("[PASS] "));
  } else {
    Serial.print(F("[FAIL] "));
  }
  Serial.println(details);
}

// 구분선 출력
void printSeparator() {
  Serial.println(F("----------------------------------------"));
}
