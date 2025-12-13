Program AoC_2025_D8;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.IOUtils, System.Generics.Collections,
  uJuntionBoxPlanner in 'uJuntionBoxPlanner.pas';

Var
  line: String;
  jmp: TJunctionBoxPlanner;
  coords: TArray<String>;
  d: TDistance;
  a, b: NativeInt;
  circuits: TArray<TArray<TJunctionBox>>;
  sizes: TList<NativeInt>;

Begin
  Try
    Try
      jmp := TJunctionBoxPlanner.Create;
      Try
        WriteLn('Loading junction boxes...');

        For line In TFile.ReadAllLines('.\junctionboxes.txt') Do
        Begin
          coords := line.Split([','], TStringSplitOptions.ExcludeEmpty);

          WriteLn(jmp.AddJunctionBox(Integer.Parse(coords[0]), Integer.Parse(coords[1]), Integer.Parse(coords[2])).NicePosition);
        End;

        WriteLn;
        WriteLn('Calculating distances...');

        jmp.CalculateDistances;

        WriteLn;
        WriteLn('Getting shortest distances...');

        // 25704 too much
        For a := 1 To 1000 Do
        Begin
          d := jmp.ShortestDistance;

          WriteLn(a.ToString + '. shortest distance: ' + FormatFloat(',.000', d.Distance) + ' between ' + d.Box1.NicePosition + ' and ' + d.Box2.NicePosition);
        End;

        WriteLn;
        WriteLn('The following circuits have been created:');

        circuits := jmp.Circuits;

        sizes := TList<NativeInt>.Create;
        Try
          For a := Low(circuits) To High(circuits) Do
          Begin
            WriteLn('Circuit #' + a.ToString + ' (' + Length(circuits[a]).ToString + ' boxes )');

            For b := Low(circuits[a]) To High(circuits[a]) Do
              Write(circuits[a][b].NicePosition + ' ');

            WriteLn;

            sizes.Add(Length(circuits[a]));
          End;

          WriteLn;
          Write('Finding the 3 largest ones...');

          sizes.Sort;

          WriteLn(' Multiple of 3 largest: ' + Integer(sizes[sizes.Count - 1] * sizes[sizes.Count - 2] * sizes[sizes.Count - 3]).ToString);

        Finally
          FreeAndNil(sizes);
        End;
      Finally
        FreeAndNil(jmp);
      End;
    Except
      On E: Exception Do
        Writeln(E.ClassName, ': ', E.Message);
    End;
  Finally
    ReadLn;
  End;
End.
