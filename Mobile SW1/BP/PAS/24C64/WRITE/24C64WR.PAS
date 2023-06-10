Uses crt;
{Programa for read & write 24C64}
var  objem,Port_lpt,Control_reg,Status_reg:word;
     code:integer;
     Dlitelnost:longint;
     klavisha:char;
     filname:text;
     Dannie_in:array[0..31,0..255] of byte;
     Proverka:array[0..31,0..255] of byte;
     outfile : file;
     fil_str:string;
     zaderzka,dannie_out:byte;
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
begin Low_pulse end;

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
end;

Procedure Read_24C64;
var Segm,offs:byte;

begin
Write('Reading ');
          Port[port_lpt]:=$FF;
          delay(1);

          Start_I2C;
          dannie_out:=$A0;
          Byte_out(dannie_out);
          Ask_in;
          dannie_out:=$00;
          Byte_out(dannie_out);
          Ask_in;
          dannie_out:=$00;
          Byte_out(dannie_out);
          Ask_in;

          Start_I2C;
          dannie_out:=$A1;
          Byte_out(dannie_out);
          Ask_in;

            for segm:=0 to 31 do
          begin
               write(chr($B1));
               for offs:=0 to 255 do
               begin
               proverka[segm,offs]:=byte_in;
if (segm=31) and (offs=255) then begin ; HIGH_pulse end else begin ask_master;end;
               end;
          end;
          Stop_I2C;
end;

Procedure Write_x24645;
var temp_wr_byte,Segm,offs:byte;

begin
  assign(outfile, fil_str);
  reset(outfile, 1);
  blockread(outfile, dannie_in, sizeof(dannie_in));
  close(outfile);
          Port[port_lpt]:=$FF;
          delay(1);
          for segm:=0 to 31 do
          begin

                for offs:=0 to 255 do
                 begin
GotoXY(2,5);Write('Writing adress location - ');Writeln((Segm*256)+offs);
                 Start_I2C;

                 dannie_out:=$A0;
                 Byte_out(dannie_out);
                 Ask_in;

                 dannie_out:=segm;
                 Byte_out(dannie_out);
                 Ask_in;

                 dannie_out:=offs;
                 Byte_out(dannie_out);
                 Ask_in;
                       dannie_out:=dannie_in[segm,offs];
                       Byte_out(dannie_out);
                       Ask_in;
                       Stop_I2C;
                       delay(Zaderzka);
                 end;
          end;
Read_24c64;
          for segm:=0 to 31 do
          begin
                for offs:=0 to 255 do
                begin
GotoXY(2,9);Write('Verifing adress location - ');Write((Segm*256)+offs);
if dannie_in[segm,offs]=proverka[segm,offs] then
begin Write(' Ok');end else begin Write(' Error'); Readkey;end;
                end;
          end;
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
  writeln('24C64 - WRITER. Version 3.0');
  writeln('Copyright (c) 1999 by SLV. Commercial version');
  writeln('Press any key ....');Readkey;
If paramcount=1 then
begin
fil_str:=paramstr(1);
Detect_port;
Assign(filname,'memory.ini');
Reset(filname);
Vihod:=false;
repeat
  ReadLn(Filname, temp_str);
  If temp_str='24C64' then
  begin
  Readln(filname,temp_str);Val(temp_str,Dlitelnost,code);
  Readln(filname,temp_str);Val(temp_str,zaderzka,code);vihod:=true;
  end;
until (temp_str='END') or (vihod=true);
Close(filname);
IF VIHOD=True then  begin write_x24645; end else begin Writeln('Not find string x24645');end;
end
else
begin
Writeln(' Required 24c64wr.exe filename.bin');
end;
end.