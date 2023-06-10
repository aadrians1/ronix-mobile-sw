Uses crt;
{Programa for read & write DS1621}
const
Control_byte=$90;
Read_temperat=$AA;
Start_convert=$EE;
Stop_convert=$22;
Acess_config=$AC;
Read_slope=$A9;
Acess_TH=$A1;
Acess_TL=$A2;

Type buffer = array[1..9000] of byte;
var  objem,Port_lpt,Control_reg,Status_reg:word;
     code:integer;
     Dlitelnost:longint;
     klavisha:char;
     filname:text;
     Dannie_in:array[0..1,0..255] of byte;
     outfile : file;

Procedure Cikl;
Var Per_cikla:longint;
Begin
For Per_cikla:=1 to Dlitelnost do begin end;
end;

Procedure Start_I2C;
{   D0 - CLK
    D1 - CS
    D2 - DI }
begin
Port[Port_lpt]:=$F5;{BIN '11110 101'}
Cikl;
Port[Port_lpt]:=$F1;{BIN '11110 001'- CLK HIGH}
Cikl;
Port[Port_lpt]:=$F1;{BIN '11110 000' CS & CLK - HIGH}
Cikl;
Port[Port_lpt]:=$F0;{BIN '11110 100'}
Cikl;
delay(1);
{Writeln('Start');}
end;

Procedure Stop_I2C;
{   D0 - CLK
    D1 - CS
    D2 - DI }
begin
Port[Port_lpt]:=$F0;{BIN '11110 000'}
Cikl;
Port[Port_lpt]:=$F1;{BIN '11110 001'- CLK HIGH}
Cikl;
Port[Port_lpt]:=$F5;{BIN '11110 101' CS & CLK - HIGH}
Cikl;
Port[Port_lpt]:=$F5;{BIN '11110 101'}
Cikl;
{Writeln('Stop');}
end;

Procedure High_pulse;
{   D0 - CLK
    D1 - CS
    D2 - DI }
begin
Port[Port_lpt]:=$F4;{BIN '11111 100'}
Cikl;
Port[Port_lpt]:=$F5;{BIN '11111 101'}
Cikl;
Port[Port_lpt]:=$F5;{BIN '11111  101'}
Cikl;
Port[Port_lpt]:=$F4;{BIN '11111  100'}
Cikl;
end;

Procedure Low_pulse;
{   D0 - CLK
    D1 - CS
    D2 - DI }
begin
Port[Port_lpt]:=$F0;{BIN '11111 000'}
Cikl;
Port[Port_lpt]:=$F1;{BIN '11111 001'}
Cikl;
Port[Port_lpt]:=$F1;{BIN '11111  001'}
Cikl;
Port[Port_lpt]:=$F0;{BIN '11111  000'}
Cikl;
end;

Procedure Ask_master;
begin Low_pulse {Writeln('ask in');}end;

Procedure Ask_in;
var temp_byte_in,byte_int:byte;
begin
Port[Port_lpt]:=$F4;{BIN '11111 100'}
Cikl;
Port[Port_lpt]:=$F5;{BIN '11111 101'}
Cikl;
Repeat
                 byte_int:=Port[Status_reg];
                 temp_byte_in:=byte_int and $20;
until temp_byte_in=$00;
Port[Port_lpt]:=$F5;{BIN '11111  101'}
Cikl;
Port[Port_lpt]:=$F4;{BIN '11111  100'}
Cikl;
{Writeln('ask in');}
end;

function Byte_in:byte;
var baitik,k,output_data,temp_byte:byte;
begin
             temp_byte:=0;
             Output_data:=0;
             for k:=1 to 8 do
  begin
Output_data:= temp_byte and $FE;
Port[Port_lpt]:=$F4;{BIN '11111 100'}
Cikl;
Port[Port_lpt]:=$F5;{BIN '11111 101'}
Cikl;
temp_byte:=Port[Status_reg];
Port[Port_lpt]:=$F5;{BIN '11111  101'}
Cikl;
Port[Port_lpt]:=$F4;{BIN '11111  100'}
Cikl;
                 baitik:=temp_byte shr 5;
                 temp_byte:=baitik and $01;
                 Output_data:=Output_data+temp_byte;
                 temp_byte:=Output_data shl 1;
                 end;
Byte_in:=output_data;
end;

Procedure Byte_out(var mimory:byte);
var temp_byte_out,temp,k:byte;
    s:string;
begin
          temp_byte_out:=mimory;
          s:='';
          for k:=1 to 8  do
             begin
             temp:=temp_byte_out and $80;
             if temp=$00 then begin Low_pulse;s:=s+'0';end;
             if temp=$80 then begin High_pulse;s:=s+'1';end;
             temp_byte_out:=mimory SHL k;
             end;
{Writeln(s);}
end;

Procedure Read_DS1621;
var dannie_out,polgradusa:byte;
    temperat: real;
begin
          ClrScr;
          Port[port_lpt]:=$FF;
          delay(1);
          Start_I2C;
          dannie_out:=Control_byte;
          Byte_out(dannie_out);
          Ask_in;

          dannie_out:=Acess_config;
          Byte_out(dannie_out);
          Ask_in;
          dannie_out:=$0A;
          Byte_out(dannie_out);
          Ask_in;
          Stop_i2c;

          Start_I2C;
          dannie_out:=Control_byte;
          Byte_out(dannie_out);
          Ask_in;

          dannie_out:=Start_convert;
          Byte_out(dannie_out);
          High_pulse;
          Stop_i2c;

          repeat
          gotoXY(1,20); Writeln('                                         ');
          Delay(1000);
{############################################}
          Start_I2C;
          dannie_out:=Control_byte;
          Byte_out(dannie_out);
          Ask_in;

          dannie_out:=Read_temperat;
          Byte_out(dannie_out);
          Ask_in;

          Start_I2C;
          dannie_out:=Control_byte+1;
          Byte_out(dannie_out);
          Ask_master;
          gotoXY(1,20);
          temperat:=(byte_in);
          Ask_master;
          if Byte_in =$80 then temperat:=temperat+0.5;
          HIGH_pulse;
          Stop_I2C;
          gotoXY(1,20);Writeln(temperat:3:1);
          delay(500);

          until keypressed;

          Start_I2C;
          dannie_out:=Control_byte;
          Byte_out(dannie_out);
          Ask_in;

          dannie_out:=Stop_convert;
          Byte_out(dannie_out);
          High_pulse;
          Stop_i2c;
end;


Procedure Detect_port;
var p:^word;
begin
p:= Ptr($00, $0408);
Port_lpt:=p^;
Control_reg:=Port_lpt+2;
Status_reg:=Port_lpt+1;
Control_reg:=$0F;
Port[Port_lpt]:=$FF;

end;

var vihod:boolean;
    temp_str:string;
begin
ClrScr;
Detect_port;
Assign(filname,'memory.ini');
Reset(filname);
Vihod:=false;
repeat
  ReadLn(Filname, temp_str);
  If (temp_str='DS1621') or (temp_str='ds1621') then
  begin
  Readln(filname,temp_str);Val(temp_str,Dlitelnost,code);vihod:=true;
  end;
until (temp_str='END') or (vihod=true);
Close(filname);
IF VIHOD=True then  begin Read_DS1621; end else begin Writeln('Not find string X24641');end;

end.