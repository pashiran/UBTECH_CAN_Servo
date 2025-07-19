
mega8_servo.hex：     文件格式 ihex


Disassembly of section .sec1:

00000000 <.sec1>:
       0:	3f c0       	rjmp	.+126    	;  reset_start()
	...
      12:	6c c7       	rjmp	.+3800   	;  0xeec_T0_OVF_ISR()  ;;;; Timer/Counter0 Overflow ISR
      14:	00 00       	nop
      16:	81 cb       	rjmp	.-2302   	;  0x171a_ISR_UART_RX_Complete()
      18:	00 00       	nop
      1a:	00 00       	nop
      1c:	53 c0       	rjmp	.+166    	;  0xc4_ISR_ADC()
	...
      26:	23 1e       	adc	r2, r19
      28:	16 19       	sub	r17, r6
      2a:	19 23       	and	r17, r25
      2c:	23 23       	and	r18, r19
      2e:	1e 16       	cp	r1, r30
      30:	19 19       	sub	r17, r9
      32:	23 23       	and	r18, r19
      34:	23 1e       	adc	r2, r19
      36:	16 19       	sub	r17, r6
      38:	19 23       	and	r17, r25
      3a:	23 23       	and	r18, r19
      3c:	1e 16       	cp	r1, r30
      3e:	19 19       	sub	r17, r9
      40:	23 23       	and	r18, r19
      42:	23 1e       	adc	r2, r19
      44:	16 19       	sub	r17, r6
      46:	19 23       	and	r17, r25
      48:	23 14       	cp	r2, r3
      4a:	14 14       	cp	r1, r4
      4c:	14 14       	cp	r1, r4
      4e:	15 07       	cpc	r17, r21
      50:	31 01       	movw	r6, r2
data_rom:               ;; 0x0052~0x007F
      52:	01 00       	.word	0x0001	; ????
      54: 00 00 
      56: 00 00
      58: 00 00 00 00 00 00 00 00
      60: 00 00 00 00 00 00 00 00   00 00 00 00 00 00 00 00
      70: 00 00 00 00 00 04 14 00   00 E8 03 00 00 00 00 00
reset_start:
      80:	cf e5       	ldi	r28, 0x5F	; 95     set SP = 0x045F
      82:	d4 e0       	ldi	r29, 0x04	; 4
      84:	cd bf       	out	0x3d, r28	; 61
      86:	de bf       	out	0x3e, r29	; 62

      88:	ce 51       	subi	r28, 0x1E	; 30   *(SP-30=0x0441) = 0xAA
      8a:	d0 40       	sbci	r29, 0x00	; 0
      8c:	0a ea       	ldi	r16, 0xAA	; 170
      8e:	08 83       	st	Y, r16

bss_section_init:   
      ;RAM(0x008E~0x0170) is bss section, size = 227 bytes 
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;---------------------------------------------------------------------------------------------
      ;     addr     |     type   | size |               comments                                  |
      ;--------------+------------+------+---------------------------------------------------------+
      ; 0x008E~0x008F|  uint16_t  |   2  | 存放ADC采样结果
      ;--------------+------------+------+---------------------------------------------------------+
      ; 0x0090       |    bool    |   1  | 通知主循环ADC采样是否完成
      ;--------------+------------+------+---------------------------------------------------------+
      ; 0x0093~0x0094|  uint16_t  |   2  | 没鸟用                                                   
      ; 0x0095~0x0096|  uint16_t  |   2  | 没鸟用                                                   
      ;--------------+------------+------+---------------------------------------------------------+
      ; 0x0097       |    byte    |   1  | servo ID ,range: 1~240                                  |
      ; 0x0108       |    byte    |   1  | 暂存从总线上接收的字节(拷贝UDR寄存器),在RX ISR中使用        |
      ; 0x0109~0x0112| byte array |  10  | 10字节缓冲区，存储RX收到的字节，供RX ISR写入               |
      ;--------------+------------+------+---------------------------------------------------------+
      ;              |            |      | 有符号整数，向后偏移角度校正，量纲暂未知                    |
      ; 0x0129~0x012A|   int16_t  |   2  | EEPROM中 0x001A-0x001B 对应其初始值，在EEPROM中大端存储，  |
      ;              |            |      | 可通过0xD2命令修改，0xD4命令读取                          |
      ;--------------+------------+------+---------------------------------------------------------+
      ;              |            |      | 有符号整数，向前偏移角度校正，量纲暂未知                    |
      ; 0x012B~0x012C|   int16_t  |   2  | EEPROM中 0x0018-0x0019 对应其初始值，在EEPROM中大端存储，  |
      ;              |            |      | 可通过0xD2命令修改，0xD4命令读取                          |
      ;--------------+------------+------+---------------------------------------------------------+
      ; 0x12D~0x136  | byte array |  10  | 10字节缓冲区，存储发送给主机的ACK帧                         |
      ; 0x14D~0x156  | byte array |  10  | 10字节缓冲区，在里面解析收到的命令帧                         |
      ; 0x0170       |    byte    |   1  | RX ISR 记录命令帧字节接收状态,                             |
      ;--------------+------------+------+---------------------------------------------------------+
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      90:	00 24       	eor	r0, r0            ; r0 = 0x00
      92:	ee e8       	ldi	r30, 0x8E	; 142   ; Z  = 0x008E
      94:	f0 e0       	ldi	r31, 0x00	; 0
      96:	11 e0       	ldi	r17, 0x01	; 1
      98:	e1 37       	cpi	r30, 0x71	; 113   ; if Z==0x0171
      9a:	f1 07       	cpc	r31, r17
      9c:	11 f0       	breq	.+4      	;  0xa2
      9e:	01 92       	st	Z+, r0            ; *Z++ = 0x00 
      a0:	fb cf       	rjmp	.-10     	;  0x98
      a2:	00 83       	st	Z, r16      ;    *(0x0171) = 0xAA ; use 0xAA mark end of bss
data_section_init:
                                      ;RAM(0x0060~0x008D) is data section, size = 46 bytes
                                      ;ROM(0x0052~0x007F) is src of data init value
      a4:	e2 e5       	ldi	r30, 0x52	; 82    Z = 0x0052
      a6:	f0 e0       	ldi	r31, 0x00	; 0
      a8:	a0 e6       	ldi	r26, 0x60	; 96    X = 0x0060
      aa:	b0 e0       	ldi	r27, 0x00	; 0
      ac:	10 e0       	ldi	r17, 0x00	; 0
      ae:	00 e0       	ldi	r16, 0x00	; 0
      b0:	0b bf       	out	0x3b, r16	; 59    REG(GICR) = 0x00
      b2:	e0 38       	cpi	r30, 0x80	; 128   if Z==0x0080 ; 0x0080 is the "reset_start"
      b4:	f1 07       	cpc	r31, r17
      b6:	21 f0       	breq	.+8      	;  0xc0
      b8:	c8 95       	lpm              ;   r0 = *ROM(Z)
      ba:	31 96       	adiw	r30, 0x01	; 1  Z++
      bc:	0d 92       	st	X+, r0      ;    X++    
      be:	f9 cf       	rjmp	.-14     	;  0xb2
jump_0x2ce_main:
      c0:	06 d1       	rcall	.+524    	;  0x2ce_main
dead_loop:
      c2:	ff cf       	rjmp	.-2      	;  0xc2



0xc4_ISR_ADC:
      c4:	2a 92       	st	-Y, r2
      c6:	3a 92       	st	-Y, r3
      c8:	8a 93       	st	-Y, r24
      ca:	2f b6       	in	r2, 0x3f	; 63
      cc:	2a 92       	st	-Y, r2
      
      ce:	34 98       	cbi	0x06, 4	; 6                   clear ADCSRA bit4 ===> ADIF=0
                                    ;                     估计本意是想清除ADIF位,但这样做是错误的,贴一段datasheet中的原文:
                                    ;                     ADIF is cleared by hardware when executing the corresponding interrupt Handling Vector. 
                                    ;                     Alternatively, ADIF is cleared by writing a logical one to the flag. 
                                    ;                     1. 这里是ADC ISR, ADIF本来就会自动清零
                                    ;                     2. 就算是手动清零,也应该是写 1 而不是 0

      d0:	37 98       	cbi	0x06, 7	; 6                   ADEN = 0 ===> disable ADC

      d2:	24 b0       	in	r2, 0x04	; 4                 r2 = ADCL
      d4:	35 b0       	in	r3, 0x05	; 5                 r3 = ADCH
      d6:	30 92 8f 00 	sts	0x008F, r3	;  0x80008f
      da:	20 92 8e 00 	sts	0x008E, r2	;  0x80008e       WORD(0x008E) = [ADCH, ADCL]
      de:	81 e0       	ldi	r24, 0x01	; 1
      e0:	80 93 90 00 	sts	0x0090, r24	;  0x800090       BOOL(0x0090) = TRUE //ADC convert finished 这个是通知主循环的
      e4:	80 93 60 00 	sts	0x0060, r24	;  0x800060       BOOL(0x0060) = TRUE //ADC convert finished 这个是通知Timer0 定时中断的
      e8:	29 90       	ld	r2, Y+
      ea:	2f be       	out	0x3f, r2	; 63
      ec:	89 91       	ld	r24, Y+
      ee:	39 90       	ld	r3, Y+
      f0:	29 90       	ld	r2, Y+
      f2:	18 95       	reti

0xf4_read_eeprom(uint8_t* buf, uint16_t eeadr, uint16_t size): ;eeadr=[r17,r16], size=[r19,r18]
      f4:	aa 92       	st	-Y, r10
      f6:	ba 92       	st	-Y, r11
      f8:	aa 80       	ldd	r10, Y+2	; 0x02
      fa:	bb 80       	ldd	r11, Y+3	; 0x03
      fc:	e1 99       	sbic	0x1c, 1	; 28   EECR, wait until EEWE = LOW
      fe:	fe cf       	rjmp	.-4      	;  0xfc
     100:	0d c0       	rjmp	.+26     	;  0x11c
     102:	18 01       	movw	r2, r16   ; r3<--r17 / r2<--r16
     104:	23 2c       	mov	r2, r3
     106:	33 24       	eor	r3, r3
     108:	2f ba       	out	0x1f, r2	; 31 EEARH = r2 = adr_high_byte
     10a:	18 01       	movw	r2, r16
     10c:	0f 5f       	subi	r16, 0xFF	; 255
     10e:	1f 4f       	sbci	r17, 0xFF	; 255
     110:	2e ba       	out	0x1e, r2	; 30 EEARL = r2 = adr_low_byte
     112:	e0 9a       	sbi	0x1c, 0	; 28
     114:	2d b2       	in	r2, 0x1d	; 29
     116:	f5 01       	movw	r30, r10   ; r31<--r11 / r30<--r10
     118:	21 92       	st	Z+, r2
     11a:	5f 01       	movw	r10, r30   ; r11<--r31 / r10<--r30
     11c:	19 01       	movw	r2, r18    ; r3<--r19 / r2<--r18
     11e:	21 50       	subi	r18, 0x01	; 1
     120:	30 40       	sbci	r19, 0x00	; 0
     122:	22 20       	and	r2, r2
     124:	71 f7       	brne	.-36     	;  0x102
     126:	33 20       	and	r3, r3
     128:	61 f7       	brne	.-40     	;  0x102
     12a:	b9 90       	ld	r11, Y+
     12c:	a9 90       	ld	r10, Y+
     12e:	08 95       	ret

0x130_write_eeprom(uint8_t* buf, uint16_t eeadr, uint16_t size): ;eeadr=[r17,r16], size=[r19,r18]
     130:	aa 92       	st	-Y, r10
     132:	ba 92       	st	-Y, r11
     134:	aa 80       	ldd	r10, Y+2	; 0x02
     136:	bb 80       	ldd	r11, Y+3	; 0x03
     138:	22 24       	eor	r2, r2
     13a:	2f ba       	out	0x1f, r2	; 31
     13c:	10 c0       	rjmp	.+32     	;  0x15e
     13e:	e1 99       	sbic	0x1c, 1	; 28
     140:	fe cf       	rjmp	.-4      	;  0x13e
     142:	18 01       	movw	r2, r16
     144:	23 2c       	mov	r2, r3
     146:	33 24       	eor	r3, r3
     148:	2f ba       	out	0x1f, r2	; 31
     14a:	18 01       	movw	r2, r16
     14c:	0f 5f       	subi	r16, 0xFF	; 255
     14e:	1f 4f       	sbci	r17, 0xFF	; 255
     150:	2e ba       	out	0x1e, r2	; 30
     152:	f5 01       	movw	r30, r10
     154:	21 90       	ld	r2, Z+
     156:	5f 01       	movw	r10, r30
     158:	2d ba       	out	0x1d, r2	; 29
     15a:	e2 9a       	sbi	0x1c, 2	; 28
     15c:	e1 9a       	sbi	0x1c, 1	; 28
     15e:	19 01       	movw	r2, r18
     160:	21 50       	subi	r18, 0x01	; 1
     162:	30 40       	sbci	r19, 0x00	; 0
     164:	22 20       	and	r2, r2
     166:	59 f7       	brne	.-42     	;  0x13e
     168:	33 20       	and	r3, r3
     16a:	49 f7       	brne	.-46     	;  0x13e
     16c:	b9 90       	ld	r11, Y+
     16e:	a9 90       	ld	r10, Y+
     170:	08 95       	ret

0x172_init_port_pins():
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                      ; PB0 IN  <--- A3950-NFAULT
                                      ; PB1 OUT ---> A3950-ENABLE
                                      ; PB2 SS
                                      ; PB3 MOSI
                                      ; PB4 MISO 
                                      ; PB5 SCK
     172:	81 e0       	ldi	r24, 0x01	; 1   PORTB = 0x01
     174:	88 bb       	out	0x18, r24	; 24
     176:	8e e3       	ldi	r24, 0x3E	; 62  DDRB = 0x3E
     178:	87 bb       	out	0x17, r24	; 23
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                      ; ADC2(PINC2) 连接 舵机角度电位器
     17a:	22 24       	eor	r2, r2
     17c:	25 ba       	out	0x15, r2	; 21  PORTC = 0x00    PortC_PIN0~PortC_PIN7 all input
     17e:	24 ba       	out	0x14, r2	; 20  DDRC  = 0x00    输入脚禁用上拉电阻
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                      ; PD2 OUT ---> 控制 TXD 三态门
                                      ; PD3 OUT ---> 控制 RXD 三态门
                                      ; PD5 OUT ---> A3950-SLEEP
                                      ; PD6 OUT ---> A3950-PHASE
                                      ; PD7 OUT ---> A3950-MODE
     180:	8c e0       	ldi	r24, 0x0C	; 12  PORTD = 0x0C    ; TXD/RXD与总线断开
     182:	82 bb       	out	0x12, r24	; 18
     184:	8c ee       	ldi	r24, 0xEC	; 236 DDRD  = 0xEC    
     186:	81 bb       	out	0x11, r24	; 17
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     188:	88 b3       	in	r24, 0x18	; 24   PORTB &= 0xFD --> PB1=LOW --> A3950-ENABLE=LOW
     18a:	8d 7f       	andi	r24, 0xFD	; 253
     18c:	88 bb       	out	0x18, r24	; 24
     18e:	95 9a       	sbi	0x12, 5	; 18     PD5=HIGH ---> A3950-SLEEP = HIGH
     190:	97 9a       	sbi	0x12, 7	; 18     PD7=HIGH ---> A3950-MODE  = HIGH
     192:	96 9a       	sbi	0x12, 6	; 18     PD6=HIGH ---> A3950-PHASE = HIGH
     194:	08 95       	ret

0x196_init_uart():
                                      ; 115200bps 8N1
                                      ; RX enable / TX enable
                                      ; RX ISR enable
                                      ; TX ISR disable
     196:	22 24       	eor	r2, r2
     198:	2a b8       	out	0x0a, r2	; 10 UCSRB = 0x00
     19a:	82 e0       	ldi	r24, 0x02	; 2
     19c:	8b b9       	out	0x0b, r24	; 11 UCSRA = 0x02 [0000 0010b] set bit1-U2X
     19e:	86 e8       	ldi	r24, 0x86	; 134

     1a0:	80 bd       	out	0x20, r24	; 32 UCSRC  = 0x86 [1000 0110b] 
                                      ;    bit5:4 = 00b ---> UPM[1:0] no Parity 
                                      ;    bit3   = 0b  ---> USBS stop-bit=1bit
                                      ;    bit2:1 = 11b ---> 8 bit
     1a2:	8f e0       	ldi	r24, 0x0F	; 15
     1a4:	89 b9       	out	0x09, r24	; 9  UBRRL = 0x0F ---> 115200bps on 14.7456MHz
     1a6:	20 bc       	out	0x20, r2	; 32 UBRRH = 0x00
     1a8:	88 e9       	ldi	r24, 0x98	; 152
     1aa:	8a b9       	out	0x0a, r24	; 10 UCSRB = 0x98 [1001 1000b]
                                      ;    bit7  = 1b  ---> RXCIE , RX ISR enable
                                      ;    bit6  = 0b  ---> TXCIE, TX ISR disable
                                      ;    bit5  = 0b  ---> UDRIE, disable
                                      ;    bit4  = 1b  ---> RXEN, RX enable
                                      ;    bit3  = 1b  ---> TXEN, TX enable
                                      ;    bit2  = 0b  ---> UCSZ2, 8-bit
     1ac:	08 95       	ret

0x1ae_device_init():
     1ae:	f8 94       	cli             ;  isr disable
     1b0:	e0 df       	rcall	.-64     	;  0x172_init_port_pins()
     1b2:	0a ef       	ldi	r16, 0xFA	; 250 
     1b4:	07 d7       	rcall	.+3598   	;  0xfc4_delay_us()
     1b6:	7f d6       	rcall	.+3326   	;  0xeb6_init_Timer0()
     1b8:	88 d6       	rcall	.+3344   	;  0xeca_init_Timer1()
     1ba:	ed df       	rcall	.-38     	;  0x196_init_uart()
     1bc:	92 9a       	sbi	0x12, 2	; 18;  PD2=HIGH ---> 断开TXD与总线的连接
     1be:	82 b3       	in	r24, 0x12	; 18 PD3=LOW  ---> RXD接通总线
     1c0:	87 7f       	andi	r24, 0xF7	; 247
     1c2:	82 bb       	out	0x12, r24	; 18
     1c4:	22 24       	eor	r2, r2
     1c6:	25 be       	out	0x35, r2	; 53 MCUCR=0x00
     1c8:	2b be       	out	0x3b, r2	; 59 GICR=0x00
     1ca:	78 94       	sei              ; isr enable
     1cc:	08 95       	ret

     
0x1ce_read_config_data_from_eeprom():
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ; EEPROM 0x0A 位置读取1字节到RAM地址 0x0097 中
                                        ; RAM(0x0097)用来存储舵机ID
     1ce:	26 97       	sbiw	r28, 0x06	; 6 ; Y -= 0x06 ---> Y=(0x0441-0x06)=0x043B
     1d0:	87 e9       	ldi	r24, 0x97	; 151   RAM(0x043C) = 0x00
     1d2:	90 e0       	ldi	r25, 0x00	; 0     *Y = RAM(0x043b) = 0x97
     1d4:	99 83       	std	Y+1, r25	; 0x01  
     1d6:	88 83       	st	Y, r24
     1d8:	21 e0       	ldi	r18, 0x01	; 1     
     1da:	30 e0       	ldi	r19, 0x00	; 0
     1dc:	0a e0       	ldi	r16, 0x0A	; 10
     1de:	10 e0       	ldi	r17, 0x00	; 0
     1e0:	89 df       	rcall	.-238    	;  0xf4_read_eeprom(buf=(uint8_t*)0x0097, eeadr=0x000A, size=1)
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                       ;  如果取到的舵机ID>0xF0 则将其修改为0x01并存入EEPROM
     1e2:	80 ef       	ldi	r24, 0xF0	; 240
     1e4:	20 90 97 00 	lds	r2, 0x0097	;  0x800097
     1e8:	82 15       	cp	r24, r2
     1ea:	60 f4       	brcc	.+24     	;  0x204  ; if *RAM(0x0097)<0xF0
     1ec:	81 e0       	ldi	r24, 0x01	; 1         ; *RAM(0x0097)=0x01
     1ee:	80 93 97 00 	sts	0x0097, r24	;  0x800097
     1f2:	87 e9       	ldi	r24, 0x97	; 151
     1f4:	90 e0       	ldi	r25, 0x00	; 0
     1f6:	99 83       	std	Y+1, r25	; 0x01
     1f8:	88 83       	st	Y, r24
     1fa:	21 e0       	ldi	r18, 0x01	; 1
     1fc:	30 e0       	ldi	r19, 0x00	; 0
     1fe:	0a e0       	ldi	r16, 0x0A	; 10
     200:	10 e0       	ldi	r17, 0x00	; 0
     202:	96 df       	rcall	.-212    	;  0x130_write_eeprom(buf=(uint8_t*)0x0097, eeadr=0x000A, size=1)
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                      ; EEPROM 读取两字节数据到RAM中， 应该是一个16位的数据类型
                                      ；最终结果: *RAM(0x012C) = *EPROM(0x0018) / *RAM(0x012B) = *EPROM(0x0019) 
     204:	ce 01       	movw	r24, r28  ; [r25,r24]<--Y
     206:	02 96       	adiw	r24, 0x02	; 2 [r25,r24] += 2
     208:	99 83       	std	Y+1, r25	; 0x01
     20a:	88 83       	st	Y, r24
     20c:	22 e0       	ldi	r18, 0x02	; 2
     20e:	30 e0       	ldi	r19, 0x00	; 0
     210:	08 e1       	ldi	r16, 0x18	; 24
     212:	10 e0       	ldi	r17, 0x00	; 0 ;将局部变量作为buf
     214:	6f df       	rcall	.-290    	;  0xf4_read_eeprom(buf=(uint8_t*)(Y+2), eeadr=0x0018, size=2)
     216:	2a 80       	ldd	r2, Y+2	; 0x02; r2 = *RAM(Y+2)
     218:	33 24       	eor	r3, r3         ; r3 = 0
     21a:	30 92 2c 01 	sts	0x012C, r3	;  0x80012c *RAM(0x012C) = 0
     21e:	20 92 2b 01 	sts	0x012B, r2	;  0x80012b *RAM(0x012B) = r2 = *RAM(Y+2)
     222:	32 2c       	mov	r3, r2      
     224:	22 24       	eor	r2, r2      ;  r3=r2 / r2=0
     226:	30 92 2c 01 	sts	0x012C, r3	;  0x80012c *RAM(0x012C) = r3 = *RAM(Y+2)
     22a:	20 92 2b 01 	sts	0x012B, r2	;  0x80012b *RAM(0x012B) = 0
     22e:	2b 80       	ldd	r2, Y+3	; 0x03 ; r2 = *RAM(Y+3)
     230:	33 24       	eor	r3, r3
     232:	40 90 2b 01 	lds	r4, 0x012B	;  0x80012b
     236:	50 90 2c 01 	lds	r5, 0x012C	;  0x80012c r4 = *RAM(0x012B) / r5 = *RAM(0x012C)
     23a:	42 0c       	add	r4, r2
     23c:	53 1c       	adc	r5, r3      ; [r5,r4] += *RAM(Y+3)
     23e:	50 92 2c 01 	sts	0x012C, r5	;  0x80012c
     242:	40 92 2b 01 	sts	0x012B, r4	;  0x80012b *RAM([0x012B, 0x012C]) = *RAM(Y+2)<<8 + *RAM(Y+3)
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                      ; EEPROM 读取两字节数据到RAM中， 应该是一个16位有符号整数变量 int16_t
                                      ；最终结果: *(int16_t*)0x0129 = *EPROM(0x001A)<<8 + *EPROM(0x001B) 
     246:	ce 01       	movw	r24, r28
     248:	04 96       	adiw	r24, 0x04	; 4
     24a:	99 83       	std	Y+1, r25	; 0x01
     24c:	88 83       	st	Y, r24
     24e:	22 e0       	ldi	r18, 0x02	; 2
     250:	30 e0       	ldi	r19, 0x00	; 0
     252:	0a e1       	ldi	r16, 0x1A	; 26
     254:	10 e0       	ldi	r17, 0x00	; 0
     256:	4e df       	rcall	.-356    	;  0xf4_read_eeprom(buf=(uint8_t*)(Y+4), eeadr=0x001A, size=2)
     258:	2c 80       	ldd	r2, Y+4	; 0x04
     25a:	33 24       	eor	r3, r3
     25c:	30 92 2a 01 	sts	0x012A, r3	;  0x80012a
     260:	20 92 29 01 	sts	0x0129, r2	;  0x800129
     264:	32 2c       	mov	r3, r2
     266:	22 24       	eor	r2, r2
     268:	30 92 2a 01 	sts	0x012A, r3	;  0x80012a
     26c:	20 92 29 01 	sts	0x0129, r2	;  0x800129
     270:	2d 80       	ldd	r2, Y+5	; 0x05
     272:	33 24       	eor	r3, r3
     274:	40 90 29 01 	lds	r4, 0x0129	;  0x800129
     278:	50 90 2a 01 	lds	r5, 0x012A	;  0x80012a
     27c:	42 0c       	add	r4, r2
     27e:	53 1c       	adc	r5, r3
     280:	50 92 2a 01 	sts	0x012A, r5	;  0x80012a
     284:	40 92 29 01 	sts	0x0129, r4	;  0x800129
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                                        ;
     288:	12 01       	movw	r2, r4    ; r3<--r5 / r2<--r4 : [r3, r2]<--*RAM([0x012A, 0x0129])
     28a:	8e e1       	ldi	r24, 0x1E	; 30
     28c:	90 e0       	ldi	r25, 0x00	; 0
     28e:	84 15       	cp	r24, r4
     290:	95 05       	cpc	r25, r5
     292:	2c f0       	brlt	.+10     	;  0x29e   if 30<*(int16_t*)0x0129
     294:	c2 01       	movw	r24, r4   ;  r25<--r5 / r24<--r4 : [r25,r24]<--*(int16_t*)0x0129
     296:	82 3e       	cpi	r24, 0xE2	; 226
     298:	ef ef       	ldi	r30, 0xFF	; 255 ; 0xFFE2 ==> -30
     29a:	9e 07       	cpc	r25, r30
     29c:	8c f4       	brge	.+34     	;  0x2c0  if *(int16_t*)0x0129>=-30
                        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                        ; X = *(int16_t*)0x0129
                        ; if ((X>30) or (X<-30))  X=0;EEPROM对应地址(0x0018)上的2byte数据清零
     29e:	22 24       	eor	r2, r2
     2a0:	33 24       	eor	r3, r3
     2a2:	30 92 2a 01 	sts	0x012A, r3	;  0x80012a
     2a6:	20 92 29 01 	sts	0x0129, r2	;  0x800129   *(int16_t*)0x0129 = 0
     2aa:	2c 82       	std	Y+4, r2	; 0x04 *(Y+4) = 0
     2ac:	2d 82       	std	Y+5, r2	; 0x05 *(Y+5) = 0
     2ae:	ce 01       	movw	r24, r28  ;   [r24,r25] = Y 
     2b0:	04 96       	adiw	r24, 0x04	; 4 [r24,r25]+=4
     2b2:	99 83       	std	Y+1, r25	; 0x01 *(Y+1) = HI_BYTE(Y+4)
     2b4:	88 83       	st	Y, r24     ;     *Y = LOW_BYTE(Y+4)  
     2b6:	22 e0       	ldi	r18, 0x02	; 2
     2b8:	30 e0       	ldi	r19, 0x00	; 0
     2ba:	08 e1       	ldi	r16, 0x18	; 24
     2bc:	10 e0       	ldi	r17, 0x00	; 0  
     2be:	38 df       	rcall	.-400    	;  0x130_write_eeprom(buf=(uint8_t*)(Y+4), eeadr=0x0018, size=2)

     2c0:	26 96       	adiw	r28, 0x06	; 6
     2c2:	08 95       	ret

0x2c4_system_init():
     2c4:	74 df       	rcall	.-280    	;  0x1ae_device_init()
     2c6:	83 df       	rcall	.-250    	;  0x1ce_read_config_data_from_eeprom()
     2c8:	82 e0       	ldi	r24, 0x02	; 2  ADMUX = 0x02 ---> 选中ADC2，即ADC接通舵机角度电位器
     2ca:	87 b9       	out	0x07, r24	; 7
     2cc:	08 95       	ret

0x2ce_main():
;entry of main()
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   0x2c4_system_init();
;   BOOL(0x016D) = TRUE;   //这个变量表示上一个角度运动操作是否已经完成,TRUE-完成 FALSE-尚未完成
;   WORD(0x0091) = 0;
;   PORTB |= 0x38;      //set SCK/MISO/MOSI high
;   0x3fc_PWM_start_stop(FALSE);
;   while(1)
;   {
;       0xff4_check_and_parse_command();
;       0x340_ADC_filter();
;       if(BOOL(0x0104)==TRUE && BOOL(0x016D)==FALSE)   //BOOL(0x0104)在Timer0的ISR中每隔1ms被设为TRUE
;       {
;          BOOL(0x0104) = FALSE;
;          WORD(0x0091)++;                     //毫秒级计数器 用来统计从角度运动操作开始到现在过了多长时间
;          if(WORD(0x0091)>WORD(0x016E))       //WORD(0x016E)记录着0x01命令中指定的角度运动时间 单位同样为ms
;          {//
;              BOOL(0x016D) = TRUE;            //BOOL(0x016D)仅在此处被设置为TRUE
;              WORD(0x0091) = 0;
;          }
;       }
;       FUNCTION(0xc1a)();
;   }   
;;;;;;;;;;;;;;;;;;;;;;;;;;;

     2ce:	fa df       	rcall	.-12     	;  0x2c4_system_init()
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;;; *(0x016D) = 1 / *(int16_t*)(0x0091) = 0
     2d0:	22 24       	eor	r2, r2      ; r2 = 0x00
     2d2:	33 24       	eor	r3, r3      ; r3 = 0x00
     2d4:	30 92 92 00 	sts	0x0092, r3	;  0x800092
     2d8:	20 92 91 00 	sts	0x0091, r2	;  0x800091
     2dc:	81 e0       	ldi	r24, 0x01	; 1
     2de:	80 93 6d 01 	sts	0x016D, r24	;  0x80016d
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;;  set SCK/MISO/MOSI high
     2e2:	88 b3       	in	r24, 0x18	; 24 ; r24 = PORTB
     2e4:	88 63       	ori	r24, 0x38	; 56 ; r24 |= 00111000b
     2e6:	88 bb       	out	0x18, r24	; 24 ; PORTB = r24
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     2e8:	00 27       	eor	r16, r16
     2ea:	88 d0       	rcall	.+272    	;  0x3fc_PWM_start_stop(FALSE)

     2ec:	27 c0       	rjmp	.+78     	;  0x33c

main_loop:
     2ee:	82 d6       	rcall	.+3332   	;  0xff4 
     2f0:	27 d0       	rcall	.+78     	;  0x340

     2f2:	20 90 04 01 	lds	r2, 0x0104	;  0x800104
     2f6:	22 20       	and	r2, r2
     2f8:	01 f1       	breq	.+64     	;  0x33a       if BOOL(0x0104)==FALSE 
     2fa:	20 90 6d 01 	lds	r2, 0x016D	;  0x80016d
     2fe:	22 20       	and	r2, r2
     300:	e1 f4       	brne	.+56     	;  0x33a       if BOOL(0x016D)==TRUE
     302:	22 24       	eor	r2, r2
     304:	20 92 04 01 	sts	0x0104, r2	;  0x800104    BOOL(0x0104)=FALSE
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;              (int16_t*)(0x0091)++
     308:	80 91 91 00 	lds	r24, 0x0091	;  0x800091
     30c:	90 91 92 00 	lds	r25, 0x0092	;  0x800092
     310:	01 96       	adiw	r24, 0x01	; 1
     312:	90 93 92 00 	sts	0x0092, r25	;  0x800092
     316:	80 93 91 00 	sts	0x0091, r24	;  0x800091
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;             
     31a:	20 90 6e 01 	lds	r2, 0x016E	;  0x80016e 
     31e:	30 90 6f 01 	lds	r3, 0x016F	;  0x80016f
     322:	28 16       	cp	r2, r24
     324:	39 06       	cpc	r3, r25
     326:	48 f4       	brcc	.+18     	;  0x33a   if *(uint16_t*)(0x016E)>=*(uint16_t*)(0x0091)
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;;; *(0x016D) = 1 / *(int16_t*)(0x0091) = 0
     328:	81 e0       	ldi	r24, 0x01	; 1
     32a:	80 93 6d 01 	sts	0x016D, r24	;  0x80016d 
     32e:	22 24       	eor	r2, r2
     330:	33 24       	eor	r3, r3
     332:	30 92 92 00 	sts	0x0092, r3	;  0x800092 
     336:	20 92 91 00 	sts	0x0091, r2	;  0x800091
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     33a:	6f d4       	rcall	.+2270   	;  0xc1a
     33c:	d8 cf       	rjmp	.-80     	;  0x2ee jump main_loop
     33e:	08 95       	ret

