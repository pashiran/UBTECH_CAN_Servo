# UBTECH Servo Protocol (English)

## Table of Contents
- [Command Overview](#command-overview)
- [Single Turn Positioning](#single-turn-positioning)
- [Multi Turn Rotation](#multi-turn-rotation)
- [Stop Commands](#stop-commands)
- [Feedback and Query Commands](#feedback-and-query-commands)
- [Setup Commands](#setup-commands)

---

## Command Overview

### Command Structure

All commands follow this general structure:

| Parameter | Description |
|-----------|-------------|
| Command Code | Unique identifier for each command |
| Parameter 01-08 | Command-specific parameters |

### Response Structure

Responses follow a similar structure with command-specific return values.

---

## Single Turn Positioning

### 1. Move to Specified Angle (Method 1) at Specified Speed

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x03 | Angle Low Byte | Angle High Byte | Speed Low Byte | Speed High Byte | Prohibition Time | - | - | 0x00 |

**Receive Command**:

| Param 01 | Param 02 | Param 03 | Param 04 |
|----------|----------|----------|----------|
| 0x04 | Servo Status | Status Word | - |

---

### 2. Move to Specified Angle (Method 2) at Specified Speed

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x15 | Angle Low Byte | Angle High Byte | Speed Low Byte | Speed High Byte | Prohibition Time | - | - | 0x00 |

**Receive Command**:

| Param 01 | Param 02 | Param 03 |
|----------|----------|----------|
| 0x16 | Servo Status | Status Word |

---

### 3. Move to Specified Angle (Method 1) in Specified Time

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x1F | Angle Low Byte | Angle High Byte | Time Low Byte | Time High Byte | Prohibition Time | - | - | 0x00 |

**Receive Command**:

| Param 01 | Param 02 | Param 03 |
|----------|----------|----------|
| 0x20 | Servo Status | Status Word |

---

### 4. Move to Specified Angle (Method 2) in Specified Time

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x21 | Angle Low Byte | Angle High Byte | Time Low Byte | Time High Byte | Prohibition Time | - | - | - |

**Receive Command**:

| Param 01 | Param 02 | Param 03 |
|----------|----------|----------|
| 0x22 | Servo Status | Status Word |

---

## Multi Turn Rotation

### 1. Incremental Rotation

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x13 | Angle Low Byte | Angle High Byte | Speed Low Byte | Speed High Byte | 0x00 | 0x00 | 0x00 | - |

**Receive Command**:

| Param 01 |
|----------|
| 0x14 |

---

### 2. Continuous Rotation (Method 1)

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x17 | Speed Low Byte | Speed High Byte | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | - |

**Receive Command**:

| Param 01 |
|----------|
| 0x18 |

---

### 3. Continuous Rotation (Method 2)

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x3B | Speed Low Byte | Speed High Byte | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | - |

**Receive Command**:

| Param 01 |
|----------|
| 0x3C |

---

## Stop Commands

### 1. Servo Stop Lock (Servo Disable)

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x2F | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | - |

**Receive Command**:

| Param 01 |
|----------|
| 0x30 |

**Description**: Stops the servo and disables it completely.

---

### 2. Servo Stop Lock

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x05 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | - |

**Receive Command**:

| Param 01 |
|----------|
| 0x06 |

**Description**: Stops the servo and locks it in place.

---

### 3. Current Position Lock

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x11 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | - |

**Receive Command**:

| Param 01 |
|----------|
| 0x12 |

**Description**: Locks the servo at its current position.

---

## Feedback and Query Commands

### 1. Periodic Feedback Status

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x19 | Feedback Cycle | - | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | - |

**Receive Command**:

| Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x1A | Angle Low | Angle High | Speed Low | Speed High | Current Low | Current High | State |

**Description**: Sets up periodic feedback of servo status including angle, speed, current, and state.

---

### 2. Read Temperature

**Send Command**:

| Cmd | Param 01-08 |
|-----|-------------|
| 0x51 | All 0x00 |

**Receive Command**:

| Param 01 | Param 02 |
|----------|----------|
| 0x52 | Temperature |

---

### 3. Read Acceleration

**Send Command**:

| Cmd | Param 01-08 |
|-----|-------------|
| 0x25 | All 0x00 |

**Receive Command**:

| Param 01 | Param 02 |
|----------|----------|
| 0x26 | Acceleration |

---

### 4. Read ID

**Send Command**:

| Cmd | Param 01-08 |
|-----|-------------|
| 0x09 | All 0x00 |

**Receive Command**:

| Param 01 | Param 02 |
|----------|----------|
| 0x0A | ID |

---

### 5. Read Angle & Version

**Send Command**:

| Cmd | Param 01-08 |
|-----|-------------|
| 0x01 | All 0x00 |

**Receive Command**:

| Param 01 | Param 02 | Param 03 | Param 04 | Param 05 |
|----------|----------|----------|----------|----------|
| 0x02 | Angle Low | Angle High | Hardware Version | Software Version |

---

### 6. Read Version Only

**Send Command**:

| Cmd | Param 01-08 |
|-----|-------------|
| 0x29 | All 0x00 |

**Receive Command**:

| Param 01 | Param 02 | Param 03 |
|----------|----------|----------|
| 0x2A | Hardware Version | Software Version |

---

### 7. Read Zero Point

**Send Command**:

| Cmd | Param 01-08 |
|-----|-------------|
| 0x0F | All 0x00 |

**Receive Command**:

| Param 01 | Param 02 | Param 03 | Param 04 |
|----------|----------|----------|----------|
| 0x10 | Zero Position Low | Zero Position High | Status Word |

---

### 8. Read Unique Code

**Send Command**:

| Cmd | Param 01-08 |
|-----|-------------|
| 0x07 | All 0x00 |

**Receive Command**:

| Param 01 | Param 02 | Param 03 |
|----------|----------|----------|
| 0x08 | 0x00 | Unique Code (multiple bytes) |

---

## Setup Commands

### 1. Set ID

**Send Command**:

| Cmd | Param 01 | Param 02 | Param 03 | Param 04 | Param 05 | Param 06 | Param 07 | Param 08 |
|-----|----------|----------|----------|----------|----------|----------|----------|----------|
| 0x07 | New ID | Unique Code Byte 1 | Unique Code Byte 2 | Unique Code Byte 3 | Unique Code Byte 4 | 0x00 | 0x00 | - |

**Receive Command**:

| Param 01 | Param 02 | Param 03 |
|----------|----------|----------|
| 0x08 | New ID | Unique Code (multiple bytes) |

**Note**: The unique code is required to change the servo ID. This prevents accidental ID changes.

---

### 2. Set Acceleration

**Send Command**:

| Cmd | Param 01 | Param 02-08 |
|-----|----------|-------------|
| 0x23 | Acceleration | All 0x00 |

**Receive Command**:

| Param 01 | Param 02 |
|----------|----------|
| 0x24 | Acceleration |

---

### 3. Set Zero Point

**Send Command**:

| Cmd | Additional Parameters |
|-----|-----------------------|
| 0x0B | To be determined |

**Note**: This command sets the zero point (home position) of the servo.

---

## Parameter Descriptions

### Angle
- **Format**: 16-bit integer (2 bytes)
- **Range**: Depends on servo model
- **Byte Order**: Low byte first, high byte second

### Speed
- **Format**: 16-bit integer (2 bytes)
- **Unit**: Varies by command
- **Byte Order**: Low byte first, high byte second

### Time
- **Format**: 16-bit integer (2 bytes)
- **Unit**: Typically milliseconds
- **Byte Order**: Low byte first, high byte second

### Prohibition Time
- **Description**: Time period during which the servo will not respond to new commands
- **Purpose**: Allows smooth completion of current movement

### Feedback Cycle
- **Description**: Interval for periodic status feedback
- **Unit**: Typically milliseconds

### Status Word
- **Description**: Bit field containing servo status flags
- **Interpretation**: Model-specific

---

## Examples

### Example 1: Move to 90 Degrees at Medium Speed

```
Send: 0x03 0x5A 0x00 0x64 0x00 0x00 0x00 0x00
```
- Angle: 0x005A (90 in decimal)
- Speed: 0x0064 (100 in decimal)

### Example 2: Read Current Position

```
Send: 0x01 0x00 0x00 0x00 0x00 0x00 0x00 0x00
Receive: 0x02 [Angle_L] [Angle_H] [HW_Ver] [SW_Ver]
```

### Example 3: Lock Servo at Current Position

```
Send: 0x11 0x00 0x00 0x00 0x00 0x00 0x00 0x00
Receive: 0x12
```

---

## Notes

1. **Byte Order**: This protocol uses little-endian byte order (low byte first)
2. **Unique Code**: Each servo has a unique code for security purposes
3. **Status Monitoring**: Use periodic feedback for real-time status updates
4. **Error Handling**: Always check response codes to ensure successful execution

---

*This document is for reference only. Verify with actual hardware before implementation.*