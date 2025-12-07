Uses crt;
{Programa for read & write 25LC040}
var  objem,Port_lpt,Control_reg,Status_reg:word;
     fil_str:string;
     code:integer;
     Dlitelnost:longint;
     klavisha:char;
     outfile:file;
     filname:text;
     Output_data:byte;
     buffer:array[0..2047] of byte;
const
read_low_256=$03;
read_high_256=$0B;
Write_low_256=$03;
Write_high_256=$0B;

Procedure Cikl;
Var Per_cikla:longint;
Begin
Delay(1){For Per_cikla:=1 to Dlitelnost do begin end;}
end;

Procedure Start_25;
{   D0 - CLK
    D1 - CS
    D2 - DI }
begin
Port[Port_lpt]:=$FF;{BIN '11111111'}
Cikl;
Port[Port_lpt]:=$F3;{BIN '11111011'- CLK HIGH}
Cikl;
Port[Port_lpt]:=$F2;{BIN '11111010' CS & CLK - HIGH}
Cikl;
Port[Port_lpt]:=$F0;{BIN '11111000'}
Cikl;
end;

Procedure Stop_25;
{   D0 - CLK
    D1 - CS
    D2 - DI }
begin
Cikl;
Port[Port_lpt]:=$FF;{BIN '11111010'}
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
Port[Port_lpt]:=$F5;{BIN '11111 101'}
Cikl;
Port[Port_lpt]:=$F4;{BIN '1111 100'}
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
Port[Port_lpt]:=$F1;{BIN '11111 001'}
Cikl;
Port[Port_lpt]:=$F0;{BIN '11111 000'}
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
Port[Port_lpt]:=$F0;{BIN '11111 000'}
Cikl;
Port[Port_lpt]:=$F1;{BIN '11111 001'}
Cikl;
temp_byte:=Port[Status_reg];
                 baitik:=temp_byte shr 5;
                 temp_byte:=baitik and $01;
                 Output_data:=Output_data+temp_byte;
                 temp_byte:=Output_data shl 1;
Port[Port_lpt]:=$F1;{BIN '11111 001'}
Cikl;
Port[Port_lpt]:=$F0;{BIN '11111 000'}
Cikl;
                 end;
Byte_in:=output_data;
end;

Procedure adress_out(var mimory:byte);
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

Procedure Read25040;
var  adres_dan:byte;
     baitik:byte;
begin
     for adres_dan:=0 to 255 do
     begin
         GotoXY(2,6);Write('Reading adress location - ');Writeln(adres_dan);
         Start_25;
         baitik:=read_low_256;
         adress_out(baitik);
         adress_out(adres_dan);
         buffer[adres_dan]:=byte_in;
         Stop_25;
         end;
     for adres_dan:=0 to 255 do
     begin
         GotoXY(2,6);Write('Reading adress location - ');Writeln(adres_dan+$100);
         Start_25;
         baitik:=read_high_256;
         adress_out(baitik);
         adress_out(adres_dan);
         buffer[adres_dan+$100]:=byte_in;
         Stop_25;
         end;
  Writeln('Read complete !');
end;


Procedure Detect_port;
var p:^word;
begin
p:= Ptr($00, $0408);
Port_lpt:=p^;
Control_reg:=Port_lpt+2;
Status_reg:=Port_lpt+1;
Port[Control_reg]:=$0F;
end;

Procedure Micro25040;

var temp_str:string;
    Vihod:boolean;
begin
objem:=512;
Assign(filname,'memory.ini');
Reset(filname);
Vihod:=false;
repeat
  ReadLn(Filname, temp_str);
  If temp_str='25XX40' then
    begin
  Readln(filname,temp_str);Val(temp_str,Dlitelnost,code);vihod:=true;
  end;
until (temp_str='END') or (vihod=true);
Close(filname);
IF VIHOD=True then
begin
Read25040;
  assign(outfile,fil_str);
  rewrite(outfile, 1);
  blockwrite(outfile, buffer, objem);
  close(outfile);
end
else
begin Writeln('Not find string 25XX40');end;
end;

var temp_str:string;
begin
ClrScr;
  writeln('25xx040-Reader,Eraser. Version 1.0');
  writeln('Copyright (c) 1999 by SLV. Commercial version');
If paramcount<>1 then
begin
repeat
ClrScr;
Writeln(' Please enter output filename:');
Readln(temp_str);
until length(temp_str)>0;
fil_str:=temp_str;
end
else
begin
fil_str:=paramstr(1);
end;
Detect_port;
Micro25040;
end.
