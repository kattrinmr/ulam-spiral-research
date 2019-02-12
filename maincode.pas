unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls, Spin;

type

  { TForm1 }

  TForm1 = class(TForm)
    Box1: TListBox;
    CDedit: TEdit;
    aEdit: TEdit;
    bEdit: TEdit;
    cEdit: TEdit;
    ang3Edit: TEdit;
    ClearCB: TCheckBox;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ShowPBut: TSpeedButton;
    DivSpin: TSpinEdit;
    SpeedButton1: TSpeedButton;
    N2YXBut: TSpeedButton;
    FibBut: TSpeedButton;
    Y2numCB: TCheckBox;
    KoefLB: TLabel;
    Y2Edit: TEdit;
    Y1Edit: TEdit;
    PolinomBut: TSpeedButton;
    TxtCB: TCheckBox;
    ShowSqCB: TCheckBox;
    ShowTCB: TCheckBox;
    GridCB: TCheckBox;
    SaveDialog1: TSaveDialog;
    ScaleSpin: TSpinEdit;
    RectSpin: TSpinEdit;
    YabsCB: TCheckBox;
    Image1: TImage;
    SaveBut: TSpeedButton;
    TriangBut: TSpeedButton;
    YValCB: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    CntEdit: TEdit;
    UlamBut: TSpeedButton;
    APBut: TSpeedButton;
    GPBut: TSpeedButton;
    procedure APButClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FibButClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PolinomButClick(Sender: TObject);
    procedure SaveButClick(Sender: TObject);
    procedure ShowPButClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure N2YXButClick(Sender: TObject);
    procedure TriangButClick(Sender: TObject);
    procedure UlamButClick(Sender: TObject);
    procedure GPButClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    procedure setPix(x, y: integer; col: TColor);
    procedure ClearPaintBox;
    procedure drawGrid;
    procedure wText(x, y: integer; s: string);

  end;

  TCoord = class
    width: integer;
    height: integer;
    constructor Create(w, h: integer);
    procedure Word2Screen(var x, y: integer); virtual; abstract;
    procedure getCoordIJ(n: longint; var i,j: longint); virtual; abstract;
    procedure fillMat; virtual; abstract;
    procedure OutMat; virtual; abstract;
  end;

  TUlama = class(TCoord)
    procedure Word2Screen(var x, y: integer); override;
    procedure getCoordIJ(n: longint; var i,j: longint); override;
    procedure fillMat; override;
    procedure OutMat; override;
  end;

  TTriang = class(TCoord)
    procedure Word2Screen(var x, y: integer); override;
    procedure getCoordIJ(n: longint; var i,j: longint); override;
    procedure fillMat; override;
    procedure OutMat; override;
  end;
var
  Form1: TForm1;

implementation

const ui = 21;
const maxErtf = 50000;
var pr: array[1..maxErtf] of boolean;
var u: array[1..21,1..21] of integer;
var
 coord: TCoord;
 ulama: TUlama;
 triang: TTriang;

// Ulama class

constructor TCoord.Create(w, h: integer);
begin
  width := w;
  height := h;
end;

procedure TUlama.Word2Screen(var x, y: integer);
var x0, y0: integer;
begin
 x0 := width div 2;   // x0, y0- середина панели
 y0 := height div 2;
 y := height - (y + y0);
 x := x+x0;
end;

