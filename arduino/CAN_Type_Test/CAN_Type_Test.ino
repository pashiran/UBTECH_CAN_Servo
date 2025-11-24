/*
 * UBTECH CAN Servo Test - MCP2515 Communication Check
 * 
 * 테스트 목적: MCP2515 CAN 모듈 통신 점검
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
 * 크리스탈: 16 MHz (MCP2515 모듈에 따라 8MHz일 수도 있음)
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
byte lastFoundServoID = 0;  // 마지막으로 발견된 서보 ID (0=없음)
byte foundServoIDs[240];    // 발견된 서보 ID 목록
int foundServoCount = 0;    // 발견된 서보 개수

// ============================================
// 함수 선언 (프로토콜 명령어 기반)
// ============================================
// 0x01: 정보 읽기
void cmdReadInfo(byte servoID);

// 0x03: 운동 제어
void cmdMoveServo(byte servoID, int position, int speed);

// 0x07: ID 수정
bool cmdGetUniqueCode(byte servoID, byte code[4]);
bool cmdChangeID(byte oldID, byte newID, byte code[4]);

// 0x11: 잠금
void cmdLockServo(byte servoID);

// 0x2F: 해제
void cmdUnlockServo(byte servoID);

// 유틸리티
void sendTwoFrameCommand(byte servoID, byte cmd, byte* data, int dataLen);
void printServoResponse(unsigned long canId, byte* buf, int len);
byte extractServoIDFromCANID(unsigned long canId);

// ============================================
// 초기화
// ============================================
void setup() {
  Serial.begin(115200);
  while (!Serial) delay(10);
  
  delay(500);
  Serial.flush();
  
  Serial.println(F("\n================================="));
  Serial.println(F("UBTECH CAN Servo - MCP2515 Test"));
  Serial.println(F("=================================\n"));

  Serial.println(F("[1] MCP2515 init..."));
  Serial.println(F("    - CAN: 1 Mbps"));
  Serial.println(F("    - Crystal: 16 MHz"));
  
  byte initResult = CAN.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ);
  
  if (initResult == CAN_OK) {
    Serial.println(F("    OK!"));
  } else {
    Serial.println(F("    FAIL!"));
    Serial.print(F("    Error: "));
    Serial.println(initResult);
    Serial.println(F("\nCheck:"));
    Serial.println(F("  1. Wiring"));
    Serial.println(F("  2. 5V power"));
    Serial.println(F("  3. SPI pins"));
    while (1) delay(1000);
  }
  
  Serial.println(F("\n[2] Set mode..."));
  if (CAN.setMode(MCP_NORMAL) == MCP2515_OK) {
    Serial.println(F("    OK!"));
  } else {
    Serial.println(F("    FAIL!"));
  }
  
  Serial.println(F("\n[3] Clock check"));
  Serial.println(F("    - 16 MHz"));
  Serial.println(F("    - 1 Mbps"));
  
  Serial.println(F("\n================================="));
  Serial.println(F("Ready"));
  Serial.println(F("=================================\n"));
  
  Serial.println(F("Searching in 3 sec..."));
  
  for (int i = 3; i > 0; i--) {
    Serial.print(F("  "));
    Serial.print(i);
    Serial.println(F("..."));
    Serial.flush();
    delay(1000);
  }
  Serial.println();
  Serial.flush();
  
  Serial.println(F("\n[4] Servo search..."));
  Serial.flush();
  delay(100);
  
  sendServoDiscovery();
  
  printMenu();
}

// ============================================
// 메뉴 출력 함수
// ============================================
void printMenu() {
  Serial.println(F("\nMenu:"));
  Serial.println(F("  1: Search"));
  Serial.println(F("  2: Test TX"));
  Serial.println(F("  3: Monitor"));
  Serial.println(F("  4: Loopback"));
  Serial.println(F("  5: Status"));
  Serial.println(F("  6: Try 500kbps"));
  Serial.println(F("  7: Rotate Demo"));
  Serial.println(F("  8: Read Info"));
  Serial.println(F("  9: Change ID"));
  Serial.println(F("  D: Debug IDs 2-6"));
  Serial.println(F("  L: Lock Servo"));
  Serial.println(F("  U: Unlock Servo"));
  Serial.println();
  Serial.flush();
}

// ============================================
// 서보 검색 함수
// ============================================
void sendServoDiscovery() {
  // 근본적 해결책: 개별 ID 쿼리 방식
  // - 브로드캐스트 대신 ID 1~240을 순차 쿼리
  // - 한 번에 1개 서보만 응답 → MCP2515 버퍼 오버플로우 방지
  // - 모든 서보를 확실하게 탐지
  
  Serial.println(F("    Scanning IDs 1~240 individually..."));
  Serial.println(F("    (Avoids MCP2515 RX buffer overflow)"));
  Serial.println();
  
  // 발견된 서보 목록 초기화
  foundServoCount = 0;
  for (int i = 0; i < 240; i++) {
    foundServoIDs[i] = 0;
  }
  
  byte frame1[8] = {0xAA, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00};  // ID는 나중에 설정
  byte frame2[8] = {0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};  // CMD=0x01 (정보 읽기)
  
  int scannedCount = 0;
  
  // ID 1~240을 순차 쿼리 (전체 범위 스캔)
  for (byte testID = 1; testID <= 240; testID++) {
    frame1[7] = testID;  // 대상 ID 설정
    
    // 명령 전송
    CAN.sendMsgBuf(0x00, 0, 8, frame1);
    delay(20);
    CAN.sendMsgBuf(0x00, 0, 8, frame2);
    
    scannedCount++;
    
    // 응답 대기 (300ms)
    unsigned long startTime = millis();
    bool foundResponse = false;
    
    while (millis() - startTime < 300) {
      if (CAN.checkReceive() == CAN_MSGAVAIL) {
        unsigned long canId;
        byte len = 0;
        byte buf[8];
        
        CAN.readMsgBuf(&canId, &len, buf);
        
        // CAN ID에서 서보 ID 추출
        byte foundServoID = extractServoIDFromCANID(canId);
        
        // 응답한 서보가 쿼리한 ID와 일치하는지 확인
        if (foundServoID == testID) {
          // 새로운 서보 발견
          foundServoIDs[foundServoCount] = foundServoID;
          foundServoCount++;
          lastFoundServoID = foundServoID;
          
          Serial.print(F("    ["));
          Serial.print(scannedCount);
          Serial.print(F("/240] Found Servo ID "));
          Serial.print(foundServoID);
          
          // 위치 정보 파싱 (타입 B: 단일 8바이트 프레임)
          if (len >= 3 && buf[0] == 0x02) {
            int posRaw = buf[1] | (buf[2] << 8);
            float angle = (posRaw * 360.0) / 4096.0;
            Serial.print(F(" @ "));
            Serial.print(angle, 1);
            Serial.print(F("°"));
          }
          Serial.println();
          
          foundResponse = true;
          break;  // 응답 받았으므로 다음 ID로
        }
      }
      delay(1);
    }
    
    // 진행 상황 표시 (매 20개마다)
    if (!foundResponse && testID % 20 == 0) {
      Serial.print(F("    ["));
      Serial.print(scannedCount);
      Serial.print(F("/240] Scanning..."));
      Serial.println();
    }
  }
  
  Serial.println();
  if (foundServoCount == 0) {
    Serial.println(F("    ! No servos found"));
    Serial.println();
    Serial.println(F("    Check:"));
    Serial.println(F("      - 24V power"));
    Serial.println(F("      - CANH/CANL wiring"));
    Serial.println(F("      - 120ohm termination"));
    Serial.println(F("      - GND common"));
    Serial.println();
    Serial.println(F("    Or servos may have IDs > 240"));
    Serial.println(F("    (Increase scan range if needed)"));
  } else {
    Serial.print(F("    === FOUND: "));
    Serial.print(foundServoCount);
    Serial.println(F(" SERVO(S) ==="));
    Serial.print(F("    IDs: "));
    for (int i = 0; i < foundServoCount; i++) {
      Serial.print(foundServoIDs[i]);
      if (i < foundServoCount - 1) Serial.print(F(", "));
    }
    Serial.println();
  }
  Serial.println();
  Serial.flush();
}

// ============================================
// 메인 루프
// ============================================
void loop() {
  if (Serial.available() > 0) {
    char input = Serial.read();
    
    switch (input) {
      case '1':
        Serial.println(F("\n>>> Search"));
        sendServoDiscovery();
        printMenu();
        break;
        
      case '2':
        Serial.println(F("\n>>> Test TX"));
        {
          byte testFrame[8] = {0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08};
          CAN.sendMsgBuf(0x100, 0, 8, testFrame);
          Serial.println(F("    OK"));
        }
        printMenu();
        break;
        
      case '3':
        Serial.println(F("\n>>> Monitor 10s"));
        monitorCAN(10000);
        printMenu();
        break;
        
      case '4':
        Serial.println(F("\n>>> Loopback"));
        testLoopback();
        printMenu();
        break;
        
      case '5':
        Serial.println(F("\n>>> Status"));
        checkCANStatus();
        printMenu();
        break;
        
      case '6':
        Serial.println(F("\n>>> Try 500kbps"));
        tryDifferentSpeed();
        printMenu();
        break;
        
      case '7':
        Serial.println(F("\n>>> Rotate Demo"));
        rotateServoDemo();
        printMenu();
        break;
        
      case '8':
        Serial.println(F("\n>>> Read Info"));
        readServoInfo();
        printMenu();
        break;
        
      case '9':
        Serial.println(F("\n>>> Change ID"));
        changeServoID();
        printMenu();
        break;
        
      case 'd':
      case 'D':
        Serial.println(F("\n>>> Debug IDs 2-6"));
        debugMissingServos();
        printMenu();
        break;
        
      case 'l':
      case 'L':
        Serial.println(F("\n>>> Lock Servo"));
        if (lastFoundServoID > 0) {
          cmdLockServo(lastFoundServoID);
        } else {
          Serial.println(F("    ! No servo found. Run 'Search' first."));
        }
        Serial.println();
        printMenu();
        break;
        
      case 'u':
      case 'U':
        Serial.println(F("\n>>> Unlock Servo"));
        if (lastFoundServoID > 0) {
          cmdUnlockServo(lastFoundServoID);
        } else {
          Serial.println(F("    ! No servo found. Run 'Search' first."));
        }
        Serial.println();
        printMenu();
        break;
        
      default:
        if (input >= 32 && input <= 126) {
          Serial.println(F("\n? Unknown"));
          printMenu();
        }
        break;
    }
  }
  
  if (CAN.checkReceive() == CAN_MSGAVAIL) {
    unsigned long canId;
    byte len = 0;
    byte buf[8];
    
    CAN.readMsgBuf(&canId, &len, buf);
    
    Serial.print(F("RX: ID=0x"));
    if (canId < 0x10) Serial.print(F("0"));
    if (canId < 0x100) Serial.print(F("0"));
    Serial.print(canId, HEX);
    Serial.print(F(" L="));
    Serial.print(len);
    Serial.print(F(" D="));
    
    for (int i = 0; i < len; i++) {
      if (buf[i] < 0x10) Serial.print(F("0"));
      Serial.print(buf[i], HEX);
      Serial.print(F(" "));
    }
    
    if (len >= 3 && buf[0] == 0xAA && buf[1] == 0x00 && buf[2] == 0x00) {
      Serial.print(F(" [UB]"));
      if (len >= 8) {
        Serial.print(F(" ID="));
        Serial.print(buf[7]);
      }
    }
    Serial.println();
  }
  
  delay(10);
}

// ============================================
// 연속 모니터링 함수
// ============================================
void monitorCAN(unsigned long duration) {
  unsigned long startTime = millis();
  int msgCount = 0;
  
  Serial.println(F("    Monitoring...\n"));
  
  while (millis() - startTime < duration) {
    if (CAN.checkReceive() == CAN_MSGAVAIL) {
      unsigned long canId;
      byte len = 0;
      byte buf[8];
      
      CAN.readMsgBuf(&canId, &len, buf);
      msgCount++;
      
      Serial.print(F("    ["));
      Serial.print(msgCount);
      Serial.print(F("] 0x"));
      if (canId < 0x100) Serial.print(F("0"));
      Serial.print(canId, HEX);
      Serial.print(F(" "));
      
      for (int i = 0; i < len; i++) {
        if (buf[i] < 0x10) Serial.print(F("0"));
        Serial.print(buf[i], HEX);
        Serial.print(F(" "));
      }
      Serial.println();
    }
    delay(10);
  }
  
  Serial.print(F("\n    Done: "));
  Serial.print(msgCount);
  Serial.println(F(" msg\n"));
}

void testLoopback() {
  Serial.println(F("    Set loopback..."));
  Serial.flush();
  
  if (CAN.setMode(MCP_LOOPBACK) == MCP2515_OK) {
    Serial.println(F("    OK\n"));
    
    byte testData[8] = {0xAA, 0xBB, 0xCC, 0xDD, 0x11, 0x22, 0x33, 0x44};
    Serial.println(F("    TX: AA BB CC DD 11 22 33 44"));
    CAN.sendMsgBuf(0x123, 0, 8, testData);
    
    delay(100);
    
    if (CAN.checkReceive() == CAN_MSGAVAIL) {
      unsigned long canId;
      byte len = 0;
      byte buf[8];
      
      CAN.readMsgBuf(&canId, &len, buf);
      
      Serial.print(F("    RX: 0x"));
      Serial.print(canId, HEX);
      Serial.print(F(" "));
      for (int i = 0; i < len; i++) {
        if (buf[i] < 0x10) Serial.print(F("0"));
        Serial.print(buf[i], HEX);
        Serial.print(F(" "));
      }
      Serial.println();
      Serial.println(F("    => HW OK!"));
    } else {
      Serial.println(F("    FAIL!"));
    }
  } else {
    Serial.println(F("    FAIL!"));
  }
  
  Serial.println();
  Serial.println(F("    Back to normal..."));
  CAN.setMode(MCP_NORMAL);
  Serial.println(F("    Done\n"));
  Serial.flush();
}

void checkCANStatus() {
  Serial.println(F("    Status:"));
  Serial.println();
  Serial.println(F("    Info:"));
  Serial.println(F("      - MCP2515: OK"));
  Serial.println(F("      - SPI: OK"));
  Serial.println(F("      - Mode: NORMAL"));
  Serial.println();
  Serial.println(F("    Checklist:"));
  Serial.println(F("      [ ] CANH wire"));
  Serial.println(F("      [ ] CANL wire"));
  Serial.println(F("      [ ] 120ohm"));
  Serial.println(F("      [ ] GND common"));
  Serial.println(F("      [ ] 24V power"));
  Serial.println();
  Serial.println(F("    Measure:"));
  Serial.println(F("      - H~L: 60ohm"));
  Serial.println(F("      - CANH: 2.5~3.5V"));
  Serial.println(F("      - CANL: 1.5~2.5V"));
  Serial.println();
  Serial.println(F("    Speed:"));
  Serial.println(F("      - Set: 1 Mbps"));
  Serial.println(F("      - This servo"));
  Serial.println();
  Serial.flush();
}

void rotateServoDemo() {
  Serial.println(F("    Rotating servo..."));
  Serial.println(F("    Press any key to stop\n"));
  Serial.flush();
  
  byte servoID = 0x00;  // 브로드캐스트 (모든 서보)
  
  // 각도 변환: 0도 = 0, 180도 = 2048, 360도 = 4095
  int pos0 = 0;           // 0도
  int pos90 = 1024;       // 90도
  int pos180 = 2048;      // 180도
  int pos270 = 3072;      // 270도
  int speed = 100;        // 100 deg/s
  
  int cycle = 0;
  
  while (Serial.available() == 0) {
    cycle++;
    
    // 0도로 이동
    Serial.print(F("    [#"));
    Serial.print(cycle);
    Serial.println(F("] -> 0 deg"));
    moveServo(servoID, pos0, speed);
    delay(2000);
    
    if (Serial.available() > 0) break;
    
    // 180도로 이동
    Serial.print(F("    [#"));
    Serial.print(cycle);
    Serial.println(F("] -> 180 deg"));
    moveServo(servoID, pos180, speed);
    delay(2000);
    
    if (Serial.available() > 0) break;
  }
  
  // 입력 버퍼 비우기
  while (Serial.available() > 0) Serial.read();
  
  Serial.println(F("\n    Stopped\n"));
  Serial.flush();
}

void moveServo(byte servoID, int position, int speed) {
  // 16바이트 논리 패킷: AA 00 00 05 00 00 00 [ID] | 03 [POS_L] [POS_H] [SPD_L] [SPD_H] 00 00 00
  byte frame1[8] = {0xAA, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, servoID};
  byte frame2[8];
  
  frame2[0] = 0x03;                    // 명령 코드: 운동 제어
  frame2[1] = position & 0xFF;         // 위치 하위바이트
  frame2[2] = (position >> 8) & 0xFF;  // 위치 상위바이트
  frame2[3] = speed & 0xFF;            // 속도 하위바이트
  frame2[4] = (speed >> 8) & 0xFF;     // 속도 상위바이트
  frame2[5] = 0x00;
  frame2[6] = 0x00;
  frame2[7] = 0x00;
  
  CAN.sendMsgBuf(0x00, 0, 8, frame1);
  delay(10);
  CAN.sendMsgBuf(0x00, 0, 8, frame2);
  delay(10);
}

void readServoInfo() {
  Serial.println(F("    Enter Servo ID (0=all, 1-240):"));
  Serial.flush();
  
  // ID 입력 대기
  while (Serial.available() == 0) delay(10);
  
  int servoID = 0;
  while (Serial.available() > 0) {
    char c = Serial.read();
    if (c >= '0' && c <= '9') {
      servoID = servoID * 10 + (c - '0');
    }
  }
  
  if (servoID > 240) {
    Serial.println(F("    ! Invalid ID\n"));
    return;
  }
  
  Serial.print(F("    Query ID: "));
  Serial.println(servoID);
  Serial.println();
  Serial.flush();
  
  // 명령 전송: AA 00 00 01 00 00 00 [ID] | 01 00 00 00 00 00 00 00
  byte frame1[8] = {0xAA, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, (byte)servoID};
  byte frame2[8] = {0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
  
  CAN.sendMsgBuf(0x00, 0, 8, frame1);
  delay(10);
  CAN.sendMsgBuf(0x00, 0, 8, frame2);
  delay(10);
  
  Serial.println(F("    Wait 2 sec...\n"));
  Serial.flush();
  
  unsigned long startTime = millis();
  int responseCount = 0;
  
  while (millis() - startTime < 2000) {
    if (CAN.checkReceive() == CAN_MSGAVAIL) {
      unsigned long canId;
      byte len = 0;
      byte buf[8];
      
      CAN.readMsgBuf(&canId, &len, buf);
      
      // 서보 응답 프레임 구조:
      // CAN ID: 서보 ID (0x101 등)
      // 바이트 0: 응답 코드 (0x02 = 정보 읽기 응답)
      // 바이트 1-2: 위치 (Little-Endian, 0-4095)
      // 바이트 3: HW 버전
      // 바이트 4: SW 버전
      // 바이트 5-7: 추가 데이터
      
      if (len == 8 && buf[0] == 0x02) {  // 응답 코드 확인
        responseCount++;
        
        // 서보 ID (CAN ID에서 추출)
        int realServoID = canId & 0xFF;  // 하위 8비트
        
        // 위치: 바이트 1-2 (Little-Endian)
        int position = buf[1] | (buf[2] << 8);
        float angle = (position * 360.0) / 4096.0;
        
        // 전체 데이터 출력
        Serial.print(F("    ["));
        Serial.print(responseCount);
        Serial.print(F("] "));
        
        // Raw 데이터
        Serial.print(F("Raw: "));
        for (int i = 0; i < len; i++) {
          if (buf[i] < 0x10) Serial.print(F("0"));
          Serial.print(buf[i], HEX);
          Serial.print(F(" "));
        }
        Serial.println();
        
        // 파싱된 데이터
        Serial.print(F("        Servo ID: "));
        Serial.print(realServoID);
        Serial.print(F(" (CAN ID: 0x"));
        if (canId < 0x100) Serial.print(F("0"));
        Serial.print(canId, HEX);
        Serial.println(F(")"));
        
        Serial.print(F("        Position: "));
        Serial.print(position);
        Serial.print(F(" ("));
        Serial.print(angle, 1);
        Serial.print(F(" deg, 0x"));
        if (buf[2] < 0x10) Serial.print(F("0"));
        Serial.print(buf[2], HEX);
        if (buf[1] < 0x10) Serial.print(F("0"));
        Serial.print(buf[1], HEX);
        Serial.println(F(")"));
        
        Serial.print(F("        HW Ver: 0x"));
        if (buf[3] < 0x10) Serial.print(F("0"));
        Serial.print(buf[3], HEX);
        Serial.print(F(" ("));
        Serial.print(buf[3]);
        Serial.println(F(")"));
        
        Serial.print(F("        SW Ver: 0x"));
        if (buf[4] < 0x10) Serial.print(F("0"));
        Serial.print(buf[4], HEX);
        Serial.print(F(" ("));
        Serial.print(buf[4]);
        Serial.println(F(")"));
        
        Serial.print(F("        Extra: "));
        for (int i = 5; i < 8; i++) {
          if (buf[i] < 0x10) Serial.print(F("0"));
          Serial.print(buf[i], HEX);
          Serial.print(F(" "));
        }
        Serial.println();
        
        Serial.println();
        Serial.flush();
      }
    }
    delay(10);
  }
  
  if (responseCount == 0) {
    Serial.println(F("    ! No response\n"));
  } else {
    Serial.print(F("\n    Found: "));
    Serial.print(responseCount);
    Serial.println(F(" servo(s)\n"));
  }
  Serial.flush();
}

void changeServoID() {
  Serial.println(F("    Step 1: Get Unique Code"));
  
  // 자동으로 마지막 발견된 ID 사용
  int oldID = lastFoundServoID;
  
  if (oldID == 0) {
    Serial.println(F("    ! No servo found yet."));
    Serial.println(F("    Run 'Search' first or enter OLD ID (1-240):"));
    Serial.flush();
    
    // ID 입력 대기
    while (Serial.available() == 0) delay(10);
    
    oldID = 0;
    while (Serial.available() > 0) {
      char c = Serial.read();
      if (c >= '0' && c <= '9') {
        oldID = oldID * 10 + (c - '0');
      }
      delay(10);
    }
    
    if (oldID < 1 || oldID > 240) {
      Serial.println(F("    ! Invalid ID\n"));
      return;
    }
  } else {
    Serial.print(F("    Using last found servo ID: "));
    Serial.println(oldID);
  }
  
  Serial.print(F("    Old ID: "));
  Serial.println(oldID);
  Serial.println();
  Serial.flush();
  
  // 고유 코드 가져오기 (새 프로토콜 함수 사용)
  byte uniqueCode[4];
  if (!cmdGetUniqueCode((byte)oldID, uniqueCode)) {
    Serial.println(F("    ! Failed to get unique code\n"));
    return;
  }
  
  // 새 ID 입력
  Serial.println(F("\n    Step 2: Set New ID"));
  Serial.println(F("    Enter NEW ID (1-240):"));
  Serial.flush();
  
  while (Serial.available() == 0) delay(10);
  int newID = 0;
  while (Serial.available() > 0) {
    char c = Serial.read();
    if (c >= '0' && c <= '9') {
      newID = newID * 10 + (c - '0');
    }
    delay(10);
  }
  
  if (newID < 1 || newID > 240) {
    Serial.println(F("    ! Invalid ID\n"));
    return;
  }
  
  Serial.print(F("    New ID: "));
  Serial.println(newID);
  Serial.println();
  Serial.flush();
  
  // ID 변경 (새 프로토콜 함수 사용)
  if (cmdChangeID((byte)oldID, (byte)newID, uniqueCode)) {
    lastFoundServoID = (byte)newID;  // 성공 시 새 ID 저장
  }
  
  Serial.println();
  Serial.flush();
}

// ============================================
// 디버그: ID 2-6 상세 진단
// ============================================
void debugMissingServos() {
  Serial.println(F("    Testing IDs 2-6 with detailed logging"));
  Serial.println(F("    This will help diagnose why they don't respond"));
  Serial.println();
  
  byte frame1[8] = {0xAA, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00};
  byte frame2[8] = {0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
  
  for (byte testID = 2; testID <= 6; testID++) {
    Serial.println(F("    ----------------------------------------"));
    Serial.print(F("    Testing ID: "));
    Serial.println(testID);
    Serial.println(F("    ----------------------------------------"));
    
    frame1[7] = testID;
    
    // 버퍼 비우기
    while (CAN.checkReceive() == CAN_MSGAVAIL) {
      unsigned long dummyId;
      byte dummyLen;
      byte dummyBuf[8];
      CAN.readMsgBuf(&dummyId, &dummyLen, dummyBuf);
    }
    
    // 프레임 1 전송
    Serial.print(F("    TX Frame1: "));
    for (int i = 0; i < 8; i++) {
      if (frame1[i] < 0x10) Serial.print(F("0"));
      Serial.print(frame1[i], HEX);
      Serial.print(F(" "));
    }
    Serial.println();
    
    byte result1 = CAN.sendMsgBuf(0x00, 0, 8, frame1);
    if (result1 != CAN_OK) {
      Serial.print(F("    ! TX1 FAILED: "));
      Serial.println(result1);
    }
    delay(20);
    
    // 프레임 2 전송
    Serial.print(F("    TX Frame2: "));
    for (int i = 0; i < 8; i++) {
      if (frame2[i] < 0x10) Serial.print(F("0"));
      Serial.print(frame2[i], HEX);
      Serial.print(F(" "));
    }
    Serial.println();
    
    byte result2 = CAN.sendMsgBuf(0x00, 0, 8, frame2);
    if (result2 != CAN_OK) {
      Serial.print(F("    ! TX2 FAILED: "));
      Serial.println(result2);
    }
    
    // 응답 대기 (500ms)
    Serial.println(F("    Waiting for response (500ms)..."));
    unsigned long startTime = millis();
    bool gotResponse = false;
    int msgCount = 0;
    
    while (millis() - startTime < 500) {
      if (CAN.checkReceive() == CAN_MSGAVAIL) {
        unsigned long canId;
        byte len = 0;
        byte buf[8];
        
        CAN.readMsgBuf(&canId, &len, buf);
        msgCount++;
        gotResponse = true;
        
        Serial.print(F("    RX["));
        Serial.print(msgCount);
        Serial.print(F("]: CAN_ID=0x"));
        if (canId < 0x100) Serial.print(F("0"));
        if (canId < 0x10) Serial.print(F("0"));
        Serial.print(canId, HEX);
        Serial.print(F(" LEN="));
        Serial.print(len);
        Serial.print(F(" DATA: "));
        
        for (int i = 0; i < len; i++) {
          if (buf[i] < 0x10) Serial.print(F("0"));
          Serial.print(buf[i], HEX);
          Serial.print(F(" "));
        }
        
        byte respondedID = extractServoIDFromCANID(canId);
        Serial.print(F(" [Servo ID: "));
        Serial.print(respondedID);
        Serial.println(F("]"));
        
        if (respondedID == testID) {
          Serial.println(F("    *** MATCH! This servo responded! ***"));
        }
      }
      delay(1);
    }
    
    if (!gotResponse) {
      Serial.println(F("    *** NO RESPONSE ***"));
      Serial.println(F("    Possible causes:"));
      Serial.println(F("      - Motor not powered"));
      Serial.println(F("      - Wrong ID (not actually ID 2-6)"));
      Serial.println(F("      - CAN bus disconnected"));
      Serial.println(F("      - Motor firmware issue"));
    } else {
      Serial.print(F("    Total messages received: "));
      Serial.println(msgCount);
    }
    
    Serial.println();
    delay(200);
  }
  
  Serial.println(F("    ========================================"));
  Serial.println(F("    Debug complete"));
  Serial.println(F("    ========================================"));
  Serial.println();
}

void tryDifferentSpeed() {
  Serial.println(F("    Reinit to 500 kbps..."));
  Serial.flush();
  
  byte initResult = CAN.begin(MCP_ANY, CAN_500KBPS, MCP_16MHZ);
  
  if (initResult == CAN_OK) {
    Serial.println(F("    OK!"));
    
    if (CAN.setMode(MCP_NORMAL) == MCP2515_OK) {
      Serial.println(F("    Mode: NORMAL"));
      Serial.println();
      
      // 서보 검색 시도
      Serial.println(F("    Search servo..."));
      sendServoDiscovery();
      
      // 다시 1Mbps로 복귀
      Serial.println(F("    Back to 1Mbps..."));
      CAN.begin(MCP_ANY, CAN_1000KBPS, MCP_16MHZ);
      CAN.setMode(MCP_NORMAL);
      Serial.println(F("    Done\n"));
    }
  } else {
    Serial.println(F("    FAIL!"));
    Serial.println(F("    Keep 1Mbps\n"));
  }
  Serial.flush();
}

// ============================================
// 프로토콜 명령어 함수들 (Protocol_CAN_Bus.md 기반)
// ============================================

// CAN ID에서 서보 ID 추출 (하위 8비트)
byte extractServoIDFromCANID(unsigned long canId) {
  return (byte)(canId & 0xFF);
}

// 2-프레임 명령 전송 유틸리티
void sendTwoFrameCommand(byte servoID, byte cmd, byte* data, int dataLen) {
  byte frame1[8] = {0xAA, 0x00, 0x00, (byte)(dataLen + 1), 0x00, 0x00, 0x00, servoID};
  byte frame2[8] = {cmd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
  
  // 데이터 복사 (최대 7바이트)
  for (int i = 0; i < dataLen && i < 7; i++) {
    frame2[i + 1] = data[i];
  }
  
  CAN.sendMsgBuf(0x00, 0, 8, frame1);
  delay(10);
  CAN.sendMsgBuf(0x00, 0, 8, frame2);
  delay(10);
}

// 서보 응답 출력
void printServoResponse(unsigned long canId, byte* buf, int len) {
  Serial.print(F("    RX: CAN_ID=0x"));
  if (canId < 0x10) Serial.print(F("0"));
  Serial.print(canId, HEX);
  Serial.print(F(" ["));
  
  for (int i = 0; i < len; i++) {
    if (buf[i] < 0x10) Serial.print(F("0"));
    Serial.print(buf[i], HEX);
    if (i < len - 1) Serial.print(F(" "));
  }
  Serial.println(F("]"));
}

// ============================================
// 명령 0x01: 정보 읽기 (Read Info)
// ============================================
void cmdReadInfo(byte servoID) {
  Serial.print(F("    Sending Read Info to servo "));
  Serial.println(servoID);
  
  byte data[7] = {0};
  sendTwoFrameCommand(servoID, 0x01, data, 0);
  
  // 응답 대기
  unsigned long startTime = millis();
  while (millis() - startTime < 2000) {
    if (CAN.checkReceive() == CAN_MSGAVAIL) {
      unsigned long canId;
      byte len = 0;
      byte buf[8];
      
      CAN.readMsgBuf(&canId, &len, buf);
      
      byte respondedID = extractServoIDFromCANID(canId);
      if (respondedID == servoID && buf[0] == 0x02) {
        Serial.println(F("    Response received:"));
        printServoResponse(canId, buf, len);
        
        // 위치 파싱
        int position = buf[1] | (buf[2] << 8);
        float angle = (position * 360.0) / 4096.0;
        Serial.print(F("        Position: "));
        Serial.print(position);
        Serial.print(F(" ("));
        Serial.print(angle, 2);
        Serial.println(F(" deg)"));
        
        Serial.print(F("        HW Ver: 0x"));
        Serial.println(buf[3], HEX);
        Serial.print(F("        SW Ver: 0x"));
        Serial.println(buf[4], HEX);
        return;
      }
    }
    delay(10);
  }
  
  Serial.println(F("    ! No response"));
}

// ============================================
// 명령 0x03: 운동 제어 (Move Servo)
// ============================================
void cmdMoveServo(byte servoID, int position, int speed) {
  byte data[4];
  data[0] = position & 0xFF;
  data[1] = (position >> 8) & 0xFF;
  data[2] = speed & 0xFF;
  data[3] = (speed >> 8) & 0xFF;
  
  sendTwoFrameCommand(servoID, 0x03, data, 4);
}

// ============================================
// 명령 0x07: ID 수정 (Change ID)
// ============================================
bool cmdGetUniqueCode(byte servoID, byte code[4]) {
  Serial.print(F("    Getting unique code from servo "));
  Serial.println(servoID);
  Serial.flush();
  
  byte data[7] = {0};
  sendTwoFrameCommand(servoID, 0x07, data, 0);
  
  Serial.println(F("    Waiting for response..."));
  Serial.flush();
  
  // 응답 대기
  unsigned long startTime = millis();
  int responseCount = 0;
  
  while (millis() - startTime < 3000) {  // 3초로 증가
    if (CAN.checkReceive() == CAN_MSGAVAIL) {
      unsigned long canId;
      byte len = 0;
      byte buf[8];
      
      CAN.readMsgBuf(&canId, &len, buf);
      responseCount++;
      
      // 디버그: 모든 응답 출력
      Serial.print(F("    ["));
      Serial.print(responseCount);
      Serial.print(F("] CAN_ID=0x"));
      if (canId < 0x10) Serial.print(F("0"));
      Serial.print(canId, HEX);
      Serial.print(F(" LEN="));
      Serial.print(len);
      Serial.print(F(" DATA: "));
      for (int i = 0; i < len; i++) {
        if (buf[i] < 0x10) Serial.print(F("0"));
        Serial.print(buf[i], HEX);
        Serial.print(F(" "));
      }
      Serial.println();
      Serial.flush();
      
      byte respondedID = extractServoIDFromCANID(canId);
      Serial.print(F("        Extracted ID: "));
      Serial.print(respondedID);
      Serial.print(F(", Expected: "));
      Serial.print(servoID);
      Serial.print(F(", buf[0]=0x"));
      Serial.println(buf[0], HEX);
      Serial.flush();
      
      // 응답 코드 0x08 확인 (길이는 6 또는 8바이트)
      if (len >= 6 && buf[0] == 0x08 && respondedID == servoID) {
        code[0] = buf[2];
        code[1] = buf[3];
        code[2] = buf[4];
        code[3] = buf[5];
        
        Serial.println(F("    SUCCESS!"));
        Serial.print(F("    Code: "));
        for (int i = 0; i < 4; i++) {
          if (code[i] < 0x10) Serial.print(F("0"));
          Serial.print(code[i], HEX);
          Serial.print(F(" "));
        }
        Serial.println();
        Serial.flush();
        return true;
      }
    }
    delay(10);
  }
  
  Serial.print(F("    ! Failed to get code ("));
  Serial.print(responseCount);
  Serial.println(F(" responses received)"));
  Serial.flush();
  return false;
}

bool cmdChangeID(byte oldID, byte newID, byte code[4]) {
  Serial.print(F("    Changing ID "));
  Serial.print(oldID);
  Serial.print(F(" -> "));
  Serial.println(newID);
  Serial.flush();
  
  byte data[5];
  data[0] = newID;
  data[1] = code[0];
  data[2] = code[1];
  data[3] = code[2];
  data[4] = code[3];
  
  sendTwoFrameCommand(oldID, 0x07, data, 5);
  
  Serial.println(F("    Waiting for response..."));
  Serial.flush();
  
  // 응답 대기
  unsigned long startTime = millis();
  int responseCount = 0;
  
  while (millis() - startTime < 3000) {  // 3초로 증가
    if (CAN.checkReceive() == CAN_MSGAVAIL) {
      unsigned long canId;
      byte len = 0;
      byte buf[8];
      
      CAN.readMsgBuf(&canId, &len, buf);
      responseCount++;
      
      // 디버그: 모든 응답 출력
      Serial.print(F("    ["));
      Serial.print(responseCount);
      Serial.print(F("] CAN_ID=0x"));
      if (canId < 0x10) Serial.print(F("0"));
      Serial.print(canId, HEX);
      Serial.print(F(" LEN="));
      Serial.print(len);
      Serial.print(F(" DATA: "));
      for (int i = 0; i < len; i++) {
        if (buf[i] < 0x10) Serial.print(F("0"));
        Serial.print(buf[i], HEX);
        Serial.print(F(" "));
      }
      Serial.println();
      Serial.flush();
      
      byte respondedID = extractServoIDFromCANID(canId);
      
      // ID 변경 확인 (길이는 6 또는 8바이트, buf[1]은 새 ID)
      if (respondedID == newID && len >= 2 && buf[0] == 0x08 && buf[1] == newID) {
        Serial.println(F("    SUCCESS! ID changed."));
        Serial.print(F("    New CAN ID: 0x"));
        if (canId < 0x10) Serial.print(F("0"));
        Serial.println(canId, HEX);
        Serial.flush();
        return true;
      }
    }
    delay(10);
  }
  
  Serial.print(F("    ! Failed to change ID ("));
  Serial.print(responseCount);
  Serial.println(F(" responses received)"));
  Serial.flush();
  return false;
}

// ============================================
// 명령 0x11: 잠금 (Lock Servo)
// ============================================
void cmdLockServo(byte servoID) {
  Serial.print(F("    Locking servo "));
  Serial.println(servoID);
  
  byte data[7] = {0};
  sendTwoFrameCommand(servoID, 0x11, data, 0);
  
  // TODO: 응답 확인 (응답 코드 0x12)
  Serial.println(F("    Lock command sent"));
}

// ============================================
// 명령 0x2F: 해제 (Unlock Servo)
// ============================================
void cmdUnlockServo(byte servoID) {
  Serial.print(F("    Unlocking servo "));
  Serial.println(servoID);
  
  byte data[7] = {0};
  sendTwoFrameCommand(servoID, 0x2F, data, 0);
  
  // TODO: 응답 확인 (응답 코드 0x30)
  Serial.println(F("    Unlock command sent"));
}
