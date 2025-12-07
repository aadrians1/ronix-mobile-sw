ECHO OFF
        rem cd \flash
        LHA E %1

         ECHO 20:57600> %1.DAT
         ECHO 21:2>> %1.DAT
         ECHO 22:1>> %1.DAT
         ECHO 23:8>> %1.DAT
         ECHO 30:10>> %1.DAT
         ECHO 31:1000>> %1.DAT
         ECHO 50:180000>> %1.DAT
         ECHO 51:180000>> %1.DAT
         ECHO 52:180000>> %1.DAT
         ECHO 53:180000>> %1.DAT
         ECHO 54:180000>> %1.DAT
        ECHO 60:%1>> %1.DAT
        ECHO 61:4>> %1.DAT
        ECHO 62:010000 1E>> %1.DAT
        ECHO 63:010000 1EFFFF>> %1.DAT
        ECHO 70:C:\FLASH90\%1>> %1.DAT
        ECHO 71:C:\FLASH90>> %1.DAT
        ECHO 72:15acf3f0>> %1.DAT
        PEROM20 %1.DAT
        DEL %1
        GOTO EXIT
:EXIT
cls
echo Aikon GsM TeAm (c) 2000