{
 Координаты (i,j) числа n на спирали в матрице Улама.
 На луче, проведенном из начала координат через узлы с координатами (-п,п),
 располагаются точки с номерами (2*n)^2
 На аналогичном луче, начинающемся из первой точки и проходящем через
 точки с координатами (n,-n+l), расположены точки с номерами (2*n-1)^2.

 Находим ближайший к N квадрат числа q.
 Если q -- четное, то в зависимости от разности q^2-N интересующая нас точка
 находится на верхней или левой ветви. И для вычисления координат достаточно откорректировать
 одну из координат угловой точки (-q,q) на величину разности.
 Если q нечетное, то ветвь, содержащая точку с номером N, находится либо внизу, либо справа.
 И тогда коррекции надо подвергнуть одну из координат точки (q, -q+1).
}
procedure TUlama.getCoordIJ(n: longint; var i,j: longint);
var q, q1, q2, d: longint;
begin
  if( n < 1) then begin
    i := 0; j := 0;
    exit;
  end;
  n := n -1;
   q1 := trunc(sqrt(n) );  // q1^2 < N
   q2 := q1 + 1;           // q2^2 > N
   //выбираем ближайший квадрат
   if( abs( n-q1*q1) < abs( n-q2*q2) ) then q := q1
   else q := q2;

   d := q*q - n;
   if( q mod 2 = 0 ) then begin  // ближайший квадрат на диагонали четных квадратов
     i := q div 2; j := -i;      // координаты квадрата
     if ( d > 0) then j := j + d  // сверху от диагонали
     else i := i + d;  // слева диагонали
   end
   else begin // ближайший квадрат на диагонали нечетных квадратов
     j := (q+1) div 2; i := -j+1;  // координаты квадрата
     if( d > 0) then j := j-d  // слева диагонали
     else i := i - d; // сверху от диагонали
   end;
end;

//Заполняем матрицу 21x21 по спирали
procedure TUlama.fillMat;
var n, i,j,lm, rm, um,dm: integer;
begin
  i := 11; j := 11;
  lm := 10; rm := 12; um :=10; dm :=12; // левая, правая, верхняя и нижняя границы
  n := 1;
  u[i,j] := 1;

 while( true) do begin
  if( rm = ui+1 ) then break;
  inc(rm);
  while( j+1 < rm )do begin inc(n); inc(j); u[i,j] := n; end;

  if( um < 0 ) then break;
  dec(um);
  while( i-1 > um )do begin inc(n); dec(i); u[i,j] := n; end;

  if( lm < 0 ) then break;
  dec(lm);
  while( j-1 > lm ) do begin inc(n); dec(j); u[i,j] := n; end;

  if( dm = ui+1 ) then break;
  inc(dm);
  while( i+1 < dm )do begin inc(n); inc(i); u[i,j] := n; end;
 end;
end;

//Выводим матрицу как таблицу в HTML
procedure TUlama.OutMat;
var i, j: integer; s, ss: string; lst: TStringList;
begin
  lst := TStringList.Create;
  lst.add('<table colspan=0 cellspacing=0 border=1>');
  for i:=1 to ui do begin
    s := '';
    for j:=1 to ui do begin
      ss := format('%3d ',[ u[i,j] ]);
      if( pr[ u[i,j] ] ) then ss := '<b>'+ss+'</b>';
      s := s + '<td>' + ss + '</td>';
    end;
    s := '<tr align=center>' + s + '</tr>';
    lst.add(s);
  end;
  lst.savetofile('mat.html');
  lst.Free;
end;
//========================================================================================

procedure TTriang.Word2Screen(var x, y: integer);
begin
  y := height - y;
end;

//n*(n+1)/2 = K => n^2+n-2*K = 0  =>
procedure TTriang.getCoordIJ(n: longint; var i,j: longint);
var r: double; K,T, x:longint;
begin
 K := n;
 r := (-1 + sqrt(1+8*K))/2;
 n := trunc(r);  // отбрасываем дробную часть
 T := (n*n+n) div 2;
 if( T <> K) then begin
   n := n+1;
   T := T + n;
 end;
 j := T-K+1;
 i := n - j + 1;end;

procedure TTriang.FillMat;
var i, j, T: integer;
begin
  T := 1;
  u[21,1] := 1;
  for i:=2 to 21 do begin
    T := T + i;
    u[22-i,1] := T;
    for j := 2 to i do begin
      u[22 - (i-j+1), j] := T - j + 1;;
    end;
  end;
end;

procedure TTriang.outMat;
var lst: TStringList; s, ss: string; i, j: integer;
begin
 lst := TStringList.Create;
 lst.add('<table colspan=0 cellspacing=0 border=1>');
 for i:=1 to ui do begin
   s := '';
   for j:=1 to i do begin
     ss := format('%3d ',[ u[i,j] ]);
     //if( pr[ u[i,j] ] ) then ss := '<b>'+ss+'</b>';
     s := s + '<td>' + ss + '</td>';
   end;
   s := '<tr align=center>' + s + '</tr>';
   lst.add(s);
 end;
 lst.savetofile('tmat.html')

