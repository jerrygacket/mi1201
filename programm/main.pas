unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, Forms, Controls, Graphics, Dialogs,
  StdCtrls, SdpoSerial, IniFiles, strutils,Math;

type

  { TForm1 }

  TForm1 = class(TForm)
    MassConnect: TButton;
    MassConnectPort: TSdpoSerial;
    Memo1: TMemo;
    Memo2: TMemo;
    TempConnectPort: TSdpoSerial;
    IntensConnectPort: TSdpoSerial;
    TempConnect: TButton;
    IntensConnect: TButton;
    Button4: TButton;
    Button5: TButton;
    Chart1: TChart;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    MassConnectPortLabel: TLabel;
    TempConnectPortLabel: TLabel;
    IntensConnectPortLabel: TLabel;
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IntensConnectPortRxData(Sender: TObject);
    procedure MassConnectPortRxData(Sender: TObject);
    procedure OnPortRxData(Sender: TObject);
    procedure PortButtonClick(Sender: TObject);
    procedure PortConfig(PortName:string);
    procedure IntensDrow(intense:string);
  private

  public

  end;

var
  Form1: TForm1;
  logFile: string = 'mi1201.log';
  Ports: array [0..2] of TSdpoSerial;
  buff: array [0..2] of string;
  // временно. потом PortStrings брать из конфига
  PortStrings: array [0..2] of string = ('MassConnectPort','TempConnectPort','IntensConnectPort');
  PortNames: TStringList;  // потому что здесь есть indexOf. после PHP тяжкооо
  massString:array of integer;

implementation

{$R *.lfm}

procedure LogInit(logFileName:string);
var
  logfile : file of byte;
  fsize:integer;
begin
  if fileexists(logFileName) then
     begin
       AssignFile(logfile, logFileName);
       Reset (logfile);
       fsize:=FileSize(logfile);
       CloseFile(logfile);
       if fsize > 100000 then
         RenameFile(logFileName ,FormatDateTime('YYYY-MM-DD',Now)+'-'+logFileName);
     end;
end;

procedure WriteLog(logFileName:string; data:string);
var
  F : TextFile;
  tmpstr:string;
begin
  AssignFile(F, logFileName);
  if fileexists(logFileName) then Append(F)
     else Rewrite(F);
  tmpstr := FormatDateTime('YYYY-MM-DD hh:nn',Now);
  tmpstr := tmpstr + ': ' +data;
  WriteLn(F, tmpstr);
  CloseFile(F);
end;

function GetConfig(section:string; parametr:string):string;
var
  INI: TINIFile;
begin
  INI := TINIFile.Create('mi1201.ini');
  result := INI.ReadString(section,parametr,'');
end;

procedure TForm1.PortConfig(PortName:string);
var
  port:TComponent;
  BaudRate,DataBits,StopBits:integer;
  Parity:String;
begin
  port := Form1.FindComponent(portName);
  BaudRate := strtoint(GetConfig(PortName,'BaudRate'));
  DataBits := strtoint(GetConfig(PortName,'DataBits'));
  //FlowControl := GetConfig(PortName,'FlowControl');
  Parity := GetConfig(PortName,'Parity');
  StopBits := strtoint(GetConfig(PortName,'StopBits'));
  port := Form1.FindComponent(portName);
  TSdpoSerial(port).SynSer.Config(BaudRate, DataBits, Parity[1],
                   StopBits, false, false);
  //Ports[i].OnRxData := @OnPortRxData;
end;

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  i:integer;
begin
  LogInit(logFile);
  WriteLog(logFile,'ok start');
  PortNames := TStringList.Create;

  for i:=0 to length(PortStrings)-1 do
    begin
      PortNames.Add(PortStrings[i]);
      //Ports[i] := TSdpoSerial(PortStrings[i]);
      //PortConfig(PortStrings[i]);
    end;
end;

procedure TForm1.IntensConnectPortRxData(Sender: TObject);
begin
      //buff[portIndex] := buff[portIndex] + IntensConnectPort.ReadData;
      //Form1.IntensDrow(IntensConnectPort.ReadData);
  IntensConnectPortLabel.Caption:=IntensConnectPort.ReadData;
end;

function HexToInt(Str : string): integer;
var i, r : integer;
begin
  val('$'+Trim(Str),r, i);
  if i<>0 then HexToInt := 0 {была ошибка в написании числа}
  else HexToInt := r;
end;

procedure TForm1.MassConnectPortRxData(Sender: TObject);
var
  i:integer;
  digits:float;
begin
  setlength(massString,length(massString)+1);
  massString[length(massString)-1] :=MassConnectPort.SynSer.RecvByte(1000);
if length(massString) = 59 then
  begin
    digits:=massString[34] + massString[35] * power(2, 8);
    case massString[37] of
    0:digits:=digits/1;
    1:digits:=digits/10;
    2:digits:=digits/100;
    4:digits:=digits/1000;
    8:digits:=digits/10000;
    end;
    if massString[36] >= 128 then digits := -digits;
    MassConnectPortLabel.Caption:=floattostr(digits);
    //Memo1.Lines.Clear;
    //Memo2.Lines.Clear;
    //Memo2.Lines.Add(inttostr(length(massString)));
    //for i:=0 to length(massString)-1 do
    //  begin
    //    Memo1.Lines.Add(inttostr(i)+': '+inttostr(massString[i]));
    //  end;
    setlength(massString,0);
    MassConnectPort.WriteData(chr($55)+chr($55)+chr($00)+chr($00)+chr($AA));
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  i:integer;
  cb:array [0..17] of string;