0x340_ADC_filter():
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ADC采样值滤波 均值滤波
;if(BOOL(0x0090)==TRUE)
;{
; BOOL(0x0090) = FALSE    //清理采样值有效标记
; ad_filter = 0
; ad_val = WORD(0x008E)   //最新ADC采样值
; if(BOOL(0x0072)==FALSE) //BOOL(0x0072)初始值为FALSE
; {
;   BOOL(0x0072) = TRUE
;   for(i=0; i<8; i++)
;   {
;     WORD_ARRAY(0x0062)[i] = ad_val
;   }
; }
; else
; {
;   for(i=7; i>=0; i--)
;   {//采样数值队列先入先出 剔除最早的那次采样结果
;     WORD_ARRAY(0x0062)[i] = WORD_ARRAY(0x0062)[i-1]
;   }
;   WORD_ARRAY(0x0062)[0] = ad_val
; }
; //均值滤波
; for(i=0; i<8; i++)
; {
;   ad_filter += WORD_ARRAY(0x0062)[i]
; }
; ad_filter /= 8
; //转换为角度值:
; //WORD(0x0101)这个变量是用来存储舵机当前实际角度的，既然AD值直接赋值给它那么:
; //mega8的AD为10位，即采样精度为 1/1024 ，舵机一整圈 360度
; //于是当前实际角度的量纲 = 360/1024 = 0.352度 
; WORD(0x0101) = ad_filter
;
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     340:	20 90 90 00 	lds	r2, 0x0090	;  0x800090
     344:	22 20       	and	r2, r2
     346:	09 f4       	brne	.+2      	;  0x34a           if BOOL(0x0090)==TRUE then continue
     348:	58 c0       	rjmp	.+176    	;  0x3fa           just return
     34a:	22 24       	eor	r2, r2
     34c:	20 92 90 00 	sts	0x0090, r2	;  0x800090        BOOL(0x0090) = FALSE
     350:	00 91 8e 00 	lds	r16, 0x008E	;  0x80008e
     354:	10 91 8f 00 	lds	r17, 0x008F	;  0x80008f        [r17,r16] = WORD(0x008E) ; get ADC value
     358:	20 90 72 00 	lds	r2, 0x0072	;  0x800072        BOOL(0x0072)仅在这个函数中使用 且初始值为FALSE
     35c:	22 20       	and	r2, r2
     35e:	99 f4       	brne	.+38     	;  0x386           if BOOL(0x0072)==TRUE goto xxxxxx
     360:	81 e0       	ldi	r24, 0x01	; 1
     362:	80 93 72 00 	sts	0x0072, r24	;  0x800072        BOOL(0x0072) = TRUE
     366:	22 27       	eor	r18, r18                       r18 = 0
     368:	0b c0       	rjmp	.+22     	;  0x380
lbl_adc_fitst_copy_loop:                            ;      0x0062~0x0071(16bytes) 
     36a:	82 e6       	ldi	r24, 0x62	; 98
     36c:	90 e0       	ldi	r25, 0x00	; 0                  [r25,r24] = 0x0062
     36e:	e2 2f       	mov	r30, r18
     370:	ff 27       	eor	r31, r31                       Z = r18
     372:	ee 0f       	add	r30, r30
     374:	ff 1f       	adc	r31, r31                       Z <<= 1
     376:	e8 0f       	add	r30, r24
     378:	f9 1f       	adc	r31, r25                       Z += 0x0062
     37a:	11 83       	std	Z+1, r17	; 0x01               WORD(Z) = WORD(0x008E)
     37c:	00 83       	st	Z, r16
     37e:	23 95       	inc	r18                            r18++
     380:	28 30       	cpi	r18, 0x08	; 8
     382:	98 f3       	brcs	.-26     	;  0x36a           if r18<8  goto lbl_adc_fitst_copy_loop
     384:	1d c0       	rjmp	.+58     	;  0x3c0

     386:	27 e0       	ldi	r18, 0x07	; 7
     388:	14 c0       	rjmp	.+40     	;  0x3b2
lbl_adc_normal_loop:
     38a:	82 e6       	ldi	r24, 0x62	; 98
     38c:	90 e0       	ldi	r25, 0x00	; 0                [r25,r24] = 0x0062
     38e:	e2 2f       	mov	r30, r18
     390:	ff 27       	eor	r31, r31                     Z = r18
     392:	31 97       	sbiw	r30, 0x01	; 1              Z -= 1
     394:	ee 0f       	add	r30, r30
     396:	ff 1f       	adc	r31, r31                     Z <<= 1
     398:	e8 0f       	add	r30, r24
     39a:	f9 1f       	adc	r31, r25                     Z += 0x0062
     39c:	20 80       	ld	r2, Z
     39e:	31 80       	ldd	r3, Z+1	; 0x01               [r3,r2] = WORD(Z)
     3a0:	e2 2f       	mov	r30, r18
     3a2:	ff 27       	eor	r31, r31                     Z = r18
     3a4:	ee 0f       	add	r30, r30
     3a6:	ff 1f       	adc	r31, r31                     Z <<= 1
     3a8:	e8 0f       	add	r30, r24
     3aa:	f9 1f       	adc	r31, r25                     Z += 0x0062
     3ac:	31 82       	std	Z+1, r3	; 0x01
     3ae:	20 82       	st	Z, r2
     3b0:	2a 95       	dec	r18                          r18--
     3b2:	80 e0       	ldi	r24, 0x00	; 0
     3b4:	82 17       	cp	r24, r18
     3b6:	48 f3       	brcs	.-46     	;  0x38a         if r18<0 goto lbl_adc_normal_loop
     3b8:	10 93 63 00 	sts	0x0063, r17	;  0x800063
     3bc:	00 93 62 00 	sts	0x0062, r16	;  0x800062      WORD(0x0062) = WORD(0x008E)

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 8个 AD采样数据求和, 结果存入[r17,r16]
     3c0:	00 27       	eor	r16, r16
     3c2:	11 27       	eor	r17, r17                     [r17,r16] = 0
     3c4:	22 27       	eor	r18, r18   ;                 r18  = 0
     3c6:	0d c0       	rjmp	.+26     	;  0x3e2
lbl_3c8_loop:
     3c8:	82 e6       	ldi	r24, 0x62	; 98
     3ca:	90 e0       	ldi	r25, 0x00	; 0            [r25,r24] = 0x0062
     3cc:	e2 2f       	mov	r30, r18
     3ce:	ff 27       	eor	r31, r31                 Z = r18
     3d0:	ee 0f       	add	r30, r30
     3d2:	ff 1f       	adc	r31, r31                 Z <<= 1
     3d4:	e8 0f       	add	r30, r24
     3d6:	f9 1f       	adc	r31, r25                 Z += 0x0062
     3d8:	20 80       	ld	r2, Z
     3da:	31 80       	ldd	r3, Z+1	; 0x01           [r3,r2] = WORD(Z)
     3dc:	02 0d       	add	r16, r2
     3de:	13 1d       	adc	r17, r3                  [r17,r16] += WORD(Z)
     3e0:	23 95       	inc	r18                      r18++
     3e2:	28 30       	cpi	r18, 0x08	; 8             
     3e4:	88 f3       	brcs	.-30     	;  0x3c8     if r18<8 goto lbl_3c8_loop
     3e6:	16 95       	lsr	r17
     3e8:	07 95       	ror	r16                      [r17,r16] >>= 1
     3ea:	16 95       	lsr	r17
     3ec:	07 95       	ror	r16                      [r17,r16] >>= 1
     3ee:	16 95       	lsr	r17
     3f0:	07 95       	ror	r16                      [r17,r16] >>= 1
     3f2:	10 93 02 01 	sts	0x0102, r17	;  0x800102
     3f6:	00 93 01 01 	sts	0x0101, r16	;  0x800101  WORD(0x0101) = [r17,r16] ;; 保存平均值
     3fa:	08 95       	ret


0x3fc_PWM_start_stop(status): ;;;; status: 0-stop / >0-start
     3fc:	aa 92       	st	-Y, r10
     3fe:	a0 2e       	mov	r10, r16
     400:	aa 20       	and	r10, r10
     402:	81 f0       	breq	.+32     	;  0x424  if r16==0
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;; PWM start
     404:	62 d5       	rcall	.+2756   	;  0xeca_init_Timer1():
     406:	82 e8       	ldi	r24, 0x82	; 130 
     408:	8f bd       	out	0x2f, r24	; 47 TCCR1A = 0x82 = 10000010b 
     40a:	89 e1       	ldi	r24, 0x19	; 25
     40c:	8e bd       	out	0x2e, r24	; 46 TCCR1B = 0x19 = 00011001b
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; set PD5 high ==> set A3950-SLEEP high
     40e:	95 9a       	sbi	0x12, 5	; 18
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BOOL(0x00E9) = TRUE / *(uint16_t*)(0x0087) = 250
     410:	81 e0       	ldi	r24, 0x01	; 1
     412:	80 93 e9 00 	sts	0x00E9, r24	;  0x8000e9
     416:	8a ef       	ldi	r24, 0xFA	; 250
     418:	90 e0       	ldi	r25, 0x00	; 0
     41a:	90 93 88 00 	sts	0x0088, r25	;  0x800088
     41e:	80 93 87 00 	sts	0x0087, r24	;  0x800087
     422:	0e c0       	rjmp	.+28     	;  0x440
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;; PWM stop
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; stop Timer1 
     424:	22 24       	eor	r2, r2
     426:	2f bc       	out	0x2f, r2	; 47
     428:	2e bc       	out	0x2e, r2	; 46
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; set PD5 low ==> set A3950-SLEEP low
     42a:	82 b3       	in	r24, 0x12	; 18
     42c:	8f 7d       	andi	r24, 0xDF	; 223
     42e:	82 bb       	out	0x12, r24	; 18
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BOOL(0x00E9) = FALSE / *(uint16_t*)(0x0087) = 1000
     430:	20 92 e9 00 	sts	0x00E9, r2	;  0x8000e9
     434:	88 ee       	ldi	r24, 0xE8	; 232
     436:	93 e0       	ldi	r25, 0x03	; 3
     438:	90 93 88 00 	sts	0x0088, r25	;  0x800088
     43c:	80 93 87 00 	sts	0x0087, r24	;  0x800087
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     440:	a9 90       	ld	r10, Y+
     442:	08 95       	ret

;func(WORD mv_time, WORD mv_position)
;{
;    WORD(0x00D5) = WORD(0x00FD)                          //WORD(0x00FD) 负责存储目标角度
;    WORD(0x00FD) = (mv_position*3+180) + WORD(0x0129)    //目标角度换算公式, WORD(0x0129) 是角度偏移量 可以理解为矫正参数
;    if(WORD(0x00D5)==WORD(0x00FD) && BOOL(0x00E9)==TRUE)
;    {//如果当前的目标角度和命令要求的角度一致 并且PWM正处于开启状态
;     //那么就不需要更新任何参数
;        return
;    }
;    else
;    {
;        BOOL fb_old  = BOOL(0x00FB)
;        WORD(0x00AE) = 0
;        BYTE(0x00B0) = 0
;        BYTE(0x0098) = LOW_BYTE(mv_time) //这个BYTE(0x0098)比较有意思，通篇只有这一处写操作，但很多地方有读操作
;        WORD(0x00A6) = WORD(0x0101)      //WORD(0x0101) 负责存储舵机当前的实际角度
;        WORD(0x00AC) = 0
;        WORD(0x00A4) = 0
;        BOOL(0x00A1) = FALSE
;        WORD(0x00DF) = 0
;        WORD(0x00B3) = 0
;        BYTE(0x00D3) = (BYTE(0x0084)-2)*2 //当前来看 BYTE(0x00D3)这个变量没有地方用到它
;        if(WORD(0x0101)<WORD(0x00FD))
;        {
;            WORD(0x00A8) = mv_position-WORD(0x0101)
;            BOOL(0x00FB) = TRUE
;            set_A3950_PHASE_LOW()
;        }
;        else
;        {
;            WORD(0x00A8) = WORD(0x0101)-mv_position
;            BOOL(0x00FB) = FALSE
;            set_A3950_PHASE_HIGH()
;        }
;        if(BOOL(0x00E9)==TRUE && BOOL(0x00FB)~=fb_old)
;        {
;            WORD(0x00E7) = WORD(0x00D5)
;        }
;        else
;        {
;            WORD(0x00E7) = WORD(0x0101)
;        }
;        call_func_0x087c()
;        0x3fc_PWM_start_stop(TRUE)
;        BOOL(0x00E9) = TRUE
;
;    }
;}
     444:	07 db       	rcall	.-2546   	;  0xfffffa54 push stack
     446:	79 01       	movw	r14, r18  ;             [r15,r14] = [r19,r18] = BYTE5 ; (文档中的运动时间)
     448:	68 01       	movw	r12, r16  ;             [r13,r12] = [r17,r16] = BYTE4 ; (文档中的目标位置)
     44a:	20 90 fd 00 	lds	r2, 0x00FD	;  0x8000fd
     44e:	30 90 fe 00 	lds	r3, 0x00FE	;  0x8000fe   [r3,r2] = WORD(0x00FD)
     452:	30 92 d6 00 	sts	0x00D6, r3	;  0x8000d6
     456:	20 92 d5 00 	sts	0x00D5, r2	;  0x8000d5   WORD(0x00D5) = WORD(0x00FD)
     45a:	03 e0       	ldi	r16, 0x03	; 3
     45c:	10 e0       	ldi	r17, 0x00	; 0             [r17,r16] = 3
     45e:	96 01       	movw	r18, r12  ;             [r19,r18] = [r13,r12] = BYTE4 ; (目标位置)
     460:	ae da       	rcall	.-2724   	;  0xfffff9be [r17,r16]*= [r19,r18] 16位无符号乘法  ===> 目标位置值*3 
     462:	c8 01       	movw	r24, r16  ;             [r25,r24] = BYTE4*3
     464:	8c 54       	subi	r24, 0x4C	; 76
     466:	9f 4f       	sbci	r25, 0xFF	; 255         [r25,r24] += 180  ===> [r25,r24] = 目标位置值*3 + 180
     468:	20 90 29 01 	lds	r2, 0x0129	;  0x800129
     46c:	30 90 2a 01 	lds	r3, 0x012A	;  0x80012a   [r3,r2] = WORD(0x0129)
     470:	2c 01       	movw	r4, r24   ;             [r5,r4] = [r25,r24] = 目标位置值*3 + 180
     472:	42 0c       	add	r4, r2
     474:	53 1c       	adc	r5, r3      ;             [r5,r4] += WORD(0x0129) 
     476:	50 92 fe 00 	sts	0x00FE, r5	;  0x8000fe   WORD(0x00FD) = [r5,r4] = (目标位置值*3+180) + WORD(0x0129)
     47a:	40 92 fd 00 	sts	0x00FD, r4	;  0x8000fd   WORD(0x00FD) = (目标位置值*3+180) + WORD(0x0129)
     47e:	12 01       	movw	r2, r4    ;             [r3,r2] = [r5,r4] = WORD(0x00FD)
     480:	40 90 d5 00 	lds	r4, 0x00D5	;  0x8000d5  
     484:	50 90 d6 00 	lds	r5, 0x00D6	;  0x8000d6   [r5,r4] = WORD(0x00D5)
     488:	42 14       	cp	r4, r2
     48a:	53 04       	cpc	r5, r3      ;             [r5,r4] vs [r3,r2]
     48c:	29 f4       	brne	.+10     	;  0x498      if WORD(0x00D5)~=WORD(0x00FD) goto xxxx
     48e:	20 90 e9 00 	lds	r2, 0x00E9	;  0x8000e9
     492:	22 20       	and	r2, r2
     494:	09 f0       	breq	.+2      	;  0x498      if BOOL(0x00E9)==FALSE goto xxxx
     496:	74 c0       	rjmp	.+232    	;  0x580      if BOOL(0x00E9)==TRUE goto lbl_0x444_func_return

     498:	a0 90 fb 00 	lds	r10, 0x00FB	;  0x8000fb   r10 = BOOL(0x00FB)
     49c:	22 24       	eor	r2, r2
     49e:	33 24       	eor	r3, r3                    [r3,r2] = 0
     4a0:	30 92 af 00 	sts	0x00AF, r3	;  0x8000af
     4a4:	20 92 ae 00 	sts	0x00AE, r2	;  0x8000ae   WORD(0x00AE) = 0
     4a8:	20 92 b0 00 	sts	0x00B0, r2	;  0x8000b0   BYTE(0x00B0) = 0
     4ac:	e0 92 98 00 	sts	0x0098, r14	;  0x800098   BYTE(0x0098) = r14 = BYTE5; (运动时间值)
     4b0:	20 90 01 01 	lds	r2, 0x0101	;  0x800101
     4b4:	30 90 02 01 	lds	r3, 0x0102	;  0x800102   [r3,r2] = WORD(0x0101)
     4b8:	30 92 a7 00 	sts	0x00A7, r3	;  0x8000a7   
     4bc:	20 92 a6 00 	sts	0x00A6, r2	;  0x8000a6   WORD(0x00A6) = [r3,r2] = WORD(0x0101)
     4c0:	22 24       	eor	r2, r2
     4c2:	33 24       	eor	r3, r3      ;             [r3,r2] = 0
     4c4:	30 92 ad 00 	sts	0x00AD, r3	;  0x8000ad
     4c8:	20 92 ac 00 	sts	0x00AC, r2	;  0x8000ac   WORD(0x00AC) = 0
     4cc:	30 92 a5 00 	sts	0x00A5, r3	;  0x8000a5
     4d0:	20 92 a4 00 	sts	0x00A4, r2	;  0x8000a4   WORD(0x00A4) = 0
     4d4:	20 92 a1 00 	sts	0x00A1, r2	;  0x8000a1   BOOL(0x00A1) = FALSE
     4d8:	30 92 e0 00 	sts	0x00E0, r3	;  0x8000e0
     4dc:	20 92 df 00 	sts	0x00DF, r2	;  0x8000df   WORD(0x00DF) = 0
     4e0:	30 92 b4 00 	sts	0x00B4, r3	;  0x8000b4
     4e4:	20 92 b3 00 	sts	0x00B3, r2	;  0x8000b3   WORD(0x00B3) = 0
     4e8:	80 91 84 00 	lds	r24, 0x0084	;  0x800084   BYTE(0x0084)初始值为20
     4ec:	82 50       	subi	r24, 0x02	; 2           r24 -= 2
     4ee:	88 0f       	add	r24, r24                  r24 *= 2
     4f0:	80 93 d3 00 	sts	0x00D3, r24	;  0x8000d3   BYTE(0x00D3) = (BYTE(0x0084)-2)*2
     4f4:	20 90 01 01 	lds	r2, 0x0101	;  0x800101
     4f8:	30 90 02 01 	lds	r3, 0x0102	;  0x800102   [r3,r2] = WORD(0x0101)
     4fc:	40 90 fd 00 	lds	r4, 0x00FD	;  0x8000fd   
     500:	50 90 fe 00 	lds	r5, 0x00FE	;  0x8000fe   [r5,r4] = WORD(0x00FD)
     504:	24 14       	cp	r2, r4
     506:	35 04       	cpc	r3, r5                    [r3,r2] VS [r5,r4]
     508:	70 f4       	brcc	.+28     	;  0x526      if WORD(0x0101)>=WORD(0x00FD) goto 
     50a:	26 01       	movw	r4, r12   ;             [r5,r4] = [r13,r12] = 目标位置值
     50c:	42 18       	sub	r4, r2
     50e:	53 08       	sbc	r5, r3                    [r5,r4] -= [r3,r2] ===> [r5,r4] -= WORD(0x0101)
     510:	50 92 a9 00 	sts	0x00A9, r5	;  0x8000a9
     514:	40 92 a8 00 	sts	0x00A8, r4	;  0x8000a8   WORD(0x00A8) = [r5,r4] = 目标位置值-WORD(0x0101)
     518:	81 e0       	ldi	r24, 0x01	; 1
     51a:	80 93 fb 00 	sts	0x00FB, r24	;  0x8000fb   BOOL(0x00FB) = TRUE
     51e:	82 b3       	in	r24, 0x12	; 18
     520:	8f 7b       	andi	r24, 0xBF	; 191
     522:	82 bb       	out	0x12, r24	; 18            PD6=LOW ===> A3950-PHASE=LOW 
     524:	0e c0       	rjmp	.+28     	;  0x542

     526:	20 90 01 01 	lds	r2, 0x0101	;  0x800101
     52a:	30 90 02 01 	lds	r3, 0x0102	;  0x800102   [r3,r2] = WORD(0x0101)
     52e:	2c 18       	sub	r2, r12
     530:	3d 08       	sbc	r3, r13                   [r3,r2] -= [r13,r12] ===> [r3,r2] -= 目标位置值
     532:	30 92 a9 00 	sts	0x00A9, r3	;  0x8000a9
     536:	20 92 a8 00 	sts	0x00A8, r2	;  0x8000a8   WORD(0x00A8) = [r3,r2] = WORD(0x0101)-目标位置值
     53a:	22 24       	eor	r2, r2
     53c:	20 92 fb 00 	sts	0x00FB, r2	;  0x8000fb   BOOL(0x00FB) = FALSE
     540:	96 9a       	sbi	0x12, 6	; 18;             PD6=HIGH ===> A3950-PHASE=HIGH 

     542:	20 90 e9 00 	lds	r2, 0x00E9	;  0x8000e9
     546:	22 20       	and	r2, r2
     548:	69 f0       	breq	.+26     	;  0x564      if BOOL(0x00E9)==FALSE goto xxxx
     54a:	20 90 fb 00 	lds	r2, 0x00FB	;  0x8000fb   BOOL(0x00E9)==TRUE
     54e:	2a 14       	cp	r2, r10                   
     550:	49 f0       	breq	.+18     	;  0x564      if BOOL(0x00FB)==r10 goto

     552:	20 90 d5 00 	lds	r2, 0x00D5	;  0x8000d5   BOOL(0x00FB)~=r10
     556:	30 90 d6 00 	lds	r3, 0x00D6	;  0x8000d6
     55a:	30 92 e8 00 	sts	0x00E8, r3	;  0x8000e8
     55e:	20 92 e7 00 	sts	0x00E7, r2	;  0x8000e7   WORD(0x00E7) = WORD(0x00D5)
     562:	08 c0       	rjmp	.+16     	;  0x574

     564:	20 90 01 01 	lds	r2, 0x0101	;  0x800101
     568:	30 90 02 01 	lds	r3, 0x0102	;  0x800102   [r3,r2] = WORD(0x0101)
     56c:	30 92 e8 00 	sts	0x00E8, r3	;  0x8000e8
     570:	20 92 e7 00 	sts	0x00E7, r2	;  0x8000e7   WORD(0x00E7) = WORD(0x0101)

     574:	83 d1       	rcall	.+774    	;  0x87c
     576:	01 e0       	ldi	r16, 0x01	; 1
     578:	41 df       	rcall	.-382    	;  0x3fc     0x3fc_PWM_start_stop(TRUE)
     57a:	81 e0       	ldi	r24, 0x01	; 1
     57c:	80 93 e9 00 	sts	0x00E9, r24	;  0x8000e9   BOOL(0x00E9) = TRUE
lbl_0x444_func_return:
     580:	5e ca       	rjmp	.-2884   	;  0xfffffa3e pop stack



     582:	22 24       	eor	r2, r2
     584:	33 24       	eor	r3, r3
     586:	30 92 a9 00 	sts	0x00A9, r3	;  0x8000a9
     58a:	20 92 a8 00 	sts	0x00A8, r2	;  0x8000a8
     58e:	30 92 e4 00 	sts	0x00E4, r3	;  0x8000e4
     592:	20 92 e3 00 	sts	0x00E3, r2	;  0x8000e3
     596:	20 90 01 01 	lds	r2, 0x0101	;  0x800101
     59a:	30 90 02 01 	lds	r3, 0x0102	;  0x800102
     59e:	40 90 a6 00 	lds	r4, 0x00A6	;  0x8000a6
     5a2:	50 90 a7 00 	lds	r5, 0x00A7	;  0x8000a7
     5a6:	42 14       	cp	r4, r2
     5a8:	53 04       	cpc	r5, r3
     5aa:	09 f4       	brne	.+2      	;  0x5ae
     5ac:	1f c1       	rjmp	.+574    	;  0x7ec
     5ae:	20 90 fb 00 	lds	r2, 0x00FB	;  0x8000fb
     5b2:	22 20       	and	r2, r2
     5b4:	99 f5       	brne	.+102    	;  0x61c
     5b6:	20 90 01 01 	lds	r2, 0x0101	;  0x800101
     5ba:	30 90 02 01 	lds	r3, 0x0102	;  0x800102
     5be:	42 14       	cp	r4, r2
     5c0:	53 04       	cpc	r5, r3
     5c2:	98 f4       	brcc	.+38     	;  0x5ea
     5c4:	30 92 a7 00 	sts	0x00A7, r3	;  0x8000a7
     5c8:	20 92 a6 00 	sts	0x00A6, r2	;  0x8000a6
     5cc:	20 90 ae 00 	lds	r2, 0x00AE	;  0x8000ae
     5d0:	30 90 af 00 	lds	r3, 0x00AF	;  0x8000af
     5d4:	30 92 ad 00 	sts	0x00AD, r3	;  0x8000ad
     5d8:	20 92 ac 00 	sts	0x00AC, r2	;  0x8000ac
     5dc:	22 24       	eor	r2, r2
     5de:	33 24       	eor	r3, r3
     5e0:	30 92 74 00 	sts	0x0074, r3	;  0x800074
     5e4:	20 92 73 00 	sts	0x0073, r2	;  0x800073
     5e8:	01 c1       	rjmp	.+514    	;  0x7ec
     5ea:	20 90 01 01 	lds	r2, 0x0101	;  0x800101
     5ee:	30 90 02 01 	lds	r3, 0x0102	;  0x800102
     5f2:	40 90 a6 00 	lds	r4, 0x00A6	;  0x8000a6
     5f6:	50 90 a7 00 	lds	r5, 0x00A7	;  0x8000a7
     5fa:	42 18       	sub	r4, r2
     5fc:	53 08       	sbc	r5, r3
     5fe:	50 92 a9 00 	sts	0x00A9, r5	;  0x8000a9
     602:	40 92 a8 00 	sts	0x00A8, r4	;  0x8000a8
     606:	40 90 e7 00 	lds	r4, 0x00E7	;  0x8000e7
     60a:	50 90 e8 00 	lds	r5, 0x00E8	;  0x8000e8
     60e:	42 18       	sub	r4, r2
     610:	53 08       	sbc	r5, r3
     612:	50 92 e4 00 	sts	0x00E4, r5	;  0x8000e4
     616:	40 92 e3 00 	sts	0x00E3, r4	;  0x8000e3
     61a:	3a c0       	rjmp	.+116    	;  0x690
     61c:	20 90 01 01 	lds	r2, 0x0101	;  0x800101
     620:	30 90 02 01 	lds	r3, 0x0102	;  0x800102
     624:	40 90 a6 00 	lds	r4, 0x00A6	;  0x8000a6
     628:	50 90 a7 00 	lds	r5, 0x00A7	;  0x8000a7
     62c:	24 14       	cp	r2, r4
     62e:	35 04       	cpc	r3, r5
     630:	98 f4       	brcc	.+38     	;  0x658
     632:	30 92 a7 00 	sts	0x00A7, r3	;  0x8000a7
     636:	20 92 a6 00 	sts	0x00A6, r2	;  0x8000a6
     63a:	20 90 ae 00 	lds	r2, 0x00AE	;  0x8000ae
     63e:	30 90 af 00 	lds	r3, 0x00AF	;  0x8000af
     642:	30 92 ad 00 	sts	0x00AD, r3	;  0x8000ad
     646:	20 92 ac 00 	sts	0x00AC, r2	;  0x8000ac
     64a:	22 24       	eor	r2, r2
     64c:	33 24       	eor	r3, r3
     64e:	30 92 74 00 	sts	0x0074, r3	;  0x800074
     652:	20 92 73 00 	sts	0x0073, r2	;  0x800073
     656:	ca c0       	rjmp	.+404    	;  0x7ec
     658:	20 90 a6 00 	lds	r2, 0x00A6	;  0x8000a6
     65c:	30 90 a7 00 	lds	r3, 0x00A7	;  0x8000a7
     660:	40 90 01 01 	lds	r4, 0x0101	;  0x800101
     664:	50 90 02 01 	lds	r5, 0x0102	;  0x800102
     668:	42 18       	sub	r4, r2
     66a:	53 08       	sbc	r5, r3
     66c:	50 92 a9 00 	sts	0x00A9, r5	;  0x8000a9
     670:	40 92 a8 00 	sts	0x00A8, r4	;  0x8000a8
     674:	20 90 e7 00 	lds	r2, 0x00E7	;  0x8000e7
     678:	30 90 e8 00 	lds	r3, 0x00E8	;  0x8000e8
     67c:	40 90 01 01 	lds	r4, 0x0101	;  0x800101
     680:	50 90 02 01 	lds	r5, 0x0102	;  0x800102
     684:	42 18       	sub	r4, r2
     686:	53 08       	sbc	r5, r3
     688:	50 92 e4 00 	sts	0x00E4, r5	;  0x8000e4
     68c:	40 92 e3 00 	sts	0x00E3, r4	;  0x8000e3
     690:	20 90 ac 00 	lds	r2, 0x00AC	;  0x8000ac
     694:	30 90 ad 00 	lds	r3, 0x00AD	;  0x8000ad
     698:	40 90 ae 00 	lds	r4, 0x00AE	;  0x8000ae
     69c:	50 90 af 00 	lds	r5, 0x00AF	;  0x8000af
     6a0:	42 18       	sub	r4, r2
     6a2:	53 08       	sbc	r5, r3
     6a4:	50 92 da 00 	sts	0x00DA, r5	;  0x8000da
     6a8:	40 92 d9 00 	sts	0x00D9, r4	;  0x8000d9
     6ac:	20 90 ec 00 	lds	r2, 0x00EC	;  0x8000ec
     6b0:	30 90 ed 00 	lds	r3, 0x00ED	;  0x8000ed
     6b4:	40 90 ae 00 	lds	r4, 0x00AE	;  0x8000ae
     6b8:	50 90 af 00 	lds	r5, 0x00AF	;  0x8000af
     6bc:	42 18       	sub	r4, r2
     6be:	53 08       	sbc	r5, r3
     6c0:	12 01       	movw	r2, r4
     6c2:	44 24       	eor	r4, r4
     6c4:	55 24       	eor	r5, r5
     6c6:	88 e0       	ldi	r24, 0x08	; 8
     6c8:	90 e0       	ldi	r25, 0x00	; 0
     6ca:	00 91 e3 00 	lds	r16, 0x00E3	;  0x8000e3
     6ce:	10 91 e4 00 	lds	r17, 0x00E4	;  0x8000e4
     6d2:	22 27       	eor	r18, r18
     6d4:	33 27       	eor	r19, r19
     6d6:	8a 93       	st	-Y, r24
     6d8:	11 da       	rcall	.-3038   	;  0xfffffafc
     6da:	5a 92       	st	-Y, r5
     6dc:	4a 92       	st	-Y, r4
     6de:	3a 92       	st	-Y, r3
     6e0:	2a 92       	st	-Y, r2
     6e2:	05 d9       	rcall	.-3574   	;  0xfffff8ee
     6e4:	10 93 e0 00 	sts	0x00E0, r17	;  0x8000e0
     6e8:	00 93 df 00 	sts	0x00DF, r16	;  0x8000df
     6ec:	88 e0       	ldi	r24, 0x08	; 8
     6ee:	90 e0       	ldi	r25, 0x00	; 0
     6f0:	00 91 e3 00 	lds	r16, 0x00E3	;  0x8000e3
     6f4:	10 91 e4 00 	lds	r17, 0x00E4	;  0x8000e4
     6f8:	22 27       	eor	r18, r18
     6fa:	33 27       	eor	r19, r19
     6fc:	8a 93       	st	-Y, r24
     6fe:	fe d9       	rcall	.-3076   	;  0xfffffafc
     700:	20 90 ae 00 	lds	r2, 0x00AE	;  0x8000ae
     704:	30 90 af 00 	lds	r3, 0x00AF	;  0x8000af
     708:	44 24       	eor	r4, r4
     70a:	55 24       	eor	r5, r5
     70c:	5a 92       	st	-Y, r5
     70e:	4a 92       	st	-Y, r4
     710:	3a 92       	st	-Y, r3
     712:	2a 92       	st	-Y, r2
     714:	ec d8       	rcall	.-3624   	;  0xfffff8ee
     716:	10 93 e0 00 	sts	0x00E0, r17	;  0x8000e0
     71a:	00 93 df 00 	sts	0x00DF, r16	;  0x8000df
     71e:	20 90 77 00 	lds	r2, 0x0077	;  0x800077
     722:	30 90 78 00 	lds	r3, 0x0078	;  0x800078
     726:	30 92 7a 00 	sts	0x007A, r3	;  0x80007a
     72a:	20 92 79 00 	sts	0x0079, r2	;  0x800079
     72e:	20 90 75 00 	lds	r2, 0x0075	;  0x800075
     732:	30 90 76 00 	lds	r3, 0x0076	;  0x800076
     736:	30 92 78 00 	sts	0x0078, r3	;  0x800078
     73a:	20 92 77 00 	sts	0x0077, r2	;  0x800077
     73e:	20 90 73 00 	lds	r2, 0x0073	;  0x800073
     742:	30 90 74 00 	lds	r3, 0x0074	;  0x800074
     746:	30 92 76 00 	sts	0x0076, r3	;  0x800076
     74a:	20 92 75 00 	sts	0x0075, r2	;  0x800075
     74e:	88 e0       	ldi	r24, 0x08	; 8
     750:	90 e0       	ldi	r25, 0x00	; 0
     752:	00 91 a8 00 	lds	r16, 0x00A8	;  0x8000a8
     756:	10 91 a9 00 	lds	r17, 0x00A9	;  0x8000a9
     75a:	22 27       	eor	r18, r18
     75c:	33 27       	eor	r19, r19
     75e:	8a 93       	st	-Y, r24
     760:	cd d9       	rcall	.-3174   	;  0xfffffafc
     762:	20 90 d9 00 	lds	r2, 0x00D9	;  0x8000d9
     766:	30 90 da 00 	lds	r3, 0x00DA	;  0x8000da
     76a:	44 24       	eor	r4, r4
     76c:	55 24       	eor	r5, r5
     76e:	5a 92       	st	-Y, r5
     770:	4a 92       	st	-Y, r4
     772:	3a 92       	st	-Y, r3
     774:	2a 92       	st	-Y, r2
     776:	bb d8       	rcall	.-3722   	;  0xfffff8ee
     778:	10 93 74 00 	sts	0x0074, r17	;  0x800074
     77c:	00 93 73 00 	sts	0x0073, r16	;  0x800073
     780:	20 90 77 00 	lds	r2, 0x0077	;  0x800077
     784:	30 90 78 00 	lds	r3, 0x0078	;  0x800078
     788:	40 90 79 00 	lds	r4, 0x0079	;  0x800079
     78c:	50 90 7a 00 	lds	r5, 0x007A	;  0x80007a
     790:	42 0c       	add	r4, r2
     792:	53 1c       	adc	r5, r3
     794:	20 90 75 00 	lds	r2, 0x0075	;  0x800075
     798:	30 90 76 00 	lds	r3, 0x0076	;  0x800076
     79c:	42 0c       	add	r4, r2
     79e:	53 1c       	adc	r5, r3
     7a0:	40 0e       	add	r4, r16
     7a2:	51 1e       	adc	r5, r17
     7a4:	56 94       	lsr	r5
     7a6:	47 94       	ror	r4
     7a8:	56 94       	lsr	r5
     7aa:	47 94       	ror	r4
     7ac:	50 92 a5 00 	sts	0x00A5, r5	;  0x8000a5
     7b0:	40 92 a4 00 	sts	0x00A4, r4	;  0x8000a4
     7b4:	8b e1       	ldi	r24, 0x1B	; 27
     7b6:	91 e0       	ldi	r25, 0x01	; 1
     7b8:	84 15       	cp	r24, r4
     7ba:	95 05       	cpc	r25, r5
     7bc:	20 f4       	brcc	.+8      	;  0x7c6
     7be:	90 93 a5 00 	sts	0x00A5, r25	;  0x8000a5
     7c2:	80 93 a4 00 	sts	0x00A4, r24	;  0x8000a4
     7c6:	81 e0       	ldi	r24, 0x01	; 1
     7c8:	80 93 a1 00 	sts	0x00A1, r24	;  0x8000a1
     7cc:	20 90 01 01 	lds	r2, 0x0101	;  0x800101
     7d0:	30 90 02 01 	lds	r3, 0x0102	;  0x800102
     7d4:	30 92 a7 00 	sts	0x00A7, r3	;  0x8000a7
     7d8:	20 92 a6 00 	sts	0x00A6, r2	;  0x8000a6
     7dc:	20 90 ae 00 	lds	r2, 0x00AE	;  0x8000ae
     7e0:	30 90 af 00 	lds	r3, 0x00AF	;  0x8000af
     7e4:	30 92 ad 00 	sts	0x00AD, r3	;  0x8000ad
     7e8:	20 92 ac 00 	sts	0x00AC, r2	;  0x8000ac
     7ec:	08 95       	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;call_0x7ee()  ;函数最终的结果是 根据几个参数计算出了 WORD(0x00D1) 的值
;{
;   //WORD(0x009C)    : 完成0x01命令要求的动作总共需要移动多少角度 可正可负
;   //WORD(0x00AE)    : 0x01命令启动之后到现在为止所经过的毫秒数
;   //BYTE(0x0098)*20 : 0x01命令要求的动作执行总时间 毫秒
;   DWORD tmp  = WORD(0x009C)*WORD(0x00AE)  
;   tmp /= (BYTE(0x0098)*20)             // tmp = [WORD(0x00AE)/(BYTE(0x0098)*20)] * WORD(0x009C)
;   WORD(0x00D1) = LOW_WORD(tmp)
;
;   //BOOL(0x00FB) : 标记转动方向 FALSE 反向转动 TRUE 正向转动
;   //WORD(0x00E7) : 动作刚开始时 舵机当时的实际角度
;   if(BOOL(0x00FB)==FALSE)
;   {
;     WORD(0x00D1) = WORD(0x00E7) - WORD(0x00D1)
;   }
;   else
;   {
;     WORD(0x00D1) += WORD(0x00E7)
;   }
;   //WORD(0x00D1) 的最终结果含义： 整个动作按毫秒分片分步执行，记录此时此刻舵机的目标角度
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     7ee:	39 d9       	rcall	.-3470   	;  0xfffffa62 stack push
     7f0:	20 90 ae 00 	lds	r2, 0x00AE	;  0x8000ae
     7f4:	30 90 af 00 	lds	r3, 0x00AF	;  0x8000af   [r3,r2]   = WORD(0x00AE)
     7f8:	44 24       	eor	r4, r4
     7fa:	55 24       	eor	r5, r5                    [r4,r5]   = 0
     7fc:	00 91 9c 00 	lds	r16, 0x009C	;  0x80009c
     800:	10 91 9d 00 	lds	r17, 0x009D	;  0x80009d   [r17,r16] = WORD(0x009C)
     804:	22 27       	eor	r18, r18
     806:	33 27       	eor	r19, r19                  [r19,r18] = 0
     808:	5a 92       	st	-Y, r5
     80a:	4a 92       	st	-Y, r4
     80c:	3a 92       	st	-Y, r3
     80e:	2a 92       	st	-Y, r2      ;             r5,r4,r3,r2 依次入栈保存
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
     810:	e6 d8       	rcall	.-3636   	;  0xfffff9de [r19, r18, r17, r16] = [r5, r4, r3, r2]*[r19, r18, r17, r16] ;;32位乘法
     812:	20 90 98 00 	lds	r2, 0x0098	;  0x800098   
     816:	33 24       	eor	r3, r3      ;             
     818:	44 24       	eor	r4, r4
     81a:	55 24       	eor	r5, r5      ;             [r5,r4,r3,r2] =  BYTE(0x0098)
     81c:	5a 92       	st	-Y, r5
     81e:	4a 92       	st	-Y, r4
     820:	3a 92       	st	-Y, r3
     822:	2a 92       	st	-Y, r2
     824:	64 d8       	rcall	.-3896   	;  0xfffff8ee [r19,r18,r17,r16] /= BYTE(0x0098) ;;32位有符号除法
     826:	44 e1       	ldi	r20, 0x14	; 20
     828:	50 e0       	ldi	r21, 0x00	; 0
     82a:	60 e0       	ldi	r22, 0x00	; 0
     82c:	70 e0       	ldi	r23, 0x00	; 0             [r23,r22,r21,r20] = 20
     82e:	7a 93       	st	-Y, r23
     830:	6a 93       	st	-Y, r22
     832:	5a 93       	st	-Y, r21
     834:	4a 93       	st	-Y, r20
     836:	5b d8       	rcall	.-3914   	;  0xfffff8ee [r19,r18,r17,r16] /= 20 ;;; 最终结果应该是个16位的
     838:	10 93 d2 00 	sts	0x00D2, r17	;  0x8000d2
     83c:	00 93 d1 00 	sts	0x00D1, r16	;  0x8000d1   WORD(0x00D1) = [r17,r16]
     840:	20 90 fb 00 	lds	r2, 0x00FB	;  0x8000fb
     844:	22 20       	and	r2, r2
     846:	59 f4       	brne	.+22     	;  0x85e      if BOOL(0x00FB)==TRUE goto xxxx
     848:	40 90 e7 00 	lds	r4, 0x00E7	;  0x8000e7
     84c:	50 90 e8 00 	lds	r5, 0x00E8	;  0x8000e8   [r5,r4] = WORD(0x00E7)
     850:	40 1a       	sub	r4, r16
     852:	51 0a       	sbc	r5, r17     ;             [r5,r4] -= WORD(0x00D1)
     854:	50 92 d2 00 	sts	0x00D2, r5	;  0x8000d2
     858:	40 92 d1 00 	sts	0x00D1, r4	;  0x8000d1   WORD(0x00D1) = [r5,r4] = WORD(0x00E7) - WORD(0x00D1)
     85c:	0e c0       	rjmp	.+28     	;  0x87a

     85e:	20 90 e7 00 	lds	r2, 0x00E7	;  0x8000e7
     862:	30 90 e8 00 	lds	r3, 0x00E8	;  0x8000e8
     866:	40 90 d1 00 	lds	r4, 0x00D1	;  0x8000d1
     86a:	50 90 d2 00 	lds	r5, 0x00D2	;  0x8000d2
     86e:	42 0c       	add	r4, r2
     870:	53 1c       	adc	r5, r3
     872:	50 92 d2 00 	sts	0x00D2, r5	;  0x8000d2
     876:	40 92 d1 00 	sts	0x00D1, r4	;  0x8000d1  WORD(0x00D1) += WORD(0x00E7)
     87a:	f8 c8       	rjmp	.-3600   	;  0xfffffa6c stack pop and return 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 输入值： WORD(0x00FD) / WORD(0x00E7) / BYTE(0x0098)
; 输出值： WORD(0x009E) / BOOL(0x0099) / WORD(0x009C)
; 经过一系列计算输出这3个结果，不过其他代码位置只使用了 WORD(0x009C)， 
; 表示目标角度和当前实际角度之间的差值，可正可负
；另外两个没用
;void call_func_0x087c()
;{
;    if(WORD(0x00FD)<WORD(0x00E7))
;    {
;        WORD(0x009C) = WORD(0x00E7)-WORD(0x00FD) //WORD(0x00FD) 负责存储目标角度
;        BOOL(0x0099) = FALSE
;    }
;    else
;    {
;        BOOL(0x0099) = TRUE
;        WORD(0x009C) = WORD(0x00FD)-WORD(0x00E7)
;    }
;    WORD(0x009E) = ((WORD(0x009C)*64/BYTE(0x0098)))/5
;    if(WORD(0x009E)>270)
;    {
;        WORD(0x009E)=270
;    }
;    if(WORD(0x009E)<10)
;    {
;        WORD(0x009E)=10
;    }
;}
     87c:	20 90 fd 00 	lds	r2, 0x00FD	;  0x8000fd
     880:	30 90 fe 00 	lds	r3, 0x00FE	;  0x8000fe  [r3, r2] = WORD(0x00FD)
     884:	40 90 e7 00 	lds	r4, 0x00E7	;  0x8000e7
     888:	50 90 e8 00 	lds	r5, 0x00E8	;  0x8000e8  [r5, r4] = WORD(0x00E7)
     88c:	24 14       	cp	r2, r4
     88e:	35 04       	cpc	r3, r5
     890:	50 f4       	brcc	.+20     	;  0x8a6     if WORD(0x00FD)>=WORD(0x00E7) goto xxxxx
     892:	42 18       	sub	r4, r2                   WORD(0x00FD)<WORD(0x00E7)
     894:	53 08       	sbc	r5, r3
     896:	50 92 9d 00 	sts	0x009D, r5	;  0x80009d
     89a:	40 92 9c 00 	sts	0x009C, r4	;  0x80009c  WORD(0x009C) = WORD(0x00E7)-WORD(0x00FD)
     89e:	22 24       	eor	r2, r2
     8a0:	20 92 99 00 	sts	0x0099, r2	;  0x800099  BOOL(0x0099) = FALSE
     8a4:	11 c0       	rjmp	.+34     	;  0x8c8     goto xxxxx

     8a6:	81 e0       	ldi	r24, 0x01	; 1 
     8a8:	80 93 99 00 	sts	0x0099, r24	;  0x800099  BOOL(0x0099) = TRUE
     8ac:	20 90 e7 00 	lds	r2, 0x00E7	;  0x8000e7
     8b0:	30 90 e8 00 	lds	r3, 0x00E8	;  0x8000e8  [r3, r2] = WORD(0x00E7)
     8b4:	40 90 fd 00 	lds	r4, 0x00FD	;  0x8000fd
     8b8:	50 90 fe 00 	lds	r5, 0x00FE	;  0x8000fe  [r5, r4] = WORD(0x00FD)
     8bc:	42 18       	sub	r4, r2
     8be:	53 08       	sbc	r5, r3
     8c0:	50 92 9d 00 	sts	0x009D, r5	;  0x80009d
     8c4:	40 92 9c 00 	sts	0x009C, r4	;  0x80009c  WORD(0x009C) = WORD(0x00FD)-WORD(0x00E7)

     8c8:	26 e0       	ldi	r18, 0x06	; 6
     8ca:	30 e0       	ldi	r19, 0x00	; 0             [r19, r18] = 6
     8cc:	00 91 9c 00 	lds	r16, 0x009C	;  0x80009c
     8d0:	10 91 9d 00 	lds	r17, 0x009D	;  0x80009d   [r17,r16] = WORD(0x009C)
     8d4:	0c d9       	rcall	.-3560   	;  0xfffffaee [r17,r16]<<=6 或者理解为 [r17,r16] = WORD(0x009C)*64
     8d6:	20 91 98 00 	lds	r18, 0x0098	;  0x800098   
     8da:	33 27       	eor	r19, r19    ;             [r19,r18] = BYTE(0x0098)
     8dc:	ee d7       	rcall	.+4060   	;  0x18ba     [r17,r16] = 0x18ba_div( [r17,r16], [r19,r18] )
     8de:	25 e0       	ldi	r18, 0x05	; 5
     8e0:	30 e0       	ldi	r19, 0x00	; 0             [r19,r18] = 5
     8e2:	eb d7       	rcall	.+4054   	;  0x18ba     [r17,r16] = 0x18ba_div( [r17,r16], [r19,r18] )
     8e4:	10 93 9f 00 	sts	0x009F, r17	;  0x80009f
     8e8:	00 93 9e 00 	sts	0x009E, r16	;  0x80009e   WORD(0x009E) = [r17,r16] = ((WORD(0x009C)*64/BYTE(0x0098)))/5
     8ec:	8e e0       	ldi	r24, 0x0E	; 14
     8ee:	91 e0       	ldi	r25, 0x01	; 1             [r25,r24]  =  270
     8f0:	80 17       	cp	r24, r16
     8f2:	91 07       	cpc	r25, r17    ;             [r25,r24] vs [r17,r16]
     8f4:	20 f4       	brcc	.+8      	;  0x8fe      if 270>=WORD(0x009E) goto 
     8f6:	90 93 9f 00 	sts	0x009F, r25	;  0x80009f
     8fa:	80 93 9e 00 	sts	0x009E, r24	;  0x80009e   if WORD(0x009E)>270 then WORD(0x009E)=270

     8fe:	80 91 9e 00 	lds	r24, 0x009E	;  0x80009e
     902:	90 91 9f 00 	lds	r25, 0x009F	;  0x80009f   [r25,r24] = WORD(0x009E)
     906:	8a 30       	cpi	r24, 0x0A	; 10
     908:	e0 e0       	ldi	r30, 0x00	; 0
     90a:	9e 07       	cpc	r25, r30    ;             [r25,r24] vs 10 
     90c:	30 f4       	brcc	.+12     	;  0x91a      if WORD(0x009E)>=10 return
     90e:	8a e0       	ldi	r24, 0x0A	; 10            
     910:	90 e0       	ldi	r25, 0x00	; 0
     912:	90 93 9f 00 	sts	0x009F, r25	;  0x80009f
     916:	80 93 9e 00 	sts	0x009E, r24	;  0x80009e   if WORD(0x009E)<10 then WORD(0x009E)=10
     91a:	08 95       	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
-----------------------------
 addr:  D0 D1 D2 D3 D4 D5 D6
-----:-----------------------
   26:  23 1e 16 19 19 23 23   
   2d:  23 1e 16 19 19 23 23  
   34:  23 1e 16 19 19 23 23 
   3b:  23 1e 16 19 19 23 23   
   42:  23 1e 16 19 19 23 23  
-----------------------------    
*/
void call_0x91c()
{
  //WORD(0x00D1):  整个动作按毫秒分片分步执行，记录此时此刻舵机的目标角度
  //WORD(0x0101):  此时此刻舵机实际角度
  WORD(0x00B1) = WORD(0x00B3)                 //WORD(0x00B1): 上次的角度误差
  WORD(0x00B3) = WORD(0x0101) - WORD(0x00D1)  //WORD(0x00B3): 这次的角度误差
  WORD(0x00C1) = WORD(0x0101) - WORD(0x00D1)  //WORD(0x00C1): 这次角度误差的副本 用于函数内部后续计算
  //误差过大时 增加饱和控制，即正负不能超过100单位角度 折合约35度
  if(WORD(0x00C1)>100)
  {
    WORD(0x00C1) = 100
  }
  if(WORD(0x00C1)<-100)
  {
    WORD(0x00C1) = -100
  }
  WORD(0x00BF) = WORD(0x00B3) - WORD(0x00B1)    //微分控制参数求取
  BYTE x
  if(WORD(0x00C1)>20)
    x = 6
  else if(WORD(0x00C1)>13)
    x = 5
  else if(WORD(0x00C1)>8)
    x = 4
  else if(WORD(0x00C1)>5)
    x = 3
  else if(WORD(0x00C1)>2)
    x = 2
  else if(WORD(0x00C1)>1)
    x = 1
  else if(WORD(0x00C1)>0)
    x = 0
  else if(WORD(0x00C1)>-2)
    x = 0
  else if(WORD(0x00C1)>-3)
    x = 1
  else if(WORD(0x00C1)>-6)
    x = 2
  else if(WORD(0x00C1)>-9)
    x = 3
  else if(WORD(0x00C1)>-14)
    x = 4
  else if(WORD(0x00C1)>-21)
    x = 5
  else
    x = 6
  //
  BYTE(0x00CF) = 0               //微分控制系数，既然归零了那么就不存在微分控制了
  //FLASH二维字节数组 
  //x=[0~6]  BYTE(0x00B0)=[0~4]
  BYTE(0x00D0) = read_flash_byte(x+BYTE(0x00B0)*7+0x0026) //查表获取和当前误差匹配的比例控制系数 存储到 BYTE(0x00D0)
  //这里好奇葩的代码 难道没有开优化??
  if(x>1)
  {
    WORD(0x007B) = WORD(0x0073)/4
    WORD(0x007D) = WORD(0x0075)/4
  }
  else
  {
    WORD(0x007B) = WORD(0x0073)/4
    WORD(0x007D) = WORD(0x0075)/4
  }
  //只是一个简单的比例控制器 U(k) = Kp * E(k) (微分系数被清零了)
  //只不过比例系数不是固定的，存储在FLASH中，误差越大，查表得到的系数越大
  WORD y = BYTE(0x0083)*BYTE(0x00D0)
  y /= BYTE(0x0084) //BYTE(0x0084)   是一个常量,值为20
  y *= WORD(0x00C1) //[r21,r20]      
  y += WORD(0x00BF)*BYTE(0x00CF)*4  //累加微分控制项 但系数归零了，所以没有微分控制
  //
  direct = BOOL(0x00D4)
  if(y>0)
  {
    PD6 = HIGH // A3950-PHASE = HIGH
    WORD(0x00D7) = y
    BOOL(0x00D4) = FALSE
  }
  else if(y<0)
  {
    PD6 = LOW // A3950-PHASE = LOW
    WORD(0x00D7) = -y
    BOOL(0x00D4) = TRUE
  }
  else
  {
    //PDxxxx???
    WORD(0x00D7) = 0
    OCR1A = 0
  }
  //
  if(direct!=BOOL(0x00D4))
  {
    OCR1A = 0
  }
  if(WORD(0x00D7)>982)
  {
    WORD(0x00D7) = 982
  }
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     91c:	ac d8       	rcall	.-3752   	;  0xfffffa76
     91e:	40 91 01 01 	lds	r20, 0x0101	;  0x800101
     922:	50 91 02 01 	lds	r21, 0x0102	;  0x800102     [r21,r20] = WORD(0x0101)
     926:	20 90 d1 00 	lds	r2, 0x00D1	;  0x8000d1
     92a:	30 90 d2 00 	lds	r3, 0x00D2	;  0x8000d2     [r3,r2]  = WORD(0x00D1)
     92e:	42 19       	sub	r20, r2
     930:	53 09       	sbc	r21, r3     ;               [r21,r20] -= WORD(0x00D1)
     932:	20 90 b3 00 	lds	r2, 0x00B3	;  0x8000b3
     936:	30 90 b4 00 	lds	r3, 0x00B4	;  0x8000b4     [r3,r2] = WORD(0x00B3)
     93a:	30 92 b2 00 	sts	0x00B2, r3	;  0x8000b2
     93e:	20 92 b1 00 	sts	0x00B1, r2	;  0x8000b1     WORD(0x00B1) = WORD(0x00B3)
     942:	50 93 b4 00 	sts	0x00B4, r21	;  0x8000b4
     946:	40 93 b3 00 	sts	0x00B3, r20	;  0x8000b3     WORD(0x00B3) = [r21,r20] = WORD(0x0101) - WORD(0x00D1)
     94a:	1a 01       	movw	r2, r20   ;               [r3,r2]  = [r21,r20]
     94c:	30 92 c2 00 	sts	0x00C2, r3	;  0x8000c2
     950:	20 92 c1 00 	sts	0x00C1, r2	;  0x8000c1     WORD(0x00C1) = WORD(0x0101) - WORD(0x00D1)
     954:	84 e6       	ldi	r24, 0x64	; 100
     956:	90 e0       	ldi	r25, 0x00	; 0               [r25,r24] = 100
     958:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     95c:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2     [r3,r2] = WORD(0x00C1)
     960:	82 15       	cp	r24, r2
     962:	93 05       	cpc	r25, r3
     964:	24 f4       	brge	.+8      	;  0x96e        if 100>=WORD(0x00C1) goto xxxx
     966:	90 93 c2 00 	sts	0x00C2, r25	;  0x8000c2
     96a:	80 93 c1 00 	sts	0x00C1, r24	;  0x8000c1     WORD(0x00C1) = 100

     96e:	80 91 c1 00 	lds	r24, 0x00C1	;  0x8000c1
     972:	90 91 c2 00 	lds	r25, 0x00C2	;  0x8000c2     [r25,r24] = WORD(0x00C1) 
     976:	8c 39       	cpi	r24, 0x9C	; 156
     978:	ef ef       	ldi	r30, 0xFF	; 255             0xFF9C <===> -100
     97a:	9e 07       	cpc	r25, r30    ;               [r25,r24] vs -100
     97c:	34 f4       	brge	.+12     	;  0x98a        if WORD(0x00C1)>=-100 goto xxxx
     97e:	8c e9       	ldi	r24, 0x9C	; 156
     980:	9f ef       	ldi	r25, 0xFF	; 255
     982:	90 93 c2 00 	sts	0x00C2, r25	;  0x8000c2
     986:	80 93 c1 00 	sts	0x00C1, r24	;  0x8000c1     WORD(0x00C1) = -100

     98a:	20 90 b1 00 	lds	r2, 0x00B1	;  0x8000b1
     98e:	30 90 b2 00 	lds	r3, 0x00B2	;  0x8000b2     [r3,r2] = WORD(0x00B1)
     992:	40 90 b3 00 	lds	r4, 0x00B3	;  0x8000b3
     996:	50 90 b4 00 	lds	r5, 0x00B4	;  0x8000b4     [r5,r4] = WORD(0x00B3)
     99a:	42 18       	sub	r4, r2
     99c:	53 08       	sbc	r5, r3      ;               [r5,r4] -= WORD(0x00B1)
     99e:	50 92 c0 00 	sts	0x00C0, r5	;  0x8000c0
     9a2:	40 92 bf 00 	sts	0x00BF, r4	;  0x8000bf     WORD(0x00BF) = [r5,r4] = WORD(0x00B3) - WORD(0x00B1)
     9a6:	84 e1       	ldi	r24, 0x14	; 20
     9a8:	90 e0       	ldi	r25, 0x00	; 0               [r25,r24] = 20
     9aa:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     9ae:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2     [r3,r2] = WORD(0x00C1)
     9b2:	82 15       	cp	r24, r2
     9b4:	93 05       	cpc	r25, r3
     9b6:	14 f4       	brge	.+4      	;  0x9bc        if 20>=WORD(0x00C1) goto xxxxx
     9b8:	66 e0       	ldi	r22, 0x06	; 6               20<WORD(0x00C1) and r22 = 6
     9ba:	85 c0       	rjmp	.+266    	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     9bc:	8d e0       	ldi	r24, 0x0D	; 13
     9be:	90 e0       	ldi	r25, 0x00	; 0               [r25,r24] = 13
     9c0:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     9c4:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2     [r3,r2] = WORD(0x00C1)
     9c8:	82 15       	cp	r24, r2
     9ca:	93 05       	cpc	r25, r3
     9cc:	14 f4       	brge	.+4      	;  0x9d2        if 13>=WORD(0x00C1) goto xxxxx
     9ce:	65 e0       	ldi	r22, 0x05	; 5               13<WORD(0x00C1) and r22 = 5
     9d0:	7a c0       	rjmp	.+244    	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     9d2:	88 e0       	ldi	r24, 0x08	; 8
     9d4:	90 e0       	ldi	r25, 0x00	; 0               [r25,r24] = 8
     9d6:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     9da:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2
     9de:	82 15       	cp	r24, r2
     9e0:	93 05       	cpc	r25, r3
     9e2:	14 f4       	brge	.+4      	;  0x9e8        if 8>=WORD(0x00C1) goto xxx
     9e4:	64 e0       	ldi	r22, 0x04	; 4               8<WORD(0x00C1) and r22 = 4
     9e6:	6f c0       	rjmp	.+222    	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     9e8:	85 e0       	ldi	r24, 0x05	; 5
     9ea:	90 e0       	ldi	r25, 0x00	; 0               [r25,r24] = 5
     9ec:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     9f0:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2
     9f4:	82 15       	cp	r24, r2
     9f6:	93 05       	cpc	r25, r3
     9f8:	14 f4       	brge	.+4      	;  0x9fe        if 5>=WORD(0x00C1) goto xxx
     9fa:	63 e0       	ldi	r22, 0x03	; 3               5<WORD(0x00C1) and r22 = 3
     9fc:	64 c0       	rjmp	.+200    	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     9fe:	82 e0       	ldi	r24, 0x02	; 2
     a00:	90 e0       	ldi	r25, 0x00	; 0               [r25,r24] = 2
     a02:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     a06:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2
     a0a:	82 15       	cp	r24, r2
     a0c:	93 05       	cpc	r25, r3
     a0e:	14 f4       	brge	.+4      	;  0xa14        if 2>=WORD(0x00C1) goto xxx
     a10:	62 e0       	ldi	r22, 0x02	; 2               2<WORD(0x00C1) and r22 = 2
     a12:	59 c0       	rjmp	.+178    	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     a14:	81 e0       	ldi	r24, 0x01	; 1
     a16:	90 e0       	ldi	r25, 0x00	; 0               [r25,r24] = 1
     a18:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     a1c:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2
     a20:	82 15       	cp	r24, r2
     a22:	93 05       	cpc	r25, r3
     a24:	14 f4       	brge	.+4      	;  0xa2a        if 1>=WORD(0x00C1) goto xxx
     a26:	61 e0       	ldi	r22, 0x01	; 1               1<WORD(0x00C1) and r22 = 1
     a28:	4e c0       	rjmp	.+156    	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     a2a:	22 24       	eor	r2, r2
     a2c:	33 24       	eor	r3, r3      ;               [r3,r2] = 0
     a2e:	40 90 c1 00 	lds	r4, 0x00C1	;  0x8000c1
     a32:	50 90 c2 00 	lds	r5, 0x00C2	;  0x8000c2
     a36:	24 14       	cp	r2, r4
     a38:	35 04       	cpc	r3, r5
     a3a:	14 f4       	brge	.+4      	;  0xa40        if 0>=WORD(0x00C1) goto xxxx
     a3c:	66 27       	eor	r22, r22                    0<WORD(0x00C1) and r22 = 0
     a3e:	43 c0       	rjmp	.+134    	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     a40:	8e ef       	ldi	r24, 0xFE	; 254
     a42:	9f ef       	ldi	r25, 0xFF	; 255            [r25,r24] = -2
     a44:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     a48:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2
     a4c:	82 15       	cp	r24, r2
     a4e:	93 05       	cpc	r25, r3
     a50:	14 f4       	brge	.+4      	;  0xa56       if -2>=WORD(0x00C1) goto xxxx
     a52:	66 27       	eor	r22, r22    ;              -2<WORD(0x00C1) and r22 = 0
     a54:	38 c0       	rjmp	.+112    	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     a56:	8d ef       	ldi	r24, 0xFD	; 253
     a58:	9f ef       	ldi	r25, 0xFF	; 255            [r25,r24] = -3
     a5a:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     a5e:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2
     a62:	82 15       	cp	r24, r2
     a64:	93 05       	cpc	r25, r3
     a66:	14 f4       	brge	.+4      	;  0xa6c       if -3>=WORD(0x00C1) goto xxxx
     a68:	61 e0       	ldi	r22, 0x01	; 1              -3<WORD(0x00C1) and r22 = 1
     a6a:	2d c0       	rjmp	.+90     	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     a6c:	8a ef       	ldi	r24, 0xFA	; 250
     a6e:	9f ef       	ldi	r25, 0xFF	; 255            [r25,r24] = -6
     a70:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     a74:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2
     a78:	82 15       	cp	r24, r2
     a7a:	93 05       	cpc	r25, r3
     a7c:	14 f4       	brge	.+4      	;  0xa82       if -6>=WORD(0x00C1) goto xxxx
     a7e:	62 e0       	ldi	r22, 0x02	; 2              -6<WORD(0x00C1) and r22 = 2
     a80:	22 c0       	rjmp	.+68     	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     a82:	87 ef       	ldi	r24, 0xF7	; 247
     a84:	9f ef       	ldi	r25, 0xFF	; 255            [r25,r24] = -9
     a86:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     a8a:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2
     a8e:	82 15       	cp	r24, r2
     a90:	93 05       	cpc	r25, r3
     a92:	14 f4       	brge	.+4      	;  0xa98       if -9>=WORD(0x00C1) goto xxxx
     a94:	63 e0       	ldi	r22, 0x03	; 3              -9<WORD(0x00C1) and r22 = 3
     a96:	17 c0       	rjmp	.+46     	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     a98:	82 ef       	ldi	r24, 0xF2	; 242
     a9a:	9f ef       	ldi	r25, 0xFF	; 255            [r25,r24] = -14
     a9c:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     aa0:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2
     aa4:	82 15       	cp	r24, r2
     aa6:	93 05       	cpc	r25, r3
     aa8:	14 f4       	brge	.+4      	;  0xaae       if -14>=WORD(0x00C1) goto xxxx
     aaa:	64 e0       	ldi	r22, 0x04	; 4              -14<WORD(0x00C1) and r22 = 4
     aac:	0c c0       	rjmp	.+24     	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     aae:	8b ee       	ldi	r24, 0xEB	; 235
     ab0:	9f ef       	ldi	r25, 0xFF	; 255            [r25,r24] = -21
     ab2:	20 90 c1 00 	lds	r2, 0x00C1	;  0x8000c1
     ab6:	30 90 c2 00 	lds	r3, 0x00C2	;  0x8000c2
     aba:	82 15       	cp	r24, r2
     abc:	93 05       	cpc	r25, r3
     abe:	14 f4       	brge	.+4      	;  0xac4       if -21>=WORD(0x00C1) goto xxxx
     ac0:	65 e0       	ldi	r22, 0x05	; 5              -21<WORD(0x00C1) and r22 = 5
     ac2:	01 c0       	rjmp	.+2      	;  0xac6
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ac4:	66 e0       	ldi	r22, 0x06	; 6

     ac6:	22 24       	eor	r2, r2                     r2 = 0
     ac8:	20 92 cf 00 	sts	0x00CF, r2	;  0x8000cf    BYTE(0x00CF) = 0
     acc:	10 91 b0 00 	lds	r17, 0x00B0	;  0x8000b0    r17 = BYTE(0x00B0)
     ad0:	07 e0       	ldi	r16, 0x07	; 7              r16 = 7
     ad2:	01 03       	mulsu	r16, r17  ;              [r1,r0] = BYTE(0x00B0)*7
     ad4:	10 01       	movw	r2, r0                   [r3,r2] = [r1,r0] = BYTE(0x00B0)*7
     ad6:	86 e2       	ldi	r24, 0x26	; 38
     ad8:	90 e0       	ldi	r25, 0x00	; 0              [r25,r24] = 0x0026
     ada:	28 0e       	add	r2, r24
     adc:	39 1e       	adc	r3, r25                    [r3,r2] += 0x0026 ===> [r3,r2] = BYTE(0x00B0)*7+0x0026
     ade:	e6 2f       	mov	r30, r22                   
     ae0:	ff 27       	eor	r31, r31                   Z = r22
     ae2:	e2 0d       	add	r30, r2
     ae4:	f3 1d       	adc	r31, r3                    Z += [r3,r2] ===> Z = r22 + BYTE(0x00B0)*7 + 0x0026
     ae6:	24 90       	lpm	r2, Z
     ae8:	20 92 d0 00 	sts	0x00D0, r2	;  0x8000d0    BYTE(0x00D0) = read_flash_byte(r22+BYTE(0x00B0)*7+0x0026) ; // r22=[0~6]  BYTE(0x00B0)=[0~4] 
     aec:	81 e0       	ldi	r24, 0x01	; 1
     aee:	86 17       	cp	r24, r22
     af0:	c8 f4       	brcc	.+50     	;  0xb24       if 1>=r22 goto xxxx
     af2:	20 90 73 00 	lds	r2, 0x0073	;  0x800073
     af6:	30 90 74 00 	lds	r3, 0x0074	;  0x800074    1<r22 and [r3,r2] = WORD(0x0073)
     afa:	36 94       	lsr	r3
     afc:	27 94       	ror	r2          ;              
     afe:	36 94       	lsr	r3
     b00:	27 94       	ror	r2          ;              [r3,r2]>>=2
     b02:	30 92 7c 00 	sts	0x007C, r3	;  0x80007c
     b06:	20 92 7b 00 	sts	0x007B, r2	;  0x80007b    WORD(0x007B) = [r3,r2] = WORD(0x0073)/4
     b0a:	20 90 75 00 	lds	r2, 0x0075	;  0x800075
     b0e:	30 90 76 00 	lds	r3, 0x0076	;  0x800076    [r3,r2] = WORD(0x0075)
     b12:	36 94       	lsr	r3
     b14:	27 94       	ror	r2
     b16:	36 94       	lsr	r3
     b18:	27 94       	ror	r2          ;              [r3,r2]>>=2
     b1a:	30 92 7e 00 	sts	0x007E, r3	;  0x80007e
     b1e:	20 92 7d 00 	sts	0x007D, r2	;  0x80007d    WORD(0x007D) = [r3,r2] = WORD(0x0075)/4
     b22:	18 c0       	rjmp	.+48     	;  0xb54

     b24:	20 90 73 00 	lds	r2, 0x0073	;  0x800073
     b28:	30 90 74 00 	lds	r3, 0x0074	;  0x800074    [r3,r2] = WORD(0x0073)
     b2c:	36 94       	lsr	r3
     b2e:	27 94       	ror	r2
     b30:	36 94       	lsr	r3
     b32:	27 94       	ror	r2          ;              [r3,r2]>>=2
     b34:	30 92 7c 00 	sts	0x007C, r3	;  0x80007c
     b38:	20 92 7b 00 	sts	0x007B, r2	;  0x80007b    WORD(0x007B) = [r3,r2] = WORD(0x0073)/4
     b3c:	20 90 75 00 	lds	r2, 0x0075	;  0x800075
     b40:	30 90 76 00 	lds	r3, 0x0076	;  0x800076    [r3,r2] = WORD(0x0075)
     b44:	36 94       	lsr	r3
     b46:	27 94       	ror	r2
     b48:	36 94       	lsr	r3
     b4a:	27 94       	ror	r2          ;              [r3,r2]>>=2
     b4c:	30 92 7e 00 	sts	0x007E, r3	;  0x80007e
     b50:	20 92 7d 00 	sts	0x007D, r2	;  0x80007d    WORD(0x007D) = [r3,r2] = WORD(0x0075)/4

     b54:	10 91 83 00 	lds	r17, 0x0083	;  0x800083    
     b58:	00 91 d0 00 	lds	r16, 0x00D0	;  0x8000d0
     b5c:	01 03       	mulsu	r16, r17  ;              [r1,r0] = r16*r17 = BYTE(0x0083)*BYTE(0x00D0)
     b5e:	20 91 84 00 	lds	r18, 0x0084	;  0x800084    BYTE(0x0084)是一个常量,值为20
     b62:	33 27       	eor	r19, r19    ;              [r19,r18] = BYTE(0x0084) = 20
     b64:	80 01       	movw	r16, r0   ;              [r17,r16] = [r1,r0] = BYTE(0x0083)*BYTE(0x00D0)
     b66:	8e d6       	rcall	.+3356   	;  0x1884      [r17,r16] = [r17,r16]/BYTE(0x0084) = BYTE(0x0083)*BYTE(0x00D0)/BYTE(0x0084)   有符号16位除法
     b68:	20 91 c1 00 	lds	r18, 0x00C1	;  0x8000c1
     b6c:	30 91 c2 00 	lds	r19, 0x00C2	;  0x8000c2
     b70:	26 d7       	rcall	.+3660   	;  0x19be      [r17,r16] *= WORD(0x00C1) 16位无符号乘法 
     b72:	a8 01       	movw	r20, r16  ;              [r21,r20] = [r17,r16]
     b74:	20 91 cf 00 	lds	r18, 0x00CF	;  0x8000cf
     b78:	33 27       	eor	r19, r19    ;              [r19,r18] = BYTE(0x00CF)
     b7a:	00 91 bf 00 	lds	r16, 0x00BF	;  0x8000bf
     b7e:	10 91 c0 00 	lds	r17, 0x00C0	;  0x8000c0    [r17,r16] = WORD(0x00BF)
     b82:	1d d7       	rcall	.+3642   	;  0x19be      [r17,r16] *= BYTE(0x00CF) 16位无符号乘法 
     b84:	18 01       	movw	r2, r16   ;              [r3,r2] = [r17,r16] = WORD(0x00BF)*BYTE(0x00CF)
     b86:	22 0c       	add	r2, r2
     b88:	33 1c       	adc	r3, r3      ;              [r3,r2] *= 2
     b8a:	22 0c       	add	r2, r2
     b8c:	33 1c       	adc	r3, r3      ;              [r3,r2] *= 2 ===> [r3,r2] = WORD(0x00BF)*BYTE(0x00CF)*4
     b8e:	42 0d       	add	r20, r2
     b90:	53 1d       	adc	r21, r3     ;              [r21,r20] += WORD(0x00BF)*BYTE(0x00CF)*4
     b92:	a0 90 d4 00 	lds	r10, 0x00D4	;  0x8000d4    r10 = BOOL(0x00D4)
     b96:	22 24       	eor	r2, r2
     b98:	33 24       	eor	r3, r3      ;              [r3,r2] = 0
     b9a:	24 16       	cp	r2, r20
     b9c:	35 06       	cpc	r3, r21
     b9e:	44 f4       	brge	.+16     	;  0xbb0       if 0>=[r21,r20] goto xxxx

     ba0:	96 9a       	sbi	0x12, 6	; 18               PD6 = HIGH // A3950-PHASE = HIGH
     ba2:	50 93 d8 00 	sts	0x00D8, r21	;  0x8000d8
     ba6:	40 93 d7 00 	sts	0x00D7, r20	;  0x8000d7    WORD(0x00D7) = [r21,r20]
     baa:	20 92 d4 00 	sts	0x00D4, r2	;  0x8000d4    BOOL(0x00D4) = FALSE
     bae:	1f c0       	rjmp	.+62     	;  0xbee

     bb0:	40 30       	cpi	r20, 0x00	; 0
     bb2:	e0 e0       	ldi	r30, 0x00	; 0
     bb4:	5e 07       	cpc	r21, r30
     bb6:	7c f4       	brge	.+30     	;  0xbd6       if [r21,r20]>=0 goto xxxxx
     bb8:	82 b3       	in	r24, 0x12	; 18             
     bba:	8f 7b       	andi	r24, 0xBF	; 191
     bbc:	82 bb       	out	0x12, r24	; 18             PD6 = LOW // A3950-PHASE = LOW
     bbe:	22 24       	eor	r2, r2
     bc0:	33 24       	eor	r3, r3      ;              [r3,r2] = 0
     bc2:	24 1a       	sub	r2, r20
     bc4:	35 0a       	sbc	r3, r21     ;              [r3,r2] -= [r21,r20]
     bc6:	30 92 d8 00 	sts	0x00D8, r3	;  0x8000d8
     bca:	20 92 d7 00 	sts	0x00D7, r2	;  0x8000d7    WORD(0x00D7) = [r3,r2] = -[r21,r20]
     bce:	81 e0       	ldi	r24, 0x01	; 1
     bd0:	80 93 d4 00 	sts	0x00D4, r24	;  0x8000d4    BOOL(0x00D4) = TRUE
     bd4:	0c c0       	rjmp	.+24     	;  0xbee

     bd6:	80 e4       	ldi	r24, 0x40	; 64
     bd8:	22 b2       	in	r2, 0x12	; 18
     bda:	28 26       	eor	r2, r24
     bdc:	22 ba       	out	0x12, r2	; 18
     bde:	22 24       	eor	r2, r2
     be0:	33 24       	eor	r3, r3
     be2:	30 92 d8 00 	sts	0x00D8, r3	;  0x8000d8
     be6:	20 92 d7 00 	sts	0x00D7, r2	;  0x8000d7   WORD(0x00D7) = 0
     bea:	3b bc       	out	0x2b, r3	; 43
     bec:	2a bc       	out	0x2a, r2	; 42            OCR1A = 0

     bee:	20 90 d4 00 	lds	r2, 0x00D4	;  0x8000d4   r2 = BOOL(0x00D4)
     bf2:	a2 14       	cp	r10, r2
     bf4:	21 f0       	breq	.+8      	;  0xbfe      if r10==BOOL(0x00D4) goto xxxxxx
     bf6:	22 24       	eor	r2, r2
     bf8:	33 24       	eor	r3, r3
     bfa:	3b bc       	out	0x2b, r3	; 43
     bfc:	2a bc       	out	0x2a, r2	; 42            OCR1A = 0

     bfe:	86 ed       	ldi	r24, 0xD6	; 214
     c00:	93 e0       	ldi	r25, 0x03	; 3             [r25,r24] = 982
     c02:	20 90 d7 00 	lds	r2, 0x00D7	;  0x8000d7
     c06:	30 90 d8 00 	lds	r3, 0x00D8	;  0x8000d8   
     c0a:	82 15       	cp	r24, r2
     c0c:	93 05       	cpc	r25, r3
     c0e:	20 f4       	brcc	.+8      	;  0xc18      if 982>=WORD(0x00D7) goto end
     c10:	90 93 d8 00 	sts	0x00D8, r25	;  0x8000d8   982<WORD(0x00D7) and WORD(0x00D7) = 982
     c14:	80 93 d7 00 	sts	0x00D7, r24	;  0x8000d7   
     c18:	35 c7       	rjmp	.+3690   	;  0x1a84

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;motor_moving_control()
;{
;  if(BOOL(0x00E9)==TRUE && BOOL(0x0106)==TRUE)
;  {//PWM驱动信号处于开启状态 且 1ms时基信号有效
;    BOOL(0x0106) = FALSE
;    WORD(0x00F8) = WORD(0x00F6)
;    WORD(0x00F6) = WORD(0x0101) //舵机当前角度
;    WORD(0x00EA)++
;    WORD(0x00AE)++
;    call_0x7ee()
;    if( (BYTE(0x0098)*20<(WORD(0x00AE)+20)) && (BYTE(0x00B0)<3) )
;    {
;      BYTE(0x00B0) = 3
;    }
;    switch(BYTE(0x00B0))
;    {
;      case 0:
;          BYTE(0x0083) = read_flash_byte(0x0049+BYTE(0x00B0)) //flash(0x0049)对应的值为20
;          call_0x91c()
;          if(WORD(0x00D7)>982)
;          {
;              WORD(0x00D7) = 982
;          }
;          OCR1A =  WORD(0x00D7)
;          if(BYTE(0x0098)*2<WORD(0x00AE))
;          {
;              BYTE(0x00B0) = 1
;          }
;          break
;      case 1:
;          BYTE(0x0083) = read_flash_byte(0x0049+BYTE(0x00B0)) //flash(0x004A)对应的值为20
;          call_0x91c()
;          OCR1A =  WORD(0x00D7)
;          if(BYTE(0x0098)*16<WORD(0x00AE))
;          {
;              BYTE(0x00B0) = 2
;          }
;          break
;      case 2:
;          BYTE(0x0083) = read_flash_byte(0x0049+BYTE(0x00B0)) //flash(0x004B)对应的值为20
;          call_0x91c()
;          OCR1A =  WORD(0x00D7)
;          if(BYTE(0x0098)*18<WORD(0x00AE) && BYTE(0x0098)*20<(WORD(0x00AE)+30))
;          {
;              BYTE(0x00B0) = 3
;              OCR1A /= 3
;          }
;          break
;      case 3:
;          BYTE(0x0083) = read_flash_byte(0x0049+BYTE(0x00B0)) //flash(0x004C)对应的值为20
;          call_0x91c()
;          OCR1A = (WORD(0x00D7)+OCR1A*3)/4
;          if(WORD(0x00AE)>=BYTE(0x0098)*20)
;          {
;              BYTE(0x00B0)++
;          }
;          break
;      case 4: 
;          WORD(0x00D1) = WORD(0x00FD)
;          if(WORD(0x00AE)%50==0)
;          {
;              BYTE(0x0083)++
;          }
;          if(BYTE(0x0083)>20)
;          {
;              BYTE(0x0083) = 20
;          }
;          call_0x91c()
;          OCR1A = WORD(0x00D7) 
;          break
;      default:
;          break
;    }
;    if(BOOL(0x00D4)!=BOOL(0x00FB) && BYTE(0x00B0)<3 )
;    {//当前实际运行方向 和 0x01命令整体转动方向相反
;     //简单说就是电机正在减速转动，处于反向制动状态
;     //为防止电流过大，要降低驱动电压，减小负向角加速度
;        OCR1A /= 3
;    }
;  }
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     c1a:	4a 93       	st	-Y, r20
     c1c:	5a 93       	st	-Y, r21
     c1e:	20 90 e9 00 	lds	r2, 0x00E9	;  0x8000e9     
     c22:	22 20       	and	r2, r2
     c24:	09 f4       	brne	.+2      	;  0xc28         if BOOL(0x00E9)==TRUE goto continue
     c26:	44 c1       	rjmp	.+648    	;  0xeb0         BOOL(0x00E9)==FALSE and return

     c28:	20 90 06 01 	lds	r2, 0x0106	;  0x800106     
     c2c:	22 20       	and	r2, r2
     c2e:	09 f4       	brne	.+2      	;  0xc32         if BOOL(0x0106)==TRUE goto continue
     c30:	3f c1       	rjmp	.+638    	;  0xeb0         BOOL(0x0106)==FALSE and return

     c32:	22 24       	eor	r2, r2
     c34:	20 92 06 01 	sts	0x0106, r2	;  0x800106      BOOL(0x0106) = FALSE
     c38:	20 90 f6 00 	lds	r2, 0x00F6	;  0x8000f6
     c3c:	30 90 f7 00 	lds	r3, 0x00F7	;  0x8000f7      [r3,r2] = WORD(0x00F6)
     c40:	30 92 f9 00 	sts	0x00F9, r3	;  0x8000f9
     c44:	20 92 f8 00 	sts	0x00F8, r2	;  0x8000f8      WORD(0x00F8) = [r3,r2] = WORD(0x00F6)
     c48:	20 90 01 01 	lds	r2, 0x0101	;  0x800101
     c4c:	30 90 02 01 	lds	r3, 0x0102	;  0x800102      [r3,r2] = WORD(0x0101)  //舵机当前角度
     c50:	30 92 f7 00 	sts	0x00F7, r3	;  0x8000f7
     c54:	20 92 f6 00 	sts	0x00F6, r2	;  0x8000f6      WORD(0x00F6) = [r3,r2] = WORD(0x0101) 
     c58:	80 91 ea 00 	lds	r24, 0x00EA	;  0x8000ea
     c5c:	90 91 eb 00 	lds	r25, 0x00EB	;  0x8000eb      [r25,r24] = WORD(0x00EA)
     c60:	01 96       	adiw	r24, 0x01	; 1              [r25,r24] += 1
     c62:	90 93 eb 00 	sts	0x00EB, r25	;  0x8000eb
     c66:	80 93 ea 00 	sts	0x00EA, r24	;  0x8000ea      WORD(0x00EA) = [r25,r24]
     c6a:	80 91 ae 00 	lds	r24, 0x00AE	;  0x8000ae
     c6e:	90 91 af 00 	lds	r25, 0x00AF	;  0x8000af      [r25,r24] = WORD(0x00AE)
     c72:	01 96       	adiw	r24, 0x01	; 1              [r25,r24] += 1
     c74:	90 93 af 00 	sts	0x00AF, r25	;  0x8000af
     c78:	80 93 ae 00 	sts	0x00AE, r24	;  0x8000ae      WORD(0x00AE) = [r25,r24]
     c7c:	b8 dd       	rcall	.-1168   	;  0x7ee         call_0x7ee()
     c7e:	10 91 98 00 	lds	r17, 0x0098	;  0x800098
     c82:	04 e1       	ldi	r16, 0x14	; 20
     c84:	01 03       	mulsu	r16, r17  ;               [r1,r0]  = BYTE(0x0098)*20
     c86:	80 91 ae 00 	lds	r24, 0x00AE	;  0x8000ae
     c8a:	90 91 af 00 	lds	r25, 0x00AF	;  0x8000af     [r25,r24] = WORD(0x00AE)
     c8e:	44 96       	adiw	r24, 0x14	; 20            [r25,r24] += 20
     c90:	08 16       	cp	r0, r24
     c92:	19 06       	cpc	r1, r25
     c94:	38 f4       	brcc	.+14     	;  0xca4        if BYTE(0x0098)*20>=(WORD(0x00AE)+20) goto xxxx
     c96:	80 91 b0 00 	lds	r24, 0x00B0	;  0x8000b0     r24 = BYTE(0x00B0)
     c9a:	83 30       	cpi	r24, 0x03	; 3               
     c9c:	18 f4       	brcc	.+6      	;  0xca4        if BYTE(0x00B0)>=3 goto xxxx
     c9e:	83 e0       	ldi	r24, 0x03	; 3
     ca0:	80 93 b0 00 	sts	0x00B0, r24	;  0x8000b0     if BYTE(0x00B0)<3 then BYTE(0x00B0) = 3

     ca4:	40 91 b0 00 	lds	r20, 0x00B0	;  0x8000b0     r20 = BYTE(0x00B0) 
     ca8:	55 27       	eor	r21, r21    ;               r21 = 0
     caa:	40 30       	cpi	r20, 0x00	; 0
     cac:	45 07       	cpc	r20, r21
     cae:	a9 f0       	breq	.+42     	;  0xcda        if r20==0 goto lbl_case_r20_is_0
     cb0:	41 30       	cpi	r20, 0x01	; 1
     cb2:	e0 e0       	ldi	r30, 0x00	; 0
     cb4:	5e 07       	cpc	r21, r30  ;                 
     cb6:	09 f4       	brne	.+2      	;  0xcba        if [r21,r20]~=1 goto lbl_check_more_case_over_1
     cb8:	3f c0       	rjmp	.+126    	;  0xd38        [r21,r20]==1 goto lbl_case_r20_is_1
lbl_check_more_case_over_1:
     cba:	42 30       	cpi	r20, 0x02	; 2
     cbc:	e0 e0       	ldi	r30, 0x00	; 0
     cbe:	5e 07       	cpc	r21, r30
     cc0:	09 f4       	brne	.+2      	;  0xcc4
     cc2:	5b c0       	rjmp	.+182    	;  0xd7a        if r20==2 goto lbl_case_r20_is_2
     cc4:	43 30       	cpi	r20, 0x03	; 3
     cc6:	e0 e0       	ldi	r30, 0x00	; 0
     cc8:	5e 07       	cpc	r21, r30
     cca:	09 f4       	brne	.+2      	;  0xcce         goto lbl_check_more_case_over_3
     ccc:	8e c0       	rjmp	.+284    	;  0xdea         if r20==2 goto lbl_case_r20_is_3
lbl_check_more_case_over_3:
     cce:	44 30       	cpi	r20, 0x04	; 4
     cd0:	e0 e0       	ldi	r30, 0x00	; 0
     cd2:	5e 07       	cpc	r21, r30
     cd4:	09 f4       	brne	.+2      	;  0xcd8
     cd6:	b6 c0       	rjmp	.+364    	;  0xe44         if r20==2 goto lbl_case_r20_is_4
     cd8:	da c0       	rjmp	.+436    	;  0xe8e         break

lbl_case_r20_is_0:
     cda:	89 e4       	ldi	r24, 0x49	; 73
     cdc:	90 e0       	ldi	r25, 0x00	; 0               [r25,r24] = 0x0049
     cde:	e0 91 b0 00 	lds	r30, 0x00B0	;  0x8000b0     
     ce2:	ff 27       	eor	r31, r31                    Z = BYTE(0x00B0)
     ce4:	e8 0f       	add	r30, r24
     ce6:	f9 1f       	adc	r31, r25                    Z += 0x0049
     ce8:	24 90       	lpm	r2, Z       ;               r2 = read_flash_byte(Z)
     cea:	20 92 83 00 	sts	0x0083, r2	;  0x800083     BYTE(0x0083) = r2 = read_flash_byte(Z) = read_flash_byte(0x0049+BYTE(0x00B0))
     cee:	16 de       	rcall	.-980    	;  0x91c        call_0x91c()
     cf0:	86 ed       	ldi	r24, 0xD6	; 214
     cf2:	93 e0       	ldi	r25, 0x03	; 3               [r25,r24] = 982
     cf4:	20 90 d7 00 	lds	r2, 0x00D7	;  0x8000d7
     cf8:	30 90 d8 00 	lds	r3, 0x00D8	;  0x8000d8     [r3,r2] = WORD(0x00D7)
     cfc:	82 15       	cp	r24, r2
     cfe:	93 05       	cpc	r25, r3   
     d00:	20 f4       	brcc	.+8      	;  0xd0a        if 982>=WORD(0x00D7) goto xxxx

     d02:	90 93 d8 00 	sts	0x00D8, r25	;  0x8000d8
     d06:	80 93 d7 00 	sts	0x00D7, r24	;  0x8000d7     WORD(0x00D7) = 982

     d0a:	20 90 d7 00 	lds	r2, 0x00D7	;  0x8000d7
     d0e:	30 90 d8 00 	lds	r3, 0x00D8	;  0x8000d8    [r3,r2] = WORD(0x00D7)
     d12:	3b bc       	out	0x2b, r3	; 43
     d14:	2a bc       	out	0x2a, r2	; 42             OCR1A =  WORD(0x00D7)
     d16:	20 90 98 00 	lds	r2, 0x0098	;  0x800098
     d1a:	33 24       	eor	r3, r3                     [r3,r2] = BYTE(0x0098)
     d1c:	22 0c       	add	r2, r2      ;              
     d1e:	33 1c       	adc	r3, r3      ;              [r3,r2] *= 2
     d20:	40 90 ae 00 	lds	r4, 0x00AE	;  0x8000ae
     d24:	50 90 af 00 	lds	r5, 0x00AF	;  0x8000af    [r5,r4] = WORD(0x00AE)
     d28:	24 14       	cp	r2, r4
     d2a:	35 04       	cpc	r3, r5
     d2c:	08 f0       	brcs	.+2      	;  0xd30       if BYTE(0x0098)*2<WORD(0x00AE) goto xxxx
     d2e:	af c0       	rjmp	.+350    	;  0xe8e       ; break
     d30:	81 e0       	ldi	r24, 0x01	; 1
     d32:	80 93 b0 00 	sts	0x00B0, r24	;  0x8000b0    ; BYTE(0x00B0) = 1
     d36:	ab c0       	rjmp	.+342    	;  0xe8e       ; break
lbl_case_r20_is_1:
     d38:	89 e4       	ldi	r24, 0x49	; 73
     d3a:	90 e0       	ldi	r25, 0x00	; 0
     d3c:	e0 91 b0 00 	lds	r30, 0x00B0	;  0x8000b0    
     d40:	ff 27       	eor	r31, r31
     d42:	e8 0f       	add	r30, r24
     d44:	f9 1f       	adc	r31, r25
     d46:	24 90       	lpm	r2, Z       ;              
     d48:	20 92 83 00 	sts	0x0083, r2	;  0x800083    BYTE(0x0083) = r2 = read_flash_byte(Z) = read_flash_byte(0x0049+BYTE(0x00B0))
     d4c:	e7 dd       	rcall	.-1074   	;  0x91c       call_0x91c()
     d4e:	20 90 d7 00 	lds	r2, 0x00D7	;  0x8000d7
     d52:	30 90 d8 00 	lds	r3, 0x00D8	;  0x8000d8    [r3,r2] = WORD(0x00D7)
     d56:	3b bc       	out	0x2b, r3	; 43
     d58:	2a bc       	out	0x2a, r2	; 42             OCR1A =  WORD(0x00D7)
     d5a:	10 91 98 00 	lds	r17, 0x0098	;  0x800098
     d5e:	00 e1       	ldi	r16, 0x10	; 16
     d60:	01 03       	mulsu	r16, r17  ;              [r1,r0]  = BYTE(0x0098)*16
     d62:	20 90 ae 00 	lds	r2, 0x00AE	;  0x8000ae
     d66:	30 90 af 00 	lds	r3, 0x00AF	;  0x8000af    [r3,r2]  = WORD(0x00AE)
     d6a:	02 14       	cp	r0, r2
     d6c:	13 04       	cpc	r1, r3
     d6e:	08 f0       	brcs	.+2      	;  0xd72       if BYTE(0x0098)*16<WORD(0x00AE) goto xxxx
     d70:	8e c0       	rjmp	.+284    	;  0xe8e       ; break
     d72:	82 e0       	ldi	r24, 0x02	; 2
     d74:	80 93 b0 00 	sts	0x00B0, r24	;  0x8000b0    BYTE(0x00B0) = 2
     d78:	8a c0       	rjmp	.+276    	;  0xe8e       ; break

lbl_case_r20_is_2:
     d7a:	89 e4       	ldi	r24, 0x49	; 73
     d7c:	90 e0       	ldi	r25, 0x00	; 0
     d7e:	e0 91 b0 00 	lds	r30, 0x00B0	;  0x8000b0
     d82:	ff 27       	eor	r31, r31
     d84:	e8 0f       	add	r30, r24
     d86:	f9 1f       	adc	r31, r25
     d88:	24 90       	lpm	r2, Z
     d8a:	20 92 83 00 	sts	0x0083, r2	;  0x800083    BYTE(0x0083) = r2 = read_flash_byte(Z) = read_flash_byte(0x0049+BYTE(0x00B0))
     d8e:	c6 dd       	rcall	.-1140   	;  0x91c       call_0x91c()
     d90:	20 90 d7 00 	lds	r2, 0x00D7	;  0x8000d7
     d94:	30 90 d8 00 	lds	r3, 0x00D8	;  0x8000d8
     d98:	3b bc       	out	0x2b, r3	; 43
     d9a:	2a bc       	out	0x2a, r2	; 42             OCR1A =  WORD(0x00D7)
     d9c:	40 90 ae 00 	lds	r4, 0x00AE	;  0x8000ae
     da0:	50 90 af 00 	lds	r5, 0x00AF	;  0x8000af    [r5,r4] = WORD(0x00AE)
     da4:	20 90 98 00 	lds	r2, 0x0098	;  0x800098    
     da8:	02 e1       	ldi	r16, 0x12	; 18             r16 = 18
     daa:	12 2d       	mov	r17, r2     ;              r17 = BYTE(0x0098)
     dac:	01 03       	mulsu	r16, r17  ;              [r1,r0] = r16*r17
     dae:	04 14       	cp	r0, r4
     db0:	15 04       	cpc	r1, r5      ;             
     db2:	08 f0       	brcs	.+2      	;  0xdb6       if BYTE(0x0098)*18<WORD(0x00AE) goto xxxx
     db4:	6c c0       	rjmp	.+216    	;  0xe8e       break
     db6:	04 e1       	ldi	r16, 0x14	; 20             r16 = 20
     db8:	01 03       	mulsu	r16, r17  ;              [r1,r0] = 20*BYTE(0x0098)
     dba:	c2 01       	movw	r24, r4   ;              [r25,r24] = [r5,r4]
     dbc:	4e 96       	adiw	r24, 0x1e	; 30           [r25,r24] += 30
     dbe:	08 16       	cp	r0, r24
     dc0:	19 06       	cpc	r1, r25
     dc2:	08 f0       	brcs	.+2      	;  0xdc6       if 20*BYTE(0x0098)<(WORD(0x00AE)+30) goto xxxx
     dc4:	64 c0       	rjmp	.+200    	;  0xe8e       break

     dc6:	83 e0       	ldi	r24, 0x03	; 3
     dc8:	80 93 b0 00 	sts	0x00B0, r24	;  0x8000b0    BYTE(0x00B0) = 3
     dcc:	20 90 d4 00 	lds	r2, 0x00D4	;  0x8000d4    r2 = BYTE(0x00D4)
     dd0:	30 90 fb 00 	lds	r3, 0x00FB	;  0x8000fb    r3 = BYTE(0x00FB)
     dd4:	32 14       	cp	r3, r2
     dd6:	09 f4       	brne	.+2      	;  0xdda       if BYTE(0x00D4)~=BYTE(0x00FB) goto xxx
     dd8:	5a c0       	rjmp	.+180    	;  0xe8e       break
     dda:	23 e0       	ldi	r18, 0x03	; 3
     ddc:	30 e0       	ldi	r19, 0x00	; 0              [r19,r18] = 3
     dde:	0a b5       	in	r16, 0x2a	; 42
     de0:	1b b5       	in	r17, 0x2b	; 43             [r17,r16] = OCR1A
     de2:	6b d5       	rcall	.+2774   	;  0x18ba      [r17,r16] = ([r17, r16]/3) 
     de4:	1b bd       	out	0x2b, r17	; 43
     de6:	0a bd       	out	0x2a, r16	; 42             OCR1A = [r17,r16]
     de8:	52 c0       	rjmp	.+164    	;  0xe8e       break

lbl_case_r20_is_3:
     dea:	89 e4       	ldi	r24, 0x49	; 73
     dec:	90 e0       	ldi	r25, 0x00	; 0
     dee:	e0 91 b0 00 	lds	r30, 0x00B0	;  0x8000b0
     df2:	ff 27       	eor	r31, r31
     df4:	e8 0f       	add	r30, r24
     df6:	f9 1f       	adc	r31, r25
     df8:	24 90       	lpm	r2, Z
     dfa:	20 92 83 00 	sts	0x0083, r2	;  0x800083   BYTE(0x0083) = r2 = read_flash_byte(Z) = read_flash_byte(0x0049+BYTE(0x00B0))
     dfe:	8e dd       	rcall	.-1252   	;  0x91c      call_0x91c()
     e00:	2a b5       	in	r18, 0x2a	; 42
     e02:	3b b5       	in	r19, 0x2b	; 43            [r19,r18] = OCR1A
     e04:	03 e0       	ldi	r16, 0x03	; 3
     e06:	10 e0       	ldi	r17, 0x00	; 0             [r17,r16] = 3
     e08:	da d5       	rcall	.+2996   	;  0x19be     [r17,r16] = OCR1A*3  16位无符号乘法 
     e0a:	20 90 d7 00 	lds	r2, 0x00D7	;  0x8000d7
     e0e:	30 90 d8 00 	lds	r3, 0x00D8	;  0x8000d8   [r3,r2] = WORD(0x00D7)
     e12:	20 0e       	add	r2, r16
     e14:	31 1e       	adc	r3, r17     ;             [r3,r2] += OCR1A*3
     e16:	36 94       	lsr	r3
     e18:	27 94       	ror	r2          ;             [r3,r2] >>= 1
     e1a:	36 94       	lsr	r3
     e1c:	27 94       	ror	r2          ;             [r3,r2] >>= 1
     e1e:	3b bc       	out	0x2b, r3	; 43
     e20:	2a bc       	out	0x2a, r2	; 42            OCR1A = [r3,r2] = (WORD(0x00D7)+OCR1A*3)/4
     e22:	10 91 98 00 	lds	r17, 0x0098	;  0x800098
     e26:	04 e1       	ldi	r16, 0x14	; 20
     e28:	01 03       	mulsu	r16, r17  ;             [r1,r0] = BYTE(0x0098)*20
     e2a:	20 90 ae 00 	lds	r2, 0x00AE	;  0x8000ae
     e2e:	30 90 af 00 	lds	r3, 0x00AF	;  0x8000af   [r3,r2] = WORD(0x00AE)
     e32:	20 14       	cp	r2, r0
     e34:	31 04       	cpc	r3, r1
     e36:	58 f1       	brcs	.+86     	;  0xe8e      if WORD(0x00AE)<BYTE(0x0098)*20 goto break
     e38:	80 91 b0 00 	lds	r24, 0x00B0	;  0x8000b0
     e3c:	8f 5f       	subi	r24, 0xFF	; 255
     e3e:	80 93 b0 00 	sts	0x00B0, r24	;  0x8000b0   BYTE(0x00B0)++
     e42:	25 c0       	rjmp	.+74     	;  0xe8e      break

lbl_case_r20_is_4:
     e44:	20 90 fd 00 	lds	r2, 0x00FD	;  0x8000fd
     e48:	30 90 fe 00 	lds	r3, 0x00FE	;  0x8000fe
     e4c:	30 92 d2 00 	sts	0x00D2, r3	;  0x8000d2
     e50:	20 92 d1 00 	sts	0x00D1, r2	;  0x8000d1    WORD(0x00D1) = WORD(0x00FD)
     e54:	22 e3       	ldi	r18, 0x32	; 50
     e56:	30 e0       	ldi	r19, 0x00	; 0             [r19,r18] = 50
     e58:	00 91 ae 00 	lds	r16, 0x00AE	;  0x8000ae
     e5c:	10 91 af 00 	lds	r17, 0x00AF	;  0x8000af   [r17,r16] = WORD(0x00AE)
     e60:	2a d5       	rcall	.+2644   	;  0x18b6     [r17,r16] = [r17,r16]%50   ;16位无符号取余
     e62:	00 30       	cpi	r16, 0x00	; 0
     e64:	01 07       	cpc	r16, r17
     e66:	29 f4       	brne	.+10     	;  0xe72      if [r17,r16]~=0 goto xxxx
     e68:	80 91 83 00 	lds	r24, 0x0083	;  0x800083
     e6c:	8f 5f       	subi	r24, 0xFF	; 255
     e6e:	80 93 83 00 	sts	0x0083, r24	;  0x800083    BYTE(0x0083)++

     e72:	84 e1       	ldi	r24, 0x14	; 20              r24 = 20
     e74:	20 90 83 00 	lds	r2, 0x0083	;  0x800083     r2 = BYTE(0x0083)
     e78:	82 15       	cp	r24, r2
     e7a:	10 f4       	brcc	.+4      	;  0xe80        if 20>=BYTE(0x0083) goto xxxx
     e7c:	80 93 83 00 	sts	0x0083, r24	;  0x800083     BYTE(0x0083)>20 and BYTE(0x0083)=20
     e80:	4d dd       	rcall	.-1382   	;  0x91c        call_0x91c()
     e82:	20 90 d7 00 	lds	r2, 0x00D7	;  0x8000d7
     e86:	30 90 d8 00 	lds	r3, 0x00D8	;  0x8000d8    
     e8a:	3b bc       	out	0x2b, r3	; 43
     e8c:	2a bc       	out	0x2a, r2	; 42              OCR1A = WORD(0x00D7) 
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     e8e:	20 90 d4 00 	lds	r2, 0x00D4	;  0x8000d4     r2 = BOOL(0x00D4)
     e92:	30 90 fb 00 	lds	r3, 0x00FB	;  0x8000fb     r3 = BOOL(0x00FB)
     e96:	32 14       	cp	r3, r2
     e98:	59 f0       	breq	.+22     	;  0xeb0        if BOOL(0x00D4)==BOOL(0x00FB) goto end
     e9a:	80 91 b0 00 	lds	r24, 0x00B0	;  0x8000b0     
     e9e:	83 30       	cpi	r24, 0x03	; 3
     ea0:	38 f4       	brcc	.+14     	;  0xeb0        if BYTE(0x00B0)>=3 goto end
     ea2:	23 e0       	ldi	r18, 0x03	; 3
     ea4:	30 e0       	ldi	r19, 0x00	; 0               [r19,r18] = 3
     ea6:	0a b5       	in	r16, 0x2a	; 42              
     ea8:	1b b5       	in	r17, 0x2b	; 43              [r17,r16] = OCR1A
     eaa:	07 d5       	rcall	.+2574   	;  0x18ba       [r17,r16] = ([r17, r16]/3) 
     eac:	1b bd       	out	0x2b, r17	; 43
     eae:	0a bd       	out	0x2a, r16	; 42              OCR1A = OCR1A/3
     eb0:	59 91       	ld	r21, Y+
     eb2:	49 91       	ld	r20, Y+
     eb4:	08 95       	ret

0xeb6_init_Timer0():
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ; F_CPU       = 14.7456MHz
     ; CLK_T0      = F_CPU/8       = 1.8432MHz
     ; Tick        = 256 - 72      = 184
     ; F_T0_OV_ISR = CLK_T0/Tick   = 0.01MHZ   = 10KHz
     ; ISR_iterval = 1/F_T0_OV_ISR = 100uS 
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     eb6:	22 24       	eor	r2, r2    ;
     eb8:	23 be       	out	0x33, r2	; 51   TCCR0 = 0x00 
     eba:	88 e4       	ldi	r24, 0x48	; 72   
     ebc:	82 bf       	out	0x32, r24	; 50   TCNT0 = 0x48 = 72
     ebe:	82 e0       	ldi	r24, 0x02	; 2    
     ec0:	83 bf       	out	0x33, r24	; 51   TCCR0 = 0x02 ===> [CS02 CS01 CS00] = 0x02 ===> CLK_io/8 (From prescaler)
     ec2:	89 b7       	in	r24, 0x39	; 57   
     ec4:	81 60       	ori	r24, 0x01	; 1
     ec6:	89 bf       	out	0x39, r24	; 57   TIMSK |= 0x01 ===> Timer/Counter0 Overflow Interrupt Enable
     ec8:	08 95       	ret

0xeca_init_Timer1():
     eca:	22 24       	eor	r2, r2
     ecc:	2e bc       	out	0x2e, r2	; 46
     ece:	8c ef       	ldi	r24, 0xFC	; 252
     ed0:	8d bd       	out	0x2d, r24	; 45    TCNT1H = 0xFC
     ed2:	8a e2       	ldi	r24, 0x2A	; 42
     ed4:	8c bd       	out	0x2c, r24	; 44    TCNT1L = 0x2A  ===> TCNT1 = 0xFC2A 
     ed6:	2b bc       	out	0x2b, r2	; 43
     ed8:	2a bc       	out	0x2a, r2	; 42    OCR1A  = 0x0000
     eda:	83 e0       	ldi	r24, 0x03	; 3
     edc:	89 bd       	out	0x29, r24	; 41    OCR1BH = 0x03
     ede:	86 ed       	ldi	r24, 0xD6	; 214
     ee0:	88 bd       	out	0x28, r24	; 40    OCR1BL = 0xD6  ===>  OCR1B = 0x03D6
     ee2:	83 e0       	ldi	r24, 0x03	; 3
     ee4:	87 bd       	out	0x27, r24	; 39    ICR1H  = 0x03
     ee6:	86 ed       	ldi	r24, 0xD6	; 214
     ee8:	86 bd       	out	0x26, r24	; 38    ICR1L  = 0xD6  ===> ICR1 = 0x03D6
     eea:	08 95       	ret

0xeec_T0_OVF_ISR():
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;{//根据Timer0的初始化代码分析可知: ISR的定时间隔为100uS
;    TCNT0 = 72           //计数器重装初值
;    BOOL(0x0105) = TRUE  //这个变量没什么用
;    if(BOOL(0x0060)==TRUE)
;    {//ADC采样结束
;        BOOL(0x0060) = FALSE //
;        ADCSRA = 0xCC        //再次启动AD采样
;    }
;    //处理定时
;    BYTE(0x0107)++
;    BYTE(0x0061)++
;    if(BYTE(0x0061)>2)
;    {//300uS间隔
;        BYTE(0x0061) = 0
;        BYTE(0x0170) = 0 //RX ISR中用到的全局变量
;        BYTE(0x0089) = 0 //在这里给人家清零,不知道搞什么名堂
;    }
;    if(BYTE(0x0107)>10)
;    {//1100uS间隔 (是不是写错了?难道不应该是1000uS?)
;        BOOL(0x0106) = TRUE
;        BOOL(0x0104) = TRUE
;        WORD(0x0085) ++
;        //下面的代码折腾着玩儿,没鸟用
;        if(WORD(0x0087)<WORD(0x0085))
;        {
;            WORD(0x0085) = 0
;            BYTE(0x0103) = (BYTE(0x0103)+1)&0x07
;            xxxx
;        }
;    }
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     eec:	2a 92       	st	-Y, r2
     eee:	3a 92       	st	-Y, r3
     ef0:	4a 92       	st	-Y, r4
     ef2:	5a 92       	st	-Y, r5
     ef4:	8a 93       	st	-Y, r24
     ef6:	9a 93       	st	-Y, r25
     ef8:	2f b6       	in	r2, 0x3f	; 63
     efa:	2a 92       	st	-Y, r2
     efc:	88 e4       	ldi	r24, 0x48	; 72
     efe:	82 bf       	out	0x32, r24	; 50  TCNT0 = 72 ; T0 计数器重装初值
     f00:	81 e0       	ldi	r24, 0x01	; 1
     f02:	80 93 05 01 	sts	0x0105, r24	;  0x800105       BOOL(0x0105) = TRUE
     f06:	20 90 60 00 	lds	r2, 0x0060	;  0x800060       
     f0a:	22 20       	and	r2, r2                        
     f0c:	29 f0       	breq	.+10     	;  0xf18          if BOOL(0x0060)==FALSE goto xxxx
     f0e:	22 24       	eor	r2, r2
     f10:	20 92 60 00 	sts	0x0060, r2	;  0x800060       BOOL(0x0060)=FALSE
     f14:	8c ec       	ldi	r24, 0xCC	; 204
     f16:	86 b9       	out	0x06, r24	; 6                 ADCSRA = 0xCC 


     f18:	80 91 07 01 	lds	r24, 0x0107	;  0x800107
     f1c:	8f 5f       	subi	r24, 0xFF	; 255
     f1e:	80 93 07 01 	sts	0x0107, r24	;  0x800107       BYTE(0x0107)++
     f22:	80 91 61 00 	lds	r24, 0x0061	;  0x800061
     f26:	8f 5f       	subi	r24, 0xFF	; 255
     f28:	80 93 61 00 	sts	0x0061, r24	;  0x800061       BYTE(0x0061)++
     f2c:	82 e0       	ldi	r24, 0x02	; 2
     f2e:	20 90 61 00 	lds	r2, 0x0061	;  0x800061
     f32:	82 15       	cp	r24, r2
     f34:	38 f4       	brcc	.+14     	;  0xf44          if 2>=BYTE(0x0061) goto lbl_T0_1ms_tick_check
     f36:	22 24       	eor	r2, r2      ;                 BYTE(0x0061)>2 then r2 = 0 
     f38:	20 92 61 00 	sts	0x0061, r2	;  0x800061       BYTE(0x0061) = 0
     f3c:	20 92 70 01 	sts	0x0170, r2	;  0x800170       BYTE(0x0170) = 0
     f40:	20 92 89 00 	sts	0x0089, r2	;  0x800089       BYTE(0x0089) = 0
lbl_T0_1ms_tick_check:
     f44:	8a e0       	ldi	r24, 0x0A	; 10                r24 = 10
     f46:	20 90 07 01 	lds	r2, 0x0107	;  0x800107       r2  = BYTE(0x0107)
     f4a:	82 15       	cp	r24, r2
     f4c:	90 f5       	brcc	.+100    	;  0xfb2          if 10>=BYTE(0x0107) goto lbl_t0_isr_return
     f4e:	22 24       	eor	r2, r2
     f50:	20 92 07 01 	sts	0x0107, r2	;  0x800107       BYTE(0x0107)>10 then BYTE(0x0107)=0
     f54:	81 e0       	ldi	r24, 0x01	; 1
     f56:	80 93 06 01 	sts	0x0106, r24	;  0x800106       BOOL(0x0106) = TRUE  1ms
     f5a:	80 93 04 01 	sts	0x0104, r24	;  0x800104       BOOL(0x0104) = TRUE  1ms
     f5e:	80 91 85 00 	lds	r24, 0x0085	;  0x800085
     f62:	90 91 86 00 	lds	r25, 0x0086	;  0x800086       [r25,r24] = WORD(0x0085)
     f66:	01 96       	adiw	r24, 0x01	; 1               [r25,r24] += 1
     f68:	2c 01       	movw	r4, r24   ;                 [r5,r4] = [r25,r24]
     f6a:	50 92 86 00 	sts	0x0086, r5	;  0x800086
     f6e:	40 92 85 00 	sts	0x0085, r4	;  0x800085       WORD(0x0085) ++
     f72:	20 90 87 00 	lds	r2, 0x0087	;  0x800087
     f76:	30 90 88 00 	lds	r3, 0x0088	;  0x800088       [r3,r2] = WORD(0x0087)
     f7a:	28 16       	cp	r2, r24
     f7c:	39 06       	cpc	r3, r25
     f7e:	c8 f4       	brcc	.+50     	;  0xfb2          if WORD(0x0087)>=WORD(0x0085) goto lbl_t0_isr_return
     f80:	22 24       	eor	r2, r2
     f82:	33 24       	eor	r3, r3
     f84:	30 92 86 00 	sts	0x0086, r3	;  0x800086
     f88:	20 92 85 00 	sts	0x0085, r2	;  0x800085       WORD(0x0085) = 0
     f8c:	80 91 03 01 	lds	r24, 0x0103	;  0x800103       
     f90:	8f 5f       	subi	r24, 0xFF	; 255             r24 = BYTE(0x0103)+1
     f92:	80 93 03 01 	sts	0x0103, r24	;  0x800103       BYTE(0x0103) = r24
     f96:	87 70       	andi	r24, 0x07	; 7
     f98:	80 93 03 01 	sts	0x0103, r24	;  0x800103       BYTE(0x0103) = (BYTE(0x0103)+1)&0x07
     f9c:	88 b3       	in	r24, 0x18	; 24
     f9e:	87 7c       	andi	r24, 0xC7	; 199
     fa0:	88 bb       	out	0x18, r24	; 24
     fa2:	20 90 03 01 	lds	r2, 0x0103	;  0x800103
     fa6:	22 0c       	add	r2, r2
     fa8:	22 0c       	add	r2, r2
     faa:	22 0c       	add	r2, r2
     fac:	38 b2       	in	r3, 0x18	; 24
     fae:	32 28       	or	r3, r2
     fb0:	38 ba       	out	0x18, r3	; 24
lbl_t0_isr_return:
     fb2:	29 90       	ld	r2, Y+
     fb4:	2f be       	out	0x3f, r2	; 63
     fb6:	99 91       	ld	r25, Y+
     fb8:	89 91       	ld	r24, Y+
     fba:	59 90       	ld	r5, Y+
     fbc:	49 90       	ld	r4, Y+
     fbe:	39 90       	ld	r3, Y+
     fc0:	29 90       	ld	r2, Y+
     fc2:	18 95       	reti

0xfc4_delay_us(n):
     fc4:	01 c0       	rjmp	.+2      	;  0xfc8
     fc6:	0a 95       	dec	r16
     fc8:	80 e0       	ldi	r24, 0x00	; 0
     fca:	80 17       	cp	r24, r16
     fcc:	e0 f3       	brcs	.-8      	;  0xfc6
     fce:	08 95       	ret

0xfd0_calculate_checksum(BYTE* adr): // adr=[r17, r16]   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BYTE calculate_checksum(BYTE* adr)
;{
;    BYTE chksum = 0
;    for(i=0;i<6;i++)
;    {
;       chksum += adr[i]
;    }
;    return chksum
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     fd0:	aa 92       	st	-Y, r10
     fd2:	4a 93       	st	-Y, r20
     fd4:	aa 24       	eor	r10, r10    ; r10 = 0, checksum
     fd6:	44 27       	eor	r20, r20    ; r20 = 0
     fd8:	07 c0       	rjmp	.+14     	;  0xfe8
lbl_calculate_checksum_loop:
     fda:	e4 2f       	mov	r30, r20    ; 
     fdc:	ff 27       	eor	r31, r31    ; Z = r20
     fde:	e0 0f       	add	r30, r16    ; 
     fe0:	f1 1f       	adc	r31, r17    ; Z += [r17,r16]
     fe2:	20 80       	ld	r2, Z       ; r2 = *Z
     fe4:	a2 0c       	add	r10, r2     ; r10 += *Z
     fe6:	43 95       	inc	r20         ; r20++
     fe8:	46 30       	cpi	r20, 0x06	; 6
     fea:	b8 f3       	brcs	.-18     	; if r20<6, goto lbl_calculate_checksum_loop
     fec:	0a 2d       	mov	r16, r10
     fee:	49 91       	ld	r20, Y+
     ff0:	a9 90       	ld	r10, Y+
     ff2:	08 95       	ret

0xff4_check_and_parse_command():
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  舵机命令解析伪代码注释
;if(BOOL(0x016D)==TRUE && BOOL(0x008A)==TRUE) //上次角度运动操作已经执行完成 且 有新的命令需要解析处理
;{
;    BOOL(0x008A) = FALSE
;    for(i=0;i<10;i++)
;    {
;        BYTE_ARRAY(0x014D)[i] = BYTE_ARRAY(0x0109)[i]
;    }
;    // BA <===> BYTE_ARRAY
;    if(BA(0x014D)[0]==0xFA && BA(0x014D)[1]==0xAF && BA(0x014D)[9]==0xED)
;    {
;        if(servoID==BA(0x014D)[2] || 0x00==BA(0x014D)[2])
;        {//舵机ID匹配 或者 广播模式
;            if(BA(0x014D)[8]~=calculate_checksum(&BA(0x014D)[2]))
;            {
;               return //校验出错 直接返回
;            }
;            //6字节校验和正确
;            disable_RX_gate() //关断RXD三态门
;            enable_TX_gate()  //开启TXD三态门
;                
;            if(BA(0x014D)[3]==0xC8)
;            {//0xC8命令
;                //这个命令没啥鸟用 参见 lbl_do_cmd_0xC8_xxxxx
;            }
;            else if(BA(0x014D)[3]<0xC8)
;            {//命令码的值小于 0xC8
;                if(BA(0x014D)[3]==0x01)
;                {//指定时间运动指令
;                    if(BA(0x014D)[4]>252)
;                    {
;                         0x1872_TX_send_byte(servoID+0xAA) // 向主机发送 OK-ACK 
;                         if(BA(0x014D)[4]==253)
;                         {
;                              PD6 = LOW // A3950-PHASE = LOW // A3950-PHASE = LOW
;                              0x3fc_PWM_start_stop(TRUE)
;                              OCR1A = 0x00F5 // 245
;                         }
;                         else if(BA(0x014D)[4]==254)
;                         {
;                              PD6 = HIGH // A3950-PHASE = HIGH
;                              0x3fc_PWM_start_stop(TRUE)
;                              OCR1A = 0x00F5 // 245
;                         }
;                         else
;                         {
;                              OCR1A = 0
;                              0x3fc_PWM_start_stop(FALSE)
;                         }
;                    }
;                    else
;                    {
;                         0x1872_TX_send_byte(servoID+0xAA)//向主机发送 OK-ACK 
;                         //取2字节宽度运动时间数据，保存在RAM中
;                         WORD(0x016E)   = BA(0x014D)[6]
;                         WORD(0x016E) <<= 8
;                         WORD(0x016E)  += BA(0x014D)[7]
;                         WORD(0x016E)  *= 18
;                         if(BOOL(0x016D)==TRUE)
;                         {   //BA(0x014D)[5] - 运动时间（格式 单位 暂未知）
;                             //BA(0x014D)[4] - 目标位置（格式 单位 暂未知）
;                             call_func_0x444(BA(0x014D)[5], BA(0x014D)[4])
;                             BOOL(0x016D) = FALSE
;                         }
;                    }
;                }
;                else if(BA(0x014D)[3]==0x02)
;                {//角度回读(舵机失电指令)
;                    TX_BUF[0] = 0xFA
;                    TX_BUF[1] = 0xAF
;                    TX_BUF[2] = servoID
;                    TX_BUF[3] = 0xAA
;
;                    tmp = (WORD(0x00FD)-180-WORD(0x0129))/3    //TX_BUF[4] TX_BUF[5] 分别为 "目标角度高字节" 、 "目标角度低字节"
;                    TX_BUF[4] = HI_BYTE(tmp)
;                    TX_BUF[5] = LOW_BYTE(tmp)
;                    
;                    tmp = WORD(0x0101)-180-WORD(0x0129)        //TX_BUF[6] TX_BUF[7] 分别为 "实际角度高字节" 、 "实际角度低字节"
;                    if(tmp>0xFF00)
;                     tmp = 0
;                    tmp /= 3
;                    if(tmp>180)
;                     tmp = 180
;                    TX_BUF[6] = HI_BYTE(tmp)
;                    TX_BUF[7] = LOW_BYTE(tmp)
;
;                    TX_BUF[8] = calculate_checksum(&TX_BUF[2])
;                    TX_BUF[9] = 0xED
;                    for(i=0;i<10;i++)
;                    {
;                        0x1872_TX_send_byte(TX_BUF[i])
;                    }
;                    0x3fc_PWM_start_stop(FALSE)
;                }
;            }
;            else if(BA(0x014D)[3]==0xCD)
;            {//修改舵机ID
;               TX_BUF[0] = 0xFA
;               TX_BUF[1] = 0xAF
;               0x130_write_eeprom(&BA(0x014D)[5], eeadr=0x000A, size=1) 将新的servoID存入EEPROM中 （EEPROM地址0x000A）
;               TX_BUF[5] = servoID //修改前的舵机ID
;               //注意 ACK中的舵机ID是修改后的ID 而 不是修改前的ID
;               0xf4_read_eeprom(&TX_BUF[2], eeadr=0x000A, size=1) 读出刚存入的舵机ID到 TX_BUF[2] 中
;               servoID = TX_BUF[2]
;               TX_BUF[3] = 0xAA
;               TX_BUF[4] = 0x00
;               TX_BUF[6] = 0x00
;               TX_BUF[7] = 0x00
;               TX_BUF[8] = 0xfd0_calculate_checksum(&TX_BUF[2])
;               TX_BUF[9] = 0xED
;               for(i=0;i<10;i++)
;               {
;                   0x1872_TX_send_byte(TX_BUF[i])
;               }
;            }
;            else if(BA(0x014D)[3]==0xD1)
;            {//这个命令代码中仅仅是回应一个ACK 没有其他任何操作 应该是个保留命令
;                TX_BUF[0] = 0xFA
;                TX_BUF[1] = 0xAF
;                TX_BUF[2] = servoID
;                TX_BUF[3] = 0xAA
;                TX_BUF[5] = 0   //你没看错，代码中就是没有填写 TX_BUF[4]
;                TX_BUF[6] = 0
;                TX_BUF[7] = 0
;                TX_BUF[8] = calculate_checksum(&TX_BUF[2])
;                TX_BUF[9] = 0xED
;                for(i=0;i<10;i++)
;                {
;                    0x1872_TX_send_byte(TX_BUF[i])
;                }
;            }
;            else if(BA(0x014D)[3]==0xD2)
;            {//设置舵机角度校正值
;               TX_BUF[0] = 0xFA
;               TX_BUF[1] = 0xAF
;               TX_BUF[2] = servoID
;               TX_BUF[3] = 0xAA
;               TX_BUF[4] = 0
;               TX_BUF[5] = 0
;               TX_BUF[6] = 0
;               TX_BUF[7] = 0
;               TX_BUF[8] = 0xfd0_calculate_checksum(&TX_BUF[2])
;               TX_BUF[9] = 0xED
;               for(i=0;i<10;i++)
;               {
;                    0x1872_TX_send_byte(TX_BUF[i])
;               }
;               //保存向前偏移校正
;               WORD(0x012B)   = BA(0x014D)[4]  //WORD(0x012B)是一个有符号16位整数变量，所以 BA(0x014D)[4~5] 要保持一致，只不过是大端模式传输
;               WORD(0x012B) <<= 8
;               WORD(0x012B)  += BA(0x014D)[5]  
;               //保存向后偏移校正
;               WORD(0x0129)   = BA(0x014D)[6]  //WORD(0x0129)和WORD(0x012B)情况类似
;               WORD(0x0129) <<= 8
;               WORD(0x0129)  += BA(0x014D)[7] 
;               //校正值存入EEPROM 注意是大端存储
;               //EEPROM(0x0018, 0x0019)  <==> WORD(0x012B) 
;               //EEPROM(0x001A, 0x001B)  <==> WORD(0x0129) 
;               0x130_write_eeprom(&BA(0x014D)[4], 0x0018, 4)
;            }
;            else if(BA(0x014D)[3]==0xD3)
;            {//这个命令读取并返回某个EEPROM字节的存储值，地址是 0x0017 这个值应该没什么用处，代码中并没有使用这个值
;               TX_BUF[0] = 0xFA
;               TX_BUF[1] = 0xAF
;               TX_BUF[2] = servoID
;               TX_BUF[3] = 0xAA
;               0xf4_read_eeprom(&TX_BUF[4], eeadr=0x0017, size=1)  //将EEPROM地址0x0017处的字节数值存入 TX_BUF[4]
;               TX_BUF[5] = 0
;               TX_BUF[6] = 0
;               TX_BUF[7] = 0
;               TX_BUF[8] = 0xfd0_calculate_checksum(&TX_BUF[2])
;               TX_BUF[9] = 0xED
;               for(i=0;i<10;i++)
;               {
;                   0x1872_TX_send_byte(TX_BUF[i])
;               }
;            }
;            else if(BA(0x014D)[3]==0xD4)
;            {//读取舵机角度校正值
;               TX_BUF[0] = 0xFA
;               TX_BUF[1] = 0xAF
;               TX_BUF[2] = servoID
;               TX_BUF[3] = 0xAA
;               //向前偏移校正高字节
;               TX_BUF[4] = LOW_BYTE(WORD(0x012B)/256)     //WORD(0x012B)是16位有符号整数
;               //向前偏移校正低字节
;               TX_BUF[5] = LOW_BYTE(WORD(0x012B)%256)
;               //向后偏移校正高字节
;               TX_BUF[6] = LOW_BYTE(WORD(0x0129)/256)    //WORD(0x0129)是16位有符号整数
;               //向后偏移校正低字节
;               TX_BUF[7] = LOW_BYTE(WORD(0x0129)%256)
;               TX_BUF[8] = calculate_checksum(&TX_BUF[2])
;               TX_BUF[9] = 0xED
;               for(i=0;i<10;i++)
;               {
;                   0x1872_TX_send_byte(TX_BUF[i])
;               }
;            }
;        }
;        //命令执行完成 重新监听总线
;        disable_TX_gate() //关断TXD三态门
;        enable_RX_gate()  //开启RXD三态门
;    }
;    else if(BA(0x014D)[0]==0xFC && BA(0x014D)[1]==0xCF)
;    {
;        
;    }
;}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ff4:	40 d5       	rcall	.+2688   	;  0x1a76  stack push
     ff6:	22 97       	sbiw	r28, 0x02	; 2        local WORD x
     ff8:	20 90 6d 01 	lds	r2, 0x016D	;  0x80016d
     ffc:	22 20       	and	r2, r2
     ffe:	09 f4       	brne	.+2      	;  0x1002   if BOOL(0x016D)==TRUE
    1000:	89 c3       	rjmp	.+1810   	;  0x1714   goto END
    1002:	20 90 8a 00 	lds	r2, 0x008A	;  0x80008a
    1006:	22 20       	and	r2, r2
    1008:	09 f4       	brne	.+2      	;  0x100c   if BOOL(0x008A)==TRUE
    100a:	84 c3       	rjmp	.+1800   	;  0x1714   goto END
    100c:	22 24       	eor	r2, r2
    100e:	20 92 8a 00 	sts	0x008A, r2	;  0x80008a BOOL(0x008A) = FALSE
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; copy 10 bytes from RAM(0x0109~0x112) to RAM(0x014D~0x156)
    1012:	44 27       	eor	r20, r20    ;  r20 = 0
    1014:	0f c0       	rjmp	.+30     	;  0x1034
    1016:	89 e0       	ldi	r24, 0x09	; 9
    1018:	91 e0       	ldi	r25, 0x01	; 1  [r25,r24] = 0x0109
    101a:	e4 2f       	mov	r30, r20
    101c:	ff 27       	eor	r31, r31       Z = r20
    101e:	e8 0f       	add	r30, r24
    1020:	f9 1f       	adc	r31, r25       Z+= [r25,r24]
    1022:	20 80       	ld	r2, Z          r2 = *Z = *(BYTE*)(0x0109+r20)
    1024:	8d e4       	ldi	r24, 0x4D	; 77
    1026:	91 e0       	ldi	r25, 0x01	; 1  [r25,r24] = 0x014D
    1028:	e4 2f       	mov	r30, r20
    102a:	ff 27       	eor	r31, r31       Z = r20
    102c:	e8 0f       	add	r30, r24
    102e:	f9 1f       	adc	r31, r25       Z+= [r25,r24] 
    1030:	20 82       	st	Z, r2          *Z = r2 ===> *(BYTE*)(0x014D+r20) = r2
    1032:	43 95       	inc	r20            r20++
    1034:	4a 30       	cpi	r20, 0x0A	; 10 
    1036:	78 f3       	brcs	.-34     	;  0x1016  if r20<10
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    1038:	80 91 4d 01 	lds	r24, 0x014D	;  0x80014d
    103c:	8a 3f       	cpi	r24, 0xFA	; 250
    103e:	09 f0       	breq	.+2      	;  0x1042   if BYTE0==0xFA
    1040:	f7 c2       	rjmp	.+1518   	;  0x1630   goto lbl_check_frame_header_0xFC
    1042:	80 91 4e 01 	lds	r24, 0x014E	;  0x80014e 
    1046:	8f 3a       	cpi	r24, 0xAF	; 175
    1048:	09 f0       	breq	.+2      	;  0x104c   if BYTE1==0xAF
    104a:	f2 c2       	rjmp	.+1508   	;  0x1630   goto lbl_check_frame_header_0xFC
    104c:	80 91 56 01 	lds	r24, 0x0156	;  0x800156
    1050:	8d 3e       	cpi	r24, 0xED	; 237
    1052:	09 f0       	breq	.+2      	;  0x1056   if BYTE9==0xED
    1054:	ed c2       	rjmp	.+1498   	;  0x1630   goto lbl_check_frame_header_0xFC
    1056:	20 90 97 00 	lds	r2, 0x0097	;  0x800097
    105a:	30 90 4f 01 	lds	r3, 0x014F	;  0x80014f
    105e:	32 14       	cp	r3, r2
    1060:	19 f0       	breq	.+6      	;  0x1068   if servoID==BYTE2
    1062:	33 20       	and	r3, r3
    1064:	09 f0       	breq	.+2      	;  0x1068   if BYTE2==0x00
    1066:	56 c3       	rjmp	.+1708   	;  0x1714   goto END
    1068:	0f e4       	ldi	r16, 0x4F	; 79
    106a:	11 e0       	ldi	r17, 0x01	; 1
    106c:	b1 df       	rcall	.-158    	;           r16 = 0xfd0_calculate_checksum(ADDR(BYTE2))
    106e:	20 90 55 01 	lds	r2, 0x0155	;  0x800155
    1072:	02 15       	cp	r16, r2
    1074:	09 f0       	breq	.+2      	;  0x1078   if BYTE8==r16 
    1076:	4e c3       	rjmp	.+1692   	;  0x1714   goto END
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    1078:	93 9a       	sbi	0x12, 3	; 18            set PD3 high ===> disable RX gate
    107a:	82 b3       	in	r24, 0x12	; 18
    107c:	8b 7f       	andi	r24, 0xFB	; 251       set PD2 low  ===> enable TX gate
    107e:	82 bb       	out	0x12, r24	; 18
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    1080:	60 91 50 01 	lds	r22, 0x0150	;  0x800150
    1084:	77 27       	eor	r23, r23
    1086:	68 3c       	cpi	r22, 0xC8	; 200
    1088:	e0 e0       	ldi	r30, 0x00	; 0
    108a:	7e 07       	cpc	r23, r30
    108c:	09 f4       	brne	.+2      	;  0x1090    if BYTE3~=0xC8
    108e:	f4 c0       	rjmp	.+488    	;  0x1278    BYTE3==0xC8 and goto lbl_do_cmd_0xC8_xxxxx
    1090:	88 ec       	ldi	r24, 0xC8	; 200
    1092:	90 e0       	ldi	r25, 0x00	; 0
    1094:	86 17       	cp	r24, r22
    1096:	97 07       	cpc	r25, r23
    1098:	54 f0       	brlt	.+20     	;  0x10ae    if BYTE3>0xC8 goto XXXXXX
    109a:	61 30       	cpi	r22, 0x01	; 1
    109c:	e0 e0       	ldi	r30, 0x00	; 0
    109e:	7e 07       	cpc	r23, r30
    10a0:	01 f1       	breq	.+64     	;  0x10e2   if BYTE3==0x01 goto lbl_do_cmd_0x01_move_at_given_time
    10a2:	62 30       	cpi	r22, 0x02	; 2
    10a4:	e0 e0       	ldi	r30, 0x00	; 0
    10a6:	7e 07       	cpc	r23, r30
    10a8:	09 f4       	brne	.+2      	;  0x10ac    if BYTE3~=0x02 
    10aa:	7f c0       	rjmp	.+254    	;  0x11aa    if BYTE3==0x02 goto lbl_do_cmd_0x02_send_cur_position
    10ac:	bc c2       	rjmp	.+1400   	;  0x1626    goto lbl_enter_bus_listen_mode

    10ae:	6d 3c       	cpi	r22, 0xCD	; 205
    10b0:	e0 e0       	ldi	r30, 0x00	; 0
    10b2:	7e 07       	cpc	r23, r30
    10b4:	09 f4       	brne	.+2      	;  0x10b8    if BYTE3~=0xCD
    10b6:	5e c1       	rjmp	.+700    	;  0x1374    BYTE3==0xCD and goto lbl_parse_cmd_0xCD_change_servoID
    10b8:	61 3d       	cpi	r22, 0xD1	; 209
    10ba:	e0 e0       	ldi	r30, 0x00	; 0
    10bc:	7e 07       	cpc	r23, r30
    10be:	09 f4       	brne	.+2      	;  0x10c2    if BYTE3~=0xD1
    10c0:	9a c1       	rjmp	.+820    	;  0x13f6    BYTE3==0xD1 and goto lbl_parse_cmd_0xD1_xxxxx
    10c2:	62 3d       	cpi	r22, 0xD2	; 210
    10c4:	e0 e0       	ldi	r30, 0x00	; 0
    10c6:	7e 07       	cpc	r23, r30
    10c8:	09 f4       	brne	.+2      	;  0x10cc    if BYTE3~=0xD2
    10ca:	c0 c1       	rjmp	.+896    	;  0x144c    BYTE3==0xD2 and goto lbl_do_cmd_0xD2_write_angle_calibration
    10cc:	63 3d       	cpi	r22, 0xD3	; 211
    10ce:	e0 e0       	ldi	r30, 0x00	; 0
    10d0:	7e 07       	cpc	r23, r30
    10d2:	09 f4       	brne	.+2      	;  0x10d6     if BYTE3~=0xD3
    10d4:	2d c2       	rjmp	.+1114   	;  0x1530     BYTE3==0xD3 and goto lbl_parse_cmd_0xD3_xxxxx
    10d6:	64 3d       	cpi	r22, 0xD4	; 212
    10d8:	e0 e0       	ldi	r30, 0x00	; 0
    10da:	7e 07       	cpc	r23, r30
    10dc:	09 f4       	brne	.+2      	;  0x10e0     if BYTE3~=0xD4
    10de:	5c c2       	rjmp	.+1208   	;  0x1598     goto lbl_do_cmd_0xD4_read_angle_calibration
    10e0:	a2 c2       	rjmp	.+1348   	;  0x1626     goto lbl_enter_bus_listen_mode
lbl_do_cmd_0x01_move_at_given_time:
    10e2:	8c ef       	ldi	r24, 0xFC	; 252
    10e4:	20 90 51 01 	lds	r2, 0x0151	;  0x800151
    10e8:	82 15       	cp	r24, r2
    10ea:	28 f5       	brcc	.+74     	;  0x1136     if BYTE4<=252 goto lbl_do_cmd_movement
    10ec:	00 91 97 00 	lds	r16, 0x0097	;  0x800097   BYTE4>252
    10f0:	06 55       	subi	r16, 0x56	; 86
    10f2:	bf d3       	rcall	.+1918   	;  0x1872_TX_send_byte(servoID+0xAA) ===> 向主机发送 OK-ACK 
    10f4:	80 91 51 01 	lds	r24, 0x0151	;  0x800151
    10f8:	8d 3f       	cpi	r24, 0xFD	; 253
    10fa:	51 f4       	brne	.+20     	;  0x1110      if BYTE4~=253 goto lbl_check_0xFE
    10fc:	82 b3       	in	r24, 0x12	; 18             BYTE4==253
    10fe:	8f 7b       	andi	r24, 0xBF	; 191
    1100:	82 bb       	out	0x12, r24	; 18             PD6 = LOW ===> A3950-PHASE = LOW 
    1102:	01 e0       	ldi	r16, 0x01	; 1
    1104:	7b d9       	rcall	.-3338   	;  0x3fc       0x3fc_PWM_start_stop(TRUE)
    1106:	85 ef       	ldi	r24, 0xF5	; 245
    1108:	90 e0       	ldi	r25, 0x00	; 0
    110a:	9b bd       	out	0x2b, r25	; 43
    110c:	8a bd       	out	0x2a, r24	; 42              OCR1A = 0x00F5 = 245
    110e:	8b c2       	rjmp	.+1302   	;  0x1626       goto lbl_enter_bus_listen_mode
lbl_check_0xFE:
    1110:	80 91 51 01 	lds	r24, 0x0151	;  0x800151
    1114:	8e 3f       	cpi	r24, 0xFE	; 254
    1116:	41 f4       	brne	.+16     	;  0x1128       if BYTE4~=254 goto lbl_check_0xFF
    1118:	96 9a       	sbi	0x12, 6	; 18                PD6 = HIGH ===> A3950-PHASE = HIGH
    111a:	01 e0       	ldi	r16, 0x01	; 1
    111c:	6f d9       	rcall	.-3362   	;  0x3fc        0x3fc_PWM_start_stop(TRUE)
    111e:	85 ef       	ldi	r24, 0xF5	; 245
    1120:	90 e0       	ldi	r25, 0x00	; 0
    1122:	9b bd       	out	0x2b, r25	; 43
    1124:	8a bd       	out	0x2a, r24	; 42              OCR1A = 0x00F5 = 245
    1126:	7f c2       	rjmp	.+1278   	;  0x1626       goto lbl_enter_bus_listen_mode
lbl_check_0xFF:
    1128:	22 24       	eor	r2, r2
    112a:	33 24       	eor	r3, r3
    112c:	3b bc       	out	0x2b, r3	; 43
    112e:	2a bc       	out	0x2a, r2	; 42              OCR1A = 0
    1130:	00 27       	eor	r16, r16
    1132:	64 d9       	rcall	.-3384   	;  0x3fc        0x3fc_PWM_start_stop(FALSE)
    1134:	78 c2       	rjmp	.+1264   	;  0x1626       goto lbl_enter_bus_listen_mode
lbl_do_cmd_movement:
    1136:	00 91 97 00 	lds	r16, 0x0097	;  0x800097
    113a:	06 55       	subi	r16, 0x56	; 86
    113c:	9a d3       	rcall	.+1844   	;  0x1872       0x1872_TX_send_byte(servoID+0xAA) ===> 向主机发送 OK-ACK 
                                        ;               取2字节宽度运动时间数据，保存在RAM中
    113e:	20 90 53 01 	lds	r2, 0x0153	;  0x800153     r2 = BYTE6 ; 文档中描述BYTE6含义为： 运动完成时间的高八位
    1142:	33 24       	eor	r3, r3
    1144:	30 92 6f 01 	sts	0x016F, r3	;  0x80016f     
    1148:	20 92 6e 01 	sts	0x016E, r2	;  0x80016e     WORD(0x016E) = BYTE6
    114c:	20 90 6e 01 	lds	r2, 0x016E	;  0x80016e
    1150:	30 90 6f 01 	lds	r3, 0x016F	;  0x80016f
    1154:	32 2c       	mov	r3, r2
    1156:	22 24       	eor	r2, r2
    1158:	30 92 6f 01 	sts	0x016F, r3	;  0x80016f
    115c:	20 92 6e 01 	sts	0x016E, r2	;  0x80016e     WORD(0x016E) <<= 8
    1160:	20 90 54 01 	lds	r2, 0x0154	;  0x800154
    1164:	33 24       	eor	r3, r3
    1166:	40 90 6e 01 	lds	r4, 0x016E	;  0x80016e
    116a:	50 90 6f 01 	lds	r5, 0x016F	;  0x80016f
    116e:	42 0c       	add	r4, r2
    1170:	53 1c       	adc	r5, r3
    1172:	50 92 6f 01 	sts	0x016F, r5	;  0x80016f
    1176:	40 92 6e 01 	sts	0x016E, r4	;  0x80016e     WORD(0x016E) += BYTE7
    117a:	92 01       	movw	r18, r4
    117c:	02 e1       	ldi	r16, 0x12	; 18
    117e:	10 e0       	ldi	r17, 0x00	; 0
    1180:	1e d4       	rcall	.+2108   	;               [r17,r16] = 0x19be_unsigned_word_multiply( 18, WORD(0x016E))
    1182:	10 93 6f 01 	sts	0x016F, r17	;  0x80016f
    1186:	00 93 6e 01 	sts	0x016E, r16	;  0x80016e     WORD(0x016E) *= 18
    118a:	20 90 6d 01 	lds	r2, 0x016D	;  0x80016d
    118e:	22 20       	and	r2, r2
    1190:	09 f4       	brne	.+2      	;  0x1194      if BOOL(0x016D)==TRUE goto xxxxx
    1192:	49 c2       	rjmp	.+1170   	;  0x1626      if BOOL(0x016D)==FALSE goto lbl_enter_bus_listen_mode
    1194:	20 91 52 01 	lds	r18, 0x0152	;  0x800152
    1198:	33 27       	eor	r19, r19    ;              [r19,r18] = BYTE5
    119a:	00 91 51 01 	lds	r16, 0x0151	;  0x800151
    119e:	11 27       	eor	r17, r17    ;              [r17,r16] = BYTE4
    11a0:	51 d9       	rcall	.-3422   	;  0x444       
    11a2:	22 24       	eor	r2, r2
    11a4:	20 92 6d 01 	sts	0x016D, r2	;  0x80016d    BOOL(0x016D) = FALSE
    11a8:	3e c2       	rjmp	.+1148   	;  0x1626      goto lbl_enter_bus_listen_mode

lbl_do_cmd_0x02_send_cur_position:
    11aa:	8a ef       	ldi	r24, 0xFA	; 250
    11ac:	80 93 2d 01 	sts	0x012D, r24	;  0x80012d    TX_BUF[0] = 0xFA
    11b0:	8f ea       	ldi	r24, 0xAF	; 175
    11b2:	80 93 2e 01 	sts	0x012E, r24	;  0x80012e    TX_BUF[1] = 0xAF
    11b6:	20 90 97 00 	lds	r2, 0x0097	;  0x800097
    11ba:	20 92 2f 01 	sts	0x012F, r2	;  0x80012f    TX_BUF[2] = servoID
    11be:	8a ea       	ldi	r24, 0xAA	; 170
    11c0:	80 93 30 01 	sts	0x0130, r24	;  0x800130    TX_BUF[3] = 0xAA
    11c4:	20 90 29 01 	lds	r2, 0x0129	;  0x800129    
    11c8:	30 90 2a 01 	lds	r3, 0x012A	;  0x80012a    [r3,r2] = WORD(0x0129)
    11cc:	60 91 fd 00 	lds	r22, 0x00FD	;  0x8000fd
    11d0:	70 91 fe 00 	lds	r23, 0x00FE	;  0x8000fe    [r23,r22] = WORD(0x00FD)
    11d4:	64 5b       	subi	r22, 0xB4	; 180
    11d6:	70 40       	sbci	r23, 0x00	; 0            [r23,r22] -= 180
    11d8:	62 19       	sub	r22, r2
    11da:	73 09       	sbc	r23, r3     ;              [r23,r22] -= [r3,r2] ====> [r23,r22] = WORD(0x00FD)-180-WORD(0x0129)
    11dc:	23 e0       	ldi	r18, 0x03	; 3
    11de:	30 e0       	ldi	r19, 0x00	; 0              [r19,r18] = 3
    11e0:	8b 01       	movw	r16, r22                 [r17,r16] = [r23,r22] 
    11e2:	6b d3       	rcall	.+1750   	;  0x18ba      [r17,r16] = ([r17, r16]/3) ====> [r17,r16] = (WORD(0x00FD)-180-WORD(0x0129))/3
    11e4:	b8 01       	movw	r22, r16  ;              [r23,r22] = [r17,r16]
    11e6:	1b 01       	movw	r2, r22   ;              tmp = [r3,r2] = [r23,r22]  = (WORD(0x00FD)-180-WORD(0x0129))/3
    11e8:	23 2c       	mov	r2, r3
    11ea:	33 24       	eor	r3, r3
    11ec:	20 92 31 01 	sts	0x0131, r2	;  0x800131    TX_BUF[4] = r2 = HI_BYTE(tmp)
    11f0:	cb 01       	movw	r24, r22  ;              
    11f2:	90 70       	andi	r25, 0x00	; 0            [r25,r24] = tmp&0xFF
    11f4:	80 93 32 01 	sts	0x0132, r24	;  0x800132    TX_BUF[5] = r24 = LOW_BYTE(tmp)
    11f8:	20 90 29 01 	lds	r2, 0x0129	;  0x800129
    11fc:	30 90 2a 01 	lds	r3, 0x012A	;  0x80012a    [r3,r2] = WORD(0x0129)
    1200:	60 91 01 01 	lds	r22, 0x0101	;  0x800101
    1204:	70 91 02 01 	lds	r23, 0x0102	;  0x800102    [r23,r22] = WORD(0x0101)
    1208:	64 5b       	subi	r22, 0xB4	; 180
    120a:	70 40       	sbci	r23, 0x00	; 0            [r23,r22] -= 180
    120c:	62 19       	sub	r22, r2
    120e:	73 09       	sbc	r23, r3     ;              [r23,r22] -= [r3,r2] ====> [r23,r22] = WORD(0x0101)-180-WORD(0x0129)
    1210:	80 e0       	ldi	r24, 0x00	; 0
    1212:	9f ef       	ldi	r25, 0xFF	; 255            [r25,r14] = 0xFF00 = 65280
    1214:	86 17       	cp	r24, r22
    1216:	97 07       	cpc	r25, r23
    1218:	10 f4       	brcc	.+4      	;  0x121e      if 0xFF00>=[r23,r22] goto xxxx
    121a:	66 27       	eor	r22, r22
    121c:	77 27       	eor	r23, r23    ;              [r23,r22] = 0

    121e:	23 e0       	ldi	r18, 0x03	; 3
    1220:	30 e0       	ldi	r19, 0x00	; 0              [r19,r18] = 3
    1222:	8b 01       	movw	r16, r22  ;              [r17,r16] = [r23,r22]         
    1224:	4a d3       	rcall	.+1684   	;  0x18ba      [r17,r16] = ([r17, r16]/3) 
    1226:	b8 01       	movw	r22, r16                 [r23,r22] = [r17,r16]
    1228:	84 eb       	ldi	r24, 0xB4	; 180
    122a:	90 e0       	ldi	r25, 0x00	; 0              [r25,r24] = 180
    122c:	80 17       	cp	r24, r16
    122e:	91 07       	cpc	r25, r17
    1230:	10 f4       	brcc	.+4      	;  0x1236      if 180>=[r17,r16] 
    1232:	64 eb       	ldi	r22, 0xB4	; 180            180<[r17,r16] and [r23,r22] = 180 
    1234:	70 e0       	ldi	r23, 0x00	; 0

    1236:	1b 01       	movw	r2, r22   ;              [r3,r2] = [r23,r22]           
    1238:	23 2c       	mov	r2, r3
    123a:	33 24       	eor	r3, r3      ;              
    123c:	20 92 33 01 	sts	0x0133, r2	;  0x800133    TX_BUF[6] = HI_BYTE([r23,r22])
    1240:	cb 01       	movw	r24, r22
    1242:	90 70       	andi	r25, 0x00	; 0            [r25,r24] = [r23,r22]&0xFF 
    1244:	80 93 34 01 	sts	0x0134, r24	;  0x800134    TX_BUF[7] = LOW_BYTE([r23,r22])
    1248:	0f e2       	ldi	r16, 0x2F	; 47
    124a:	11 e0       	ldi	r17, 0x01	; 1
    124c:	c1 de       	rcall	.-638    	;  0xfd0
    124e:	00 93 35 01 	sts	0x0135, r16	;  0x800135    TX_BUF[8] = 0xfd0_calculate_checksum(&TX_BUF[2])
    1252:	8d ee       	ldi	r24, 0xED	; 237
    1254:	80 93 36 01 	sts	0x0136, r24	;  0x800136    TX_BUF[9] = 0xED
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; send 10 bytes TX buffer
    1258:	44 27       	eor	r20, r20
    125a:	09 c0       	rjmp	.+18     	;  0x126e
    125c:	8d e2       	ldi	r24, 0x2D	; 45
    125e:	91 e0       	ldi	r25, 0x01	; 1
    1260:	e4 2f       	mov	r30, r20
    1262:	ff 27       	eor	r31, r31
    1264:	e8 0f       	add	r30, r24
    1266:	f9 1f       	adc	r31, r25
    1268:	00 81       	ld	r16, Z
    126a:	03 d3       	rcall	.+1542   	;  0x1872     0x1872_TX_send_byte(TX_BUF[r20])
    126c:	43 95       	inc	r20
    126e:	4a 30       	cpi	r20, 0x0A	; 10
    1270:	a8 f3       	brcs	.-22     	;  0x125c
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    1272:	00 27       	eor	r16, r16
    1274:	c3 d8       	rcall	.-3706   	;  0x3fc      0x3fc_PWM_start_stop(FALSE)
    1276:	d7 c1       	rjmp	.+942    	;  0x1626     goto lbl_enter_bus_listen_mode

lbl_do_cmd_0xC8_xxxxx:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; 这个命令没啥鸟用 
    ; 仅仅是从命令中取出 BYTE4~BYTE7,  (分别代表两个16位无符号整数)
    ; 然后分别存储到 WORD(0x0095) 和 WORD(0x0093) 中，(比较无语的是这两个变量通篇代码中没有引用)
    ; 最后存储到EEPROM中
    1278:	20 90 51 01 	lds	r2, 0x0151	;  0x800151   r2 = BYTE4
    127c:	33 24       	eor	r3, r3
    127e:	30 92 96 00 	sts	0x0096, r3	;  0x800096
    1282:	20 92 95 00 	sts	0x0095, r2	;  0x800095   WORD(0x0095) = BYTE4
    1286:	20 91 95 00 	lds	r18, 0x0095	;  0x800095
    128a:	30 91 96 00 	lds	r19, 0x0096	;  0x800096   [r19,r18] = WORD(0x0095)
    128e:	00 e0       	ldi	r16, 0x00	; 0
    1290:	11 e0       	ldi	r17, 0x01	; 1             [r17,r16] = 256
    1292:	95 d3       	rcall	.+1834   	;  0x19be     [r17,r16] = WORD(0x0095)*256 16位无符号乘法
    1294:	10 93 96 00 	sts	0x0096, r17	;  0x800096
    1298:	00 93 95 00 	sts	0x0095, r16	;  0x800095   WORD(0x0095) = [r17,r16]
    129c:	20 90 52 01 	lds	r2, 0x0152	;  0x800152  
    12a0:	33 24       	eor	r3, r3      ;             [r3,r2] = BYTE5
    12a2:	28 01       	movw	r4, r16   ;             [r5,r4] = [r17,r16]
    12a4:	42 0c       	add	r4, r2
    12a6:	53 1c       	adc	r5, r3      ;             [r5,r4] += BYTE5
    12a8:	50 92 96 00 	sts	0x0096, r5	;  0x800096
    12ac:	40 92 95 00 	sts	0x0095, r4	;  0x800095   WORD(0x0095) += BYTE5
    12b0:	81 e5       	ldi	r24, 0x51	; 81
    12b2:	91 e0       	ldi	r25, 0x01	; 1
    12b4:	99 83       	std	Y+1, r25	; 0x01
    12b6:	88 83       	st	Y, r24
    12b8:	22 e0       	ldi	r18, 0x02	; 2
    12ba:	30 e0       	ldi	r19, 0x00	; 0
    12bc:	03 e1       	ldi	r16, 0x13	; 19
    12be:	10 e0       	ldi	r17, 0x00	; 0
    12c0:	37 d7       	rcall	.+3694   	;  0x2130
    12c2:	20 90 53 01 	lds	r2, 0x0153	;  0x800153
    12c6:	33 24       	eor	r3, r3
    12c8:	30 92 94 00 	sts	0x0094, r3	;  0x800094
    12cc:	20 92 93 00 	sts	0x0093, r2	;  0x800093
    12d0:	20 91 93 00 	lds	r18, 0x0093	;  0x800093
    12d4:	30 91 94 00 	lds	r19, 0x0094	;  0x800094
    12d8:	00 e0       	ldi	r16, 0x00	; 0
    12da:	11 e0       	ldi	r17, 0x01	; 1
    12dc:	70 d3       	rcall	.+1760   	;  0x19be
    12de:	10 93 94 00 	sts	0x0094, r17	;  0x800094
    12e2:	00 93 93 00 	sts	0x0093, r16	;  0x800093
    12e6:	20 90 54 01 	lds	r2, 0x0154	;  0x800154
    12ea:	33 24       	eor	r3, r3
    12ec:	28 01       	movw	r4, r16
    12ee:	42 0c       	add	r4, r2
    12f0:	53 1c       	adc	r5, r3
    12f2:	50 92 94 00 	sts	0x0094, r5	;  0x800094
    12f6:	40 92 93 00 	sts	0x0093, r4	;  0x800093
    12fa:	83 e5       	ldi	r24, 0x53	; 83
    12fc:	91 e0       	ldi	r25, 0x01	; 1
    12fe:	99 83       	std	Y+1, r25	; 0x01
    1300:	88 83       	st	Y, r24
    1302:	22 e0       	ldi	r18, 0x02	; 2
    1304:	30 e0       	ldi	r19, 0x00	; 0
    1306:	05 e1       	ldi	r16, 0x15	; 21
    1308:	10 e0       	ldi	r17, 0x00	; 0
    130a:	12 d7       	rcall	.+3620   	;  0x2130
    130c:	8a ef       	ldi	r24, 0xFA	; 250
    130e:	80 93 2d 01 	sts	0x012D, r24	;  0x80012d
    1312:	8f ea       	ldi	r24, 0xAF	; 175
    1314:	80 93 2e 01 	sts	0x012E, r24	;  0x80012e
    1318:	20 90 97 00 	lds	r2, 0x0097	;  0x800097
    131c:	20 92 2f 01 	sts	0x012F, r2	;  0x80012f
    1320:	8a ea       	ldi	r24, 0xAA	; 170
    1322:	80 93 30 01 	sts	0x0130, r24	;  0x800130
    1326:	20 90 51 01 	lds	r2, 0x0151	;  0x800151
    132a:	20 92 31 01 	sts	0x0131, r2	;  0x800131
    132e:	20 90 52 01 	lds	r2, 0x0152	;  0x800152
    1332:	20 92 32 01 	sts	0x0132, r2	;  0x800132
    1336:	20 90 53 01 	lds	r2, 0x0153	;  0x800153
    133a:	20 92 33 01 	sts	0x0133, r2	;  0x800133
    133e:	20 90 54 01 	lds	r2, 0x0154	;  0x800154
    1342:	20 92 34 01 	sts	0x0134, r2	;  0x800134
    1346:	0f e2       	ldi	r16, 0x2F	; 47
    1348:	11 e0       	ldi	r17, 0x01	; 1
    134a:	42 de       	rcall	.-892    	;  0xfd0
    134c:	a0 2e       	mov	r10, r16
    134e:	a0 92 35 01 	sts	0x0135, r10	;  0x800135
    1352:	8d ee       	ldi	r24, 0xED	; 237
    1354:	80 93 36 01 	sts	0x0136, r24	;  0x800136
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;send 10 bytes TX buffer
    1358:	44 27       	eor	r20, r20
    135a:	09 c0       	rjmp	.+18     	;  0x136e
    135c:	8d e2       	ldi	r24, 0x2D	; 45
    135e:	91 e0       	ldi	r25, 0x01	; 1
    1360:	e4 2f       	mov	r30, r20
    1362:	ff 27       	eor	r31, r31
    1364:	e8 0f       	add	r30, r24
    1366:	f9 1f       	adc	r31, r25
    1368:	00 81       	ld	r16, Z
    136a:	83 d2       	rcall	.+1286   	;  0x1872
    136c:	43 95       	inc	r20
    136e:	4a 30       	cpi	r20, 0x0A	; 10
    1370:	a8 f3       	brcs	.-22     	;  0x135c
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    1372:	59 c1       	rjmp	.+690    	;  0x1626    goto lbl_enter_bus_listen_mode
lbl_parse_cmd_0xCD_change_servoID:
    1374:	8a ef       	ldi	r24, 0xFA	; 250
    1376:	80 93 2d 01 	sts	0x012D, r24	;  0x80012d  TX_BUF[0] = 0xFA
    137a:	8f ea       	ldi	r24, 0xAF	; 175
    137c:	80 93 2e 01 	sts	0x012E, r24	;  0x80012e  TX_BUF[1] = 0xAF
    1380:	82 e5       	ldi	r24, 0x52	; 82           
    1382:	91 e0       	ldi	r25, 0x01	; 1
    1384:	99 83       	std	Y+1, r25	; 0x01
    1386:	88 83       	st	Y, r24
    1388:	21 e0       	ldi	r18, 0x01	; 1
    138a:	30 e0       	ldi	r19, 0x00	; 0
    138c:	0a e0       	ldi	r16, 0x0A	; 10
    138e:	10 e0       	ldi	r17, 0x00	; 0
    1390:	cf d6       	rcall	.+3486   	;  0x2130    0x130_write_eeprom(buf=(uint8_t*)0x0152, eeadr=0x000A, size=1) 将新的servoID存入EEPROM中 （EEPROM地址0x000A）
    1392:	20 90 97 00 	lds	r2, 0x0097	;  0x800097  
    1396:	20 92 32 01 	sts	0x0132, r2	;  0x800132  TX_BUF[5] = servoID //当前舵机ID
    139a:	8f e2       	ldi	r24, 0x2F	; 47          
    139c:	91 e0       	ldi	r25, 0x01	; 1
    139e:	99 83       	std	Y+1, r25	; 0x01
    13a0:	88 83       	st	Y, r24
    13a2:	21 e0       	ldi	r18, 0x01	; 1
    13a4:	30 e0       	ldi	r19, 0x00	; 0
    13a6:	0a e0       	ldi	r16, 0x0A	; 10
    13a8:	10 e0       	ldi	r17, 0x00	; 0
    13aa:	a4 d6       	rcall	.+3400   	;  0x20f4    0xf4_read_eeprom(&TX_BUF[2], eeadr=0x000A, size=1) 读出刚存入的舵机ID到 TX_BUF[2] 中
    13ac:	20 90 2f 01 	lds	r2, 0x012F	;  0x80012f 
    13b0:	20 92 97 00 	sts	0x0097, r2	;  0x800097  servoID = TX_BUF[2]
    13b4:	8a ea       	ldi	r24, 0xAA	; 170
    13b6:	80 93 30 01 	sts	0x0130, r24	;  0x800130  TX_BUF[3] = 0xAA
    13ba:	22 24       	eor	r2, r2
    13bc:	20 92 31 01 	sts	0x0131, r2	;  0x800131  TX_BUF[4] = 0x00
    13c0:	20 92 33 01 	sts	0x0133, r2	;  0x800133  TX_BUF[6] = 0x00
    13c4:	20 92 34 01 	sts	0x0134, r2	;  0x800134  TX_BUF[7] = 0x00
    13c8:	0f e2       	ldi	r16, 0x2F	; 47
    13ca:	11 e0       	ldi	r17, 0x01	; 1
    13cc:	01 de       	rcall	.-1022   	;  
    13ce:	a0 2e       	mov	r10, r16
    13d0:	a0 92 35 01 	sts	0x0135, r10	;            TX_BUF[8] = 0xfd0_calculate_checksum(&TX_BUF[2])
    13d4:	8d ee       	ldi	r24, 0xED	; 237
    13d6:	80 93 36 01 	sts	0x0136, r24	;            TX_BUF[9] = 0xED 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;send 10 bytes TX buffer
    13da:	44 27       	eor	r20, r20
    13dc:	09 c0       	rjmp	.+18     	;  0x13f0
lbl_tx_send_byte_loop:
    13de:	8d e2       	ldi	r24, 0x2D	; 45
    13e0:	91 e0       	ldi	r25, 0x01	; 1
    13e2:	e4 2f       	mov	r30, r20
    13e4:	ff 27       	eor	r31, r31
    13e6:	e8 0f       	add	r30, r24
    13e8:	f9 1f       	adc	r31, r25
    13ea:	00 81       	ld	r16, Z      
    13ec:	42 d2       	rcall	.+1156   	;  0x1872_TX_send_byte(BYTE(0x012D+r20))
    13ee:	43 95       	inc	r20         ;  r20++
    13f0:	4a 30       	cpi	r20, 0x0A	; 10
    13f2:	a8 f3       	brcs	.-22     	;  if r20<10 goto lbl_tx_send_byte_loop
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    13f4:	18 c1       	rjmp	.+560    	;  0x1626  goto lbl_enter_bus_listen_mode
lbl_parse_cmd_0xD1_xxxxx:
    13f6:	8a ef       	ldi	r24, 0xFA	; 250
    13f8:	80 93 2d 01 	sts	0x012D, r24	;  0x80012d       TX_BUF[0] = 0xFA
    13fc:	8f ea       	ldi	r24, 0xAF	; 175
    13fe:	80 93 2e 01 	sts	0x012E, r24	;  0x80012e       TX_BUF[1] = 0xAF
    1402:	20 90 97 00 	lds	r2, 0x0097	;  0x800097
    1406:	20 92 2f 01 	sts	0x012F, r2	;  0x80012f       TX_BUF[2] = servoID
    140a:	8a ea       	ldi	r24, 0xAA	; 170
    140c:	80 93 30 01 	sts	0x0130, r24	;  0x800130       TX_BUF[3] = 0xAA
    1410:	22 24       	eor	r2, r2
    1412:	20 92 32 01 	sts	0x0132, r2	;  0x800132       TX_BUF[5] = 0
    1416:	20 92 33 01 	sts	0x0133, r2	;  0x800133       TX_BUF[6] = 0
    141a:	20 92 34 01 	sts	0x0134, r2	;  0x800134       TX_BUF[7] = 0
    141e:	0f e2       	ldi	r16, 0x2F	; 47
    1420:	11 e0       	ldi	r17, 0x01	; 1
    1422:	d6 dd       	rcall	.-1108   	;  0xfd0
    1424:	a0 2e       	mov	r10, r16
    1426:	a0 92 35 01 	sts	0x0135, r10	;  0x800135       TX_BUF[8] = 0xfd0_calculate_checksum(&TX_BUF[2])
    142a:	8d ee       	ldi	r24, 0xED	; 237
    142c:	80 93 36 01 	sts	0x0136, r24	;  0x800136       TX_BUF[9] = 0xED
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;send 10 bytes TX buffer TX buffer
    1430:	44 27       	eor	r20, r20
    1432:	09 c0       	rjmp	.+18     	;  0x1446
    1434:	8d e2       	ldi	r24, 0x2D	; 45
    1436:	91 e0       	ldi	r25, 0x01	; 1
    1438:	e4 2f       	mov	r30, r20
    143a:	ff 27       	eor	r31, r31
    143c:	e8 0f       	add	r30, r24
    143e:	f9 1f       	adc	r31, r25
    1440:	00 81       	ld	r16, Z
    1442:	17 d2       	rcall	.+1070   	;  0x1872
    1444:	43 95       	inc	r20
    1446:	4a 30       	cpi	r20, 0x0A	; 10
    1448:	a8 f3       	brcs	.-22     	;  0x1434
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    144a:	ed c0       	rjmp	.+474    	;  0x1626  goto lbl_enter_bus_listen_mode

lbl_do_cmd_0xD2_write_angle_calibration:
    144c:	8a ef       	ldi	r24, 0xFA	; 250
    144e:	80 93 2d 01 	sts	0x012D, r24	;  0x80012d        TX_BUF[0] = 0xFA
    1452:	8f ea       	ldi	r24, 0xAF	; 175
    1454:	80 93 2e 01 	sts	0x012E, r24	;  0x80012e        TX_BUF[1] = 0xAF
    1458:	20 90 97 00 	lds	r2, 0x0097	;  0x800097  
    145c:	20 92 2f 01 	sts	0x012F, r2	;  0x80012f        TX_BUF[2] = servoID
    1460:	8a ea       	ldi	r24, 0xAA	; 170
    1462:	80 93 30 01 	sts	0x0130, r24	;  0x800130        TX_BUF[3] = 0xAA
    1466:	22 24       	eor	r2, r2
    1468:	20 92 31 01 	sts	0x0131, r2	;  0x800131        TX_BUF[4] = 0
    146c:	20 92 32 01 	sts	0x0132, r2	;  0x800132        TX_BUF[5] = 0
    1470:	20 92 33 01 	sts	0x0133, r2	;  0x800133        TX_BUF[6] = 0
    1474:	20 92 34 01 	sts	0x0134, r2	;  0x800134        TX_BUF[7] = 0
    1478:	0f e2       	ldi	r16, 0x2F	; 47
    147a:	11 e0       	ldi	r17, 0x01	; 1
    147c:	a9 dd       	rcall	.-1198   	;  0xfd0
    147e:	a0 2e       	mov	r10, r16
    1480:	a0 92 35 01 	sts	0x0135, r10	;  0x800135        TX_BUF[8] = 0xfd0_calculate_checksum(&TX_BUF[2])
    1484:	8d ee       	ldi	r24, 0xED	; 237
    1486:	80 93 36 01 	sts	0x0136, r24	;  0x800136        TX_BUF[9] = 0xED
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;send 10 bytes TX buffer
    148a:	44 27       	eor	r20, r20
    148c:	09 c0       	rjmp	.+18     	;  0x14a0
    148e:	8d e2       	ldi	r24, 0x2D	; 45
    1490:	91 e0       	ldi	r25, 0x01	; 1
    1492:	e4 2f       	mov	r30, r20
    1494:	ff 27       	eor	r31, r31
    1496:	e8 0f       	add	r30, r24
    1498:	f9 1f       	adc	r31, r25
    149a:	00 81       	ld	r16, Z
    149c:	ea d1       	rcall	.+980    	;  0x1872
    149e:	43 95       	inc	r20
    14a0:	4a 30       	cpi	r20, 0x0A	; 10
    14a2:	a8 f3       	brcs	.-22     	;  0x148e
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    14a4:	20 90 51 01 	lds	r2, 0x0151	;  0x800151
    14a8:	33 24       	eor	r3, r3      ；                  [r3,r2] = BYTE(0x0151) 向前偏移校正高字节
    14aa:	30 92 2c 01 	sts	0x012C, r3	;  0x80012c
    14ae:	20 92 2b 01 	sts	0x012B, r2	;  0x80012b         WORD(0x012B) = BYTE(0x0151)
    14b2:	20 90 2b 01 	lds	r2, 0x012B	;  0x80012b
    14b6:	30 90 2c 01 	lds	r3, 0x012C	;  0x80012c         [r3,r2] = WORD(0x012B)
    14ba:	32 2c       	mov	r3, r2
    14bc:	22 24       	eor	r2, r2      ;                   [r3,r2] <<= 8
    14be:	30 92 2c 01 	sts	0x012C, r3	;  0x80012c
    14c2:	20 92 2b 01 	sts	0x012B, r2	;  0x80012b         WORD(0x012B) = [r3,r2]
    14c6:	20 90 52 01 	lds	r2, 0x0152	;  0x800152
    14ca:	33 24       	eor	r3, r3      ;                   [r3,r2] = BYTE(0x0152) 向前偏移校正低字节
    14cc:	40 90 2b 01 	lds	r4, 0x012B	;  0x80012b
    14d0:	50 90 2c 01 	lds	r5, 0x012C	;  0x80012c         [r5,r4] = WORD(0x012B)
    14d4:	42 0c       	add	r4, r2
    14d6:	53 1c       	adc	r5, r3      ;                   [r5,r4] += BYTE(0x0152)
    14d8:	50 92 2c 01 	sts	0x012C, r5	;  0x80012c
    14dc:	40 92 2b 01 	sts	0x012B, r4	;  0x80012b         WORD(0x012B) = [r5,r4]
    14e0:	20 90 53 01 	lds	r2, 0x0153	;  0x800153      
    14e4:	33 24       	eor	r3, r3      ;                   [r3,r2] = BYTE(0x0153) 向后偏移校正高字节
    14e6:	30 92 2a 01 	sts	0x012A, r3	;  0x80012a
    14ea:	20 92 29 01 	sts	0x0129, r2	;  0x800129         WORD(0x0129) = [r3,r2]
    14ee:	20 90 29 01 	lds	r2, 0x0129	;  0x800129
    14f2:	30 90 2a 01 	lds	r3, 0x012A	;  0x80012a         [r3,r2] = WORD(0x0129)
    14f6:	32 2c       	mov	r3, r2
    14f8:	22 24       	eor	r2, r2      ;                   [r3,r2] <<= 8
    14fa:	30 92 2a 01 	sts	0x012A, r3	;  0x80012a
    14fe:	20 92 29 01 	sts	0x0129, r2	;  0x800129         WORD(0x0129) = [r3,r2]
    1502:	20 90 54 01 	lds	r2, 0x0154	;  0x800154      
    1506:	33 24       	eor	r3, r3      ;                   [r3,r2] = BYTE(0x0154) 向后偏移校正低字节
    1508:	40 90 29 01 	lds	r4, 0x0129	;  0x800129
    150c:	50 90 2a 01 	lds	r5, 0x012A	;  0x80012a         [r5,r4] = WORD(0x0129)
    1510:	42 0c       	add	r4, r2
    1512:	53 1c       	adc	r5, r3      ;                   [r5,r4] += BYTE(0x0154)
    1514:	50 92 2a 01 	sts	0x012A, r5	;  0x80012a
    1518:	40 92 29 01 	sts	0x0129, r4	;  0x800129         WORD(0x0129) = [r5,r4]
    151c:	81 e5       	ldi	r24, 0x51	; 81                  保存参数到EEPROM中 注意是大端存储
    151e:	91 e0       	ldi	r25, 0x01	; 1
    1520:	99 83       	std	Y+1, r25	; 0x01
    1522:	88 83       	st	Y, r24
    1524:	24 e0       	ldi	r18, 0x04	; 4
    1526:	30 e0       	ldi	r19, 0x00	; 0
    1528:	08 e1       	ldi	r16, 0x18	; 24
    152a:	10 e0       	ldi	r17, 0x00	; 0
    152c:	01 d6       	rcall	.+3074   	;  0x2130          0x130_write_eeprom(&BYTE(0x0151), 0x0018, 4)
    152e:	7b c0       	rjmp	.+246    	;  0x1626 goto lbl_enter_bus_listen_mode

lbl_parse_cmd_0xD3_xxxxx:
    1530:	8a ef       	ldi	r24, 0xFA	; 250
    1532:	80 93 2d 01 	sts	0x012D, r24	;  0x80012d       TX_BUF[0] = 0xFA
    1536:	8f ea       	ldi	r24, 0xAF	; 175
    1538:	80 93 2e 01 	sts	0x012E, r24	;  0x80012e       TX_BUF[1] = 0xAF
    153c:	20 90 97 00 	lds	r2, 0x0097	;  0x800097      
    1540:	20 92 2f 01 	sts	0x012F, r2	;  0x80012f       TX_BUF[2] = servoID
    1544:	8a ea       	ldi	r24, 0xAA	; 170
    1546:	80 93 30 01 	sts	0x0130, r24	;  0x800130       TX_BUF[3] = 0xAA
    154a:	81 e3       	ldi	r24, 0x31	; 49
    154c:	91 e0       	ldi	r25, 0x01	; 1
    154e:	99 83       	std	Y+1, r25	; 0x01
    1550:	88 83       	st	Y, r24
    1552:	21 e0       	ldi	r18, 0x01	; 1
    1554:	30 e0       	ldi	r19, 0x00	; 0
    1556:	07 e1       	ldi	r16, 0x17	; 23
    1558:	10 e0       	ldi	r17, 0x00	; 0
    155a:	cc d5       	rcall	.+2968   	;  0x20f4         0xf4_read_eeprom(&TX_BUF[4], eeadr=0x0017, size=1)
    155c:	22 24       	eor	r2, r2
    155e:	20 92 32 01 	sts	0x0132, r2	;  0x800132       TX_BUF[5] = 0
    1562:	20 92 33 01 	sts	0x0133, r2	;  0x800133       TX_BUF[6] = 0
    1566:	20 92 34 01 	sts	0x0134, r2	;  0x800134       TX_BUF[7] = 0
    156a:	0f e2       	ldi	r16, 0x2F	; 47
    156c:	11 e0       	ldi	r17, 0x01	; 1
    156e:	30 dd       	rcall	.-1440   	;  0xfd0          
    1570:	a0 2e       	mov	r10, r16
    1572:	a0 92 35 01 	sts	0x0135, r10	;  0x800135       TX_BUF[8] = 0xfd0_calculate_checksum(&TX_BUF[2])
    1576:	8d ee       	ldi	r24, 0xED	; 237
    1578:	80 93 36 01 	sts	0x0136, r24	;  0x800136       TX_BUF[9] = 0xED
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;send 10 bytes TX buffer
    157c:	44 27       	eor	r20, r20
    157e:	09 c0       	rjmp	.+18     	;  0x1592
    1580:	8d e2       	ldi	r24, 0x2D	; 45
    1582:	91 e0       	ldi	r25, 0x01	; 1
    1584:	e4 2f       	mov	r30, r20
    1586:	ff 27       	eor	r31, r31
    1588:	e8 0f       	add	r30, r24
    158a:	f9 1f       	adc	r31, r25
    158c:	00 81       	ld	r16, Z
    158e:	71 d1       	rcall	.+738    	;  0x1872
    1590:	43 95       	inc	r20
    1592:	4a 30       	cpi	r20, 0x0A	; 10
    1594:	a8 f3       	brcs	.-22     	;  0x1580
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    1596:	47 c0       	rjmp	.+142    	;  0x1626 goto lbl_enter_bus_listen_mode

lbl_do_cmd_0xD4_read_angle_calibration:
    1598:	8a ef       	ldi	r24, 0xFA	; 250
    159a:	80 93 2d 01 	sts	0x012D, r24	;  0x80012d    TX_BUF[0] = 0xFA
    159e:	8f ea       	ldi	r24, 0xAF	; 175
    15a0:	80 93 2e 01 	sts	0x012E, r24	;  0x80012e    TX_BUF[1] = 0xAF
    15a4:	20 90 97 00 	lds	r2, 0x0097	;  0x800097
    15a8:	20 92 2f 01 	sts	0x012F, r2	;  0x80012f    TX_BUF[2] = servoID
    15ac:	8a ea       	ldi	r24, 0xAA	; 170
    15ae:	80 93 30 01 	sts	0x0130, r24	;  0x800130    TX_BUF[3] = 0xAA
    15b2:	20 e0       	ldi	r18, 0x00	; 0
    15b4:	31 e0       	ldi	r19, 0x01	; 1              [r19,r18] = 0x0100 = 256
    15b6:	00 91 2b 01 	lds	r16, 0x012B	;  0x80012b
    15ba:	10 91 2c 01 	lds	r17, 0x012C	;  0x80012c    [r17,r16] = WORD(0x012B)
    15be:	62 d1       	rcall	.+708    	;  0x1884      [r17,r16] = [r17,r16]/256 有符号16位除法
    15c0:	00 93 31 01 	sts	0x0131, r16	;  0x800131    TX_BUF[4] = LOW_BYTE(WORD(0x012B)/256) 除数仅低字节有效
    15c4:	20 e0       	ldi	r18, 0x00	; 0
    15c6:	31 e0       	ldi	r19, 0x01	; 1              [r19,r18] = 0x0100 = 256
    15c8:	00 91 2b 01 	lds	r16, 0x012B	;  0x80012b
    15cc:	10 91 2c 01 	lds	r17, 0x012C	;  0x80012c    [r17,r16] = WORD(0x012B)
    15d0:	55 d1       	rcall	.+682    	;  0x187c      [r17,r16] = [r17,r16]%256 有符号16位取余
    15d2:	00 93 32 01 	sts	0x0132, r16	;  0x800132    TX_BUF[5] = LOW_BYTE(WORD(0x012B)%256) 余数仅低字节有效
    15d6:	20 e0       	ldi	r18, 0x00	; 0
    15d8:	31 e0       	ldi	r19, 0x01	; 1              [r19,r18] = 0x0100 = 256
    15da:	00 91 29 01 	lds	r16, 0x0129	;  0x800129
    15de:	10 91 2a 01 	lds	r17, 0x012A	;  0x80012a    [r17,r16] = WORD(0x0129)
    15e2:	50 d1       	rcall	.+672    	;  0x1884      [r17,r16] = [r17,r16]/256 有符号16位除法
    15e4:	00 93 33 01 	sts	0x0133, r16	;  0x800133    TX_BUF[6] = LOW_BYTE(WORD(0x0129)/256) 除数仅低字节有效
    15e8:	20 e0       	ldi	r18, 0x00	; 0
    15ea:	31 e0       	ldi	r19, 0x01	; 1              [r19,r18] = 0x0100 = 256
    15ec:	00 91 29 01 	lds	r16, 0x0129	;  0x800129
    15f0:	10 91 2a 01 	lds	r17, 0x012A	;  0x80012a    [r17,r16] = WORD(0x0129)
    15f4:	43 d1       	rcall	.+646    	;  0x187c      [r17,r16] = [r17,r16]%256 有符号16位取余
    15f6:	00 93 34 01 	sts	0x0134, r16	;  0x800134    TX_BUF[7] = LOW_BYTE(WORD(0x0129)%256) 余数仅低字节有效
    15fa:	0f e2       	ldi	r16, 0x2F	; 47
    15fc:	11 e0       	ldi	r17, 0x01	; 1
    15fe:	e8 dc       	rcall	.-1584   	;  0xfd0      
    1600:	a0 2e       	mov	r10, r16
    1602:	a0 92 35 01 	sts	0x0135, r10	;  0x800135    TX_BUF[8] = 0xfd0_calculate_checksum(&TX_BUF[2])
    1606:	8d ee       	ldi	r24, 0xED	; 237
    1608:	80 93 36 01 	sts	0x0136, r24	;  0x800136    TX_BUF[9] = 0xED 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;send 10 bytes TX buffer
    160c:	44 27       	eor	r20, r20
    160e:	09 c0       	rjmp	.+18     	;  0x1622
    1610:	8d e2       	ldi	r24, 0x2D	; 45
    1612:	91 e0       	ldi	r25, 0x01	; 1
    1614:	e4 2f       	mov	r30, r20
    1616:	ff 27       	eor	r31, r31
    1618:	e8 0f       	add	r30, r24
    161a:	f9 1f       	adc	r31, r25
    161c:	00 81       	ld	r16, Z
    161e:	29 d1       	rcall	.+594    	;  0x1872      0x1872_TX_send_byte(TX_BUF[r20])
    1620:	43 95       	inc	r20
    1622:	4a 30       	cpi	r20, 0x0A	; 10
    1624:	a8 f3       	brcs	.-22     	;  0x1610
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lbl_enter_bus_listen_mode:
    1626:	92 9a       	sbi	0x12, 2	; 18      set PD2 high ==> disable TX gate
    1628:	82 b3       	in	r24, 0x12	; 18
    162a:	87 7f       	andi	r24, 0xF7	; 247 set PD3 low ==> enable RX gate
    162c:	82 bb       	out	0x12, r24	; 18
    162e:	72 c0       	rjmp	.+228    	;  0x1714

lbl_check_frame_header_0xFC:
    1630:	80 91 4d 01 	lds	r24, 0x014D	;  0x80014d
    1634:	8c 3f       	cpi	r24, 0xFC	; 252
    1636:	09 f0       	breq	.+2      	;  0x163a   if BYTE0==0xFC
    1638:	6d c0       	rjmp	.+218    	;  0x1714   goto END
    163a:	80 91 4e 01 	lds	r24, 0x014E	;  0x80014e
    163e:	8f 3c       	cpi	r24, 0xCF	; 207
    1640:	09 f0       	breq	.+2      	;  0x1644   if BYTE0==0xCF
    1642:	68 c0       	rjmp	.+208    	;  0x1714   goto END
    1644:	20 90 97 00 	lds	r2, 0x0097	;  0x800097
    1648:	30 90 4f 01 	lds	r3, 0x014F	;  0x80014f
    164c:	32 14       	cp	r3, r2
    164e:	09 f0       	breq	.+2      	;  0x1652
    1650:	61 c0       	rjmp	.+194    	;  0x1714
    1652:	0f e4       	ldi	r16, 0x4F	; 79
    1654:	11 e0       	ldi	r17, 0x01	; 1
    1656:	bc dc       	rcall	.-1672   	;  0xfd0
    1658:	a0 2e       	mov	r10, r16
    165a:	20 90 55 01 	lds	r2, 0x0155	;  0x800155
    165e:	02 15       	cp	r16, r2
    1660:	09 f0       	breq	.+2      	;  0x1664
    1662:	58 c0       	rjmp	.+176    	;  0x1714
    1664:	60 91 50 01 	lds	r22, 0x0150	;  0x800150
    1668:	77 27       	eor	r23, r23
    166a:	61 30       	cpi	r22, 0x01	; 1
    166c:	e0 e0       	ldi	r30, 0x00	; 0
    166e:	7e 07       	cpc	r23, r30
    1670:	31 f0       	breq	.+12     	;  0x167e
    1672:	62 30       	cpi	r22, 0x02	; 2
    1674:	e0 e0       	ldi	r30, 0x00	; 0
    1676:	7e 07       	cpc	r23, r30
    1678:	09 f4       	brne	.+2      	;  0x167c
    167a:	41 c0       	rjmp	.+130    	;  0x16fe
    167c:	4b c0       	rjmp	.+150    	;  0x1714
    167e:	93 9a       	sbi	0x12, 3	; 18
    1680:	82 b3       	in	r24, 0x12	; 18
    1682:	8b 7f       	andi	r24, 0xFB	; 251
    1684:	82 bb       	out	0x12, r24	; 18
    1686:	8c ef       	ldi	r24, 0xFC	; 252
    1688:	80 93 2d 01 	sts	0x012D, r24	;  0x80012d
    168c:	8f ec       	ldi	r24, 0xCF	; 207
    168e:	80 93 2e 01 	sts	0x012E, r24	;  0x80012e
    1692:	20 90 97 00 	lds	r2, 0x0097	;  0x800097
    1696:	20 92 2f 01 	sts	0x012F, r2	;  0x80012f
    169a:	8a ea       	ldi	r24, 0xAA	; 170
    169c:	80 93 30 01 	sts	0x0130, r24	;  0x800130
    16a0:	ee e4       	ldi	r30, 0x4E	; 78
    16a2:	f0 e0       	ldi	r31, 0x00	; 0
    16a4:	24 90       	lpm	r2, Z
    16a6:	20 92 31 01 	sts	0x0131, r2	;  0x800131
    16aa:	ef e4       	ldi	r30, 0x4F	; 79
    16ac:	f0 e0       	ldi	r31, 0x00	; 0
    16ae:	24 90       	lpm	r2, Z
    16b0:	20 92 32 01 	sts	0x0132, r2	;  0x800132
    16b4:	e0 e5       	ldi	r30, 0x50	; 80
    16b6:	f0 e0       	ldi	r31, 0x00	; 0
    16b8:	24 90       	lpm	r2, Z
    16ba:	20 92 33 01 	sts	0x0133, r2	;  0x800133
    16be:	e1 e5       	ldi	r30, 0x51	; 81
    16c0:	f0 e0       	ldi	r31, 0x00	; 0
    16c2:	24 90       	lpm	r2, Z
    16c4:	20 92 34 01 	sts	0x0134, r2	;  0x800134
    16c8:	0f e2       	ldi	r16, 0x2F	; 47
    16ca:	11 e0       	ldi	r17, 0x01	; 1
    16cc:	81 dc       	rcall	.-1790   	;  0xfd0
    16ce:	a0 2e       	mov	r10, r16
    16d0:	a0 92 35 01 	sts	0x0135, r10	;  0x800135
    16d4:	8d ee       	ldi	r24, 0xED	; 237
    16d6:	80 93 36 01 	sts	0x0136, r24	;  0x800136
    16da:	44 27       	eor	r20, r20
    16dc:	09 c0       	rjmp	.+18     	;  0x16f0
    16de:	8d e2       	ldi	r24, 0x2D	; 45
    16e0:	91 e0       	ldi	r25, 0x01	; 1
    16e2:	e4 2f       	mov	r30, r20
    16e4:	ff 27       	eor	r31, r31
    16e6:	e8 0f       	add	r30, r24
    16e8:	f9 1f       	adc	r31, r25
    16ea:	00 81       	ld	r16, Z
    16ec:	c2 d0       	rcall	.+388    	;  0x1872
    16ee:	43 95       	inc	r20
    16f0:	4a 30       	cpi	r20, 0x0A	; 10
    16f2:	a8 f3       	brcs	.-22     	;  0x16de
    16f4:	92 9a       	sbi	0x12, 2	; 18
    16f6:	82 b3       	in	r24, 0x12	; 18
    16f8:	87 7f       	andi	r24, 0xF7	; 247
    16fa:	82 bb       	out	0x12, r24	; 18
    16fc:	0b c0       	rjmp	.+22     	;  0x1714
    16fe:	92 9a       	sbi	0x12, 2	; 18
    1700:	82 b3       	in	r24, 0x12	; 18
    1702:	87 7f       	andi	r24, 0xF7	; 247
    1704:	82 bb       	out	0x12, r24	; 18
    1706:	f8 94       	cli
    1708:	22 24       	eor	r2, r2
    170a:	28 ba       	out	0x18, r2	; 24
    170c:	23 be       	out	0x33, r2	; 51
    170e:	2a b8       	out	0x0a, r2	; 10
    1710:	0c 94 00 0e 	jmp	0x1c00	;  0x1c00
    1714:	22 96       	adiw	r28, 0x02	; 2          destroy WORD x
    1716:	b6 c1       	rjmp	.+876    	;  0x1a84    stack pop
    1718:	08 95       	ret

0x171a_ISR_UART_RX_Complete(): 
    171a:	2a 92       	st	-Y, r2
    171c:	3a 92       	st	-Y, r3
    171e:	0a 93       	st	-Y, r16
    1720:	1a 93       	st	-Y, r17
    1722:	8a 93       	st	-Y, r24
    1724:	9a 93       	st	-Y, r25
    1726:	aa 93       	st	-Y, r26
    1728:	ea 93       	st	-Y, r30
    172a:	fa 93       	st	-Y, r31
    172c:	2f b6       	in	r2, 0x3f	; 63   ; push SREG
    172e:	2a 92       	st	-Y, r2
    1730:	2c b0       	in	r2, 0x0c	; 12   ;r2=UDR
    1732:	20 92 08 01 	sts	0x0108, r2	;  BYTE(0x0108) = UDR    BYTE(0x0108)是RX接收字节暂存   记作 RX_BYTE
    1736:	00 91 70 01 	lds	r16, 0x0170	;  0x800170              BYTE(0x0170)是命令帧特殊字节接收状态记录, 0/1/2/3 记作 RX_FRAME_CHECKER
    173a:	11 27       	eor	r17, r17    ;  r17 = 0
    173c:	00 30       	cpi	r16, 0x00	; 0
    173e:	01 07       	cpc	r16, r17
    1740:	79 f0       	breq	.+30     	;  0x1760 ; if RX_FRAME_CHECKER==0 (0x0170位于bss section,所以初始值是0) goto lbl_rx_check_frame_1st_byte
    1742:	01 30       	cpi	r16, 0x01	; 1
    1744:	e0 e0       	ldi	r30, 0x00	; 0
    1746:	1e 07       	cpc	r17, r30
    1748:	49 f1       	breq	.+82     	;  0x179c ; if RX_FRAME_CHECKER==1 goto lbl_rx_check_frame_2nd_byte
    174a:	02 30       	cpi	r16, 0x02	; 2
    174c:	e0 e0       	ldi	r30, 0x00	; 0
    174e:	1e 07       	cpc	r17, r30
    1750:	09 f4       	brne	.+2      	;  0x1754 ; if RX_FRAME_CHECKER~=2 
    1752:	46 c0       	rjmp	.+140    	;  0x17e0   RX_FRAME_CHECKER==2 and goto lbl_rx_check_frame_3rd_and_more_byte
    1754:	03 30       	cpi	r16, 0x03	; 3
    1756:	e0 e0       	ldi	r30, 0x00	; 0
    1758:	1e 07       	cpc	r17, r30
    175a:	09 f4       	brne	.+2      	;  0x175e ; if RX_FRAME_CHECKER~=3
    175c:	5b c0       	rjmp	.+182    	;  0x1814   if RX_FRAME_CHECKER==3 goto lbl_rx_check_frame_last_byte
    175e:	7a c0       	rjmp	.+244    	;  0x1854   goto END
lbl_rx_check_frame_1st_byte:
    1760:	20 90 08 01 	lds	r2, 0x0108	;  0x800108; 
    1764:	82 2d       	mov	r24, r2
    1766:	8a 3f       	cpi	r24, 0xFA	; 250
    1768:	19 f0       	breq	.+6      	;  0x1770  ; if RX_BYTE==0xFA 
    176a:	8c 3f       	cpi	r24, 0xFC	; 252
    176c:	09 f0       	breq	.+2      	;  0x1770  ; if RX_BYTE==0xFC 
    176e:	72 c0       	rjmp	.+228    	;  0x1854    goto END
    1770:	20 90 89 00 	lds	r2, 0x0089	;  0x800089; BYTE(0x0089)是RX接收字节计数器(初始值为0x00), 记作 RX_CNT
    1774:	33 24       	eor	r3, r3
    1776:	82 2d       	mov	r24, r2
    1778:	8f 5f       	subi	r24, 0xFF	; 255
    177a:	80 93 89 00 	sts	0x0089, r24	;  0x800089  RX_CNT++
    177e:	89 e0       	ldi	r24, 0x09	; 9
    1780:	91 e0       	ldi	r25, 0x01	; 1
    1782:	e2 2d       	mov	r30, r2
    1784:	ff 27       	eor	r31, r31    ;  Z = r2
    1786:	e8 0f       	add	r30, r24
    1788:	f9 1f       	adc	r31, r25    ;  Z += 0x0109
    178a:	20 90 08 01 	lds	r2, 0x0108	;  0x800108
    178e:	20 82       	st	Z, r2       ；            BYTE_ARRAY(0x0109)[RX_CNT-1] = RX_BYTE
    1790:	80 91 70 01 	lds	r24, 0x0170	;  0x800170
    1794:	8f 5f       	subi	r24, 0xFF	; 255
    1796:	80 93 70 01 	sts	0x0170, r24	;  0x800170   RX_FRAME_CHECKER++
    179a:	5c c0       	rjmp	.+184    	;  0x1854     goto END
lbl_rx_check_frame_2nd_byte:
    179c:	00 91 08 01 	lds	r16, 0x0108	;  0x800108
    17a0:	0f 3a       	cpi	r16, 0xAF	; 175
    17a2:	11 f0       	breq	.+4      	;  0x17a8    if RX_BYTE==0xAF
    17a4:	0f 3c       	cpi	r16, 0xCF	; 207          
    17a6:	b1 f4       	brne	.+44     	;  0x17d4    if RX_BYTE~=0xCF goto lbl_reset_rx__cnt

    17a8:	00 91 89 00 	lds	r16, 0x0089	;  0x800089
    17ac:	11 27       	eor	r17, r17
    17ae:	80 2f       	mov	r24, r16
    17b0:	8f 5f       	subi	r24, 0xFF	; 255 
    17b2:	80 93 89 00 	sts	0x0089, r24	;  0x800089  RX_CNT++
    17b6:	89 e0       	ldi	r24, 0x09	; 9
    17b8:	91 e0       	ldi	r25, 0x01	; 1
    17ba:	e0 2f       	mov	r30, r16
    17bc:	ff 27       	eor	r31, r31
    17be:	e8 0f       	add	r30, r24
    17c0:	f9 1f       	adc	r31, r25
    17c2:	20 90 08 01 	lds	r2, 0x0108	;  0x800108
    17c6:	20 82       	st	Z, r2       ;            BYTE_ARRAY(0x0109)[RX_CNT-1] = RX_BYTE
    17c8:	80 91 70 01 	lds	r24, 0x0170	;  0x800170
    17cc:	8f 5f       	subi	r24, 0xFF	; 255
    17ce:	80 93 70 01 	sts	0x0170, r24	;  0x800170   RX_FRAME_CHECKER++
    17d2:	40 c0       	rjmp	.+128    	;  0x1854     goto END
lbl_reset_rx__cnt:
    17d4:	22 24       	eor	r2, r2
    17d6:	20 92 89 00 	sts	0x0089, r2	;  0x800089   RX_CNT = 0
    17da:	20 92 70 01 	sts	0x0170, r2	;  0x800170   RX_FRAME_CHECKER = 0
    17de:	3a c0       	rjmp	.+116    	;  0x1854     goto END

lbl_rx_check_frame_3rd_and_more_byte
    17e0:	00 91 89 00 	lds	r16, 0x0089	;  0x800089   
    17e4:	11 27       	eor	r17, r17
    17e6:	80 2f       	mov	r24, r16
    17e8:	8f 5f       	subi	r24, 0xFF	; 255
    17ea:	80 93 89 00 	sts	0x0089, r24	;  0x800089  RX_CNT++
    17ee:	89 e0       	ldi	r24, 0x09	; 9
    17f0:	91 e0       	ldi	r25, 0x01	; 1
    17f2:	e0 2f       	mov	r30, r16
    17f4:	ff 27       	eor	r31, r31
    17f6:	e8 0f       	add	r30, r24
    17f8:	f9 1f       	adc	r31, r25
    17fa:	20 90 08 01 	lds	r2, 0x0108	;  0x800108
    17fe:	20 82       	st	Z, r2       ;            BYTE_ARRAY(0x0109)[RX_CNT-1] = RX_BYTE
    1800:	80 91 89 00 	lds	r24, 0x0089	;  0x800089
    1804:	89 30       	cpi	r24, 0x09	; 9
    1806:	31 f5       	brne	.+76     	;  0x1854    if RX_CNT~=9 goto END
    1808:	80 91 70 01 	lds	r24, 0x0170	;  0x800170  if RX_CNT==9 RX_FRAME_CHECKER++ ===>  3
    180c:	8f 5f       	subi	r24, 0xFF	; 255
    180e:	80 93 70 01 	sts	0x0170, r24	;  0x800170
    1812:	20 c0       	rjmp	.+64     	;  0x1854    goto END
lbl_rx_check_frame_last_byte:
    1814:	00 91 09 01 	lds	r16, 0x0109	;  0x800109
    1818:	0a 3f       	cpi	r16, 0xFA	; 250
    181a:	11 f0       	breq	.+4      	;  0x1820    if BYTE(0x0109)==0xFA goto xxxxx
    181c:	0c 3f       	cpi	r16, 0xFC	; 252
    181e:	a9 f4       	brne	.+42     	;  0x184a    if BYTE(0x0109)~=0xFC goto lbl_reset_rx_status
    1820:	80 91 08 01 	lds	r24, 0x0108	;  0x800108
    1824:	8d 3e       	cpi	r24, 0xED	; 237
    1826:	71 f4       	brne	.+28     	;  0x1844    if RX_BYTE~=0xED goto lbl_mark_bad_frame
    1828:	89 e0       	ldi	r24, 0x09	; 9
    182a:	91 e0       	ldi	r25, 0x01	; 1
    182c:	e0 91 89 00 	lds	r30, 0x0089	;  0x800089
    1830:	ff 27       	eor	r31, r31
    1832:	e8 0f       	add	r30, r24
    1834:	f9 1f       	adc	r31, r25
    1836:	20 90 08 01 	lds	r2, 0x0108	;  0x800108
    183a:	20 82       	st	Z, r2       ;            BYTE_ARRAY(0x0109)[RX_CNT-1] = RX_BYTE
lbl_mark_good_frame:
    183c:	81 e0       	ldi	r24, 0x01	; 1
    183e:	80 93 8a 00 	sts	0x008A, r24	;  0x80008a  BOOL(0x008A) = TRUE
    1842:	03 c0       	rjmp	.+6      	;  0x184a    goto lbl_reset_rx_status
lbl_mark_bad_frame:
    1844:	22 24       	eor	r2, r2
    1846:	20 92 8a 00 	sts	0x008A, r2	;  0x80008a  BOOL(0x008A) = FALSE
lbl_reset_rx_status:
    184a:	22 24       	eor	r2, r2
    184c:	20 92 89 00 	sts	0x0089, r2	;  0x800089  RX_CNT = 0
    1850:	20 92 70 01 	sts	0x0170, r2	;  0x800170  RX_FRAME_CHECKER = 0
    1854:	22 24       	eor	r2, r2
    1856:	20 92 61 00 	sts	0x0061, r2	;  0x800061  BYTE(0x0061) = 0
    185a:	29 90       	ld	r2, Y+
    185c:	2f be       	out	0x3f, r2	; 63 pop SREG
    185e:	f9 91       	ld	r31, Y+
    1860:	e9 91       	ld	r30, Y+
    1862:	a9 91       	ld	r26, Y+
    1864:	99 91       	ld	r25, Y+
    1866:	89 91       	ld	r24, Y+
    1868:	19 91       	ld	r17, Y+
    186a:	09 91       	ld	r16, Y+
    186c:	39 90       	ld	r3, Y+
    186e:	29 90       	ld	r2, Y+
    1870:	18 95       	reti

0x1872_TX_send_byte(BYTE ch):
    1872:	0c b9       	out	0x0c, r16	; 12     UDR = ch
    1874:	5e 9b       	sbis	0x0b, 6	; 11     等待字节发送完毕 TXC位=1
    1876:	fe cf       	rjmp	.-4      	;  0x1874
    1878:	5e 9a       	sbi	0x0b, 6	; 11       clear bit TXC 
    187a:	08 95       	ret

0x187c_signed_mod(WORD x, WORD y ):     ;  <====>(x%y) ;;;; x=[r17, r16], y=[r19,r18], return [r17,r16] 有符号16位取余
    187c:	68 94       	set
    187e:	da 92       	st	-Y, r13
    1880:	d1 2e       	mov	r13, r17
    1882:	04 c0       	rjmp	.+8      	;  0x188c
0x1884_signed_div(WORD x, WORD y ):     ;  <====>(x/y) ;;;; x=[r17, r16], y=[r19,r18], return [r17,r16] 有符号16位除法
    1884:	e8 94       	clt             ;            Clear T in SREG
    1886:	da 92       	st	-Y, r13
    1888:	d1 2e       	mov	r13, r17    ;            r13  = r17       
    188a:	d3 26       	eor	r13, r19    ;            r13 ^= r19 ===> r13 = r17^r19
    188c:	17 ff       	sbrs	r17, 7    ;            if bit7_r17==1 goto lbl_r17_r16_negative 
    188e:	04 c0       	rjmp	.+8      	;  0x1898    bit7_r17==0  and goto lbl_r17_r16_positive 
lbl_r17_r16_negative:
    1890:	10 95       	com	r17         ;           
    1892:	00 95       	com	r16         ;            [r17,r16] = ~[r17,r16]
    1894:	0f 5f       	subi	r16, 0xFF	; 255 
    1896:	1f 4f       	sbci	r17, 0xFF	; 255        [r17,r16]++
lbl_r17_r16_positive:
    1898:	37 ff       	sbrs	r19, 7    ;            if bit7_r19==1 goto lbl_r19_r18_negative 
    189a:	04 c0       	rjmp	.+8      	;  0x18a4    bit7_r19==0 and goto lbl_r19_r18_positive
lbl_r19_r18_negative:                   ;             
    189c:	30 95       	com	r19
    189e:	20 95       	com	r18         ;            [r19,r18] = ~[r19,r18]
    18a0:	2f 5f       	subi	r18, 0xFF	; 255     
    18a2:	3f 4f       	sbci	r19, 0xFF	; 255        [r19,r18]++
lbl_r19_r18_positive:
    18a4:	0b d0       	rcall	.+22     	;  0x18bc    [r17,r16] = [r17, r16]/[r19,r18]
    18a6:	d7 fe       	sbrs	r13, 7    ;            if bit7_r13==1 goto lbl_result_negtive 
    18a8:	04 c0       	rjmp	.+8      	;  0x18b2    bit7_r13==0 and return
lbl_result_negtive:
    18aa:	10 95       	com	r17
    18ac:	00 95       	com	r16         ;            [r17,r16] = ~[r17,r16]
    18ae:	0f 5f       	subi	r16, 0xFF	; 255
    18b0:	1f 4f       	sbci	r17, 0xFF	; 255        [r17,r16]++
    18b2:	d9 90       	ld	r13, Y+
    18b4:	08 95       	ret

0x18b6_mod(WORD x, WORD y ):            ;  <====>(x%y) ;;;; x=[r17, r16], y=[r19,r18], return [r17,r16] 无符号16位取余
    18b6:	68 94       	set
    18b8:	01 c0       	rjmp	.+2      	;  0x18bc
0x18ba_div(WORD x, WORD y ):            ;  <====>(x/y) ;;;; x=[r17, r16], y=[r19,r18], return [r17,r16] 无符号16位除法
    18ba:	e8 94       	clt             ;                Clear T in SREG
    18bc:	ea 92       	st	-Y, r14
    18be:	fa 92       	st	-Y, r15
    18c0:	8a 93       	st	-Y, r24
    18c2:	ee 24       	eor	r14, r14
    18c4:	ff 24       	eor	r15, r15                   ; [r15,r14] = 0
    18c6:	80 e1       	ldi	r24, 0x10	; 16               r24 = 16
    
    18c8:	00 0f       	add	r16, r16                   
    18ca:	11 1f       	adc	r17, r17                     
    18cc:	ee 1c       	adc	r14, r14
    18ce:	ff 1c       	adc	r15, r15  ;                  [r15,r14,r17,r16]<<=1
    18d0:	e2 16       	cp	r14, r18
    18d2:	f3 06       	cpc	r15, r19
    18d4:	18 f0       	brcs	.+6      	;  0x18dc        if [r15,r14]<[r19,r18]

    18d6:	e2 1a       	sub	r14, r18   ;                 [r15,r14]>=[r19,r18] and [r15,r14] -= [r19,r18]
    18d8:	f3 0a       	sbc	r15, r19
    18da:	03 95       	inc	r16        ;                 r16 += 1      

    18dc:	8a 95       	dec	r24
    18de:	a1 f7       	brne	.-24     	;  0x18c8        if r24>0 goto loop
    18e0:	16 f4       	brtc	.+4      	;  0x18e6        if T==0 goto end 
    18e2:	0e 2d       	mov	r16, r14
    18e4:	1f 2d       	mov	r17, r15
    18e6:	89 91       	ld	r24, Y+
    18e8:	f9 90       	ld	r15, Y+
    18ea:	e9 90       	ld	r14, Y+
    18ec:	08 95       	ret

func_signed_32bit_div():                ; (x/y)  x = [r19,r18,r17,r16], y = [r27,r26,r25,r24] ==结果==> [r19,r18,r17,r16]
    18ee:	e8 94       	clt             ;  bit T = 0
    18f0:	01 c0       	rjmp	.+2      	;  0x18f4
    18f2:	68 94       	set

    18f4:	2f d0       	rcall	.+94     	;  0x1954      [r27,r26,r25,r24] = pop(Y) / r12 = r19^r27
    18f6:	cc 24       	eor	r12, r12    ;              r12 = 0
    18f8:	08 c0       	rjmp	.+16     	;  0x190a
    18fa:	e8 94       	clt
    18fc:	01 c0       	rjmp	.+2      	;  0x1900
    18fe:	68 94       	set
    1900:	29 d0       	rcall	.+82     	;  0x1954
    1902:	37 fd       	sbrc	r19, 7
    1904:	c6 d0       	rcall	.+396    	;  0x1a92
    1906:	b7 fd       	sbrc	r27, 7
    1908:	51 d0       	rcall	.+162    	;  0x19ac

    190a:	77 24       	eor	r7, r7
    190c:	88 24       	eor	r8, r8
    190e:	99 24       	eor	r9, r9
    1910:	aa 24       	eor	r10, r10     
    1912:	bb 24       	eor	r11, r11    ;         r7 = 0 / [r11,r10,r9,r8] = 0
    1914:	41 d0       	rcall	.+130    	;  0x1998 r30 = (r16|r17|r18|r19) 
    1916:	c1 f0       	breq	.+48     	;  0x1948 if [r19,r18,r17,r16] = 0 goto xxxx
    1918:	44 d0       	rcall	.+136    	;  0x19a2 r30 = (r27|r26|r25|r24)
    191a:	b1 f0       	breq	.+44     	;  0x1948 if [r27,r26,r25,r24]==0 goto xxxx
    191c:	e8 e2       	ldi	r30, 0x28	; 40        r30 = 40
    191e:	00 0f       	add	r16, r16
    1920:	11 1f       	adc	r17, r17
    1922:	22 1f       	adc	r18, r18
    1924:	33 1f       	adc	r19, r19    ;         [r19,r18,r17,r16] <<= 1
    1926:	77 1c       	adc	r7, r7
    1928:	88 1c       	adc	r8, r8
    192a:	99 1c       	adc	r9, r9
    192c:	aa 1c       	adc	r10, r10
    192e:	bb 1c       	adc	r11, r11
    1930:	88 16       	cp	r8, r24
    1932:	99 06       	cpc	r9, r25
    1934:	aa 06       	cpc	r10, r26
    1936:	bb 06       	cpc	r11, r27
    1938:	28 f0       	brcs	.+10     	;  0x1944
    193a:	88 1a       	sub	r8, r24
    193c:	99 0a       	sbc	r9, r25
    193e:	aa 0a       	sbc	r10, r26
    1940:	bb 0a       	sbc	r11, r27
    1942:	03 95       	inc	r16
    1944:	ea 95       	dec	r30
    1946:	59 f7       	brne	.-42     	;  0x191e

    1948:	26 f4       	brtc	.+8      	;  0x1952
    194a:	08 2d       	mov	r16, r8     ;  if bit T==1 则 32位有符号余数放入输出寄存器 [r19,r18,r17,r16]
    194c:	19 2d       	mov	r17, r9
    194e:	2a 2d       	mov	r18, r10
    1950:	3b 2d       	mov	r19, r11
    1952:	13 c0       	rjmp	.+38     	;  0x197a


    1954:	7a 92       	st	-Y, r7
    1956:	8a 92       	st	-Y, r8
    1958:	9a 92       	st	-Y, r9
    195a:	aa 92       	st	-Y, r10
    195c:	ba 92       	st	-Y, r11
    195e:	ca 92       	st	-Y, r12
    1960:	ea 93       	st	-Y, r30
    1962:	8a 93       	st	-Y, r24
    1964:	9a 93       	st	-Y, r25
    1966:	aa 93       	st	-Y, r26
    1968:	ba 93       	st	-Y, r27
    196a:	8b 85       	ldd	r24, Y+11	; 0x0b
    196c:	9c 85       	ldd	r25, Y+12	; 0x0c
    196e:	ad 85       	ldd	r26, Y+13	; 0x0d
    1970:	be 85       	ldd	r27, Y+14	; 0x0e
    1972:	c3 2e       	mov	r12, r19
    1974:	0e f0       	brts	.+2      	;  0x1978
    1976:	cb 26       	eor	r12, r27
    1978:	08 95       	ret


    197a:	c7 fc       	sbrc	r12, 7
    197c:	8a d0       	rcall	.+276    	;  0x1a92  if r12_bit7==1 则 [r19,r18,r17,r16] 取补码 即转为负数
    197e:	b9 91       	ld	r27, Y+
    1980:	a9 91       	ld	r26, Y+
    1982:	99 91       	ld	r25, Y+
    1984:	89 91       	ld	r24, Y+
    1986:	e9 91       	ld	r30, Y+
    1988:	c9 90       	ld	r12, Y+
    198a:	b9 90       	ld	r11, Y+
    198c:	a9 90       	ld	r10, Y+
    198e:	99 90       	ld	r9, Y+
    1990:	89 90       	ld	r8, Y+
    1992:	79 90       	ld	r7, Y+
    1994:	24 96       	adiw	r28, 0x04	; 4    ; Y += 4
    1996:	08 95       	ret

    1998:	e0 2f       	mov	r30, r16 ;       r30 = (r16|r17|r18|r19)
    199a:	e1 2b       	or	r30, r17
    199c:	e2 2b       	or	r30, r18
    199e:	e3 2b       	or	r30, r19
    19a0:	08 95       	ret

    19a2:	e8 2f       	mov	r30, r24 ;       r30 = (r27|r26|r25|r24)        
    19a4:	e9 2b       	or	r30, r25
    19a6:	ea 2b       	or	r30, r26
    19a8:	eb 2b       	or	r30, r27
    19aa:	08 95       	ret

    19ac:	80 95       	com	r24
    19ae:	90 95       	com	r25
    19b0:	a0 95       	com	r26
    19b2:	b0 95       	com	r27
    19b4:	8f 5f       	subi	r24, 0xFF	; 255
    19b6:	9f 4f       	sbci	r25, 0xFF	; 255
    19b8:	af 4f       	sbci	r26, 0xFF	; 255
    19ba:	bf 4f       	sbci	r27, 0xFF	; 255
    19bc:	08 95       	ret

0x19be_unsigned_word_multiply( WORD a, WORD b): ;; a = [r17,r16], b = [r19,r18] / return [r17,r16]
    19be:	0a 92       	st	-Y, r0
    19c0:	1a 92       	st	-Y, r1
    19c2:	8a 93       	st	-Y, r24
    19c4:	9a 93       	st	-Y, r25
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MUL: performs 8-bit × 8-bit → 16-bit unsigned multiplication
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Rd(8) * Rr(8) ----> R1(16H), R0(16L)
    19c6:	02 9f       	mul	r16, r18    ; r16*r18 = [r1, r0]
    19c8:	c0 01       	movw	r24, r0   ; [r25, r24] = [r1, r0]
    19ca:	12 9f       	mul	r17, r18    ; r17*r18 = [r1, r0]
    19cc:	90 0d       	add	r25, r0     ; r25 += r0
    19ce:	03 9f       	mul	r16, r19    ; r16*r19 = [r1, r0]
    19d0:	90 0d       	add	r25, r0     ; r25 += r0
    19d2:	8c 01       	movw	r16, r24  ; [r17, r16] = [r25, r24]
    19d4:	99 91       	ld	r25, Y+
    19d6:	89 91       	ld	r24, Y+
    19d8:	19 90       	ld	r1, Y+
    19da:	09 90       	ld	r0, Y+
    19dc:	08 95       	ret

;;;32位乘法(DWORD x, DWORD y):           ; x = [*(Y+3), *(Y+2), *(Y+1), *Y], y = [r19, r18, r17, r16] ==> 结果存入 [r19, r18, r17, r16]
    19de:	62 d0       	rcall	.+196    	;  0x1aa4   [r25,r24] = WORD(0x00AE) / [r26,r27] = 0
    19e0:	7a 92       	st	-Y, r7
    19e2:	79 d0       	rcall	.+242    	;  0x1ad6   r30 = (r16|r17|r18|r19)  ;;;此时 [r17,r16] = WORD(0x009C) / [r19,r18] = 0
    19e4:	51 f1       	breq	.+84     	;  0x1a3a   if([r17,r16]==[r19,r18]==0) ====> return
    19e6:	77 24       	eor	r7, r7
    19e8:	7c d0       	rcall	.+248    	;  0x1ae2   r30 = (r24|r25|r26|r27)
    19ea:	19 f4       	brne	.+6      	;  0x19f2   if([r25,r24]>0) goto xxxx
    19ec:	8c 01       	movw	r16, r24  ;           [r17,r16] = [r25,r24]
    19ee:	9d 01       	movw	r18, r26  ;           [r19,r18] = [r27,r26]
    19f0:	24 c0       	rjmp	.+72     	;  0x1a3a   ====> return

    19f2:	0a 92       	st	-Y, r0
    19f4:	1a 92       	st	-Y, r1
    19f6:	08 9f       	mul	r16, r24    ;  r16*r24 = [r1, r0]
    19f8:	b0 2c       	mov	r11, r0
    19fa:	a1 2c       	mov	r10, r1     ;  [r11,r10] = [r1,r0]
    19fc:	28 9f       	mul	r18, r24    ;  r18*r24 = [r1, r0]
    19fe:	90 2c       	mov	r9, r0
    1a00:	81 2c       	mov	r8, r1      ;  [r9,r8] = [r1,r0]
    1a02:	18 9f       	mul	r17, r24    
    1a04:	a0 0c       	add	r10, r0
    1a06:	91 1c       	adc	r9, r1
    1a08:	87 1c       	adc	r8, r7
    1a0a:	09 9f       	mul	r16, r25
    1a0c:	a0 0c       	add	r10, r0
    1a0e:	91 1c       	adc	r9, r1
    1a10:	87 1c       	adc	r8, r7
    1a12:	19 9f       	mul	r17, r25
    1a14:	90 0c       	add	r9, r0
    1a16:	81 1c       	adc	r8, r1
    1a18:	0a 9f       	mul	r16, r26
    1a1a:	90 0c       	add	r9, r0
    1a1c:	81 1c       	adc	r8, r1
    1a1e:	38 9f       	mul	r19, r24
    1a20:	80 0c       	add	r8, r0
    1a22:	29 9f       	mul	r18, r25
    1a24:	80 0c       	add	r8, r0
    1a26:	1a 9f       	mul	r17, r26
    1a28:	80 0c       	add	r8, r0
    1a2a:	0b 9f       	mul	r16, r27
    1a2c:	80 0c       	add	r8, r0
    1a2e:	19 90       	ld	r1, Y+
    1a30:	09 90       	ld	r0, Y+
    1a32:	0b 2d       	mov	r16, r11
    1a34:	1a 2d       	mov	r17, r10
    1a36:	29 2d       	mov	r18, r9
    1a38:	38 2d       	mov	r19, r8

    1a3a:	79 90       	ld	r7, Y+
    1a3c:	41 c0       	rjmp	.+130    	;  0x1ac0 goto lbl_1ac0_stack_push_and_return
    1a3e:	a9 90       	ld	r10, Y+
    1a40:	b9 90       	ld	r11, Y+
    1a42:	c9 90       	ld	r12, Y+
    1a44:	d9 90       	ld	r13, Y+
    1a46:	e9 90       	ld	r14, Y+
    1a48:	f9 90       	ld	r15, Y+
    1a4a:	08 95       	ret


    1a4c:	7a 93       	st	-Y, r23
    1a4e:	6a 93       	st	-Y, r22
    1a50:	5a 93       	st	-Y, r21
    1a52:	4a 93       	st	-Y, r20
    1a54:	fa 92       	st	-Y, r15
    1a56:	ea 92       	st	-Y, r14
    1a58:	da 92       	st	-Y, r13
    1a5a:	ca 92       	st	-Y, r12
    1a5c:	ba 92       	st	-Y, r11
    1a5e:	aa 92       	st	-Y, r10
    1a60:	08 95       	ret
    1a62:	7a 93       	st	-Y, r23
    1a64:	6a 93       	st	-Y, r22
    1a66:	5a 93       	st	-Y, r21
    1a68:	4a 93       	st	-Y, r20
    1a6a:	08 95       	ret
    1a6c:	49 91       	ld	r20, Y+
    1a6e:	59 91       	ld	r21, Y+
    1a70:	69 91       	ld	r22, Y+
    1a72:	79 91       	ld	r23, Y+
    1a74:	08 95       	ret


    1a76:	7a 93       	st	-Y, r23
    1a78:	6a 93       	st	-Y, r22
    1a7a:	5a 93       	st	-Y, r21
    1a7c:	4a 93       	st	-Y, r20
    1a7e:	ba 92       	st	-Y, r11
    1a80:	aa 92       	st	-Y, r10
    1a82:	08 95       	ret
    
    1a84:	a9 90       	ld	r10, Y+
    1a86:	b9 90       	ld	r11, Y+
    1a88:	49 91       	ld	r20, Y+
    1a8a:	59 91       	ld	r21, Y+
    1a8c:	69 91       	ld	r22, Y+
    1a8e:	79 91       	ld	r23, Y+
    1a90:	08 95       	ret

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  32位取补码： IN<==[r19,r18,r17,r16] / OUT==>[r19,r18,r17,r16]
    1a92:	00 95       	com	r16
    1a94:	10 95       	com	r17
    1a96:	20 95       	com	r18
    1a98:	30 95       	com	r19  ;              [r19,r18,r17,r16] = ~[r19,r18,r17,r16]
    1a9a:	0f 5f       	subi	r16, 0xFF	; 255
    1a9c:	1f 4f       	sbci	r17, 0xFF	; 255
    1a9e:	2f 4f       	sbci	r18, 0xFF	; 255
    1aa0:	3f 4f       	sbci	r19, 0xFF	; 255   [r19,r18,r17,r16] += 1
    1aa2:	08 95       	ret

    1aa4:	8a 92       	st	-Y, r8
    1aa6:	9a 92       	st	-Y, r9
    1aa8:	aa 92       	st	-Y, r10
    1aaa:	ba 92       	st	-Y, r11
    1aac:	ea 93       	st	-Y, r30
    1aae:	8a 93       	st	-Y, r24
    1ab0:	9a 93       	st	-Y, r25
    1ab2:	aa 93       	st	-Y, r26
    1ab4:	ba 93       	st	-Y, r27
    1ab6:	89 85       	ldd	r24, Y+9	; 0x09
    1ab8:	9a 85       	ldd	r25, Y+10	; 0x0a
    1aba:	ab 85       	ldd	r26, Y+11	; 0x0b
    1abc:	bc 85       	ldd	r27, Y+12	; 0x0c
    1abe:	08 95       	ret
lbl_1ac0_stack_push_and_return:
    1ac0:	b9 91       	ld	r27, Y+
    1ac2:	a9 91       	ld	r26, Y+
    1ac4:	99 91       	ld	r25, Y+
    1ac6:	89 91       	ld	r24, Y+
    1ac8:	e9 91       	ld	r30, Y+
    1aca:	b9 90       	ld	r11, Y+
    1acc:	a9 90       	ld	r10, Y+
    1ace:	99 90       	ld	r9, Y+
    1ad0:	89 90       	ld	r8, Y+
    1ad2:	24 96       	adiw	r28, 0x04	; 4   Y += 4
    1ad4:	08 95       	ret

    1ad6:	ee 27       	eor	r30, r30  ;   r30 = (r16|r17|r18|r19)
    1ad8:	e0 2b       	or	r30, r16
    1ada:	e1 2b       	or	r30, r17
    1adc:	e2 2b       	or	r30, r18
    1ade:	e3 2b       	or	r30, r19
    1ae0:	08 95       	ret
    1ae2:	ee 27       	eor	r30, r30  ;   r30 = (r24|r25|r26|r27)
    1ae4:	e8 2b       	or	r30, r24
    1ae6:	e9 2b       	or	r30, r25
    1ae8:	ea 2b       	or	r30, r26
    1aea:	eb 2b       	or	r30, r27
    1aec:	08 95       	ret


    1aee:	22 23       	and	r18, r18
    1af0:	21 f0       	breq	.+8      	;  0x1afa      if([r19,r18]==0) return
    1af2:	00 0f       	add	r16, r16    ;
    1af4:	11 1f       	adc	r17, r17    ;              [r17, r16] += [r17, r16] <===> [r17, r16]<<=1
    1af6:	2a 95       	dec	r18         ;              [r19,r18]--
    1af8:	fa cf       	rjmp	.-12     	;  0x1aee
    1afa:	08 95       	ret

    1afc:	0f 92       	push	r0
    1afe:	09 90       	ld	r0, Y+
    1b00:	00 20       	and	r0, r0
    1b02:	31 f0       	breq	.+12     	;  0x1b10
    1b04:	00 0f       	add	r16, r16
    1b06:	11 1f       	adc	r17, r17
    1b08:	22 1f       	adc	r18, r18
    1b0a:	33 1f       	adc	r19, r19
    1b0c:	0a 94       	dec	r0
    1b0e:	f8 cf       	rjmp	.-16     	;  0x1b00
    1b10:	0f 90       	pop	r0
    1b12:	08 95       	ret
	...
    1b40:	ff ff       	.word	0xffff	; ????
    1b42:	ff ff       	.word	0xffff	; ????
    1b44:	ff ff       	.word	0xffff	; ????
    1b46:	ff ff       	.word	0xffff	; ????
    1b48:	ff ff       	.word	0xffff	; ????
    1b4a:	ff ff       	.word	0xffff	; ????
    1b4c:	ff ff       	.word	0xffff	; ????
    1b4e:	ff ff       	.word	0xffff	; ????
    1b50:	ff ff       	.word	0xffff	; ????
    1b52:	ff ff       	.word	0xffff	; ????
    1b54:	ff ff       	.word	0xffff	; ????
    1b56:	ff ff       	.word	0xffff	; ????
    1b58:	ff ff       	.word	0xffff	; ????
    1b5a:	ff ff       	.word	0xffff	; ????
    1b5c:	ff ff       	.word	0xffff	; ????
    1b5e:	ff ff       	.word	0xffff	; ????
    1b60:	ff ff       	.word	0xffff	; ????
    1b62:	ff ff       	.word	0xffff	; ????
    1b64:	ff ff       	.word	0xffff	; ????
    1b66:	ff ff       	.word	0xffff	; ????
    1b68:	ff ff       	.word	0xffff	; ????
    1b6a:	ff ff       	.word	0xffff	; ????
    1b6c:	ff ff       	.word	0xffff	; ????
    1b6e:	ff ff       	.word	0xffff	; ????
    1b70:	ff ff       	.word	0xffff	; ????
    1b72:	ff ff       	.word	0xffff	; ????
    1b74:	ff ff       	.word	0xffff	; ????
    1b76:	ff ff       	.word	0xffff	; ????
    1b78:	ff ff       	.word	0xffff	; ????
    1b7a:	ff ff       	.word	0xffff	; ????
    1b7c:	ff ff       	.word	0xffff	; ????
    1b7e:	ff ff       	.word	0xffff	; ????
    1b80:	ff ff       	.word	0xffff	; ????
    1b82:	ff ff       	.word	0xffff	; ????
    1b84:	ff ff       	.word	0xffff	; ????
    1b86:	ff ff       	.word	0xffff	; ????
    1b88:	ff ff       	.word	0xffff	; ????
    1b8a:	ff ff       	.word	0xffff	; ????
    1b8c:	ff ff       	.word	0xffff	; ????
    1b8e:	ff ff       	.word	0xffff	; ????
    1b90:	ff ff       	.word	0xffff	; ????
    1b92:	ff ff       	.word	0xffff	; ????
    1b94:	ff ff       	.word	0xffff	; ????
    1b96:	ff ff       	.word	0xffff	; ????
    1b98:	ff ff       	.word	0xffff	; ????
    1b9a:	ff ff       	.word	0xffff	; ????
    1b9c:	ff ff       	.word	0xffff	; ????
    1b9e:	ff ff       	.word	0xffff	; ????
    1ba0:	ff ff       	.word	0xffff	; ????
    1ba2:	ff ff       	.word	0xffff	; ????
    1ba4:	ff ff       	.word	0xffff	; ????
    1ba6:	ff ff       	.word	0xffff	; ????
    1ba8:	ff ff       	.word	0xffff	; ????
    1baa:	ff ff       	.word	0xffff	; ????
    1bac:	ff ff       	.word	0xffff	; ????
    1bae:	ff ff       	.word	0xffff	; ????
    1bb0:	ff ff       	.word	0xffff	; ????
    1bb2:	ff ff       	.word	0xffff	; ????
    1bb4:	ff ff       	.word	0xffff	; ????
    1bb6:	ff ff       	.word	0xffff	; ????
    1bb8:	ff ff       	.word	0xffff	; ????
    1bba:	ff ff       	.word	0xffff	; ????
    1bbc:	ff ff       	.word	0xffff	; ????
    1bbe:	ff ff       	.word	0xffff	; ????
    1bc0:	ff ff       	.word	0xffff	; ????
    1bc2:	ff ff       	.word	0xffff	; ????
    1bc4:	ff ff       	.word	0xffff	; ????
    1bc6:	ff ff       	.word	0xffff	; ????
    1bc8:	ff ff       	.word	0xffff	; ????
    1bca:	ff ff       	.word	0xffff	; ????
    1bcc:	ff ff       	.word	0xffff	; ????
    1bce:	ff ff       	.word	0xffff	; ????
    1bd0:	ff ff       	.word	0xffff	; ????
    1bd2:	ff ff       	.word	0xffff	; ????
    1bd4:	ff ff       	.word	0xffff	; ????
    1bd6:	ff ff       	.word	0xffff	; ????
    1bd8:	ff ff       	.word	0xffff	; ????
    1bda:	ff ff       	.word	0xffff	; ????
    1bdc:	ff ff       	.word	0xffff	; ????
    1bde:	ff ff       	.word	0xffff	; ????
    1be0:	ff ff       	.word	0xffff	; ????
    1be2:	ff ff       	.word	0xffff	; ????
    1be4:	ff ff       	.word	0xffff	; ????
    1be6:	ff ff       	.word	0xffff	; ????
    1be8:	ff ff       	.word	0xffff	; ????
    1bea:	ff ff       	.word	0xffff	; ????
    1bec:	ff ff       	.word	0xffff	; ????
    1bee:	ff ff       	.word	0xffff	; ????
    1bf0:	ff ff       	.word	0xffff	; ????
    1bf2:	ff ff       	.word	0xffff	; ????
    1bf4:	ff ff       	.word	0xffff	; ????
    1bf6:	ff ff       	.word	0xffff	; ????
    1bf8:	ff ff       	.word	0xffff	; ????
    1bfa:	ff ff       	.word	0xffff	; ????
    1bfc:	ff ff       	.word	0xffff	; ????
    1bfe:	ff ff       	.word	0xffff	; ????


    1c00:	13 c0       	rjmp	.+38     	;  0x1c28
    1c02:	ff ff       	.word	0xffff	; ????
    1c04:	ff ff       	.word	0xffff	; ????
    1c06:	ff ff       	.word	0xffff	; ????
    1c08:	ff ff       	.word	0xffff	; ????
    1c0a:	ff ff       	.word	0xffff	; ????
    1c0c:	ff ff       	.word	0xffff	; ????
    1c0e:	ff ff       	.word	0xffff	; ????
    1c10:	ff ff       	.word	0xffff	; ????
    1c12:	ff ff       	.word	0xffff	; ????
    1c14:	ff ff       	.word	0xffff	; ????
    1c16:	ff ff       	.word	0xffff	; ????
    1c18:	ff ff       	.word	0xffff	; ????
    1c1a:	ff ff       	.word	0xffff	; ????
    1c1c:	ff ff       	.word	0xffff	; ????
    1c1e:	ff ff       	.word	0xffff	; ????
    1c20:	ff ff       	.word	0xffff	; ????
    1c22:	ff ff       	.word	0xffff	; ????
    1c24:	ff ff       	.word	0xffff	; ????
    1c26:	00 ff       	sbrs	r16, 0
    1c28:	01 e0       	ldi	r16, 0x01	; 1
    1c2a:	05 bf       	out	0x35, r16	; 53
    1c2c:	02 e0       	ldi	r16, 0x02	; 2
    1c2e:	05 bf       	out	0x35, r16	; 53
    1c30:	cf e5       	ldi	r28, 0x5F	; 95
    1c32:	d4 e0       	ldi	r29, 0x04	; 4
    1c34:	cd bf       	out	0x3d, r28	; 61
    1c36:	de bf       	out	0x3e, r29	; 62
    1c38:	ce 51       	subi	r28, 0x1E	; 30
    1c3a:	d0 40       	sbci	r29, 0x00	; 0
    1c3c:	0a ea       	ldi	r16, 0xAA	; 170
    1c3e:	08 83       	st	Y, r16
    1c40:	00 24       	eor	r0, r0
    1c42:	e1 e6       	ldi	r30, 0x61	; 97
    1c44:	f0 e0       	ldi	r31, 0x00	; 0
    1c46:	10 e0       	ldi	r17, 0x00	; 0
    1c48:	e1 3b       	cpi	r30, 0xB1	; 177
    1c4a:	f1 07       	cpc	r31, r17
    1c4c:	11 f0       	breq	.+4      	;  0x1c52
    1c4e:	01 92       	st	Z+, r0
    1c50:	fb cf       	rjmp	.-10     	;  0x1c48
    1c52:	00 83       	st	Z, r16
    1c54:	e6 e2       	ldi	r30, 0x26	; 38
    1c56:	fc e1       	ldi	r31, 0x1C	; 28
    1c58:	a0 e6       	ldi	r26, 0x60	; 96
    1c5a:	b0 e0       	ldi	r27, 0x00	; 0
    1c5c:	1c e1       	ldi	r17, 0x1C	; 28
    1c5e:	00 e0       	ldi	r16, 0x00	; 0
    1c60:	0b bf       	out	0x3b, r16	; 59
    1c62:	e7 32       	cpi	r30, 0x27	; 39
    1c64:	f1 07       	cpc	r31, r17
    1c66:	21 f0       	breq	.+8      	;  0x1c70
    1c68:	c8 95       	lpm
    1c6a:	31 96       	adiw	r30, 0x01	; 1
    1c6c:	0d 92       	st	X+, r0
    1c6e:	f9 cf       	rjmp	.-14     	;  0x1c62
    1c70:	4f d1       	rcall	.+670    	;  0x1f10
    1c72:	ff cf       	rjmp	.-2      	;  0x1c72
    1c74:	1f d0       	rcall	.+62     	;  0x1cb4
    1c76:	f8 01       	movw	r30, r16
    1c78:	20 93 57 00 	sts	0x0057, r18	;  0x800057
    1c7c:	e8 95       	spm
    1c7e:	08 95       	ret
    1c80:	19 d0       	rcall	.+50     	;  0x1cb4
    1c82:	f9 01       	movw	r30, r18
    1c84:	08 01       	movw	r0, r16
    1c86:	31 e0       	ldi	r19, 0x01	; 1
    1c88:	30 93 57 00 	sts	0x0057, r19	;  0x800057
    1c8c:	e8 95       	spm
    1c8e:	08 95       	ret
    1c90:	f1 2f       	mov	r31, r17
    1c92:	e0 2f       	mov	r30, r16
    1c94:	04 91       	lpm	r16, Z
    1c96:	11 27       	eor	r17, r17
    1c98:	08 95       	ret
    1c9a:	f8 01       	movw	r30, r16
    1c9c:	20 fd       	sbrc	r18, 0
    1c9e:	20 93 57 00 	sts	0x0057, r18	;  0x800057
    1ca2:	05 91       	lpm	r16, Z+
    1ca4:	14 91       	lpm	r17, Z
    1ca6:	08 95       	ret
    1ca8:	05 d0       	rcall	.+10     	;  0x1cb4
    1caa:	b1 e1       	ldi	r27, 0x11	; 17
    1cac:	b0 93 57 00 	sts	0x0057, r27	;  0x800057
    1cb0:	e8 95       	spm
    1cb2:	08 95       	ret
    1cb4:	b0 91 57 00 	lds	r27, 0x0057	;  0x800057
    1cb8:	b0 fd       	sbrc	r27, 0
    1cba:	fc cf       	rjmp	.-8      	;  0x1cb4
    1cbc:	08 95       	ret
    1cbe:	81 e0       	ldi	r24, 0x01	; 1
    1cc0:	8b bf       	out	0x3b, r24	; 59
    1cc2:	22 24       	eor	r2, r2
    1cc4:	2b be       	out	0x3b, r2	; 59
    1cc6:	0c 94 00 00 	jmp	0	;  0x0
    1cca:	08 95       	ret
    1ccc:	f8 94       	cli
    1cce:	22 24       	eor	r2, r2
    1cd0:	28 ba       	out	0x18, r2	; 24
    1cd2:	83 e0       	ldi	r24, 0x03	; 3
    1cd4:	87 bb       	out	0x17, r24	; 23
    1cd6:	25 ba       	out	0x15, r2	; 21
    1cd8:	24 ba       	out	0x14, r2	; 20
    1cda:	8c e0       	ldi	r24, 0x0C	; 12
    1cdc:	82 bb       	out	0x12, r24	; 18
    1cde:	81 bb       	out	0x11, r24	; 17
    1ce0:	2a b8       	out	0x0a, r2	; 10
    1ce2:	82 e0       	ldi	r24, 0x02	; 2
    1ce4:	8b b9       	out	0x0b, r24	; 11
    1ce6:	86 e8       	ldi	r24, 0x86	; 134
    1ce8:	80 bd       	out	0x20, r24	; 32
    1cea:	8f e0       	ldi	r24, 0x0F	; 15
    1cec:	89 b9       	out	0x09, r24	; 9
    1cee:	20 bc       	out	0x20, r2	; 32
    1cf0:	88 e1       	ldi	r24, 0x18	; 24
    1cf2:	8a b9       	out	0x0a, r24	; 10
    1cf4:	84 ee       	ldi	r24, 0xE4	; 228
    1cf6:	84 bd       	out	0x24, r24	; 36
    1cf8:	8c e1       	ldi	r24, 0x1C	; 28
    1cfa:	83 bd       	out	0x23, r24	; 35
    1cfc:	8e e0       	ldi	r24, 0x0E	; 14
    1cfe:	85 bd       	out	0x25, r24	; 37
    1d00:	25 be       	out	0x35, r2	; 53
    1d02:	2b be       	out	0x3b, r2	; 59
    1d04:	29 be       	out	0x39, r2	; 57
    1d06:	08 95       	ret
    1d08:	aa 92       	st	-Y, r10
    1d0a:	ca 92       	st	-Y, r12
    1d0c:	aa 24       	eor	r10, r10
    1d0e:	cc 24       	eor	r12, r12
    1d10:	07 c0       	rjmp	.+14     	;  0x1d20
    1d12:	ec 2d       	mov	r30, r12
    1d14:	ff 27       	eor	r31, r31
    1d16:	e2 0f       	add	r30, r18
    1d18:	f3 1f       	adc	r31, r19
    1d1a:	20 80       	ld	r2, Z
    1d1c:	a2 0c       	add	r10, r2
    1d1e:	c3 94       	inc	r12
    1d20:	c0 16       	cp	r12, r16
    1d22:	b8 f3       	brcs	.-18     	;  0x1d12
    1d24:	0a 2d       	mov	r16, r10
    1d26:	c9 90       	ld	r12, Y+
    1d28:	a9 90       	ld	r10, Y+
    1d2a:	08 95       	ret
    1d2c:	5f 9b       	sbis	0x0b, 7	; 11
    1d2e:	fe cf       	rjmp	.-4      	;  0x1d2c
    1d30:	0c b1       	in	r16, 0x0c	; 12
    1d32:	08 95       	ret
    1d34:	0c b9       	out	0x0c, r16	; 12
    1d36:	5e 9b       	sbis	0x0b, 6	; 11
    1d38:	fe cf       	rjmp	.-4      	;  0x1d36
    1d3a:	5e 9a       	sbi	0x0b, 6	; 11
    1d3c:	08 95       	ret
    1d3e:	00 27       	eor	r16, r16
    1d40:	28 ec       	ldi	r18, 0xC8	; 200
    1d42:	5f 9b       	sbis	0x0b, 7	; 11
    1d44:	0f c0       	rjmp	.+30     	;  0x1d64
    1d46:	20 2e       	mov	r2, r16
    1d48:	33 24       	eor	r3, r3
    1d4a:	0f 5f       	subi	r16, 0xFF	; 255
    1d4c:	81 e6       	ldi	r24, 0x61	; 97
    1d4e:	90 e0       	ldi	r25, 0x00	; 0
    1d50:	e2 2d       	mov	r30, r2
    1d52:	ff 27       	eor	r31, r31
    1d54:	e8 0f       	add	r30, r24
    1d56:	f9 1f       	adc	r31, r25
    1d58:	2c b0       	in	r2, 0x0c	; 12
    1d5a:	20 82       	st	Z, r2
    1d5c:	07 34       	cpi	r16, 0x47	; 71
    1d5e:	08 f0       	brcs	.+2      	;  0x1d62
    1d60:	0a c0       	rjmp	.+20     	;  0x1d76
    1d62:	2a e0       	ldi	r18, 0x0A	; 10
    1d64:	28 b6       	in	r2, 0x38	; 56
    1d66:	27 fe       	sbrs	r2, 7
    1d68:	04 c0       	rjmp	.+8      	;  0x1d72
    1d6a:	88 b7       	in	r24, 0x38	; 56
    1d6c:	80 68       	ori	r24, 0x80	; 128
    1d6e:	88 bf       	out	0x38, r24	; 56
    1d70:	2a 95       	dec	r18
    1d72:	22 23       	and	r18, r18
    1d74:	31 f7       	brne	.-52     	;  0x1d42
    1d76:	08 95       	ret
    1d78:	26 d1       	rcall	.+588    	;  0x1fc6
    1d7a:	21 97       	sbiw	r28, 0x01	; 1
    1d7c:	00 24       	eor	r0, r0
    1d7e:	08 82       	st	Y, r0
    1d80:	de df       	rcall	.-68     	;  0x1d3e
    1d82:	07 34       	cpi	r16, 0x47	; 71
    1d84:	09 f0       	breq	.+2      	;  0x1d88
    1d86:	c2 c0       	rjmp	.+388    	;  0x1f0c
    1d88:	80 91 61 00 	lds	r24, 0x0061	;  0x800061
    1d8c:	8d 3f       	cpi	r24, 0xFD	; 253
    1d8e:	09 f0       	breq	.+2      	;  0x1d92
    1d90:	b9 c0       	rjmp	.+370    	;  0x1f04
    1d92:	80 91 62 00 	lds	r24, 0x0062	;  0x800062
    1d96:	8f 3d       	cpi	r24, 0xDF	; 223
    1d98:	09 f0       	breq	.+2      	;  0x1d9c
    1d9a:	b4 c0       	rjmp	.+360    	;  0x1f04
    1d9c:	80 91 a7 00 	lds	r24, 0x00A7	;  0x8000a7
    1da0:	8d 3e       	cpi	r24, 0xED	; 237
    1da2:	09 f0       	breq	.+2      	;  0x1da6
    1da4:	af c0       	rjmp	.+350    	;  0x1f04
    1da6:	20 90 60 00 	lds	r2, 0x0060	;  0x800060
    1daa:	30 90 63 00 	lds	r3, 0x0063	;  0x800063
    1dae:	32 14       	cp	r3, r2
    1db0:	09 f0       	breq	.+2      	;  0x1db4
    1db2:	a8 c0       	rjmp	.+336    	;  0x1f04
    1db4:	23 e6       	ldi	r18, 0x63	; 99
    1db6:	30 e0       	ldi	r19, 0x00	; 0
    1db8:	03 e4       	ldi	r16, 0x43	; 67
    1dba:	a6 df       	rcall	.-180    	;  0x1d08
    1dbc:	20 90 a6 00 	lds	r2, 0x00A6	;  0x8000a6
    1dc0:	20 16       	cp	r2, r16
    1dc2:	09 f0       	breq	.+2      	;  0x1dc6
    1dc4:	9f c0       	rjmp	.+318    	;  0x1f04
    1dc6:	8e ee       	ldi	r24, 0xEE	; 238
    1dc8:	a8 2e       	mov	r10, r24
    1dca:	80 91 64 00 	lds	r24, 0x0064	;  0x800064
    1dce:	81 30       	cpi	r24, 0x01	; 1
    1dd0:	09 f0       	breq	.+2      	;  0x1dd4
    1dd2:	5b c0       	rjmp	.+182    	;  0x1e8a
    1dd4:	80 91 65 00 	lds	r24, 0x0065	;  0x800065
    1dd8:	80 37       	cpi	r24, 0x70	; 112
    1dda:	08 f0       	brcs	.+2      	;  0x1dde
    1ddc:	5f c0       	rjmp	.+190    	;  0x1e9c
    1dde:	c0 90 65 00 	lds	r12, 0x0065	;  0x800065
    1de2:	dd 24       	eor	r13, r13
    1de4:	26 e0       	ldi	r18, 0x06	; 6
    1de6:	30 e0       	ldi	r19, 0x00	; 0
    1de8:	86 01       	movw	r16, r12
    1dea:	f8 d0       	rcall	.+496    	;  0x1fdc
    1dec:	68 01       	movw	r12, r16
    1dee:	66 27       	eor	r22, r22
    1df0:	19 c0       	rjmp	.+50     	;  0x1e24
    1df2:	87 e6       	ldi	r24, 0x67	; 103
    1df4:	90 e0       	ldi	r25, 0x00	; 0
    1df6:	e6 2f       	mov	r30, r22
    1df8:	ff 27       	eor	r31, r31
    1dfa:	e8 0f       	add	r30, r24
    1dfc:	f9 1f       	adc	r31, r25
    1dfe:	e0 80       	ld	r14, Z
    1e00:	ff 24       	eor	r15, r15
    1e02:	fe 2c       	mov	r15, r14
    1e04:	ee 24       	eor	r14, r14
    1e06:	86 e6       	ldi	r24, 0x66	; 102
    1e08:	90 e0       	ldi	r25, 0x00	; 0
    1e0a:	e6 2f       	mov	r30, r22
    1e0c:	ff 27       	eor	r31, r31
    1e0e:	e8 0f       	add	r30, r24
    1e10:	f9 1f       	adc	r31, r25
    1e12:	20 80       	ld	r2, Z
    1e14:	33 24       	eor	r3, r3
    1e16:	e2 0c       	add	r14, r2
    1e18:	f3 1c       	adc	r15, r3
    1e1a:	26 2f       	mov	r18, r22
    1e1c:	33 27       	eor	r19, r19
    1e1e:	87 01       	movw	r16, r14
    1e20:	2f df       	rcall	.-418    	;  0x1c80
    1e22:	6e 5f       	subi	r22, 0xFE	; 254
    1e24:	60 34       	cpi	r22, 0x40	; 64
    1e26:	28 f3       	brcs	.-54     	;  0x1df2
    1e28:	23 e0       	ldi	r18, 0x03	; 3
    1e2a:	86 01       	movw	r16, r12
    1e2c:	23 df       	rcall	.-442    	;  0x1c74
    1e2e:	25 e0       	ldi	r18, 0x05	; 5
    1e30:	86 01       	movw	r16, r12
    1e32:	20 df       	rcall	.-448    	;  0x1c74
    1e34:	39 df       	rcall	.-398    	;  0x1ca8
    1e36:	8a ea       	ldi	r24, 0xAA	; 170
    1e38:	a8 2e       	mov	r10, r24
    1e3a:	66 27       	eor	r22, r22
    1e3c:	23 c0       	rjmp	.+70     	;  0x1e84
    1e3e:	22 27       	eor	r18, r18
    1e40:	26 2e       	mov	r2, r22
    1e42:	33 24       	eor	r3, r3
    1e44:	86 01       	movw	r16, r12
    1e46:	02 0d       	add	r16, r2
    1e48:	13 1d       	adc	r17, r3
    1e4a:	27 df       	rcall	.-434    	;  0x1c9a
    1e4c:	a8 01       	movw	r20, r16
    1e4e:	87 e6       	ldi	r24, 0x67	; 103
    1e50:	90 e0       	ldi	r25, 0x00	; 0
    1e52:	e6 2f       	mov	r30, r22
    1e54:	ff 27       	eor	r31, r31
    1e56:	e8 0f       	add	r30, r24
    1e58:	f9 1f       	adc	r31, r25
    1e5a:	e0 80       	ld	r14, Z
    1e5c:	ff 24       	eor	r15, r15
    1e5e:	fe 2c       	mov	r15, r14
    1e60:	ee 24       	eor	r14, r14
    1e62:	86 e6       	ldi	r24, 0x66	; 102
    1e64:	90 e0       	ldi	r25, 0x00	; 0
    1e66:	e6 2f       	mov	r30, r22
    1e68:	ff 27       	eor	r31, r31
    1e6a:	e8 0f       	add	r30, r24
    1e6c:	f9 1f       	adc	r31, r25
    1e6e:	20 80       	ld	r2, Z
    1e70:	33 24       	eor	r3, r3
    1e72:	e2 0c       	add	r14, r2
    1e74:	f3 1c       	adc	r15, r3
    1e76:	e0 16       	cp	r14, r16
    1e78:	f1 06       	cpc	r15, r17
    1e7a:	19 f0       	breq	.+6      	;  0x1e82
    1e7c:	8e ee       	ldi	r24, 0xEE	; 238
    1e7e:	a8 2e       	mov	r10, r24
    1e80:	0d c0       	rjmp	.+26     	;  0x1e9c
    1e82:	6e 5f       	subi	r22, 0xFE	; 254
    1e84:	60 34       	cpi	r22, 0x40	; 64
    1e86:	d8 f2       	brcs	.-74     	;  0x1e3e
    1e88:	09 c0       	rjmp	.+18     	;  0x1e9c
    1e8a:	80 91 64 00 	lds	r24, 0x0064	;  0x800064
    1e8e:	82 30       	cpi	r24, 0x02	; 2
    1e90:	29 f4       	brne	.+10     	;  0x1e9c
    1e92:	8a ea       	ldi	r24, 0xAA	; 170
    1e94:	a8 2e       	mov	r10, r24
    1e96:	00 24       	eor	r0, r0
    1e98:	03 94       	inc	r0
    1e9a:	08 82       	st	Y, r0
    1e9c:	93 9a       	sbi	0x12, 3	; 18
    1e9e:	82 b3       	in	r24, 0x12	; 18
    1ea0:	8b 7f       	andi	r24, 0xFB	; 251
    1ea2:	82 bb       	out	0x12, r24	; 18
    1ea4:	8d ef       	ldi	r24, 0xFD	; 253
    1ea6:	80 93 61 00 	sts	0x0061, r24	;  0x800061
    1eaa:	8f ed       	ldi	r24, 0xDF	; 223
    1eac:	80 93 62 00 	sts	0x0062, r24	;  0x800062
    1eb0:	20 90 60 00 	lds	r2, 0x0060	;  0x800060
    1eb4:	20 92 63 00 	sts	0x0063, r2	;  0x800063
    1eb8:	a0 92 64 00 	sts	0x0064, r10	;  0x800064
    1ebc:	22 24       	eor	r2, r2
    1ebe:	20 92 65 00 	sts	0x0065, r2	;  0x800065
    1ec2:	20 92 66 00 	sts	0x0066, r2	;  0x800066
    1ec6:	20 92 67 00 	sts	0x0067, r2	;  0x800067
    1eca:	20 92 68 00 	sts	0x0068, r2	;  0x800068
    1ece:	23 e6       	ldi	r18, 0x63	; 99
    1ed0:	30 e0       	ldi	r19, 0x00	; 0
    1ed2:	06 e0       	ldi	r16, 0x06	; 6
    1ed4:	19 df       	rcall	.-462    	;  0x1d08
    1ed6:	a0 2e       	mov	r10, r16
    1ed8:	a0 92 69 00 	sts	0x0069, r10	;  0x800069
    1edc:	8d ee       	ldi	r24, 0xED	; 237
    1ede:	80 93 6a 00 	sts	0x006A, r24	;  0x80006a
    1ee2:	66 27       	eor	r22, r22
    1ee4:	09 c0       	rjmp	.+18     	;  0x1ef8
    1ee6:	81 e6       	ldi	r24, 0x61	; 97
    1ee8:	90 e0       	ldi	r25, 0x00	; 0
    1eea:	e6 2f       	mov	r30, r22
    1eec:	ff 27       	eor	r31, r31
    1eee:	e8 0f       	add	r30, r24
    1ef0:	f9 1f       	adc	r31, r25
    1ef2:	00 81       	ld	r16, Z
    1ef4:	1f df       	rcall	.-450    	;  0x1d34
    1ef6:	63 95       	inc	r22
    1ef8:	6a 30       	cpi	r22, 0x0A	; 10
    1efa:	a8 f3       	brcs	.-22     	;  0x1ee6
    1efc:	92 9a       	sbi	0x12, 2	; 18
    1efe:	82 b3       	in	r24, 0x12	; 18
    1f00:	87 7f       	andi	r24, 0xF7	; 247
    1f02:	82 bb       	out	0x12, r24	; 18
    1f04:	08 80       	ld	r0, Y
    1f06:	00 20       	and	r0, r0
    1f08:	09 f0       	breq	.+2      	;  0x1f0c
    1f0a:	d9 de       	rcall	.-590    	;  0x1cbe
    1f0c:	21 96       	adiw	r28, 0x01	; 1
    1f0e:	50 c0       	rjmp	.+160    	;  0x1fb0
    1f10:	dd de       	rcall	.-582    	;  0x1ccc
    1f12:	0a e0       	ldi	r16, 0x0A	; 10
    1f14:	10 e0       	ldi	r17, 0x00	; 0
    1f16:	69 d0       	rcall	.+210    	;  0x1fea
    1f18:	00 93 60 00 	sts	0x0060, r16	;  0x800060
    1f1c:	93 9a       	sbi	0x12, 3	; 18
    1f1e:	82 b3       	in	r24, 0x12	; 18
    1f20:	8b 7f       	andi	r24, 0xFB	; 251
    1f22:	82 bb       	out	0x12, r24	; 18
    1f24:	8c ef       	ldi	r24, 0xFC	; 252
    1f26:	80 93 61 00 	sts	0x0061, r24	;  0x800061
    1f2a:	8f ec       	ldi	r24, 0xCF	; 207
    1f2c:	80 93 62 00 	sts	0x0062, r24	;  0x800062
    1f30:	20 2e       	mov	r2, r16
    1f32:	20 92 63 00 	sts	0x0063, r2	;  0x800063
    1f36:	8a ea       	ldi	r24, 0xAA	; 170
    1f38:	80 93 64 00 	sts	0x0064, r24	;  0x800064
    1f3c:	00 e0       	ldi	r16, 0x00	; 0
    1f3e:	15 e0       	ldi	r17, 0x05	; 5
    1f40:	a7 de       	rcall	.-690    	;  0x1c90
    1f42:	00 93 65 00 	sts	0x0065, r16	;  0x800065
    1f46:	01 e0       	ldi	r16, 0x01	; 1
    1f48:	15 e0       	ldi	r17, 0x05	; 5
    1f4a:	a2 de       	rcall	.-700    	;  0x1c90
    1f4c:	a0 2e       	mov	r10, r16
    1f4e:	a0 92 66 00 	sts	0x0066, r10	;  0x800066
    1f52:	02 e0       	ldi	r16, 0x02	; 2
    1f54:	15 e0       	ldi	r17, 0x05	; 5
    1f56:	9c de       	rcall	.-712    	;  0x1c90
    1f58:	a0 2e       	mov	r10, r16
    1f5a:	a0 92 67 00 	sts	0x0067, r10	;  0x800067
    1f5e:	03 e0       	ldi	r16, 0x03	; 3
    1f60:	15 e0       	ldi	r17, 0x05	; 5
    1f62:	96 de       	rcall	.-724    	;  0x1c90
    1f64:	a0 2e       	mov	r10, r16
    1f66:	a0 92 68 00 	sts	0x0068, r10	;  0x800068
    1f6a:	23 e6       	ldi	r18, 0x63	; 99
    1f6c:	30 e0       	ldi	r19, 0x00	; 0
    1f6e:	06 e0       	ldi	r16, 0x06	; 6
    1f70:	cb de       	rcall	.-618    	;  0x1d08
    1f72:	a0 2e       	mov	r10, r16
    1f74:	a0 92 69 00 	sts	0x0069, r10	;  0x800069
    1f78:	8d ee       	ldi	r24, 0xED	; 237
    1f7a:	80 93 6a 00 	sts	0x006A, r24	;  0x80006a
    1f7e:	44 27       	eor	r20, r20
    1f80:	09 c0       	rjmp	.+18     	;  0x1f94
    1f82:	81 e6       	ldi	r24, 0x61	; 97
    1f84:	90 e0       	ldi	r25, 0x00	; 0
    1f86:	e4 2f       	mov	r30, r20
    1f88:	ff 27       	eor	r31, r31
    1f8a:	e8 0f       	add	r30, r24
    1f8c:	f9 1f       	adc	r31, r25
    1f8e:	00 81       	ld	r16, Z
    1f90:	d1 de       	rcall	.-606    	;  0x1d34
    1f92:	43 95       	inc	r20
    1f94:	4a 30       	cpi	r20, 0x0A	; 10
    1f96:	a8 f3       	brcs	.-22     	;  0x1f82
    1f98:	92 9a       	sbi	0x12, 2	; 18
    1f9a:	82 b3       	in	r24, 0x12	; 18
    1f9c:	87 7f       	andi	r24, 0xF7	; 247
    1f9e:	82 bb       	out	0x12, r24	; 18
    1fa0:	05 c0       	rjmp	.+10     	;  0x1fac
    1fa2:	ea de       	rcall	.-556    	;  0x1d78
    1fa4:	81 e0       	ldi	r24, 0x01	; 1
    1fa6:	28 b2       	in	r2, 0x18	; 24
    1fa8:	28 26       	eor	r2, r24
    1faa:	28 ba       	out	0x18, r2	; 24
    1fac:	fa cf       	rjmp	.-12     	;  0x1fa2
    1fae:	08 95       	ret
    1fb0:	a9 90       	ld	r10, Y+
    1fb2:	b9 90       	ld	r11, Y+
    1fb4:	c9 90       	ld	r12, Y+
    1fb6:	d9 90       	ld	r13, Y+
    1fb8:	e9 90       	ld	r14, Y+
    1fba:	f9 90       	ld	r15, Y+
    1fbc:	49 91       	ld	r20, Y+
    1fbe:	59 91       	ld	r21, Y+
    1fc0:	69 91       	ld	r22, Y+
    1fc2:	79 91       	ld	r23, Y+
    1fc4:	08 95       	ret
    1fc6:	7a 93       	st	-Y, r23
    1fc8:	6a 93       	st	-Y, r22
    1fca:	5a 93       	st	-Y, r21
    1fcc:	4a 93       	st	-Y, r20
    1fce:	fa 92       	st	-Y, r15
    1fd0:	ea 92       	st	-Y, r14
    1fd2:	da 92       	st	-Y, r13
    1fd4:	ca 92       	st	-Y, r12
    1fd6:	ba 92       	st	-Y, r11
    1fd8:	aa 92       	st	-Y, r10
    1fda:	08 95       	ret
    1fdc:	22 23       	and	r18, r18
    1fde:	21 f0       	breq	.+8      	;  0x1fe8
    1fe0:	00 0f       	add	r16, r16
    1fe2:	11 1f       	adc	r17, r17
    1fe4:	2a 95       	dec	r18
    1fe6:	fa cf       	rjmp	.-12     	;  0x1fdc
    1fe8:	08 95       	ret
    1fea:	e1 99       	sbic	0x1c, 1	; 28
    1fec:	fe cf       	rjmp	.-4      	;  0x1fea
    1fee:	1f bb       	out	0x1f, r17	; 31
    1ff0:	0e bb       	out	0x1e, r16	; 30
    1ff2:	e0 9a       	sbi	0x1c, 0	; 28
    1ff4:	0d b3       	in	r16, 0x1d	; 29
    1ff6:	08 95       	ret