end;

//========================================================================================
  // Эратосфен
procedure Eratosfen(n:longint);
  var i, k: longint;
  begin
    for i:=1 to n do begin
      if( i mod 2 = 0 ) then pr[i] := false
      else pr[i]:= true;
    end;
    pr[1] := true; pr[2] := true;
    i := 3;
    while i*i <= N do begin
         if pr[i] then begin
             k := i*i;
             while k <= N do begin
                 pr[k] := false;
                 k := k+i;
             end;
         end;
         i := i+1;
    end;
end;

// Координаты в системе (номер ringa, длина от нечетного квадрата)
procedure CoordSq( k: longint; var sq, len: longint);
var q: longint;
begin
  q := trunc(sqrt(k) );
  if q mod 2 = 0 then q := q-1; // считаем лт нечетного квадрата
  len := k - q*q;
  sq := (q+1) div 2; // q = 2n-1, где n = 1, 2,...
end;

{
 Координаты (i,j) числа n на спирали в матрице.
 На луче, проведенном из начала координат через узлы с координатами (-п,п),
 располагаются точки с номерами (2*n)^2
 На аналогичном луче, начинающемся из первой точки и проходящем через
 точки с координатами (n,-n+l), расположены точки с номерами (2*n-1)^2.

 Находим ближайший к N квадрат числа q.
 Если q -- четное, то в зависимости от разности q^2-N интересующая нас точка
 находится на верхней или левой ветви. И для вычисления координат достаточно откорректировать
 одну из координат угловой точки (-q,q) на величину разности.
 Если q нечетное, то ветвь, содержащая точку с номером N, находится либо внизу, либо справа.
 И тогда коррекции надо подвергнуть одну из координат точки (q, -q+1).
}
procedure getCoordIJ(n: longint; var i,j: longint);
var q, q1, q2, d: longint;
begin
 if( n < 1) then begin
   i := 0; j := 0;
   exit;
 end;
 n := n -1;
  q1 := trunc(sqrt(n) );  // q1^2 < N
  q2 := q1 + 1;           // q2^2 > N
  //выбираем ближайший квадрат
  if( abs( n-q1*q1) < abs( n-q2*q2) ) then q := q1
  else q := q2;

  d := q*q - n;
  if( q mod 2 = 0 ) then begin  // ближайший квадрат на диагонали четных квадратов
    i := q div 2; j := -i;      // координаты квадрата
    if ( d > 0) then j := j + d  // сверху от диагонали
    else i := i + d;  // слева диагонали
  end
  else begin // ближайший квадрат на диагонали нечетных квадратов
    j := (q+1) div 2; i := -j+1;  // координаты квадрата
    if( d > 0) then j := j-d  // слева диагонали
    else i := i - d; // сверху от диагонали
  end;
end;

// Определяем число на спирали по его координатам
function getN(x,y: integer): longint;
var q,N0: longint;
begin
  if( (y > 0) and (abs(x) <= y) ) then begin // Верхняя четверть
    q := 2*y; N0 := q*q-y;
    Result := N0-x;
    exit;
  end;

  if( (x > 0) and (abs(y) < x) ) then begin // Правая четверть
    q := 2*x-1; N0 := q*q+x-1;
    Result := N0 + y;
    exit;
  end;

  if ( (y < 0) and ( abs(x) <= abs(y)) ) then begin // Нижняя четверть
    q := 2*abs(y)+1; N0 := q*q - abs(y) -1;
    Result := N0 + x;
    exit;
  end;

  if ( (x < 0) and ( abs(x) >= abs(y)) ) then begin // Левая четверть
    q := 2*abs(x); N0 := q*q + abs(x);
    Result := N0 - y;
    exit;
  end;