begin
Memo1.Lines.Clear;
Memo2.Lines.Clear;
//Memo1.Lines.Add(massString);
//memo2.Lines.Add(inttostr(length(massString)));
//massString:='';
//for i:=1 to length(massString)-1 do
//      begin
//        Memo1.Lines.Add(massString[i]);
//      end;
if not IntensConnectPort.Active then exit;
  IntensConnectPort.ReadData;
   cb[0]:='*RST';
   cb[1]:='SYST:ZCH ON';
   cb[2]:='RANG 2e-9';//+inttostr(radiogroup1.ItemIndex+2);
   cb[3]:='INIT';
   cb[4]:='SYST:ZCOR:ACQ';
   cb[5]:='SYST:ZCOR ON';
   cb[6]:='RANG:AUTO ON';
   cb[7]:='SYST:ZCH OFF';
   cb[8]:='NPLC 5.0';//+edit1.Text;
   cb[9]:='FORM:ELEM READ';
   cb[10]:='TRIG:COUN 1';
   cb[11]:='TRAC:POIN 1';
   cb[12]:='TRAC:FEED SENS';
   cb[13]:='TRAC:FEED:CONT NEXT';
   cb[14]:='RANG:AUTO:ULIM 2e-6';
   cb[15]:='SYST:AZER  '+ GetConfig('ampermetr','azer');
   cb[16]:='MED ' + GetConfig('ampermetr','med');
   cb[17]:='AVER ' + GetConfig('ampermetr','aver');
   //if autozer.Checked then
   //   cb[15]:='SYST:AZER ON'
   //else
   //   cb[15]:='SYST:AZER OFF';
   //if MednF.Checked then
   //  cb[16]:='MED ON'
   //else
   //  cb[16]:='MED OFF';
   //if DigF.Checked then
   //  cb[17]:='AVER ON'
   //else
   //  cb[17]:='AVER OFF';
   for i:=0 to 17 do
     begin
       IntensConnectPort.WriteData(cb[i]+chr(13));
       sleep(200);
     end;
   //IntensConnectPort.WriteData('READ?'+chr(13));
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  IntensConnectPort.WriteData('READ?'+chr(13));
//massString := '';
//MassConnectPort.SynSer.SendByte($55);
//MassConnectPort.SynSer.SendByte($55);
//MassConnectPort.SynSer.SendByte($00);
//MassConnectPort.SynSer.SendByte($00);
//MassConnectPort.SynSer.SendByte($AA);
//MassConnectPort.WriteData(chr($55)+chr($55)+chr($00)+chr($00)+chr($AA));
end;

procedure TForm1.OnPortRxData(Sender: TObject);
var
  status:string;
  portIndex:integer;
begin
  with (Sender as TSdpoSerial) do
  begin
      portIndex := PortNames.indexOf(Name);
      buff[portIndex] := buff[portIndex] + ReadData;
      //if pos(#13,buff[portIndex]) = 0 then exit;
      case portIndex of
      0:
        begin
          memo1.Lines.Add(ReadData);
          if length(buff[portIndex]) = 19 then
             TLabel(Form1.FindComponent(Name + 'Label')).caption := buff[portIndex];
        end;
      1:TLabel(Form1.FindComponent(Name + 'Label')).caption := buff[portIndex];
      2:
        begin
//          if (buff[portIndex][length(buff[portIndex])]=#13) then
            //if pos(#13,buff[portIndex]) <> 0 then
             Form1.IntensDrow(buff[portIndex]);
        end;
      end;
      buff[portIndex]:='';
  end;

  //buff:=trim(buff);
  //if (pos('Info;',buff) > 0) and (StartBtn.Enabled = false) then
  //   begin
  //     status := ExtractWord(2,buff,[';']);
  //     case status of
  //       'Ready':
  //          begin
  //            StartBtn.Enabled := true;
  //            if StopBtn.Enabled then StopBtn.Click;
  //            StopBtn.Enabled := false;
  //            StatusBar1.Panels[0].Text := 'Готов';
  //          end;
  //       'StartWork':
  //          begin
  //            StatusBar1.Panels[0].Text := 'Работаю';
  //          end;
  //       //'Detect':
  //       //   begin
  //       //     port1 := ExtractWord(3,buff,[';']);
  //       //   end;
  //       else
  //         begin
  //           StatusBar1.Panels[0].Text := 'Непонятно...';
  //         end;
  //     end;
  //   end;
  //if pos('Data;',buff) <> 0 then
  //    begin
  //      if not TryStrToFloat(ExtractWord(2,buff,[';']),temp1) then temp1:=0;
  //      if not TryStrToInt(ExtractWord(3,buff,[';']),level1) then level1:=0;
  //      label5.Caption:='Текущая: ' + inttostr(trunc(temp1));
  //      level1Bar.Position:=level1;
  //    end;
  //WriteLog(buff);
  //buff[portIndex]:='';
end;

procedure TForm1.IntensDrow(intense:string);
begin
  IntensConnectPortLabel.caption := intense;
  //IntensConnectPort.WriteData('READ?'+chr(13));
end;

procedure TForm1.PortButtonClick(Sender: TObject);
var
  portName:string;
  port:TComponent;
begin
  with (Sender as TButton) do
  begin
    portName := Name + 'Port';
    port := Form1.FindComponent(portName);
    if TSdpoSerial(port).Active then
      begin
        TSdpoSerial(port).Close;
        Caption:='Отключено';
      end
    else
      begin
        //TSdpoSerial(port).Device := GetConfig(portName,'Device');
        TSdpoSerial(port).Open;
        if TSdpoSerial(port).Active then
          begin
            //PortConfig(portName);
            if portName = 'MassConnectPort' then MassConnectPort.WriteData(chr($55)+chr($55)+chr($00)+chr($00)+chr($AA));
            Caption:='Подключено';
          end;
      end;
  end;
end;

end.


