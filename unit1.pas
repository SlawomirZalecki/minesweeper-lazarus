unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, LResources;

type

  { TForm1 }

  TForm1 = class(TForm)
    About: TLabel;
    LNomor: TLabel;
    LOpen: TLabel;
    TBaris: TEdit;
    Timer1: TTimer;
    TKolom: TEdit;
    TMine: TEdit;
    LMine: TLabel;
    LKolom: TLabel;
    LBaris: TLabel;
    new_game_button: TButton;
    procedure FormCreate(Sender: TObject);
    procedure LOpenClick(Sender: TObject);
    procedure new_game_buttonClick(Sender: TObject);
    procedure pilih_kotak(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tandai(nomor: integer);
    procedure buka_kotak(nomor: integer);
    procedure buat_kotak_awal(nomor: integer);
    procedure TBarisChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TKolomChange(Sender: TObject);
    procedure printlabel();
    procedure tunjukkan_nomor(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  Kolom: integer;
  Baris: integer;
  Mine : integer;
  square_size: integer;
  bom : array [0..999] of boolean;
  arr_kotak : array[0..999] of TImage;
  visited : array [0..999] of boolean;
  tanda : array[0..999] of boolean;
  opened : integer;
  found : integer;
  timelps: integer;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.printlabel();
var
  waktu: integer;
begin
   waktu := timelps;
   if timelps < 0 then begin
      waktu := 0;
   end;
   LOpen.Caption := '( ' + IntToStr(Opened) + ' | ' + IntToStr(Found) + ' ) ' + IntToStr(waktu);
end;

function valid(r: integer; c: integer):boolean;
begin
   if ((r>=0) and (r<baris) and (c>=0) and (c<kolom)) then valid:=true
   else valid:=false;
end;

procedure menang();
var
  waktu : integer;
begin
   waktu := timelps;
   timelps := -1;
   ShowMessage('SELAMAT! ANDA MENANG!'#10'Ukuran Grid: ' + IntToStr(Baris) + ' x ' + IntToStr(Kolom) + #10 + 'Mines: ' + IntToStr(Mine) + #10 + 'Waktu: ' + IntToStr(waktu));
end;

procedure kalah(LNomor: integer);
var
  i: integer;
begin
   timelps := -1;
   for i:= 0 to baris*kolom-1 do begin
       if bom[i] then begin
          if tanda[i] then begin
             arr_kotak[i].Picture.LoadFromLazarusResource('tandabom');
          end else begin
              arr_kotak[i].Picture.LoadFromLazarusResource('birubom');
          end;
       end;
       arr_kotak[i].enabled := False;
   end;
   arr_kotak[LNomor].Picture.LoadFromLazarusResource('orangebom');
   ShowMessage('KABOOOM! ANDA KALAH');
end;

procedure TForm1.buka_kotak(nomor: integer);
var
  pinggir: integer;
  r,c: integer;
  pin: array[0..7] of integer;
  pir: array[0..7] of integer;
  pic: array[0..7] of integer;
  i: integer;
  filename: string;
begin
   if not bom[nomor] then begin
      if tanda[nomor] then begin
         tanda[nomor] := false;
         dec(found);
         printlabel();
      end;
      visited[nomor] := true;
      pinggir := 0;
      r := nomor div kolom;
      c := nomor mod kolom;
      pir[0] := r-1; pic[0] := c-1; pin[0] := nomor-kolom-1;
      pir[1] := r-1; pic[1] := c;   pin[1] := nomor-kolom;
      pir[2] := r-1; pic[2] := c+1; pin[2] := nomor-kolom+1;
      pir[3] := r;   pic[3] := c-1; pin[3] := nomor-1;
      pir[4] := r;   pic[4] := c+1; pin[4] := nomor+1;
      pir[5] := r+1; pic[5] := c-1; pin[5] := nomor+kolom-1;
      pir[6] := r+1; pic[6] := c;   pin[6] := nomor+kolom;
      pir[7] := r+1; pic[7] := c+1; pin[7] := nomor+kolom+1;

      for i:= 0 to 7 do begin
          if (valid(pir[i],pic[i]) and bom[pin[i]]) then inc(pinggir);
      end;

      if (pinggir = 0) then begin
         arr_kotak[nomor].Picture.LoadFromLazarusResource('putih');
         inc(opened);
         printlabel();
         arr_kotak[nomor].Enabled := False;
         if (opened >= Baris*Kolom - Mine) then menang();
         if ((valid(pir[0],pic[0])) and not visited[pin[0]]) then buka_kotak(pin[0]);
         if ((valid(pir[1],pic[1])) and not visited[pin[1]]) then buka_kotak(pin[1]);
         if ((valid(pir[2],pic[2])) and not visited[pin[2]]) then buka_kotak(pin[2]);
         if ((valid(pir[3],pic[3])) and not visited[pin[3]]) then buka_kotak(pin[3]);
         if ((valid(pir[4],pic[4])) and not visited[pin[4]]) then buka_kotak(pin[4]);
         if ((valid(pir[5],pic[5])) and not visited[pin[5]]) then buka_kotak(pin[5]);
         if ((valid(pir[6],pic[6])) and not visited[pin[6]]) then buka_kotak(pin[6]);
         if ((valid(pir[7],pic[7])) and not visited[pin[7]]) then buka_kotak(pin[7]);
      end else begin
         filename := IntToStr(pinggir);
         inc(opened);
         printlabel();
         arr_kotak[nomor].Enabled := False;
         arr_kotak[nomor].Picture.LoadFromLazarusResource(filename);
         if (opened >= Baris*Kolom - Mine) then menang();
      end;
   end;
end;

procedure TForm1.buat_kotak_awal(nomor: integer);
var
  nama_kotak: string;
begin
      arr_kotak[nomor] := TImage.Create(Form1);
      nama_kotak := 'kotak' + IntToStr(nomor);
      with arr_kotak[nomor] do begin
        Height := square_size;
        Width := square_size;
        Name := nama_kotak;
        Parent := Form1;
        Enabled := True;
        Tag := nomor;
        Left := (nomor mod kolom) * square_size;
        Top := 50 + (nomor div kolom) * square_size;
        OnMouseUp := @pilih_kotak;
        OnMouseEnter := @tunjukkan_nomor;
        Picture.LoadFromLazarusResource('biru');
        BringToFront;
      end;
end;

procedure TForm1.tandai(nomor:integer);
begin
   if (tanda[nomor]) then begin
      tanda[nomor] := False;
      dec(found);
      arr_kotak[nomor].Picture.LoadFromLazarusResource('biru');
      printlabel();
   end else begin
      tanda[nomor] := True;
      inc(found);
      arr_kotak[nomor].Picture.LoadFromLazarusResource('tanda');
      printlabel();
   end;
end;

procedure TForm1.TBarisChange(Sender: TObject);
begin
   if (TBaris.Text <> '') and (TKolom.Text <> '') then
      TMine.Text := IntToStr(StrToInt(TBaris.Text)*StrToInt(TKolom.Text) div 4);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
   if (timelps >= 0) then begin
      inc(timelps);
      printlabel();
//      if (opened >= Baris*Kolom - Mine) then menang();
   end;
end;

procedure TForm1.TKolomChange(Sender: TObject);
begin
   if (TBaris.Text <> '') and (TKolom.Text <> '') then
      TMine.Text := IntToStr(StrToInt(TBaris.Text)*StrToInt(TKolom.Text) div 4);
end;

procedure TForm1.pilih_kotak(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
var
  nomor: integer;
begin
   if Sender is TImage then begin
      nomor := TImage(Sender).Tag;
   end;
   if Button = mbRight then begin
      tandai(nomor);
   end else if bom[nomor] then begin
      kalah(nomor);
   end else begin
      buka_kotak(nomor);
   end;

end;

procedure TForm1.new_game_buttonClick(Sender: TObject);
var
  i: integer;
  rand : integer;
begin
   Kolom := StrToInt(TKolom.Text);
   Baris := StrToInt(TBaris.Text);
   if (Kolom < Baris) then begin
      Kolom := Kolom + Baris;
      Baris := Kolom - Baris;
      Kolom := Kolom - Baris;
   end;
   Mine := StrToInt(TMine.Text);

   if Baris < 8 then begin
      ShowMessage('Maaf, baris minimum adalah 8');
   end else if Kolom < 8 then begin
      ShowMessage('Maaf, kolom minimum adalah 8');
   end else if Mine < Baris*Kolom div 10 then begin
      ShowMessage('Maaf, jumlah minimum mines adalah ' + IntToStr(Baris*Kolom div 10));
   end else begin
      timelps := 0;
      opened := 0;
      found := 0;
      if (Kolom*24 > 320) then begin
         Form1.Width := Kolom*24;
      end else begin
         Form1.Width := 320;
      end;
      Form1.Height := 50 + Baris*24;
      for i:= 0 to 999 do begin
         bom[i] := false;
         FreeAndNil(arr_kotak[i]);
         visited[i] := false;
         tanda[i] := False;
      end;
      for i:= 0 to (kolom*baris)-1 do begin
         buat_kotak_awal(i);
      end;
      i := Mine;
      while (i>0) do begin
         rand := Random(baris*kolom);
         if (bom[rand] = false) then begin
            bom[rand] := true;
//            arr_kotak[rand].Picture.LoadFromLazarusResource('orange');
            i := i - 1;
         end;
      end;
   end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   Randomize;
   timelps := -1;
   square_size := 24;
   LNomor.Caption := '';
end;

procedure TForm1.LOpenClick(Sender: TObject);
begin
//   opened := opened + StrToInt(TMine.Text);
//   printlabel();
end;

procedure TForm1.tunjukkan_nomor(Sender: TObject);
var
  r,c,nomor: integer;
begin
//   nomor := TImage(Sender).Tag;
//   r := nomor div kolom;
//   c := nomor mod kolom;
//   LNomor.Caption := IntToStr(r) + ',' + IntToStr(c);
end;

initialization
 {$I sprites.lrs}
end.

{ Made by YA_}
