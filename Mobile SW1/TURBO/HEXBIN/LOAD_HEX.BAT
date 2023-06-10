@REM  Пример BAT-файла для загрузки HEX-файлов
@REM  с настройкой меню для микросхемы 8751
@REM  через командную строку:
@REM  load_hex.bat hex_file.hex

hexbin.exe %1 bin_file.bin I
turbo-v6.exe bin_file.bin /6/7/3/2/1/3/1
del bin_file.bin

