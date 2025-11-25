| Category | Command Name | Send CMD | Send Param 01 | Send Param 02 | Send Param 03 | Send Param 04 | Send Param 05 | Send Param 06 | Send Param 07 | Send Param 08 | Receive CMD | Receive Param 01 | Receive Param 02 | Receive Param 03 | Receive Param 04 | Receive Param 05 | Receive Param 06 | Receive Param 07 | Receive Param 08 |
|----------|--------------|----------|---------------|---------------|---------------|---------------|---------------|---------------|---------------|---------------|-------------|------------------|------------------|------------------|------------------|------------------|------------------|------------------|------------------|
| Single Turn Positioning | Move to specified angle1 at specified speed | 0x03 | Angle Low Byte | Angle High Byte | Speed Low Byte | Speed High Byte | Prohibition Time | nan | nan | 0x00 | 0x04 | Servo Status | Status Word | nan | nan | nan | nan | nan | nan |
| Single Turn Positioning | Move to specified angle2 at specified speed | 0x15 | Angle Low Byte | Angle High Byte | Speed Low Byte | Speed High Byte | Prohibition Time | nan | nan | 0x00 | 0x16 | Servo Status | Status Word | nan | nan | nan | nan | nan | nan |
| Single Turn Positioning | Move to specified angle1 in specified time | 0x1f | Angle Low Byte | Angle High Byte | Time Low Byte | Time High Byte | Prohibition Time | nan | nan | 0x00 | 0x20 | Servo Status | Status Word | nan | nan | nan | nan | nan | nan |
| Single Turn Positioning | Move to specified angle2 in specified time | 0x21 | Angle Low Byte | Angle High Byte | Time Low Byte | Time High Byte | Prohibition Time | nan | nan | nan | 0x22 | Servo Status | Status Word | nan | nan | nan | nan | nan | nan |
| Multi Turn Rotation | Incremental rotation | 0x13 | Angle Low Byte | Angle High Byte | Speed Low Byte | Speed High Byte | 0x00 | 0x00 | 0x00 | 0x00 | 0x14 | nan | nan | nan | nan | nan | nan | nan | nan |
| Multi Turn Rotation | Continuous rotation 1 | 0x17 | Speed Low Byte | Speed High Byte | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x18 | nan | nan | nan | nan | nan | nan | nan | nan |
| Multi Turn Rotation | Continuous rotation 2 | 0x3b | Speed Low Byte | Speed High Byte | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x3c | nan | nan | nan | nan | nan | nan | nan | nan |
| Stop | Servo stop lock servo disable | 0x2f | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x30 | nan | nan | nan | nan | nan | nan | nan | nan |
| Stop | Servo stop lock | 0x05 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x06 | nan | nan | nan | nan | nan | nan | nan | nan |
| Stop | current position lock | 0x11 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x12 | nan | nan | nan | nan | nan | nan | nan | nan |
| Feedback Cycle | Periodic Feedback Status | 0x19 | Feedback Cycle | nan | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x1a | angle | nan | Speed | nan | Current | nan | state? | nan |
| Feedback Cycle | Read temparature | 0x51 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x52 | temparature | nan | nan | nan | nan | nan | nan | nan |
| Feedback Cycle | Read accecleration | 0x25 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x26 | accelaration | nan | nan | nan | nan | nan | nan | nan |
| Feedback Cycle | Read ID | 0x09 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x0a | ID | nan | nan | nan | nan | nan | nan | nan |
| Feedback Cycle | Read Angle&Version | 0x01 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x02 | Angle | nan | Hardware Version | Software Version | nan | nan | nan | nan |
| Feedback Cycle | Read Version | 0x29 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x2a | Hardware Version | Software Version | nan | nan | nan | nan | nan | nan |
| Feedback Cycle | Read zero point | 0x0f | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x10 | Zero Postion | nan | Status Word | nan | nan | nan | nan | nan |
| Feedback Cycle | Read Unique Code | 0x07 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x08 | 0x00 | Unique Code | nan | nan | nan | nan | nan | nan |
| Setup | Set ID | 0x07 | id | Unique Code | nan | nan | nan | 0x00 | 0x00 | 0x00 | 0x08 | ID | Unique Code | nan | nan | nan | nan | nan | nan |
| Setup | Set acceleration | 0x23 | Acceleration | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x24 | accelaration | nan | nan | nan | nan | nan | nan | nan |
| Setup | Set Zero Point | 0x0b | nan | nan | nan | nan | nan | nan | nan | nan | nan | nan | nan | nan | nan | nan | nan | nan | nan |
