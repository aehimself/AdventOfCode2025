Unit uIngredientRange;

Interface

Type
  TIngredientID = UInt64;

  TIngredientRange = Class
  strict private
    _rangeend: TIngredientID;
    _rangestart: TIngredientID;
    Function GetLength: UInt64;
  public
    Constructor Create(Const inRangeStart, inRangeEnd: TIngredientID); ReIntroduce;
    Function Contains(Const inIngredient: TIngredientID): Boolean;
    Function EndInRange(Const inRange: TIngredientRange): Boolean;
    Function InRange(Const inRange: TIngredientRange): Boolean;
    Function StartInRange(Const inRange: TIngredientRange): Boolean;
    Property RangeEnd: TIngredientID Read _rangeend;
    Property RangeStart: TIngredientID Read _rangestart;
    Property Length: UInt64 Read GetLength;
  End;

Implementation

//
// TIngredientRange
//

Function TIngredientRange.Contains(Const inIngredient: TIngredientID): Boolean;
Begin
  Result := (inIngredient >= _rangestart) And (inIngredient <= _rangeend);
End;

Constructor TIngredientRange.Create(Const inRangeStart, inRangeEnd: TIngredientID);
Begin
  inherited Create;

  _rangeend := inRangeEnd;
  _rangestart := inRangeStart
End;

Function TIngredientRange.EndInRange(Const inRange: TIngredientRange): Boolean;
Begin
  Result := (_rangeend >= inRange.RangeStart) And (_rangeend <= inRange.RangeEnd);
End;

Function TIngredientRange.GetLength: UInt64;
Begin
  Result := _rangeend - _rangestart + 1;
End;

Function TIngredientRange.InRange(Const inRange: TIngredientRange): Boolean;
Begin
  Result := Self.StartInRange(inRange) And Self.EndInRange(inRange);
End;

Function TIngredientRange.StartInRange(Const inRange: TIngredientRange): Boolean;
Begin
  Result := (_rangestart >= inRange.RangeStart) And (_rangestart <= inRange.RangeEnd);
End;

End.
