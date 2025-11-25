/*
 * UBTECH CAN Servo - Command Test Suite
 * 
 * Purpose: Test all CAN protocol commands
 * Based on: CAN_servo_protocol_en.md
 * 
 * Wiring:
 *   MCP2515 VCC  -> Arduino 5V
 *   MCP2515 GND  -> Arduino GND
 *   MCP2515 CS   -> Arduino D10
 *   MCP2515 MISO -> Arduino D12
 *   MCP2515 MOSI -> Arduino D11
 *   MCP2515 SCK  -> Arduino D13
 *   MCP2515 INT  -> Arduino D2
 */

#include <mcp_can.h>
#include <SPI.h>

// ============================================
// Configuration
// ============================================
#define CAN_CS_PIN 10
#define CAN_INT_PIN 2
#define RESPONSE_TIMEOUT 2000

MCP_CAN CAN(CAN_CS_PIN);

byte targetServoID = 1;  // Default servo ID

// ============================================
// Utility Functions
// ============================================

/**
 * CAN 명령 전송 (2-프레임 방식)
 * @param id 서보 ID
 * @param cmd 명령 코드
 * @param params 파라미터 배열
 * @param len 파라미터 길이
 */
void sendCmd(byte id, byte cmd, byte* params, int len) {
  byte frame1[8] = {0xAA, 0x00, 0x00, (byte)(len + 1), 0x00, 0x00, 0x00, id};
  byte frame2[8] = {cmd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
  
  for (int i = 0; i < len && i < 7; i++) frame2[i + 1] = params[i];
  
  CAN.sendMsgBuf(0x00, 0, 8, frame1);
  delay(10);
  CAN.sendMsgBuf(0x00, 0, 8, frame2);
  delay(10);
}

/**
 * 서보 응답 대기
 * @param expectedCmd 예상 응답 명령 코드
 * @param outBuf 응답 데이터 저장 버퍼
 * @param outLen 응답 길이 저장 변수
 * @return 응답 수신 성공 여부
 */
bool waitResponse(byte expectedCmd, byte* outBuf, int* outLen) {
  unsigned long start = millis();
  while (millis() - start < RESPONSE_TIMEOUT) {
    if (CAN.checkReceive() == CAN_MSGAVAIL) {
      unsigned long canId;
      byte len = 0;
      byte buf[8];
      CAN.readMsgBuf(&canId, &len, buf);
      
      if (buf[0] == expectedCmd) {
        *outLen = len;
        memcpy(outBuf, buf, len);
        return true;
      }
    }
    delay(1);
  }
  return false;
}

/**
 * 바이트 배열을 16진수로 출력
 * @param data 출력할 데이터 배열
 * @param len 데이터 길이
 */
void printHex(byte* data, int len) {
  for (int i = 0; i < len; i++) {
    if (data[i] < 0x10) Serial.print('0');
    Serial.print(data[i], HEX);
    Serial.print(' ');
  }
}

/**
 * 시리얼에서 정수 입력 받기
 * @return 입력받은 정수값
 */
int readInt() {
  while (Serial.available() == 0) delay(10);
  int val = 0;
  while (Serial.available() > 0) {
    char c = Serial.read();
    if (c >= '0' && c <= '9') val = val * 10 + (c - '0');
    delay(10);
  }
  return val;
}

// ============================================
// Menu System
// ============================================

/**
 * 메뉴 출력
 */
void printMenu() {
  Serial.println(F("\n===== CAN Servo Command Test ====="));
  Serial.print(F("Target Servo ID: "));
  Serial.println(targetServoID);
  Serial.println();
  Serial.println(F("Single Turn Positioning:"));
  Serial.println(F("  1: Move angle1 (speed)"));
  Serial.println(F("  2: Move angle2 (speed)"));
  Serial.println(F("  3: Move angle1 (time)"));
  Serial.println(F("  4: Move angle2 (time)"));
  Serial.println();
  Serial.println(F("Multi Turn:"));
  Serial.println(F("  5: Incremental rotation"));
  Serial.println(F("  6: Continuous rotation 1"));
  Serial.println(F("  7: Continuous rotation 2"));
  Serial.println();
  Serial.println(F("Stop:"));
  Serial.println(F("  8: Stop & disable"));
  Serial.println(F("  9: Stop & lock"));
  Serial.println(F("  A: Lock current position"));
  Serial.println();
  Serial.println(F("Feedback:"));
  Serial.println(F("  B: Periodic feedback"));
  Serial.println(F("  C: Read temperature"));
  Serial.println(F("  D: Read acceleration"));
  Serial.println(F("  E: Read ID"));
  Serial.println(F("  F: Read angle & version"));
  Serial.println(F("  G: Read version"));
  Serial.println(F("  H: Read zero point"));
  Serial.println(F("  I: Read unique code"));
  Serial.println();
  Serial.println(F("Setup:"));
  Serial.println(F("  J: Set ID"));
  Serial.println(F("  K: Set acceleration"));
  Serial.println(F("  L: Set zero point"));
  Serial.println();
  Serial.println(F("System:"));
  Serial.println(F("  T: Change target ID"));
  Serial.println(F("  M: Show menu"));
  Serial.println(F("==================================\n"));
}

/**
 * 타겟 서보 ID 변경
 */
void changeTargetID() {
  Serial.print(F("New Target ID (1-240): "));
  targetServoID = readInt();
  Serial.print(F("Target changed to: "));
  Serial.println(targetServoID);
}

// ============================================
// Setup & Loop
// ============================================
void setup() {
  Serial.begin(115200);
  while (!Serial) delay(10);
  
  Serial.println(F("\n===== UBTECH CAN Servo Command Test ====="));
  Serial.println(F("Initializing MCP2515..."));
  
  if (CAN.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ) != CAN_OK) {
    Serial.println(F("MCP2515 Init FAILED!"));
    while (1) delay(1000);
  }
  
  if (CAN.setMode(MCP_NORMAL) != MCP2515_OK) {
    Serial.println(F("Mode Set FAILED!"));
    while (1) delay(1000);
  }
  
  Serial.println(F("MCP2515 Ready!"));
  printMenu();
}

