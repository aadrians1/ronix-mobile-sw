Uses crt;
{Programa for read & write 93c76/86}
var  objem,Port_lpt,Control_reg,Status_reg:word;
     fil_str:string;
     code:integer;
     Dlitelnost:longint;
     klavisha:char;
     outfile:file;
     filname:text;
     Output_data:byte;
     buffer:array[0..2047] of byte;

Procedure Cikl;
Var Per_cikla:longint;
Begin
For Per_cikla:=1 to Dlitelnost do begin end;
end;

Procedure Start93LC;
{   D0 - CLK
    D1 - CS
    D2 - DI }
begin
Port[Port_lpt]:=$F0;{BIN '11111000'}
Cikl;
Port[Port_lpt]:=$F1;{BIN '11111001'- CLK HIGH}
Cikl;
Port[Port_lpt]:=$F3;{BIN '11111011' CS & CLK - HIGH}
Cikl;
Port[Port_lpt]:=$F2;{BIN '11111010'}
Cikl;
end;

Procedure Stop93LC;
{   D0 - CLK
    D1 - CS
    D2 - DI }
begin
Port[Port_lpt]:=$F0;{BIN '11111010'}
Cikl;
end;

Procedure High_pulse;
{   D0 - CLK
    D1 - CS
    D2 - DI }
begin
Port[Port_lpt]:=$F6;{BIN '11111 110'}
Cikl;
Port[Port_lpt]:=$F7;{BIN '11111 111'}
Cikl;
Port[Port_lpt]:=$F7;{BIN '11111  111'}
Cikl;
Port[Port_lpt]:=$F6;{BIN '11111  110'}
Cikl;
end;

Procedure Low_pulse;
{   D0 - CLK
    D1 - CS
    D2 - DI }
begin
Port[Port_lpt]:=$F2;{BIN '11111 010'}
Cikl;
Port[Port_lpt]:=$F3;{BIN '11111 011'}
Cikl;
Port[Port_lpt]:=$F3;{BIN '11111  011'}
Cikl;
Port[Port_lpt]:=$F2;{BIN '11111  010'}
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
Low_pulse; {Proverit rabotu chtenija}
temp_byte:=Port[Status_reg];
                 baitik:=temp_byte shr 5;
                 temp_byte:=baitik and $01;
                 Output_data:=Output_data+temp_byte;
                 temp_byte:=Output_data shl 1;
                 end;
Byte_in:=output_data;
end;

Procedure adress_out(var mimory:word);
var temp_byte_out,temp,k:word;
    s:string;
begin
          temp_byte_out:=mimory;
          s:='';
          for k:=1 to 11  do
             begin
             temp:=temp_byte_out and $400;
             if temp=$000 then begin Low_pulse;s:=s+'0';end;
             if temp=$400 then begin High_pulse;s:=s+'1';end;
             temp_byte_out:=mimory SHL k;
             end;
end;
Procedure Ewen93LC;
begin
          Start93LC;
          High_Pulse;
          Low_Pulse;
          Low_Pulse;
          High_Pulse;High_Pulse;Low_Pulse;High_Pulse;Low_Pulse;
          High_Pulse;Low_Pulse;High_Pulse;Low_Pulse;High_Pulse;Low_Pulse;
          Stop93LC;
Delay(100);
end;
Procedure Read93LC;
var  adres_dan:word;
     temp_byte,baitik,bb:byte;
begin
     for adres_dan:=0 to (objem-1) do
     begin
          GotoXY(2,6);Write('Reading adress location - ');Writeln(adres_dan);
          Start93LC;
          High_Pulse;
          High_Pulse;
          Low_Pulse;
          adress_out(adres_dan);
         buffer[adres_dan]:=byte_in;
         Stop93LC;
         end;
  Writeln('Read complete !');
end;

Procedure Erase93LS;
var  adress_dan:word;
begin
          Ewen93LC;
          Start93LC;
          High_Pulse;
          Low_Pulse;
          Low_Pulse;
          High_Pulse;Low_Pulse;High_Pulse;Low_Pulse;High_Pulse;Low_Pulse;
          High_Pulse;Low_Pulse;High_Pulse;Low_Pulse;High_Pulse;
          Stop93LC;
Delay(100);
Writeln('Erase complete !');
Read93LC;
     for adress_dan:=0 to (objem-1) do
begin
GotoXY(2,9);Write('Verifing adress location - ');Write(adress_dan);
if buffer[adress_dan]=$FF then
begin Write(' Ok');end else begin Write(' Error'); Readln;end;
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
end;

Procedure Micro93_76_86;

var temp_str:string;
    Vihod:boolean;
begin
Writeln('Do you want programm : (1)-93LC76, (2)-93LC86');
repeat
Klavisha:=Readkey;
if klavisha=#49 then objem:=1024;
if klavisha=#50 then objem:=2048;
until (klavisha=#49) or (klavisha=#50);

Assign(filname,'memory.ini');
Reset(filname);
Vihod:=false;
repeat
  ReadLn(Filname, temp_str);
  If temp_str='93CXX' then
  begin
  Readln(filname,temp_str);Val(temp_str,Dlitelnost,code);vihod:=true;
  end;
until (temp_str='END') or (vihod=true);
Close(filname);
IF VIHOD=True then
begin
Writeln('Do you want programm : (1)-Read, (2)-Erase');
repeat
Klavisha:=Readkey;
if klavisha=#49 then
begin
Read93LC;
  assign(outfile,fil_str);
  rewrite(outfile, 1);
  blockwrite(outfile, buffer, objem);
  close(outfile);

end;

if klavisha=#50 then Erase93ls;
until (klavisha=#49) or (klavisha=#50);
end
else
begin Writeln('Not find string 93CXX');end;
end;

var temp_str:string;
begin
ClrScr;
ClrScr;
  writeln('93LCxx-Reader,Eraser. Version 1.0');
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
Micro93_76_86;
end.