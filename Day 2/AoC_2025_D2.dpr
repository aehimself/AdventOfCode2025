Program AoC_2025_D2;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  uIDRangeHandler in 'uIDRangeHandler.pas',
  uIDValidator in 'uIDValidator.pas',
  uID in 'uID.pas';

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

          For id in idranges[a].GetInvalidIDs(TIDValidatorPart2) Do
          Begin
            WriteLn('- Invalid ID found: ' + id.ToString);

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