void loop() {
  if (Serial.available() > 0) {
    char cmd = Serial.read();
    while (Serial.available() > 0) Serial.read(); // Clear buffer
    
    Serial.print(F("\n> Command: "));
    Serial.println(cmd);
    
    switch (cmd) {
      case '1': cmd_MoveAngle1Speed(); break;
      case '2': cmd_MoveAngle2Speed(); break;
      case '3': cmd_MoveAngle1Time(); break;
      case '4': cmd_MoveAngle2Time(); break;
      case '5': cmd_IncrementalRotation(); break;
      case '6': cmd_ContinuousRotation1(); break;
      case '7': cmd_ContinuousRotation2(); break;
      case '8': cmd_ServoStopDisable(); break;
      case '9': cmd_ServoStopLock(); break;
      case 'A': case 'a': cmd_CurrentPositionLock(); break;
      case 'B': case 'b': cmd_PeriodicFeedback(); break;
      case 'C': case 'c': cmd_ReadTemperature(); break;
      case 'D': case 'd': cmd_ReadAcceleration(); break;
      case 'E': case 'e': cmd_ReadID(); break;
      case 'F': case 'f': cmd_ReadAngleVersion(); break;
      case 'G': case 'g': cmd_ReadVersion(); break;
      case 'H': case 'h': cmd_ReadZeroPoint(); break;
      case 'I': case 'i': cmd_ReadUniqueCode(); break;
      case 'J': case 'j': cmd_SetID(); break;
      case 'K': case 'k': cmd_SetAcceleration(); break;
      case 'L': case 'l': cmd_SetZeroPoint(); break;
      case 'T': case 't': changeTargetID(); break;
      case 'M': case 'm': printMenu(); break;
      default:
        if (cmd >= 32 && cmd <= 126) {
          Serial.println(F("Unknown command"));
          printMenu();
        }
        break;
    }
  }
  
  delay(10);
}

