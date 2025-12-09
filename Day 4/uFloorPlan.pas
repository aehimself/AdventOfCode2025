Unit uFloorPlan;

Interface

Uses System.SysUtils;

Type
  TMapObject = ( moEmpty, moPaperRoll );

  TFloorPlan = Class
  strict private
    _map: TArray<TArray<TMapObject>>;
    Procedure SetMapObject(Const inColumn, inRow: NativeInt; Const inMapObject: TMapObject);
    Function GetMapHeight: NativeInt;
    Function GetMapObject(Const inColumn, inRow: NativeInt): TMapObject;
    Function GetMapWidth: NativeInt;
  public
    Constructor Create; ReIntroduce;
    Procedure ClearMap;
    Procedure SetMapDimensions(Const inColumnAmount, inRowAmount: NativeInt);
    Function NeighbouringPaperRolls(Const inColumn, inRow: NativeInt): Integer;
    Property MapHeight: NativeInt Read GetMapHeight;
    Property MapWidth: NativeInt Read GetMapWidth;
    Property MapObject[Const inColumn, inRow: NativeInt]: TMapObject Read GetMapObject Write SetMapObject; Default;
  End;

  EFloorPlanException = Class(Exception);

Implementation

//
// TFloorPlan
//

Procedure TFloorPlan.ClearMap;
Var
  a: NativeInt;
Begin
  For a := Low(_map) To High(_map) Do
    FillChar(_map[a][0], Length(_map[a]), 0);
End;

Constructor TFloorPlan.Create;
Begin
  inherited;

  SetMapDimensions(10, 10);
  ClearMap;
End;

Function TFloorPlan.GetMapHeight: NativeInt;
Begin
  Result := Length(_map);
End;

Function TFloorPlan.GetMapObject(Const inColumn, inRow: NativeInt): TMapObject;
Begin
  Result := _map[inRow][inColumn];
End;

Function TFloorPlan.GetMapWidth: NativeInt;
Begin
  If Length(_map) = 0 Then
    Result := 0
  Else
    Result := Length(_map[0]);
End;

Function TFloorPlan.NeighbouringPaperRolls(Const inColumn, inRow: NativeInt): Integer;
Var
  row, col: NativeInt;
Begin
  If (inColumn < 0) Or (inColumn >= Self.MapWidth) Or (inRow < 0) Or (inRow >= Self.MapHeight) Then
    Raise EFloorPlanException.Create('Invalid floor plan position!');

  Result := 0;

  For col := -1 To 1 Do
    For row := -1 To 1 Do
      If (Abs(row) + Abs(col) <> 0) And (inColumn + col >= 0) And (inColumn + col < Self.MapWidth) And (inRow + row >= 0) And
         (inRow + row < Self.MapWidth) And (_map[inRow + row][inColumn + col] = moPaperRoll) Then
        Inc(Result);
End;

Procedure TFloorPlan.SetMapDimensions(Const inColumnAmount, inRowAmount: NativeInt);
Var
  a: NativeInt;
Begin
  If (inColumnAmount = 0) Or (inRowAmount = 0) Then
    Raise EFloorPlanException.Create('Invalid floor plan dimansions!');

  SetLength(_map, inRowAmount);

  For a := Low(_map) To High(_map) Do
    SetLength(_map[a], inColumnAmount);
End;

Procedure TFloorPlan.SetMapObject(Const inColumn, inRow: NativeInt; Const inMapObject: TMapObject);
Begin
  _map[inRow][inColumn] := inMapObject;
End;

End.
