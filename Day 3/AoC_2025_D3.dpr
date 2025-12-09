Program AoC_2025_D3;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.IOUtils,
  uBatteryBank in 'uBatteryBank.pas';

Var
  line: String;
  banks: TBatteryBanks;
  bank: TBatteryBank;
  totaljolts: Integer;

Begin
  totaljolts := 0;

  Try
    Try
      For line In TFile.ReadAllLines('.\batterybanks.txt') Do
      Begin
        banks := TBatteryBanks.Create;
        Try
          bank := banks.AddBank(line);

          WriteLn('Battery bank: ' + line + ', maximum joltage: ' + bank.MaxJoltage.ToString);

          totaljolts := totaljolts + bank.MaxJoltage;
        Finally
          FreeAndNil(banks);
        End;
      End;

      WriteLn;
      WriteLn('Total battery joltage: ' + totaljolts.ToString);
    Except
      On E: Exception Do
        Writeln(E.ClassName, ': ', E.Message);
    End;
  Finally
    ReadLn;
  End;
End.
