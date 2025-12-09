Unit uBatteryBank;

Interface

Uses System.Generics.Collections;

Type
  TBatteryBank = Class
  strict private
    _batteries: TArray<Byte>;
    Function LargestNumberFromPos(Const inStartPos: NativeInt; Const inIgnoreLastElementAmount: Integer): NativeInt;
  public
    Constructor Create(Const inBankString: String); ReIntroduce;
    Function MaxJoltage(Const inBatteryAmount: Integer): UInt64;
  End;

  TBatteryBanks = Class(TObjectList<TBatteryBank>)
  public
    Function AddBank(Const inBankString: String): TBatteryBank;
  End;

Implementation

Uses System.SysUtils;

//
// TBatteryBank
//

Constructor TBatteryBank.Create(Const inBankString: String);
Var
  a: NativeInt;
Begin
  inherited Create;

  SetLength(_batteries, inBankString.Length);

  For a := Low(_batteries) To High(_batteries) Do
    _batteries[a] := Byte.Parse(inBankString.Chars[a]);
End;

Function TBatteryBank.LargestNumberFromPos(Const inStartPos: NativeInt; Const inIgnoreLastElementAmount: Integer): NativeInt;
Var
  a, last: NativeInt;
Begin
  Result := inStartPos;

  last := High(_batteries) - inIgnoreLastElementAmount;

  For a := inStartPos + 1 To last Do
  Begin
    If _batteries[a] > _batteries[Result] Then
      Result := a;

    If _batteries[Result] = 9 Then
      Break;
  End;
End;

Function TBatteryBank.MaxJoltage(Const inBatteryAmount: Integer): UInt64;
Var
  indexes: TArray<NativeInt>;
  previndex, a: NativeInt;
  s: String;
Begin
  SetLength(indexes, inBatteryAmount);
  s := '';
  previndex := 0;

  For a := Low(indexes) To High(indexes) Do
  Begin
    indexes[a] := LargestNumberFromPos(previndex, High(indexes) - a);

    previndex := indexes[a] + 1;

    s := s + _batteries[indexes[a]].ToString;
  End;

  Result := Int64.Parse(s);
End;

//
// TBatteryBanks
//

Function TBatteryBanks.AddBank(Const inBankString: String): TBatteryBank;
Begin
  Result := TBatteryBank.Create(inBankString);

  Self.Add(Result);
End;

End.
