Nokia Data Suite 2.0	
(c) 1998 Nokia Mobile Phones. All rights reserved.

=================================================================
TABLE OF CONTENTS (README.TXT)
=================================================================

1. Introduction
2. Abbreviations used in this document
3. System requirements
4. Last minute additions and changes to the user documentations
5. Compatibility notes
6. Changes made to version 2.0
7. About v.42bis
8. Other Information

=================================================================
1.  INTRODUCTION
=================================================================

This document provides information to help you properly run Nokia
Data Suite 2.0, hereafter called NDS.

It deals with last minute additions and changes to the user
documentations as well as compatibility issues and possible problem 
causes and is intended to be read prior to the installation of
NDS.

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
IR		Infra Red
IrDa		Infra Red Data Association

=================================================================
3. SYSTEM REQUIREMENTS
=================================================================

To install and run NDS, you need the following:

  * Personal Computer with a Pentium 60 MHz processor or higher
  * Windows 95/98/NT4.0 operating system
  * At least 9 MB of free hard disk space
  * 8 MB of RAM (recommended)
  

=================================================================
4. LAST MINUTE ADDITIONS AND CHANGES TO THE USER DOCUMENTATIONS
=================================================================

4.1  How to transfer contacts information between phones

SIM cards from different network operators might support
different name and number lengths. When transferring entries from
one SIM to another, length reductions might become necessary
if the two SIMs support different name and number lengths. 

4.11  Between 8110 and 6110 

This section describes how to transfer the contacts information
from Nokia 8110 phone (Phone 1) to Nokia 6110 phone (Phone 2). 

1.  Connect Phone 1 to the computer and start NDS version 1.0.
2.  Read the "Contacts Directory". 
3.  Save the Contacts Directory to the PC, using "Export
    To File" command.
4.  Disconnect Phone 1 and close NCDS version 1.0.
5.  Open the NDS version 2.0 and connect phone 2. Wait until NDS
    has recognised that no phone is connected.
    (Very important!)
6.  "Read From Phone".
7.  open the Contacts Directory which you have just saved with 
    version 2.0, using "Import From File" command	
8.  Save the Contacts Directory to the phone, using "Save To
     Phone" command (NDS will inform you if shortening of
     entries is necessary.)
----------------------------------------------------------------- 


4.12  Between phone memory and SIM memory

This section describes how to transfer entries from the phone
memory to the SIM-memory.

1.  Connect your phone to the computer and start NDS.
2.  Read the "Contacts Directory"
3.  Mark the phone memory (B) entries that you would like to
    transfer to the SIM-memory (A).
4.  Use the command "Change memory type" from the "Edit" menu. 
    (NDS will inform you if shortening of entries is necessary.)
5.  Save the Contacts Directory to the phone, using the "Save To
    Phone" command.
----------------------------------------------------------------- 


=================================================================
5. COMPATIBILITY NOTES
=================================================================

5.1  Advanced Power Management (APM)

On some laptops, enabling certain APM-features may result in
communication problems between computer and phone and possible
connection loss.
For a more detailed description, please refer to the
troubleshooting file TROUBLESHOOTING.TXT
----------------------------------------------------------------- 

5.2  Applications
 
Remember to specify the "Nokia GSM Voice 2.0" modem to be used in
your application if you intend to dial voice calls. Specify the
"Nokia GSM Data 2.0" modem in all data and fax applications.

If you intend using Nokia CellularWare as well as NDS then
ensure that these applications do not use the same physical
communication port.

Certain 16-bit Windows applications will cause problems if they
directly connect to the communication port where NDS is
connected. Do not use such applications while NDS is running.

It is recommended to use "Zmodem" as the default transfer
protocol.
 
It is recommended to use fax class 1 as the default fax class.

-----------------------------------------------------------------

5.3  IR (Windows 95)

The NDS is compatible only with Microsoft IR stack. The functionality
of IR depends on your PC's hardware compatibility. It is recommended
to use cable in Data and Fax connections for reliability and practical
issues.

----------------------------------------------------------------- 


5.4  Phone hardware/software and cables

NDS is intended to be used with the Nokia 6100 and 5100 
series phones (or their variants) and DAU-9P cable.
NDS does not work with phones other than the ones specified.

Certain cellular networks do not support 7-bit data calls and
connection problems may occur if applications have been 
configured for 7-bit use.

The default data transfer speed is 9600 bps. Configuring 
applications to use transfer speeds other than the default value
may result in data transfer problems, unless the SIM has been
configured to support them.

During data calls, the number of battery-level indication bars
displayed in the Monitor might differ from the ones displayed
on the phone.

Please remember that NDS is fully functional only after it has
recognised the presence of a powered-on phone. This process may
take a few seconds and as soon as the RF and battery-level 
indication bars appear in the NDS Monitor, full functionality
has been attained.
----------------------------------------------------------------- 


5.5 TSRs, 16-bit drivers

Since NDS is a 32-bit application requiring multithreading, 
operation with 16-bit applications cannot be fully guaranteed.

Certain 16-bit drivers remaining in the CONFIG.SYS file from
previous Windows installations, such as 3.11 or Windows for
Workgroups, have been found to conflict with the NDS, if not
removed.

=================================================================
6. CHANGES MADE TO VERSION 2.0
=================================================================

6.1 Nokia GSM Data 2.0

Contains enhanced and tested compatibility with more equipment
and application vendors and environments.

Enhanced SMS support with different networks.

6.2 Other changes

Version 2.0 is compatible with Windows 95/98/NT4.0

6.3 Note about CAPI

If any problems occur with CAPI make sure that you are using
the latest version of it. The latest version of CAPI is available
in Club Nokia web site at www.forum.nokia.com.

=================================================================
7. ABOUT v.42bis
=================================================================

Nokia Data Suite contains support for v.42bis data
compression. It allows data speed up to 38400 bps in optimal
circumstances if data can be compressed effectively. When using
v.42bis data compression with NDS it requires that underlying
GSM network supports it. If GSM network does not support v.42bis
data compression, connection is made without data compression.

=================================================================
8. OTHER INFORMATION
=================================================================

More information about this product can be found from web pages; 
WWW.FORUM.NOKIA.COM or WWW.NOKIA.COM. You can also register yourself
to the club Nokia from WWW.CLUB.NOKIA.COM.

-----------------------------------------------------------------

NOKIA is a trademark of Nokia Corporation.

MS-DOS is a trademark of Microsoft Corporation.

Windows NT, Windows 95 and Windows 98 are registered trademarks
of Microsoft Corporation.

Other products may be trademarks or registered trademarks of
their respective manufacturers.

(c) 1998 Nokia Mobile Phones. All rights reserved.

Nokia Mobile Phones operates a policy of continuous improvement.
Therefore we reserve the right to make changes and improvements
to any of the products described in this guide without prior 
notice.

Nokia Mobile Phones is not responsible for any loss of data,
income or any consequential damage howsoever caused.
