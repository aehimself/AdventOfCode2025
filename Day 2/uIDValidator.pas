Unit uIDValidator;

Interface

Uses uID;

Type
  TIDValidator = Class
  public
    Function IsIDValid(Const inID: TID): Boolean; Virtual; Abstract;
  End;

  TIDValidatorClass = Class Of TIDValidator;

  TIDValidatorPart1 = Class(TIDValidator)
  public
    Function IsIDValid(Const inID: TID): Boolean; Override;
  End;

  TIDValidatorPart2 = Class(TIDValidator)
  public
    Function IsIDValid(Const inID: TID): Boolean; Override;
  End;

Implementation

Uses System.SysUtils;

//
// TIDValidatorPart1
//

Function TIDValidatorPart1.IsIDValid(Const inID: TID): Boolean;
Var
  s, firsthalf, secondhalf: String;
Begin
  s := inID.ToString;

  Result := s.Length Mod 2 <> 0;

  If Result Then
    Exit;

  firsthalf := s.Substring(0, s.Length Div 2);
  secondhalf := s.Substring(s.Length Div 2);
  Result := firsthalf <> secondhalf;
End;

//
// TIDValidatorPart2
//

Function TIDValidatorPart2.IsIDValid(Const inID: TID): Boolean;
Var
  id, checking, tempid: String;
  a: NativeInt;
Begin
  id := inID.ToString;

  Result := True;

  For a := 1 To id.Length Div 2 Do
  Begin
    checking := id.Substring(0, a);

    tempid := checking;

    While tempid.Length < id.Length Do
      tempid := tempid + checking;

    Result := tempid <> id;

    If Not Result Then
      Break;
  End;
End;

End.
