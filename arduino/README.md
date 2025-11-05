# Arduino Test Code

각 서보 타입별 프로토콜 테스트용 아두이노 코드

## 폴더 구조

- **A_Type_Test/**: CAN 버스 기반 서보 테스트 (60kg/25kg 대형 서보)
- **B_Type_Test/**: UART 시리얼 기반 서보 테스트 (중소형 서보)
- **C_Type_Test/**: 제어 보드 프로토콜 서보 테스트 (통합 제어보드)

## 테스트 방법

1. 해당 서보 타입에 맞는 폴더의 `.ino` 파일을 Arduino IDE로 열기
2. 회로 연결 후 아두이노에 업로드
3. Serial Monitor로 동작 확인
