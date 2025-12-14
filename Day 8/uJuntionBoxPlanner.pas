Unit uJuntionBoxPlanner;

Interface

Uses System.Generics.Collections;

Type
  TJunctionBox = Class
  strict private
    _x: Integer;
    _y: Integer;
    _z: Integer;
    Function GetNicePosition: String;
  public
    Constructor Create(Const inX, inY, inZ: Integer); ReIntroduce;
    Property NicePosition: String Read GetNicePosition;
    Property X: Integer Read _x;
    Property Y: Integer Read _y;
    Property Z: Integer Read _z;
  End;

  TDistance = Record
    Box1: TJunctionBox;
    Box2: TJunctionBox;
    Distance: Extended;
  End;

  TJunctionBoxPlanner = Class
  strict private
    _boxes: TObjectList<TJunctionBox>;
    _circuits: TObjectList<TList<TJunctionBox>>;
    _distances: TDictionary<TJunctionBox, TDictionary<TJunctionBox, Extended>>;
    Procedure AddBoxToCircuit(Const inBox: TJunctionBox; Const inCircuit: NativeInt);
    Function BoxCircuit(Const inJunctionBox: TJunctionBox): NativeInt;
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Procedure CalculateDistances;
    Function AddJunctionBox(Const inX, inY, inZ: Integer): TJunctionBox;
    Function Circuits: TArray<TArray<TJunctionBox>>;
    Function ShortestDistance(Const inMinDistance: Extended): TDistance;
  End;

Implementation

Uses System.SysUtils, System.Math;

//
// TJunctionBox
//

Constructor TJunctionBox.Create(Const inX, inY, inZ: Integer);
Begin
  inherited Create;

  _x := inX;
  _y := inY;
  _z := inZ;
End;

Function TJunctionBox.GetNicePosition: String;
Begin
  Result := Format('( %d, %d, %d )', [_x, _y, _z]);
End;

//
// TJunctionBoxPlanner
//

Procedure TJunctionBoxPlanner.AddBoxToCircuit(Const inBox: TJunctionBox; Const inCircuit: NativeInt);
Begin
  // Then, add the box
  _circuits[inCircuit].Add(inBox);
End;

Function TJunctionBoxPlanner.AddJunctionBox(Const inX, inY, inZ: Integer): TJunctionBox;
Begin
  Result := TJunctionBox.Create(inX, inY, inZ);

  _boxes.Add(Result);
End;

Function TJunctionBoxPlanner.BoxCircuit(Const inJunctionBox: TJunctionBox): NativeInt;
Var
  a: NativeInt;
Begin
  Result := -1;

  For a := 0 To _circuits.Count - 1 Do
    If _circuits[a].Contains(inJunctionBox) Then
    Begin
      Result := a;

      Break;
    End;
End;

Procedure TJunctionBoxPlanner.CalculateDistances;
Var
  box1, box2: TJunctionBox;
  distance: Extended;
Begin
  For box1 In _boxes Do
    For box2 In _boxes Do
      If box1 <> box2 Then
      Begin
        If Not _distances.ContainsKey(box1) Then
          _distances.Add(box1, TDictionary<TJunctionBox, Extended>.Create);

        If Not _distances.ContainsKey(box2) Then
          _distances.Add(box2, TDictionary<TJunctionBox, Extended>.Create);

        // https://en.wikipedia.org/wiki/Euclidean_distance

        distance := Sqr(Power(box1.X - box2.X, 2) + Power(box1.Y - box2.Y, 2) + Power(box1.Z - box2.Z, 2));

        _distances[box1].AddOrSetValue(box2, distance);
        _distances[box2].AddOrSetValue(box1, distance);
      End;
End;

Function TJunctionBoxPlanner.Circuits: TArray<TArray<TJunctionBox>>;
Var
  a: NativeInt;
Begin
  SetLength(Result, _circuits.Count);

  For a := 0 To _circuits.Count - 1 Do
    Result[a] := _circuits[a].ToArray;
End;

Constructor TJunctionBoxPlanner.Create;
Begin
  inherited Create;

  _boxes := TObjectList<TJunctionBox>.Create;
  _circuits := TObjectList<TList<TJunctionBox>>.Create;
  _distances := TDictionary<TJunctionBox, TDictionary<TJunctionBox, Extended>>.Create;
End;

Destructor TJunctionBoxPlanner.Destroy;
Begin
  FreeAndNil(_boxes);
  FreeAndNil(_circuits);
  FreeAndNil(_distances);

  inherited;
End;

Function TJunctionBoxPlanner.ShortestDistance(Const inMinDistance: Extended): TDistance;
Var
  box1, box2, boxenum: TJunctionBox;
  box1circuit, box2circuit: NativeInt;
Begin
  Result.Box1 := nil;
  Result.Box2 := nil;
  Result.Distance := Extended.MaxValue;

  For box1 In _distances.Keys Do
    For box2 In _distances.Keys Do
      If (box1 <> box2) And _distances[box1].ContainsKey(box2) And (_distances[box1][box2] > inMinDistance) And
         (_distances[box1][box2] < Result.Distance) Then
      Begin
        Result.Box1 := box1;
        Result.Box2 := box2;
        Result.Distance := _distances[box1][box2];
      End;

  If Not Assigned(Result.Box1) Or Not Assigned(Result.Box2) Then
    Exit;

  // Check if Box1 is in a circuit already. If not, create one and add it
  box1circuit := BoxCircuit(Result.Box1);

  If box1circuit = -1 Then
  Begin
    box1circuit := _circuits.Add(TList<TJunctionBox>.Create);
    _circuits[box1circuit].Add(Result.Box1);

    WriteLn('Circuit #' + box1circuit.ToString + ' has been created for ' + result.Box1.NicePosition);
  End
  Else
    WriteLn(Result.Box1.NicePosition + ' has been found in circuit #' + box1circuit.ToString);

  // Let's see if box2 (which we are about to add to box1s circuit) is in a circuit already. If it is,
  // we have to merge the circuits
  box2circuit := BoxCircuit(Result.Box2);

  If box2circuit = box1circuit Then
    WriteLn(Result.Box1.NicePosition + ' has been found in the same circuit.')
  Else If box2circuit <> -1 Then
  Begin
    For boxenum In _circuits[box2circuit] Do
    Begin
      Self.AddBoxToCircuit(boxenum, box1circuit);

      WriteLn('Box ' + boxenum.NicePosition + ' has been moved from circuit #' + box2circuit.ToString + ' to #' + box1circuit.ToString);
    End;

    _circuits.Delete(box2circuit);
  End
  Else
  Begin
    Self.AddBoxToCircuit(Result.Box2, box1circuit);

    WriteLn(Result.box2.NicePosition + ' has been added to circuit #' + box1circuit.ToString);
  End;
End;

End.
