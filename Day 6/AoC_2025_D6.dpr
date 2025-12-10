Program AoC_2025_D6;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.IOUtils,
  uHomeworkSolver in 'uHomeworkSolver.pas';

Var
  line: String;
  solver: THomeworkSolver;
  a: NativeInt;

Begin
  Try
    Try
      solver := THomeworkSolver.Create;
      Try
        WriteLn('Filling up homework solver...');

        For line In TFile.ReadAllLines('.\homework.txt') Do
        Begin
          WriteLn(line);

          solver.AddHomeworkLine(line);
        End;

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
