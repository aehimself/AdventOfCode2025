Program AoC_2025_D7;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  uManifoldMapper in 'uManifoldMapper.pas';

Var
  line: String;
  mmap: TManifoldMapper;
Begin
  Try
    Try
      mmap := TManifoldMapper.Create;
      Try
        For line In TFile.ReadAllLines('.\manifold.txt') Do
          mmap.AddLevel(line);

        WriteLn;
        WriteLn('Total splitters hit: ' + mmap.SplitterCount.ToString);
        WriteLn('Maximum path count: ' + mmap.MaximumPathCount.ToString);
      Finally
        FreeAndNil(mmap);
      End;
    Except
      On E: Exception Do
        Writeln(E.ClassName, ': ', E.Message);
    End;
  Finally
    ReadLn;
  End;
End.
