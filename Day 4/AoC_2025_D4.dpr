Program AoC_2025_D4;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.IOUtils,
  uFloorPlan in 'uFloorPlan.pas';

Var
  floorplan: TFloorPlan;
  lines: TArray<String>;
  row, col: NativeInt;
  count, totalremovable: Integer;

Begin
  totalremovable := 0;

  Try
    Try
      lines := TFile.ReadAllLines('.\floorplan.txt');

      floorplan := TFloorPlan.Create;
      Try
        floorplan.SetMapDimensions(Length(lines[0]), Length(lines));

        WriteLn('*** Filling floor plan...');
        For row := Low(lines) To High(lines) Do
        Begin
          WriteLn(lines[row]);

          For col := 0 To Length(lines[row]) - 1 Do
            If lines[row].Chars[col] = '@' Then
              floorplan[col, row] := moPaperRoll
            Else
              floorplan[col, row] := moEmpty;
        End;

        WriteLn;

        WriteLn('*** Counting accessible paper rolls...');

        For row := 0 To floorplan.MapHeight - 1 Do
          For col := 0 To floorplan.MapWidth - 1 Do
          Begin
            If floorplan[col, row] <> moPaperRoll Then
              Continue;

            count := floorplan.NeighbouringPaperRolls(col, row);

            If count <= 3 Then
            Begin
              Inc(totalremovable);

              WriteLn('Paper roll at row ' + row.ToString + ' column ' + col.ToString + ' has only ' + count.ToString + ' neighbouring paper rolls!');
            End;
          End;

        WriteLn('A total of ' + totalremovable.ToString + ' paper rolls can be accessed by a forklift.');

        WriteLn;
      Finally
        FreeAndNil(floorplan);
      End;
    Except
      On E: Exception Do
        Writeln(E.ClassName, ': ', E.Message);
    End;
  Finally
    ReadLn;
  End;
End.
