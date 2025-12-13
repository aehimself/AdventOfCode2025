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
    Procedure RemoveDistanceBetween(Const inBox1, inBox2: TJunctionBox);
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Procedure CalculateDistances;
    Function AddJunctionBox(Const inX, inY, inZ: Integer): TJunctionBox;
    Function Circuits: TArray<TArray<TJunctionBox>>;
    Function ShortestDistance: TDistance;
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

//
// TJunctionBoxPlanner
//

Function TJunctionBoxPlanner.AddJunctionBox(Const inX, inY, inZ: Integer): TJunctionBox;
Begin
  Result := TJunctionBox.Create(inX, inY, inZ);

  _boxes.Add(Result);
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

Procedure TJunctionBoxPlanner.RemoveDistanceBetween(Const inBox1, inBox2: TJunctionBox);
Begin
  If _distances.ContainsKey(inBox1) Then
  Begin
    _distances[inBox1].Remove(inBox2);

    If _distances[inBox1].Count = 0 Then
      _distances.Remove(inBox1);
  End;

  If _distances.ContainsKey(inBox2) Then
  Begin
    _distances[inBox2].Remove(inBox1);

    If _distances[inBox2].Count = 0 Then
      _distances.Remove(inBox2);
  End;
End;

Function TJunctionBoxPlanner.ShortestDistance: TDistance;
Var
  box1, box2, boxenum: TJunctionBox;
  found: Boolean;
  enum: TList<TJunctionBox>;
  a: NativeInt;
Begin
  Result.Box1 := nil;
  Result.Box2 := nil;
  Result.Distance := Extended.MaxValue;

  For box1 In _distances.Keys Do
    For box2 In _distances.Keys Do
      If (box1 <> box2) And _distances[box1].ContainsKey(box2) And (_distances[box1][box2] < Result.Distance) Then
      Begin
        Result.Box1 := box1;
        Result.Box2 := box2;
        Result.Distance := _distances[box1][box2];
      End;

  If Assigned(Result.Box1) And Assigned(Result.Box2) Then
  Begin
    Self.RemoveDistanceBetween(Result.Box1, Result.Box2);

    found := False;

    For enum In _circuits Do
    Begin
      If enum.Contains(Result.Box1) And enum.Contains(Result.Box2) Then
        found := True
      Else If enum.Contains(Result.Box1) And Not enum.Contains(Result.Box2) Then
      Begin
        enum.Add(Result.Box2);

        found := True;
      End
      Else If enum.Contains(Result.Box2) And Not enum.Contains(Result.Box1) Then
      Begin
        enum.Add(Result.Box1);

        found := True;
      End;

      If found Then
      Begin
        For boxenum in enum Do
        Begin
          Self.RemoveDistanceBetween(Result.Box1, boxenum);
          Self.RemoveDistanceBetween(Result.Box2, boxenum);
        End;

        Break;
      End;
    End;

    If Not found Then
    Begin
      a := _circuits.Add(TList<TJunctionBox>.Create);

      _circuits[a].AddRange([Result.Box1, Result.Box2]);
    End;
  End;
End;

Function TJunctionBox.GetNicePosition: String;
Begin
  Result := Format('( %d, %d, %d )', [_x, _y, _z]);
End;

End.
