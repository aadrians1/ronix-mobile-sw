	QP - quick programmer version 2.01.

	To install under DOS.

1. Connect the programmer with PC.
2. Plug in the Power supply.
3. Check, please, if You have the right PORT settings in QP.INI file,
   if not, use Setup under File menu to adjust all necessary settings
   when running QP.EXE.   
4. If You set setting RunUnderWindows=0, the programmer will work
   aprox. two times quicker under DOS.
5. Run the programm QP.EXE.
6. If all is done correctly, in the right-down corner of the monitor
   will appear the hardware version.
	The programmer is ready for work.


	Serial PORT wire.

	You must use serial port exceeding wire. It meens, that if You
plug the programmer in the port without a wire - it will work. 

The programmer uses only 3 wires:

	female connector			male connector
	     2	>----------		-------------> 2
	     3  >----------  		-------------> 3
	     5  >----------		-------------> 5
	     
	To install under Windows.

 The same operations as under DOS except:

1. RunUnderWindows=1  in QP.INI file, this will make to run the programm
   properly, even it will work also with wrong settings.
2. In Windows System Settings it is better to make Your local PORT settings to:
	Baud Rate:     38400   8 N 1      Protocol:  None
3. You must know, that Windows gives You virtual machine for work and
   if some other programm uses the serial port, it is not enough to stop
   that programm, You must close it to get the physical port for the programmer.
	
       Power supply.

      The programmer needs DC current supply of 12 to 15 V. Two controllers
and two voltage regulators  on the board use aprox. 4mA. Programming voltage
is made by NE555 . The protocol in the programmer is made so, that in case 
of bad condictions for power supply, it will reset without making any damage 
to programming device. If such case happens, please, check the status with 
"Analyze". If it shows, that the device can be programmed, repair the power 
and programm the device again.
	Sometimes You can go out of the situation by programming seperatelly 
bytes by blocks making them with commands ALT-A and ALT-Z, or with the mouse 
right button, or after verify - programm only the difference by marking ALT+M. 
	
1. For some earlier made serial EEPROM's for example X2402, the power
supply coming out from the PIC16C65 port is not enough for propper work.
In such cases You can strengthen it by  shorting for the time of program-
ming in the EPROM - 32 socket pins 3 and 32. DON'T FORGET TO TAKE IT OFF
AFTER !!!!
2. For the devices SDA2506 or 2506 - You must use pull up resistor 4-20k.
   Please, put it in EPROM - 24/28 socket between pins 28 and 25.
   Without it the device will be programmed properly, only You will not
   be able to read and verify it.	
3. For devices to be programmed in ISP mode - please check the right
   connections in the help window. 	
4. For some parallel EEPROM's to operate correctly helps a blocking capacitor
   of 0.47 uF between GND and VCC (+5V)near the device ( may be in side socket).  
   In some cases ( when an ERROR of COM port occurs ) change power supply for
   stronger current (0.5 A or more), as in moments of changing addresses and CE
   some parallel EEPROM's needs strong current supply.
5. For Scenix SX devices use Vpp 12V. Never 13.5, as it can damadge the device.
   Some revisions are not working properly in parallel mode. It looks like
   factory is more concentrating attention to ISP mode programming. It works in
   all revisions. 	