// ============================================
// Command Functions (Based on protocol table)
// ============================================

// Single Turn Positioning

/**
 * 명령 0x03: 지정된 각도로 지정된 속도로 이동 (angle1)
 */
void cmd_MoveAngle1Speed() {
  Serial.print(F("Angle (0-4095): "));
  int angle = readInt();
  Serial.print(F("Speed (0-65535): "));
  int speed = readInt();
  
  byte params[4] = {angle & 0xFF, (angle >> 8) & 0xFF, speed & 0xFF, (speed >> 8) & 0xFF};
  sendCmd(targetServoID, 0x03, params, 4);
  
  byte resp[8];
  int len;
  if (waitResponse(0x04, resp, &len)) {
    Serial.print(F("OK - Status: "));
    printHex(resp, len);
    Serial.println();
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x15: 지정된 각도로 지정된 속도로 이동 (angle2)
 */
void cmd_MoveAngle2Speed() {
  Serial.print(F("Angle (0-4095): "));
  int angle = readInt();
  Serial.print(F("Speed (0-65535): "));
  int speed = readInt();
  
  byte params[4] = {angle & 0xFF, (angle >> 8) & 0xFF, speed & 0xFF, (speed >> 8) & 0xFF};
  sendCmd(targetServoID, 0x15, params, 4);
  
  byte resp[8];
  int len;
  if (waitResponse(0x16, resp, &len)) {
    Serial.print(F("OK - Status: "));
    printHex(resp, len);
    Serial.println();
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x1F: 지정된 시간 내에 지정된 각도로 이동 (angle1)
 */
void cmd_MoveAngle1Time() {
  Serial.print(F("Angle (0-4095): "));
  int angle = readInt();
  Serial.print(F("Time (ms): "));
  int time = readInt();
  
  byte params[4] = {angle & 0xFF, (angle >> 8) & 0xFF, time & 0xFF, (time >> 8) & 0xFF};
  sendCmd(targetServoID, 0x1F, params, 4);
  
  byte resp[8];
  int len;
  if (waitResponse(0x20, resp, &len)) {
    Serial.print(F("OK - Status: "));
    printHex(resp, len);
    Serial.println();
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x21: 지정된 시간 내에 지정된 각도로 이동 (angle2)
 */
void cmd_MoveAngle2Time() {
  Serial.print(F("Angle (0-4095): "));
  int angle = readInt();
  Serial.print(F("Time (ms): "));
  int time = readInt();
  
  byte params[4] = {angle & 0xFF, (angle >> 8) & 0xFF, time & 0xFF, (time >> 8) & 0xFF};
  sendCmd(targetServoID, 0x21, params, 4);
  
  byte resp[8];
  int len;
  if (waitResponse(0x22, resp, &len)) {
    Serial.print(F("OK - Status: "));
    printHex(resp, len);
    Serial.println();
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

// Multi Turn Rotation

/**
 * 명령 0x13: 증분 회전 (상대 각도 이동)
 */
void cmd_IncrementalRotation() {
  Serial.print(F("Angle (0-65535): "));
  int angle = readInt();
  Serial.print(F("Speed (0-65535): "));
  int speed = readInt();
  
  byte params[4] = {angle & 0xFF, (angle >> 8) & 0xFF, speed & 0xFF, (speed >> 8) & 0xFF};
  sendCmd(targetServoID, 0x13, params, 4);
  
  byte resp[8];
  int len;
  if (waitResponse(0x14, resp, &len)) {
    Serial.println(F("OK"));
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x17: 연속 회전 1 (지정 속도로 계속 회전)
 */
void cmd_ContinuousRotation1() {
  Serial.print(F("Speed (0-65535): "));
  int speed = readInt();
  
  byte params[2] = {speed & 0xFF, (speed >> 8) & 0xFF};
  sendCmd(targetServoID, 0x17, params, 2);
  
  byte resp[8];
  int len;
  if (waitResponse(0x18, resp, &len)) {
    Serial.println(F("OK"));
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x3B: 연속 회전 2 (지정 속도로 계속 회전)
 */
void cmd_ContinuousRotation2() {
  Serial.print(F("Speed (0-65535): "));
  int speed = readInt();
  
  byte params[2] = {speed & 0xFF, (speed >> 8) & 0xFF};
  sendCmd(targetServoID, 0x3B, params, 2);
  
  byte resp[8];
  int len;
  if (waitResponse(0x3C, resp, &len)) {
    Serial.println(F("OK"));
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

// Stop Commands

/**
 * 명령 0x2F: 서보 정지 및 비활성화 (토크 해제)
 */
void cmd_ServoStopDisable() {
  byte params[0];
  sendCmd(targetServoID, 0x2F, params, 0);
  
  byte resp[8];
  int len;
  if (waitResponse(0x30, resp, &len)) {
    Serial.println(F("OK - Servo stopped & disabled"));
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x05: 서보 정지 및 잠금 (토크 유지)
 */
void cmd_ServoStopLock() {
  byte params[0];
  sendCmd(targetServoID, 0x05, params, 0);
  
  byte resp[8];
  int len;
  if (waitResponse(0x06, resp, &len)) {
    Serial.println(F("OK - Servo stopped & locked"));
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x11: 현재 위치 잠금 (현재 위치에서 토크 유지)
 */
void cmd_CurrentPositionLock() {
  byte params[0];
  sendCmd(targetServoID, 0x11, params, 0);
  
  byte resp[8];
  int len;
  if (waitResponse(0x12, resp, &len)) {
    Serial.println(F("OK - Position locked"));
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

// Feedback Commands

/**
 * 명령 0x19: 주기적 피드백 설정 (각도, 속도, 전류)
 */
void cmd_PeriodicFeedback() {
  Serial.print(F("Feedback Cycle (ms): "));
  int cycle = readInt();
  
  byte params[1] = {(byte)cycle};
  sendCmd(targetServoID, 0x19, params, 1);
  
  byte resp[8];
  int len;
  if (waitResponse(0x1A, resp, &len)) {
    Serial.print(F("OK - Angle: "));
    int angle = resp[1] | (resp[2] << 8);
    Serial.print(angle);
    Serial.print(F(", Speed: "));
    Serial.print(resp[3]);
    Serial.print(F(", Current: "));
    Serial.println(resp[5]);
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x51: 온도 읽기
 */
void cmd_ReadTemperature() {
  byte params[0];
  sendCmd(targetServoID, 0x51, params, 0);
  
  byte resp[8];
  int len;
  if (waitResponse(0x52, resp, &len)) {
    Serial.print(F("OK - Temperature: "));
    Serial.print(resp[1]);
    Serial.println(F("°C"));
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x25: 가속도 읽기
 */
void cmd_ReadAcceleration() {
  byte params[0];
  sendCmd(targetServoID, 0x25, params, 0);
  
  byte resp[8];
  int len;
  if (waitResponse(0x26, resp, &len)) {
    Serial.print(F("OK - Acceleration: "));
    printHex(resp + 1, len - 1);
    Serial.println();
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x09: 서보 ID 읽기
 */
void cmd_ReadID() {
  byte params[0];
  sendCmd(targetServoID, 0x09, params, 0);
  
  byte resp[8];
  int len;
  if (waitResponse(0x0A, resp, &len)) {
    Serial.print(F("OK - ID: "));
    Serial.println(resp[1]);
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x01: 각도 및 버전 정보 읽기
 */
void cmd_ReadAngleVersion() {
  byte params[0];
  sendCmd(targetServoID, 0x01, params, 0);
  
  byte resp[8];
  int len;
  if (waitResponse(0x02, resp, &len)) {
    Serial.print(F("OK - Angle: "));
    int angle = resp[1] | (resp[2] << 8);
    Serial.print(angle);
    Serial.print(F(", HW: 0x"));
    Serial.print(resp[3], HEX);
    Serial.print(F(", SW: 0x"));
    Serial.println(resp[4], HEX);
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x29: 버전 정보 읽기 (HW/SW)
 */
void cmd_ReadVersion() {
  byte params[0];
  sendCmd(targetServoID, 0x29, params, 0);
  
  byte resp[8];
  int len;
  if (waitResponse(0x2A, resp, &len)) {
    Serial.print(F("OK - HW: 0x"));
    Serial.print(resp[1], HEX);
    Serial.print(F(", SW: 0x"));
    Serial.println(resp[2], HEX);
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x0F: 영점(Zero Point) 위치 읽기
 */
void cmd_ReadZeroPoint() {
  byte params[0];
  sendCmd(targetServoID, 0x0F, params, 0);
  
  byte resp[8];
  int len;
  if (waitResponse(0x10, resp, &len)) {
    Serial.print(F("OK - Zero Position: "));
    int pos = resp[1] | (resp[2] << 8);
    Serial.print(pos);
    Serial.print(F(", Status: 0x"));
    Serial.println(resp[3], HEX);
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x07: 고유 코드 읽기 (ID 변경 시 필요)
 */
void cmd_ReadUniqueCode() {
  byte params[0];
  sendCmd(targetServoID, 0x07, params, 0);
  
  byte resp[8];
  int len;
  if (waitResponse(0x08, resp, &len)) {
    Serial.print(F("OK - Code: "));
    printHex(resp + 2, 4);
    Serial.println();
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

// Setup Commands

/**
 * 명령 0x07: 서보 ID 변경 (고유 코드 필요)
 */
void cmd_SetID() {
  Serial.println(F("Get unique code first..."));
  byte params[0];
  sendCmd(targetServoID, 0x07, params, 0);
  
  byte resp[8];
  int len;
  if (!waitResponse(0x08, resp, &len)) {
    Serial.println(F("FAILED to get unique code"));
    return;
  }
  
  byte code[4];
  memcpy(code, resp + 2, 4);
  
  Serial.print(F("New ID (1-240): "));
  int newID = readInt();
  
  byte params2[5] = {(byte)newID, code[0], code[1], code[2], code[3]};
  sendCmd(targetServoID, 0x07, params2, 5);
  
  if (waitResponse(0x08, resp, &len)) {
    Serial.print(F("OK - ID changed to "));
    Serial.println(newID);
    targetServoID = newID;
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x23: 가속도 설정
 */
void cmd_SetAcceleration() {
  Serial.print(F("Acceleration (0-255): "));
  int accel = readInt();
  
  byte params[1] = {(byte)accel};
  sendCmd(targetServoID, 0x23, params, 1);
  
  byte resp[8];
  int len;
  if (waitResponse(0x24, resp, &len)) {
    Serial.println(F("OK"));
  } else {
    Serial.println(F("TIMEOUT"));
  }
}

/**
 * 명령 0x0B: 영점(Zero Point) 설정
 */
void cmd_SetZeroPoint() {
  byte params[0];
  sendCmd(targetServoID, 0x0B, params, 0);
  Serial.println(F("Command sent (no response expected)"));
}

// ============================================
// Menu System
// ============================================
void printMenu() {
  Serial.println(F("\n===== CAN Servo Command Test ====="));
  Serial.print(F("Target Servo ID: "));
  Serial.println(targetServoID);
  Serial.println();
  Serial.println(F("Single Turn Positioning:"));
  Serial.println(F("  1: Move angle1 (speed)"));
  Serial.println(F("  2: Move angle2 (speed)"));
  Serial.println(F("  3: Move angle1 (time)"));
  Serial.println(F("  4: Move angle2 (time)"));
  Serial.println();
  Serial.println(F("Multi Turn:"));
  Serial.println(F("  5: Incremental rotation"));
  Serial.println(F("  6: Continuous rotation 1"));
  Serial.println(F("  7: Continuous rotation 2"));
  Serial.println();
  Serial.println(F("Stop:"));
  Serial.println(F("  8: Stop & disable"));
  Serial.println(F("  9: Stop & lock"));
  Serial.println(F("  A: Lock current position"));
  Serial.println();
  Serial.println(F("Feedback:"));
  Serial.println(F("  B: Periodic feedback"));
  Serial.println(F("  C: Read temperature"));
  Serial.println(F("  D: Read acceleration"));
  Serial.println(F("  E: Read ID"));
  Serial.println(F("  F: Read angle & version"));
  Serial.println(F("  G: Read version"));
  Serial.println(F("  H: Read zero point"));
  Serial.println(F("  I: Read unique code"));
  Serial.println();
  Serial.println(F("Setup:"));
  Serial.println(F("  J: Set ID"));
  Serial.println(F("  K: Set acceleration"));
  Serial.println(F("  L: Set zero point"));
  Serial.println();
  Serial.println(F("System:"));
  Serial.println(F("  T: Change target ID"));
  Serial.println(F("  M: Show menu"));
  Serial.println(F("==================================\n"));
}

void changeTargetID() {
  Serial.print(F("New Target ID (1-240): "));
  targetServoID = readInt();
  Serial.print(F("Target changed to: "));
  Serial.println(targetServoID);
}

// ============================================
// Setup & Loop
// ============================================
void setup() {
  Serial.begin(115200);
  while (!Serial) delay(10);
  
  Serial.println(F("\n===== UBTECH CAN Servo Command Test ====="));
  Serial.println(F("Initializing MCP2515..."));
  
  if (CAN.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ) != CAN_OK) {
    Serial.println(F("MCP2515 Init FAILED!"));
    while (1) delay(1000);
  }
  
  if (CAN.setMode(MCP_NORMAL) != MCP2515_OK) {
    Serial.println(F("Mode Set FAILED!"));
    while (1) delay(1000);
  }
  
  Serial.println(F("MCP2515 Ready!"));
  printMenu();
}

void loop() {
  if (Serial.available() > 0) {
    char cmd = Serial.read();
    while (Serial.available() > 0) Serial.read(); // Clear buffer
    
    Serial.print(F("\n> Command: "));
    Serial.println(cmd);
    
    switch (cmd) {
      case '1': cmd_MoveAngle1Speed(); break;
      case '2': cmd_MoveAngle2Speed(); break;
      case '3': cmd_MoveAngle1Time(); break;
      case '4': cmd_MoveAngle2Time(); break;
      case '5': cmd_IncrementalRotation(); break;
      case '6': cmd_ContinuousRotation1(); break;
      case '7': cmd_ContinuousRotation2(); break;
      case '8': cmd_ServoStopDisable(); break;
      case '9': cmd_ServoStopLock(); break;
      case 'A': case 'a': cmd_CurrentPositionLock(); break;
      case 'B': case 'b': cmd_PeriodicFeedback(); break;
      case 'C': case 'c': cmd_ReadTemperature(); break;
      case 'D': case 'd': cmd_ReadAcceleration(); break;
      case 'E': case 'e': cmd_ReadID(); break;
      case 'F': case 'f': cmd_ReadAngleVersion(); break;
      case 'G': case 'g': cmd_ReadVersion(); break;
      case 'H': case 'h': cmd_ReadZeroPoint(); break;
      case 'I': case 'i': cmd_ReadUniqueCode(); break;
      case 'J': case 'j': cmd_SetID(); break;
      case 'K': case 'k': cmd_SetAcceleration(); break;
      case 'L': case 'l': cmd_SetZeroPoint(); break;
      case 'T': case 't': changeTargetID(); break;
      case 'M': case 'm': printMenu(); break;
      default:
        if (cmd >= 32 && cmd <= 126) {
          Serial.println(F("Unknown command"));
          printMenu();
        }
        break;
    }
  }
  
  delay(10);
}