end;
{
Коэффициеты квадратного полинома y=ax^2+bx+c
по конечной разности cd (common difference) и y1=P(1) и y2=P(2)
а = cd / 2 ( для полинома 2-й степени)
Если cd четная
  a = cd div 2
  P(1) = y1 = a+b+c
  P(2) = y2 = 4a+2b+c
  =>
  b=y2-y1-3a
  c=2*y1-y2+2a
Если cd нечетная
  P(x)=cd*x^2/2+bx+c = (cd*x^2+2bx+2c)/2
  => 2*P(x) = cd*x^2+2bx+2c
  ищем 2b и 2c
  =>
  2*y1 = cd+2b+2c
  2*y2 = 4*cd+4b+2c
  =>
  2*y2-2*y1 = 3*cd+2b =>
                        2b = 2*y2-2*y1 - 3*cd
  2c = 2*y1-cd-2b = 2*y1-cd-2*y2+2*y1 + 3*cd =>
                        2c = 4*y1-2*y2+2*cd
}
procedure Polinom(cd, y1,y2:longint; var a, b, c, d: longint);
begin
 if( cd mod 2 = 0) then begin
  a := cd div 2;  //a=(конечная разность) div (факториал степени полинома)
  b := y2-y1-3*a;   // Решаем систему с двумя неизвестными
  c := 2*y1-y2+2*a;
  d := 1;          //делитель = 1
 end else begin
  a := cd;
  b := 2*y2-2*y1 - 3*cd;
  c := 4*y1-2*y2+2*cd;
  d := 2;
 end;
end;

{$R *.lfm}

{ TForm1 }
// Заполняем решето
procedure TForm1.FormCreate(Sender: TObject);
begin
 ClearPaintBox;
 with Image1.Canvas do begin
  ulama := TUlama.Create(width, height);
  triang := TTriang.Create(width, height);
  coord := ulama;
 end;
end;


// Чистим Image
procedure TForm1.ClearPaintBox;
begin
 if not ClearCB.Checked then exit;
 with Image1.Canvas do begin
   Brush.Style := bsClear;
   Brush.Color := clWhite;
   FillRect(ClientRect);
   rectangle(0,0, width, height);
 end;
end;


//Draw pixel
// (x,y) в координатах, где (0,0) в центре
procedure TForm1.setPix(x, y: integer; col: TColor);
var x0,y0, scale : integer;
begin
  scale := ScaleSpin.value;     //масштаб
  x := x*scale; y := y*scale;   // scale
  coord.Word2Screen(x, y);      // мировые координаты в экранные
  with Image1 do begin
{
    x0 := width div 2;   // x0, y0- середина панели
    y0 := height div 2;
    y := height - (y + y0);
    x := x+x0;
}
    canvas.Brush.color := col;
    canvas.pen.color := col;
    canvas.Pixels[x,y] := col;
    scale := RectSpin.value;   //размер квадрата
    canvas.rectangle(x,y,x+scale,y+scale);
  end;
end;

//Вывод текста
procedure TForm1.wText(x, y: integer; s: string);
var x0,y0, scale : integer;
begin
 scale := ScaleSpin.value;
 x := x*scale; y := y*scale;
 coord.Word2Screen(x, y);      // мировые координаты в экранные
 y := y + RectSpin.value +1; // + размер rectangla
 with Image1 do begin
  canvas.Brush.color := clWhite;
  Canvas.Font.Color := clBlack;
  canvas.textOut(x, y, s);
 end;
end;

//Рисуем квадраты (rings) на панели
procedure TForm1.drawGrid;
var x1,y1 , x2, y2, i, scale: integer;
begin
 scale := ScaleSpin.value;
 with Image1 do begin
   x1 := width div 2 - 1;
   y1 := height div 2 - 1;
   x2 := width div 2 + 1;   // x0, y0- середина панели
   y2 := height div 2 + 1;
   for i:=1 to 40 do begin
     x1 := x1 - scale; y1 := y1 - scale;
     x2 := x2 + scale; y2 := y2 + scale;
     canvas.line(x1,y1,x2,y1);
     canvas.line(x2,y1,x2,y2);
     canvas.line(x2,y2,x1,y2);
     canvas.line(x1,y2,x1,y1);
   end;
 end;

