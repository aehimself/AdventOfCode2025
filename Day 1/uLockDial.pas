Unit uLockDial;

Interface

Uses System.SysUtils;

Type
  TLockDial = Class
  strict private
    _max: Integer;
    _min: Integer;
    _pos: Integer;
    {$IFDEF DEBUG}
    Procedure SelfTest;
    {$ENDIF}
    Procedure SetMax(Const inMax: Integer);
    Procedure SetMin(Const inMin: Integer);
    Function DistanceBetween(Const inNumber1, inNumber2: Integer): Integer;
    Function GetMaxDistance: Integer;
    Function SanitizeAmount(Const inAmount: Integer): Integer;
  public
    Constructor Create; ReIntroduce;
    Procedure MoveLeft(Const inAmount: Integer; Var outRolledOver: Boolean);
    Procedure MoveRight(Const inAmount: Integer; Var outRolledOver: Boolean);
    Property Max: Integer Read _max Write SetMax;
    Property MaxDistance: Integer Read GetMaxDistance;
    Property Min: Integer Read _min Write SetMin;
    Property Position: Integer Read _pos Write _pos;
  End;

  ELockDialException = Class(Exception);

Implementation

Constructor TLockDial.Create;
Begin
  inherited;

  _max := 99;
  _min := 0;
  _pos := 50;

  {$IFDEF DEBUG}
  Self.SelfTest;
  {$ENDIF}
End;

Function TLockDial.DistanceBetween(Const inNumber1, inNumber2: Integer): Integer;
Begin
  // To make sure to avoid overflows

  If inNumber1 > inNumber2 Then
    Result := inNumber1 - inNumber2
  Else
    Result := inNumber2 - inNumber1;
End;

Function TLockDial.GetMaxDistance: Integer;
Begin
  Result := _max - _min + 1;
End;

Procedure TLockDial.MoveLeft(Const inAmount: Integer; Var outRolledOver: Boolean);
Var
  amount, distance: Integer;
Begin
  amount := SanitizeAmount(inAmount);

  If amount <= 0 Then
    Exit;

  distance := DistanceBetween(_min, _pos);

  If amount <= distance Then
  Begin
    _pos := _pos - amount;

    outRolledOver := False;
  End
  Else
  Begin
    outRolledOver := _pos <> 0;

    _pos := _max - amount + distance + 1;
  End;
End;

Procedure TLockDial.MoveRight(Const inAmount: Integer; Var outRolledOver: Boolean);
Var
  amount, distance: Integer;
Begin
  amount := SanitizeAmount(inAmount);

  If amount <= 0 Then
    Exit;

  distance := DistanceBetween(_pos, _max);

  If amount <= distance Then
  Begin
    _pos := _pos + amount;

    outRolledOver := False;
  End
  Else
  Begin
    outRolledOver := _pos <> 0;

    _pos := _min + amount - distance - 1;
  End;
End;

Function TLockDial.SanitizeAmount(Const inAmount: Integer): Integer;
Begin
  Result := inAmount Mod GetMaxDistance;
End;

{$IFDEF DEBUG}
Procedure TLockDial.SelfTest;
Var
  prevmax, prevmin, prevpos: Integer;
  dummy: Boolean;
Begin
  If Not DistanceBetween(-1, -2) = 1 Then
    Raise ELockDialException.Create('Selftest failure: Distance between -1 and -2 is not 1!');

  If Not DistanceBetween(-2, -1) = 1 Then
    Raise ELockDialException.Create('Selftest failure: Distance between -2 and -1 is not 1!');

  If Not DistanceBetween(-1, -1) = 0 Then
    Raise ELockDialException.Create('Selftest failure: Distance between -1 and -1 is not 0!');

  If Not DistanceBetween(1, 2) = 1 Then
    Raise ELockDialException.Create('Selftest failure: Distance between 1 and 2 is not 1!');

  If Not DistanceBetween(2, 1) = 1 Then
    Raise ELockDialException.Create('Selftest failure: Distance between 2 and 1 is not 1!');

  If Not DistanceBetween(1, 1) = 0 Then
    Raise ELockDialException.Create('Selftest failure: Distance between 1 and 1 is not 0!');

  prevmax := _max;
  prevmin := _min;
  prevpos := _pos;
  Try
    _min := 0;
    _max := 99;
    _pos := 50;

    MoveLeft(68, dummy);

    If _pos <> 82 Then
      Raise ELockDialException.Create('Selftest failure: Moving left from 50 by 68 does not result in position 82!');

    MoveLeft(30, dummy);

    If _pos <> 52 Then
      Raise ELockDialException.Create('Selftest failure: Moving left from 82 by 30 does not result in position 52!');

    MoveRight(48, dummy);

    If _pos <> 0 Then
      Raise ELockDialException.Create('Selftest failure: Moving right from 52 by 48 does not result in position 0!');

    MoveLeft(5, dummy);

    If _pos <> 95 Then
      Raise ELockDialException.Create('Selftest failure: Moving left from 0 by 5 does not result in position 95!');

    MoveRight(60, dummy);

    If _pos <> 55 Then
      Raise ELockDialException.Create('Selftest failure: Moving right from 95 by 60 does not result in position 55!');

    MoveLeft(55, dummy);

    If _pos <> 0 Then
      Raise ELockDialException.Create('Selftest failure: Moving left from 55 by 55 does not result in position 0!');

    MoveLeft(1, dummy);

    If _pos <> 99 Then
      Raise ELockDialException.Create('Selftest failure: Moving left from 0 by 1 does not result in position 99!');

    MoveLeft(99, dummy);

    If _pos <> 0 Then
      Raise ELockDialException.Create('Selftest failure: Moving left from 99 by 99 does not result in position 0!');

    MoveRight(14, dummy);

    If _pos <> 14 Then
      Raise ELockDialException.Create('Selftest failure: Moving right from 0 by 14 does not result in position 14!');

    MoveLeft(82, dummy);

    If _pos <> 32 Then
      Raise ELockDialException.Create('Selftest failure: Moving left from 14 by 82 does not result in position 32!');
  Finally
    _max := prevmax;
    _min := prevmin;
    _pos := prevpos;
  End;
End;
{$ENDIF}

Procedure TLockDial.SetMax(Const inMax: Integer);
Begin
  If inMax = _max Then
    Exit;

  If inMax <= _min Then
    Raise ELockDialException.Create('Maximum can not be less or equal to the minimum!');

  _max := inMax;

  If _pos > _max Then
    _pos := _max;
End;

Procedure TLockDial.SetMin(Const inMin: Integer);
Begin
  If inMin = _min Then
    Exit;

  If inMin >= _max Then
    Raise ELockDialException.Create('Minimum can not be greater or equal to the maximum!');

  _min := inMin;

  If _pos < _min Then
    _pos := _min;
End;

End.
