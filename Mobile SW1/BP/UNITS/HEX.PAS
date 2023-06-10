unit Hex;


interface
function DecToHex(vhod:longint): String;
function DecToBin(vhod:longint): String;

implementation

Function Bukva(temp:byte):Char;
begin
Case Temp of
1:bukva:='1';
2:bukva:='2';
3:bukva:='3';
4:bukva:='4';
5:bukva:='5';
6:bukva:='6';
7:bukva:='7';
8:bukva:='8';
9:bukva:='9';
10:bukva:='A';
11:bukva:='B';
12:bukva:='C';
13:bukva:='D';
14:bukva:='E';
15:bukva:='F';
0:bukva:='0';
end
end;

function DecToHex(vhod:longint): String;
var dlina,baitik:byte;
    stroka:string;
begin
Stroka:='';
repeat
baitik:=vhod and $0000000F;
Stroka:=bukva(baitik)+Stroka;
vhod:=vhod shr 4;
until vhod=$00;
if (Frac(length(Stroka)/2))>0 Then Stroka:='0'+Stroka;
DecToHex:=Stroka;
end;

function DecToBin(vhod:longint): String;
var dlina,baitik:byte;
    stroka:string;
begin
Stroka:='';
repeat
baitik:=vhod and $00000001;
Stroka:=bukva(baitik)+Stroka;
vhod:=vhod shr 1;
until vhod=$00;
DecTobin:=Stroka;
end;

end.