# UBTECH Servo Communication Protocol (Additional Commands)

## Table of Contents
- [Control Commands with Feedback](#control-commands-with-feedback)
- [Control Commands without Feedback](#control-commands-without-feedback)
- [Unknown Commands](#unknown-commands)
- [Broadcast Mode](#broadcast-mode)

---

## Control Commands with Feedback

These commands provide real-time feedback about the servo's status during operation.

### 1. Speed Control with Feedback (Command: 0x0B)

**Send Command**:

| Byte | 0 | 1 | 2 |
|------|---|---|---|
| Content | 0x0B | Speed | - |

**Feedback Response**:

| Byte | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|------|---|---|---|---|---|---|---|---|
| Content | 0x0B | Real-time Location Low Byte | Real-time Location High Byte | Real-time Speed | - | Real-time Current (mA) Low | Real-time Current (mA) High | - |

**Description**: 
- Controls servo speed
- Provides continuous feedback of position, speed, and current consumption
- Useful for monitoring servo performance during operation

---

### 2. Position Control with Feedback (Command: 0x0C)

**Send Command**:

| Byte | 0 | 1 | 2 | 3 | 4 |
|------|---|---|---|---|---|
| Content | 0x0C | Position Low Byte (int16) | Position High Byte (int16) | Speed | - |

**Feedback Response**:

| Byte | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|------|---|---|---|---|---|---|---|---|
| Content | 0x0C | Real-time Location Low Byte (int16) | Real-time Location High Byte (int16) | Real-time Speed | - | Real-time Current Low | Real-time Current High | - |

**Description**:
- Position range: 16-bit signed integer (0-65536)
- Provides continuous feedback during movement
- Current measurement helps monitor load

---

### 3. Torque and Speed Control with Feedback (Command: 0x0D)

**Send Command**:

| Byte | 0 | 1 | 2 |
|------|---|---|---|
| Content | 0x0D | Speed | - |

**Feedback Response**:

| Byte | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|------|---|---|---|---|---|---|---|---|
| Content | 0x0D | Real-time Location Low Byte | Real-time Location High Byte | Real-time Speed | - | Real-time Current Low | Real-time Current High | - |

**Description**:
- Combined torque and speed control
- Real-time monitoring of all key parameters
- Suitable for applications requiring precise force control

---

## Control Commands without Feedback

These commands do not provide automatic feedback. Use query commands separately if feedback is needed.

### 1. Position Control without Feedback (Command: 0x01)

**Send Command**:

| Byte | 0 | 1 | 2 | 3 | 4 |
|------|---|---|---|---|---|
| Content | 0x01 | Position Low Byte (int16) | Position High Byte (int16) | Speed | - |

**Response**:

| Byte | 0 | 1 | 2 |
|------|---|---|---|
| Content | 0x01 | 0x00 | 0x01 |

**Description**:
- Simple position control without feedback
- Position range: 0-65536 (16-bit unsigned integer)
- Faster execution due to no feedback overhead

---

### 2. Position Control without Feedback (Command: 0x03)

**Send Command**:

| Byte | 0 | 1 | 2 | 3 | 4 |
|------|---|---|---|---|---|
| Content | 0x03 | Position Low Byte (int16) | Position High Byte (int16) | Speed | - |

**Response**:

| Byte | 0 | 1 | 2 |
|------|---|---|---|
| Content | 0x03 | 0x00 | 0x01 |

**Description**:
- Alternative position control command
- Similar to 0x01 but may have different timing characteristics
- Position range: 0-65536 (16-bit unsigned integer)

---

## Unknown Commands

The following commands have been identified but their exact functions are not fully documented:

### Command 0x05

**Send Command**: 0x05 [parameters unknown]

**Response**: 0x05 [response format unknown]

**Note**: Function to be determined through testing

---

### Command 0x07

**Send Command**: 0x07 [parameters unknown]

**Response**: 0x07 [response format unknown]

**Note**: Function to be determined through testing

---

### Command 0x08

**Send Command**: 0x08 [parameters unknown]

**Response**: 0x08 [response format unknown]

**Note**: Function to be determined through testing

---

### Command 0x0E

**Send Command**: 0x0E [parameters unknown]

**Response**: 0x0E [response format unknown]

**Note**: Function to be determined through testing

---

## Broadcast Mode

### Broadcasting to All Servos

When using ID 0x00 (broadcast address), all servos on the bus will receive and execute the command.

**Special Behavior**:
- Send command with ID 0x00
- All servos execute the command
- Response format: Each servo responds with 0x1XX, where XX is the servo's actual ID
- After receiving the broadcast response, servos can be controlled individually using their specific IDs

**Example Use Case**:
```
1. Send command to ID 0x00 (broadcast)
2. All servos respond with 0x1[ID]
3. Now you know all servo IDs on the bus
4. Control each servo individually using its specific ID
```

**Warning**: 
- Use broadcast mode carefully to avoid unintended servo movements
- Not recommended for ID change operations unless only one servo is connected

---

## Data Format Notes

### Position (int16, 65536)

**Format**: 16-bit signed integer
- **Range**: -32768 to 32767 (or 0 to 65535 if unsigned)
- **Resolution**: 65536 steps for full rotation
- **Calculation**: Angle = (Position / 65536) × 360°
- **Byte Order**: Little-endian (low byte first)

**Example**:
```
Position = 16384 (0x4000)
Angle = (16384 / 65536) × 360° = 90°

Bytes: [0x00, 0x40]
       Low   High
```

### Speed

**Format**: 8-bit or 16-bit unsigned integer (command-dependent)
- **Range**: Command-specific
- **Unit**: Typically RPM or degrees per second
- **Note**: Refer to specific command for speed format

### Current (mA)

**Format**: 16-bit unsigned integer
- **Range**: 0 to 65535 mA
- **Unit**: Milliamperes
- **Purpose**: Monitor servo load and detect stalling
- **Byte Order**: Little-endian (low byte first)

---

## Command Comparison

### Commands with Feedback vs Without Feedback

| Feature | With Feedback (0x0B, 0x0C, 0x0D) | Without Feedback (0x01, 0x03) |
|---------|----------------------------------|-------------------------------|
| Real-time Position | ✓ | ✗ |
| Real-time Speed | ✓ | ✗ |
| Real-time Current | ✓ | ✗ |
| Execution Speed | Slower | Faster |
| Bus Traffic | Higher | Lower |
| Best Use Case | Precise control, monitoring | Simple positioning, batch operations |

---

## Usage Examples

### Example 1: Move Servo to 90° with Feedback

```
Send: 0x0C 0x00 0x40 0x64
      [Cmd] [Pos_L] [Pos_H] [Speed]

Position: 0x4000 = 16384 (90 degrees)
Speed: 0x64 = 100

Receive (continuous): 0x0C [Current_Pos_L] [Current_Pos_H] [Current_Speed] 0x00 [Current_L] [Current_H] 0x00
```

### Example 2: Set Speed without Position Feedback

```
Send: 0x0B 0x50
      [Cmd] [Speed]

Speed: 0x50 = 80

Receive (continuous): 0x0B [Pos_L] [Pos_H] 0x50 0x00 [Current_L] [Current_H] 0x00
```

### Example 3: Simple Position Control

```
Send: 0x01 0x00 0x40 0x64
      [Cmd] [Pos_L] [Pos_H] [Speed]

Position: 0x4000 = 16384 (90 degrees)
Speed: 0x64 = 100

Receive: 0x01 0x00 0x01
         [Cmd] [Status] [OK]
```

---

## Best Practices

1. **Choose Appropriate Command**: Use feedback commands for precision, non-feedback for speed
2. **Monitor Current**: High current indicates high load or stalling
3. **Broadcast Carefully**: Test broadcast commands with single servo first
4. **Error Handling**: Always check response codes
5. **Bus Management**: Limit number of feedback commands to reduce bus traffic

---

## Troubleshooting

### No Response from Servo
- Check servo ID
- Verify bus connections
- Ensure proper power supply
- Try broadcast mode to discover servo IDs

### Incorrect Position
- Verify position calculation (65536 steps per rotation)
- Check byte order (little-endian)
- Confirm servo calibration

### High Current Draw
- Check for mechanical obstruction
- Verify load is within servo specification
- Reduce speed for heavy loads

---

*This document is based on reverse engineering and testing. Some commands may have additional undocumented features. Always test with actual hardware before deployment.*