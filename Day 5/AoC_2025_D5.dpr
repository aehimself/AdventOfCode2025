Program AoC_2025_D5;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.IOUtils,
  uInventoryManager in 'uInventoryManager.pas';

Var
  invmgr: TInventoryManager;
  line: String;
  available: Boolean;
  ingredient: TIngredientID;
  fresh: Integer;

Begin
  available := False;
  fresh := 0;

  Try
    Try
      invmgr := TInventoryManager.Create;
      Try
        WriteLn('Parsing fresh ingredient ranges...');

        For line In TFile.ReadAllLines('.\ingredients.txt') Do
        Begin
          If line.IsEmpty Then
          Begin
            WriteLn;
            WriteLn('End of fresh ingredients. Parsing available ingredients...');

            available := True;

            Continue;
          End;

          If available Then
            invmgr.AddAvailable(TIngredientID.Parse(line))
          Else
            invmgr.AddFresh(line);

          WriteLn(line);
        End;

        WriteLn;
        WriteLn('Checking for fresh ingredients...');

        For ingredient In invmgr.AvailableIngredients Do
          If invmgr.IsFresh(ingredient) Then
          Begin
            WriteLn('Ingredient ' + ingredient.ToString + ' is fresh!');

            Inc(fresh);
          End;

        WriteLn;
        WriteLn('A total of ' + fresh.ToString + ' ingredient(s) are fresh.');

      Finally
        FreeAndNil(invmgr);
      End;
    Except
      On E: Exception Do
        Writeln(E.ClassName, ': ', E.Message);
    End;
  Finally
    ReadLn;
  End;
End.
