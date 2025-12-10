Program AoC_2025_D6;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.IOUtils,
  uHomeworkSolver in 'uHomeworkSolver.pas';

Var
  lines: TArray<String>;
  line: String;
  solver: THomeworkSolver;
  a, col: NativeInt;

Begin
  Try
    Try
      solver := THomeworkSolver.Create;
      Try
        WriteLn('Filling up homework solver...');

        lines := TFile.ReadAllLines('.\homework.txt');

        If Length(lines) = 0 Then
          Exit;

        col := Length(lines[0]);
        Repeat
          Dec(col);
          line := '';

          For a := 0 To Length(lines) - 1 Do
            If lines[a].Chars[col] <> ' ' Then
              line := line + lines[a].Chars[col];

          WriteLn(line);

          solver.AddHomeworkLine(line);
        Until col = 0;

        WriteLn;
        WriteLn('Problem results:');

        For a := 0 To solver.ProblemCount - 1 Do
        Begin
          Write('#' + a.ToString + ' (');

          Case solver[a].ArithmeticOperation Of
            aoAddition:
              Write('addition');
            aoMultiplication:
              Write('multiplication');
            Else
              Write('unknown');
          End;

          WriteLn('): ' + solver[a].Result.ToString);
        End;

        WriteLn;
        WriteLn('Solver result: ' + solver.Results.ToString);
      Finally
        FreeAndNil(solver);
      End;
    Except
      On E: Exception Do
        Writeln(E.ClassName, ': ', E.Message);
    End;
  Finally
    ReadLn;
  End;
End.
