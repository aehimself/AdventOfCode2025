Program AoC_2025_D2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.IOUtils,
  uIDRangeHandler in 'uIDRangeHandler.pas';

Function IsIDInvalid(Const inID: TID): Boolean;
Var
  id, checking, tempid: String;
  a: NativeInt;
Begin
  id := inID.ToString;

  Result := False;

  For a := 1 To id.Length Div 2 Do
  Begin
    checking := id.Substring(0, a);

    tempid := checking;

    While tempid.Length < id.Length Do
      tempid := tempid + checking;

    Result := tempid = id;

    If Result Then
      Break;
  End;
End;

Var
  line, range: String;
  idranges: TIDRangeHandler;
  a: NativeInt;
  id, idsum: TID;
Begin
  idsum := 0;

  Try
    Try
      idranges := TIDRangeHandler.Create;
      Try
        For line In TFile.ReadAllLines('.\idranges.txt') Do
          For range In line.Split([',']) Do
            idranges.AddRange(range);

        For a := 0 To idranges.RangeCount - 1 Do
        Begin
          WriteLn('Checking IDs in range ' + idranges[a].Banner);

          For id In idranges[a].IDs Do
            If IsIDInvalid(id) Then
            Begin
              WriteLn('Invalid ID found: ' + id.ToString);

              idsum := idsum + id;
            End;
        End;

        WriteLn;
        WriteLn('Sum of all invalid IDs: ' + idsum.ToString);
      Finally
        FreeAndNil(idranges);
      End;
    Except
      On E: Exception Do
        Writeln(E.ClassName, ': ', E.Message);
    End;
  Finally
    ReadLn;
  End;
End.
