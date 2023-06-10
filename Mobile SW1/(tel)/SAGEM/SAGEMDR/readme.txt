Sagem Doctor Version 1.1 Read-me:
--------------------------------

This program allows to read and write memory fields in the eeprom of a
Sagem 900 series phone. As several important settings are stored in
the eeprom, changes at the wrong fields can damage the phone in several
ways. Please do not change fields without a reason just to see what
happens.

A backup and restore function is included, but this might not help with
all problems as some errors will make data communication with the phone
impossible.

Anyway, you have been warned and please don't blame me if your phone
won't work after treating it with this program.


quick vs. full backup:
----------------------
The phone's firmware allows for field numbers between 0 and 16383. However,
most of the fields are not used in current phones. When creating a quick
backup, only those fields are read that are known to contain data; fields
that are always empty are skipped. A full backup will try to read all fields,
even the ones that are usually empty. New firmware revisions can introduce
new fields that are now empty, so this method is preferable because it will
find those fields, too.
  
Note that using the restore function will not delete fields that were empty
at the time of the backup and have been added to the memory since then. As
far as I know, this concerns game highscores and SMS messages and phonebook
entries stored in the phone. These fields will keep their current state.

RAM-Dump feature:
-----------------
Sagem Doctor now can read the RAM of the phone. Choosing this option will
read 2 megabytes of the memory.

Common problems:
----------------

- No connection to the phone is possible when running under Windows.
+ This seems to be a problem of the way Windows handles the serial
  ports. Try to establish a connection over a windows application
  (i.e. HyperTerminal) first. After that, the port should also work
  in DOS applications.
  If you can't get the program running under windows, try starting
  the program in DOS-mode.

- Many "timeout" error messages when commands are sent
+ The Sagem phones have a built-in power saving function which will
  disable the data communication when not used for a certain time.
  Pressing 'C' on the phone will wake the phone up, so try this if
  you are having timeout problems.


Changes for Version 1.1b:
-------------------------
+ Fixed display when editing empty eeprom fields
+ A little work at the RAM dump feature

Changes for Version 1.1a:
-------------------------
+ read full 2 megabytes of RAM, version 1.1 missed the last byte
+ fixed address display when continuing RAM-dump

Changes for Version 1.1:
------------------------
+ support for 19200 baud connection
+ RAM-dump feature
+ bugfix: No more crashed when the field to edit was empty
+ bugfix: backup stopped at field 16183, not 16383, so two fields were missing
+ better handling of serial communication -> no more "Answer was broken"
+ ...