end;

// рисуем простые числа на скатерти
procedure TForm1.UlamButClick(Sender: TObject);
var n, k: longint; x, y: integer; s: string;
begin
 n := strtoint(CntEdit.text);
 Eratosfen(n);
 coord.fillMat; coord.outMat;  // выводим матрицу в html файл
 with Image1 do begin
    ClearPaintBox;
    Box1.Clear;
    if GridCB.checked then DrawGrid;
  for k :=0 to n do begin
     if pr[k] then begin  //если к простое число
      coord.getCoordIJ(k, y, x);  // координаты числа к
      setPix(x,y,clBlue);
        if TxtCB.checked then wText(x,y, inttostr(k));
      s := inttostr(k) + ' ' + inttostr(x) + ' ' + inttostr(y) + ' ' + inttostr(k);
      box1.Items.add(s);
    end;
  end;
 end;
end;


//геометрическая прогрессия
procedure TForm1.GPButClick(Sender: TObject);
var k,n,i, b, d, x,y: longint; s: string;
begin
 ClearPaintBox;
 Box1.Clear;
 b := strtoint(edit1.text);
 d := strtoint(edit2.text);
 n := strtoint(CntEdit.text);
 k := 0;
 for i:=1 to n do begin
  b := b * d;
  coord.getCoordIJ(b, y, x);
  s := inttostr(y) + ' ' + inttostr(x) + ' ' + inttostr(b)+ ' ' + inttostr(i);
  box1.Items.add(s);
  k := k+1;
  if TxtCB.checked then wText(x,y, inttostr(k));
  setPix(x,y,clBlack);
 end;
end;

{ Арифметическая прогрессия}
procedure TForm1.APButClick(Sender: TObject);
var k,n,i, b, d, x,y: longint; s: string;
  col: TColor;
begin
  ClearPaintBox;
  Box1.Clear;
  if GridCB.checked then drawGrid;  //darw grid  если надо
  b := strtoint(edit1.text);   // 1-й член
  d := strtoint(edit2.text);   // приращение
  n := strtoint(CntEdit.text);   // количество
  Eratosfen(n);
  k := 0;
  for i:=1 to n do begin
   b := b + d;
   if pr[b] then col := clRed else col := clBlack;
   coord.getCoordIJ(b, y, x);
   if YvalCB.checked then  x:=i;// вместо х берем номер
   if Y2numCB.checked then begin
     if b mod 2 <> 0 then col := clBlack else col := clBlue;
     CoordSq( b, x, y);
     x := x - strtoint(Y1Edit.text); y:=y - strtoint(Y2Edit.text) ;
   end;
   if YabsCB.checked then  y := abs(y);


   setPix(x,y,col);

   inc(k);
   if TxtCB.checked then wText(x,y, inttostr(k));

   s := inttostr(y) + ' ' + inttostr(x) + ' ' + inttostr(b)+ ' ' + inttostr(i);
   box1.Items.add(s);
  end;
end;

// Вывод m-угольных чисел
procedure TForm1.TriangButClick(Sender: TObject);
var k, n,i, b, m, x,y: longint; s: string; col: TColor;
begin

 ClearPaintBox;
 Box1.Clear;
 n := strtoint(CntEdit.text);
 m := strtoint(ang3Edit.text);   // m- размерность

 if GridCB.checked then drawGrid;
 k := 0;
 col := clBlack;
 for i:=1 to n do begin
  b := ((m-2)*i*i-(m-4)*i) div 2;  // b := m-угольное число
  coord.getCoordIJ(b, y, x);
  if ShowTCB.checked then begin
    if YvalCB.checked then  x:=i-50;//
    if YabsCB.checked then  y := abs(y);
    setPix(x,y,col);
  end;
  if ShowSqCB.checked then begin
    b := i*i div (m - 1);
    coord.getCoordIJ(b, y, x);
    setPix(x,y,clRed);
  end;

  inc(k);
  if TxtCB.checked then wText(x,y, inttostr(k));

  s := inttostr(b) + ' ' + inttostr(y) + ' ' + inttostr(x)+ ' ' + inttostr(i);
  box1.Items.add(s);
 end;
