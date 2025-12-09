Unit uBatteryBank;

Interface

Uses System.Generics.Collections;

Type
  TBatteryBank = Class
  strict private
    _batteries: TArray<Byte>;
    Function LargestNumberFromPos(Const inStartPos: NativeInt; Const inIgnoreLast: Boolean): NativeInt;
  public
    Constructor Create(Const inBankString: String); ReIntroduce;
    Function MaxJoltage: Byte;
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

Function TBatteryBank.LargestNumberFromPos(Const inStartPos: NativeInt; Const inIgnoreLast: Boolean): NativeInt;
Var
  a, last: NativeInt;
Begin
  Result := inStartPos;

  last := High(_batteries);

  If inIgnoreLast Then
    last := last - 1;

  For a := inStartPos + 1 To last Do
  Begin
    If _batteries[a] > _batteries[Result] Then
      Result := a;

    If _batteries[Result] = 9 Then
      Break;
  End;
End;

Function TBatteryBank.MaxJoltage: Byte;
Var
  first, second: NativeInt;
Begin
  first := LargestNumberFromPos(0, True);
  second := LargestNumberFromPos(first + 1, False);

  Result := Byte.Parse(_batteries[first].ToString + _batteries[second].ToString);
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
