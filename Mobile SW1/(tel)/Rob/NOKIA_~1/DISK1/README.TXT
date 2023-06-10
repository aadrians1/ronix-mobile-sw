Nokia Data Suite 3.0	
(c) 1999 Nokia Mobile Phones. All rights reserved.

=================================================================
TABLE OF CONTENTS (README.TXT)
=================================================================

1. Introduction
2. Abbreviations used in this document
3. System requirements
4. Last minute additions and changes to the user documentation
5. Compatibility notes
6. About v.42bis
7. Other Information

=================================================================
1.  INTRODUCTION
=================================================================

This document provides information to help you to use Nokia
Data Suite 3.0, hereafter called NDS.

It deals with last minute additions and changes to the user 
documentation as well as compatibility issues and possible 
problem causes and is intended to be read before the 
installation of NDS.

For a more detailed description on how to deal with certain
problems that you might encounter, please refer to the 
troubleshooting file TROUBLESHOOTING.TXT


=================================================================
2.  ABBREVIATIONS USED IN THIS DOCUMENT
=================================================================

APM		Advanced Power Management
bps		Bits per second
MB		Megabyte
MHz		Megahertz
NDS		Nokia Data Suite
RAM		Random Access Memory
SIM		Subscriber Identification Module
TSR		Terminate and Stay Resident
UART		Universal Asynchronous Receiver/Transmitter
IR		Infrared
IrDA		Infrared Data Association

=================================================================
3. SYSTEM REQUIREMENTS
=================================================================

To install and run NDS, you need the following:
  
* an Intel compatible PC running Windows 95/98 or Windows NT 4.0 
  with Service Pack 3.
* a Nokia 6110 or a Nokia 5110 compatible phone operating in a 
  GSM900 or GSM1800 network.
* the DAU-9P connection cable supplied with Nokia Data Suite.
* at least 15 MB of free disk space (depends on language 
  selection).
* 32 MB of RAM (recommended).
* 800 * 600 display resolution.

=================================================================
4. LAST MINUTE ADDITIONS AND CHANGES TO THE USER DOCUMENTATION
=================================================================

4.1 Importing contacts to Phone memory.

You can use Import and Export functions of the Contacts 
application to import contacts from a file to your phone or vice 
versa. When importing contacts to the phone, select either Phone 
or SIM as the target memory of the phone, using the "Memory in 
use" functionality of the phone.

Note that the Import and Export format of Nokia Data Suite 3.0
is compatible with the Outlook 98 .csv format. In some language 
versions you might meet incompatibility.


4.2 Calendar software configurations.

In order to use the Calendar Import and Export functions of Nokia 
Data Suite 3.0, make sure that you have finished your PC Calendar 
software configuration. Unfinised configurations may cause 
difficulties in the import/export functions.

If you have problems with importing or exporting notes between 
the phone to Microsoft Schedule+, you should open the MS 
Schedule+ application before the import or export. The required 
network or local password must be given before importing or 
exporting calendar notes.


4.3 Writing text messages when the phone is not connected.

When the phone is not connected or in service, or when it is 
switched off, messages will be placed in the Outbox folder. The
messages will be sent when the phone is connected, switched on 
and in service.

To be able to write and send a text message to Outbox when the 
phone is not connected, you must have at least one Message 
setting group saved to NDS. Message setting groups are saved to 
NDS using the New Setting Group function in the Messages tab of
the Settings application. 


4.4 Uninstalling Nokia Data Suite 3.0 when Nokia Card Phone 2.0 
is installed.

When uninstalling Nokia Data Suite 3.0 on a computer that has 
Nokia Card Phone 2.0 installed, select "No to All" in the "Remove
shared file?" dialog. If "Yes" or "Yes to All" is selected, Nokia
Card Phone 2.0 will not work properly, and it must be reinstalled.


4.5 Component self-registration failed during the installation.

During the installation, there might appear the error message
"Failed to self-register files ...". Because of this failure, the
User Interface will not work properly. To resolve this problem, 
you need to reinstall Nokia Data Suite 3.0.


4.6 Supplementary Services

