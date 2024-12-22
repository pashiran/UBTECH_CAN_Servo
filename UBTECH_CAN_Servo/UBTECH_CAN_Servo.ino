#include <mcp_can.h>
#include <SPI.h>

// MCP2515 to Arduino Connections:
// VCC -> 5V
// GND -> GND
// CS  -> D10
// SO  -> D12
// SI  -> D11
// SCK -> D13
// INT -> D2

const int SPI_CS_PIN = 10;
MCP_CAN CAN(SPI_CS_PIN);

void setup() {
    Serial.begin(115200);
    while (!Serial) {
        ; // wait for serial port to connect. Needed for native USB port only
    }

    // Initialize CAN BUS Shield
    while (CAN_OK != CAN.begin(MCP_ANY, CAN_1000KBPS, MCP_8MHZ)) {
        Serial.println("CAN BUS Shield init fail");
        Serial.println("Init CAN BUS Shield again");
        delay(100);
    }
    Serial.println("CAN BUS Shield init ok!");
}

void loop() {
    // 송신할 데이터 설정
    byte cmd[8] = { /* 0xAA,*/ 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, };
    unsigned int toID = 0xAA;  // 송신할 CAN ID를 0xAA로 설정

    // CAN 메시지 전송
    if (CAN_OK == CAN.sendMsgBuf(toID, 0, 8, cmd)) {
        Serial.println("Message sent to ID 0xAA! Waiting for a response...");
    } else {
        Serial.println("Failed to send message.");
        delay(1000);  // 전송 실패 시 재시도 대기
        return;  // 전송 실패 시 함수 종료
    }
    //의문: 보내는 데이터의 최대 길이는?  주소 포함 16바이트를 보내야 하는데 현재는 모자람

    
    // 수신 데이터가 많을 수 있으므로, 전체 데이터를 저장할 배열 준비
    const int maxDataLength = 16; // 필요한 최대 길이 설정
    byte fullData[maxDataLength];
    int receivedLength = 0;

    // 수신 대기
    while (true) {
        // 수신 확인
        if (CAN_MSGAVAIL == CAN.checkReceive()) {
            long unsigned int rxId;
            byte len = 0;
            byte buf[8];

            CAN.readMsgBuf(&rxId, &len, buf); // CAN ID와 메시지 읽기

            // 수신한 CAN ID 출력
            Serial.print("Received CAN data from ID: 0x");
            Serial.println(rxId, HEX);

            // 수신한 데이터 출력
            Serial.print("Data: ");
            for (int i = 0; i < len; i++) {
                Serial.print(buf[i], HEX);
                Serial.print(" ");

                // 전체 데이터에 추가 (최대 길이를 넘지 않도록 제한)
                if (receivedLength < maxDataLength) {
                    fullData[receivedLength++] = buf[i];
                }
            }
            Serial.println();

            // 원하는 데이터 길이에 도달했는지 확인
            if (receivedLength >= maxDataLength) {
                break;
            }
        }
    }

    // 전체 수신 데이터 출력
    Serial.print("Full received data: ");
    for (int i = 0; i < receivedLength; i++) {
        Serial.print(fullData[i], HEX);
        Serial.print(" ");
    }
    Serial.println();

    delay(1000);  // 다음 전송 주기까지 대기
}
