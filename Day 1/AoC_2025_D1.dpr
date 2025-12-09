Program AoC_2025_D1;

{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils, System.IOUtils,
  uLockDial in 'uLockDial.pas';

Var
  dial: TLockDial;
  line: String;
  amount, zeroes: Integer;
Begin
  zeroes := 0;

  Try
    Try
      dial := TLockDial.Create;
      Try
        For line In TFile.ReadAllLines('.\combination.txt') Do
        Begin
          Write('- Read line: "' + line + '"... ');

          amount := Integer.Parse(line.Substring(1));

          Write(' Turning dial by the amount of ' + amount.ToString + '... ');

          Case UpperCase(line[1])[1] Of
            'L':
            Begin
              Write(' Left!');

              dial.MoveLeft(amount);
            End;
            'R':
            Begin
              Write(' Right!');

              dial.MoveRight(amount);
            End;
            Else
              Raise Exception.Create('Unknown direction to move the dial!');
          End;

          WriteLn(' Position is ' + dial.Position.ToString + '.');

          If dial.Position = 0 Then
            Inc(zeroes);
        End;
      Finally
        FreeAndNil(dial);
      End;

      WriteLn;
      WriteLn('At the end of the combination the dial reached position zero ' + zeroes.ToString + ' time(s).');
    Except
      On E: Exception Do
        Writeln(E.ClassName, ': ', E.Message);
    End;
  Finally
    ReadLn;
  End;
End.
