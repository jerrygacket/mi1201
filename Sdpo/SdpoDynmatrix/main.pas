unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, dynmatrix, dynmatrixutils,
  StdCtrls, LCLIntf;

type

  { TFMain }

  TFMain = class(TForm)
    BTest1: TButton;
    BTest2: TButton;
    BTest3: TButton;
    BTest4: TButton;
    BTest5: TButton;
    BTest6: TButton;
    EditHilbertDim: TEdit;
    Memo: TMemo;
    BTest7: TButton;
    BTest8: TButton;
    procedure BTest1Click(Sender: TObject);
    procedure BTest2Click(Sender: TObject);
    procedure BTest3Click(Sender: TObject);
    procedure BTest4Click(Sender: TObject);
    procedure BTest5Click(Sender: TObject);
    procedure BTest6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BTest7Click(Sender: TObject);
    procedure BTest8Click(Sender: TObject);
  private
    { private declarations }
  public
    M: TDMatrix;
  end;

var
  FMain: TFMain;

implementation

{ TFMain }

procedure TFMain.FormCreate(Sender: TObject);
begin
//  M.SetSize(3,2);
end;


procedure TFMain.BTest1Click(Sender: TObject);
var A, B: TDMatrix;
begin
  A := Meye(3);
  A := A + A;
  A := A + 1;
  A := -A;
  A.setv(0,2,0);
  //A := A * M;
  B := Minv(A);
  //MAddToStringList(M, Memo.lines, '%.4f', ';');
  MAddToStringList(A, Memo.lines);
  MAddToStringList(A*B, Memo.lines);
  MAddToStringList(Mpow(A,6) - A**6, Memo.lines);
  MAddToStringList(Minv(A) - A**-1, Memo.lines);
end;

procedure TFMain.BTest2Click(Sender: TObject);
var A, B, C: TDMatrix;
begin
  //A := Meye(3);
  A := Minc(3,3);
  B := A;
  C := A * B;

  B.setv(0,0,10);
  C := B.t;
  MAddToStringList(A, Memo.lines);
  MAddToStringList(B, Memo.lines);
  MAddToStringList(C, Memo.lines);
  MAddToStringList(Mhflip(C), Memo.lines);
end;

function dround(v: double): double;
begin
  result := round(v);
end;


procedure TFMain.BTest3Click(Sender: TObject);
var A, B, E: TDMatrix;
    r, c, n, i: longint;
    st, st_old: Dword;
    v: double;
begin
  n:= strtointdef(EditHilbertDim.text, 5);
  
  A := MZeros(n,n);
  for r:= 0 to n-1 do begin
    for c:= 0 to n-1 do begin
      A.setv(r, c, 1.0 / (r + c + 1));
    end;
  end;
  MAddToStringList(A, Memo.lines);

  st_old := gettickcount();
  for i := 1 to 100000 do begin
    B := Minv_fast(A);
  end;
  st_old := gettickcount() - st_old;

  st := gettickcount();
  for i := 1 to 100000 do begin
    B := Minv(A);
  end;
  st := gettickcount() - st;
  Memo.lines.Add(format('Time: %d, old: %d',[st, st_old]));

  MAddToStringList(B, Memo.lines);
  E := MFunc(B, @dround);
  E := B - E;
  MAddToStringList(E, Memo.lines);

  v := 0;
  for r:= 0 to n-1 do begin
    for c:= 0 to n-1 do begin
      v := v + abs(E.getv(r, c));
    end;
  end;
  if n > 0 then v := v / (n*n);
  Memo.lines.Add(format('Max value: %g, mean: %g',[MmaxAbs(E), v]));
  //B := Minv_old(A);
  //B.AddToStringList(Memo.lines);
end;

procedure TFMain.BTest4Click(Sender: TObject);
var A, B, C: TDMatrix;
begin
  A := Mzeros(1,3) + 1;
  B := A + 1;
  C := MConv(A, B);
  MAddToStringList(A, Memo.lines);
  MAddToStringList(B, Memo.lines);
  MAddToStringList(C, Memo.lines);
end;

procedure TFMain.BTest5Click(Sender: TObject);
var A, B, C: TDMatrix;
begin
  A := Minc(3,3);
  B := MOneCol(A,1);
  C := Mcrop(A, 1, 1, 2, 2);
  MAddToStringList(A, Memo.lines);
  MAddToStringList(B, Memo.lines);
  MAddToStringList(C, Memo.lines);
  MAddToStringList(MStamp(A,C,0,0), Memo.lines);
end;

procedure TFMain.BTest6Click(Sender: TObject);
var A: TDMatrix;
begin
  Memo.Lines.Add('A.IsGood '+BoolToStr(A.IsGood,True));
  A := Meye(3);
  Memo.Lines.Add('A.IsGood '+BoolToStr(A.IsGood,True));
end;

procedure TFMain.BTest7Click(Sender: TObject);
var A, B: TDMatrix;
begin
  A := StringToDMatrix('1 2 3; 1 1 0; 1 0 1');
  MAddToStringList(A, Memo.lines);
  B := StringToDMatrix('1 2 3 4').t;
  MAddToStringList(B, Memo.lines);
  MAddToStringList(MDiag(B), Memo.lines);
  Memo.Lines.add(format('%.6g',[MTrace(MDiag(B))]));
  MAddToStringList(MGetDiag(MDiag(B)), Memo.lines);

end;

procedure TFMain.BTest8Click(Sender: TObject);
var A, B: TDMatrix;
begin
  A := StringToDMatrix('1 2 3; 1 1 0; 1 0 1');
  Memo.Lines.Add('A');
  MAddToStringList(A, Memo.lines);
  B := StringToDMatrix('1 2 3');
  Memo.Lines.Add('B');
  MAddToStringList(B, Memo.lines);
  Memo.Lines.Add('Stack(A ,B)');
  MAddToStringList(MStack(A, B), Memo.lines);

  Memo.Lines.Add('Join(A ,B.t)');
  MAddToStringList(MJoin(A, B.t), Memo.lines);
end;


initialization
  {$I main.lrs}

end.

