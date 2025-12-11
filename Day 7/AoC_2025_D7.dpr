Program AoC_2025_D7;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.IOUtils,
  uManifoldSimulator in 'uManifoldSimulator.pas';

Var
  line: String;
  msim: TManifoldSimulator;
  level: TManifoldLevel;
  a: NativeInt;
Begin
  Try
    Try
      msim := TManifoldSimulator.Create;
      Try
        For line In TFile.ReadAllLines('.\manifold.txt') Do
        Begin
          level := msim.NewLevel;

          // Fill starting beams from the file
          a := line.IndexOf('S');

          While a > -1 Do
          Begin
            level.Beam[a] := True;

            a := line.IndexOf('S', a + 1);
          End;

          // Fill splitters from the file
          a := line.IndexOf('^');

          While a > -1 Do
          Begin
            level.Splitter[a] := True;

            a := line.IndexOf('^', a + 1);
          End;
        End;

        WriteLn;
        WriteLn('Total splitters hit: ' + msim.TotalSplittersHit.ToString);
      Finally
        FreeAndNil(msim);
      End;
    Except
      On E: Exception Do
        Writeln(E.ClassName, ': ', E.Message);
    End;
  Finally
    ReadLn;
  End;
End.