end;
// Сохранить Image в файл
procedure TForm1.SaveButClick(Sender: TObject);
begin
 if SaveDialog1.Execute then
    Image1.Picture.SaveToFile(SaveDialog1.Filename);
end;

// Определяем коэф-ты полинома ax^2+bx+c по конечной разности и Y(x=1) и Y(x=2)
procedure TForm1.PolinomButClick(Sender: TObject);
var a, b, c, d, y3: longint;   s: string;
begin
  Polinom( strtoint(CDedit.Text), // common difference
           strtoint(Y1Edit.Text), // Y(1)
           strtoint(Y2Edit.Text), // Y(2)
           a, b , c, d);             // получаем коэф-ты полинома
  // Формируем строку для вывода
  s := '(' + inttostr(a) + '*x^2';
  if b < 0 then s := s + inttostr(b)
  else s := s + '+' + inttostr(b);
  s := s + '*x';
  if c < 0 then s := s + inttostr(c)
  else s := s + '+' + inttostr(c) + ')';
  if( d = 2 ) then s := s + '/2';
  y3 := (a*9+b*3+c) div d;
  s := s+' ('+inttostr(y3)+')';
  KoefLB.Caption := s;
  aEdit.text := inttostr(a);
  bEdit.text := inttostr(b);
  cEdit.text := inttostr(c);
  divSpin.value := d;
end;

// Рисуем значения полинома (ax^2+bx+c)/Div на спирали
procedure TForm1.ShowPButClick(Sender: TObject);
var a, b, c, d, n, i, k, x, y: longint; s: string; col: TColor;
begin
 a := strtoint(aEdit.text);
 b := strtoint(bEdit.text);
 c := strtoint(cEdit.text);
 d := DivSpin.value;
 ClearPaintBox;
 Box1.Clear;
 n := strtoint(CntEdit.text);
  Eratosfen(n);
 for i :=1 to n do begin
    k := (a*i*i + b*i + c);
    if k < 0 then continue;  // пропускаем значения меньше 0
    k := k div d;
    coord.getCoordIJ(k, y, x);  // координаты числа к
    col := clBlack;
{
    if( k > maxErtf) then break;
    if pr[k] then  col := clRed;//если к простое число
}
    setPix(x,y,col);
    if TxtCB.checked then wText(x,y, inttostr(i));
    s := inttostr(k) + ' ' + inttostr(x) + ' ' + inttostr(y);
    box1.Items.add(s);
   end;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  coord.fillMat;
  coord.outMat;
end;

procedure TForm1.N2YXButClick(Sender: TObject);
var
  K,x,y:longint; r: single;
begin
  K := strtoint(aEdit.text);
  coord.getCoordIJ(K,y,x);
  bEdit.text := inttostr(x);
  cEdit.text := inttostr(y);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if( ComboBox1.ItemIndex = 0 ) then coord := ulama
  else coord := triang;
end;

procedure TForm1.FibButClick(Sender: TObject);
var k, n,i, b, x,y: longint; s: string; col: TColor;
  fib: array[1..2] of longint;
begin

 ClearPaintBox;
 Box1.Clear;
 n := strtoint(CntEdit.text);
 k := 0;
 col := clBlack;
 fib[1] := 1; fib[2] := 1;
 for i:=1 to n do begin
  if k > 30 then break;
  b := fib[1] + fib[2];
  if b > maxErtf then col := clBlack
  else
    if pr[b] then col := clRed else col := clBlack;
  fib[1] := fib[2]; fib[2] := b;
  coord.getCoordIJ(b, y, x);
  if YvalCB.checked then  x:=i;// вместо х берем номер
  setPix(x,y,col);
  inc(k);
  if TxtCB.checked then wText(x,y, inttostr(k));

  s := inttostr(b) + ' ' + inttostr(y) + ' ' + inttostr(x)+ ' ' + inttostr(i);
  box1.Items.add(s);
 end;
end;


end.