Use the keypad of your phone when you send Supplementary Service 
commands to the network. The Dialler application of NDS is not 
able to transmit these commands. 


=================================================================
5. COMPATIBILITY NOTES
=================================================================

5.1  Advanced Power Management (APM)

On some laptops, enabling certain APM features may result in
communication problems between computer and phone and possible
connection loss.
For a more detailed description, please refer to the
troubleshooting file TROUBLESHOOTING.TXT
----------------------------------------------------------------- 

5.2  Applications
 
Remember to specify the "Nokia GSM Voice 3.0" as the modem to be 
used in your application if you intend to dial voice calls. 
Specify the "Nokia GSM Data 3.0" as the modem in all data and 
fax applications.

Certain 16-bit Windows applications will cause problems if they
directly connect to the communication port where NDS is
connected. Do not use such applications while NDS is running.

It is recommended that you use "Zmodem" as the default transfer
protocol.
 
It is recommended that you use fax class 1 as the default fax 
class.

-----------------------------------------------------------------

5.3  IR (Windows 95)

The NDS is compatible only with Microsoft IR stack. 
The functionality of IR depends on your PC's hardware 
compatibility. It is recommended that you use the cable in data 
and fax connections for reliability and practical issues.

----------------------------------------------------------------- 

5.4  Phone hardware/software and cables

NDS is intended to be used with the Nokia 6100 and Nokia 5100 
series GSM phones (or their variants) and the DAU-9P cable.
NDS does not work with phones other than the ones specified.

Certain cellular networks do not support 7-bit data calls and
connection problems may occur if applications have been 
configured for 7-bit use.

The default data transfer speed is 9600 bps. Configuring 
applications to use transfer speeds other than the default value
may result in data transfer problems, unless the SIM has been
configured to support them.

More information about the 14400 bps data transfer speed in Forum
Nokia (www.forum.nokia.com).

During data calls, the number of battery-level indication bars
displayed in the Monitor window may differ from the ones displayed
on the phone display.

Please remember that NDS is fully functional only after it has
recognised the presence of a phone that is switched on. This 
process may take a few seconds and as soon as the radio signal
strength and battery-level indication bars appear in the NDS 
Monitor, full functionality has been attained.
----------------------------------------------------------------- 


5.5 TSRs, 16-bit drivers

Since NDS is a 32-bit application that requires multithreading, 
operation with 16-bit applications cannot be fully guaranteed.

Certain 16-bit drivers remaining in the CONFIG.SYS file from
previous Windows installations, such as 3.11 or Windows for
Workgroups, have been found to conflict with the NDS, if not
removed.

5.6 Note about CAPI

If any problems occur with CAPI make sure that you are using
the latest version of it. The latest version of CAPI is available
in Club Nokia Web site at www.forum.nokia.com.

=================================================================
6. ABOUT v.42bis
=================================================================

Nokia Data Suite contains support for v.42bis data
compression. It allows data speed up to 38400 bps in optimal
circumstances if data can be compressed effectively. When using
v.42bis data compression with NDS it requires that underlying
GSM network supports it. If GSM network does not support v.42bis
data compression, connection is made without data compression.

=================================================================
7. OTHER INFORMATION
=================================================================

More information about this product can be found from Web pages:
WWW.FORUM.NOKIA.COM or WWW.NOKIA.COM. You can also register 
yourself to the Club Nokia from WWW.CLUB.NOKIA.COM.

-----------------------------------------------------------------

Copyright©1997-1999. Nokia Mobile Phones. All rights reserved.

Nokia and Nokia Connecting People are registered trademarks of 
Nokia Corporation. Windows 95, Windows 98 and Windows NT 4.0 are 
registered trademarks of Microsoft Corporation.
Other products and company names mentioned herein may be 
registered trademarks or trade names of their respective owners.

Nokia Mobile Phones operates on a policy of continuous 
improvement. Therefore we reserve the right to make changes and 
improvements to any of the products described in this guide 
without prior notice.

Nokia Mobile Phones is not responsible for any loss of data,
income or any consequential damage howsoever caused.
