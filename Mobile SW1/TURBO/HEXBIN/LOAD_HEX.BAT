@REM  �ਬ�� BAT-䠩�� ��� ����㧪� HEX-䠩���
@REM  � ����ன��� ���� ��� �����奬� 8751
@REM  �१ ��������� ��ப�:
@REM  load_hex.bat hex_file.hex

hexbin.exe %1 bin_file.bin I
turbo-v6.exe bin_file.bin /6/7/3/2/1/3/1
del bin_file.bin

