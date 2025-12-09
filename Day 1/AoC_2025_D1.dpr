Program AoC_2025_D1;

{$APPTYPE CONSOLE}

{$R *.res}

Uses
  System.SysUtils, System.IOUtils,
  uLockDial in 'uLockDial.pas';

Var
  dial: TLockDial;
  line: String;
  amount, zeroes, rollovers: Integer;
  rollover: Boolean;
Begin
  zeroes := 0;
  rollover := False;

  Try
    Try
      dial := TLockDial.Create;
      Try
        For line In TFile.ReadAllLines('.\combination.txt') Do
        Begin
          Write('- ' + line + '... ');

          amount := Integer.Parse(line.Substring(1));

          Write(' Turning dial by the amount of ' + amount.ToString + '... ');

          Case UpperCase(line[1])[1] Of
            'L':
            Begin
              Write(' Left! ');

              dial.MoveLeft(amount, rollover);
            End;
            'R':
            Begin
              Write(' Right! ');

              dial.MoveRight(amount, rollover);
            End;
            Else
              Raise Exception.Create('Unknown direction to move the dial!');
          End;

          Write('Final position is ' + dial.Position.ToString + '. ');

          rollovers := amount Div dial.MaxDistance;
          If rollover And (dial.Position <> 0) Then
            Inc(rollovers);

          WriteLn('Dial rolls over a total of ' + rollovers.ToString + ' time(s).');

          If dial.Position = 0 Then
            Inc(zeroes);

          Inc(zeroes, rollovers);
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
