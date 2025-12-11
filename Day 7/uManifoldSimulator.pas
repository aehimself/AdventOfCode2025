Unit uManifoldSimulator;

Interface

Uses System.Generics.Collections, System.SysUtils;

Type
  TManifoldLevel = Class
  strict private
    _beams: TList<NativeInt>;
    _splitters: TList<NativeInt>;
    Procedure SetBeam(Const inIndex: NativeInt; Const inBeam: Boolean);
    Procedure SetSplitter(Const inIndex: NativeInt; Const inSplitter: Boolean);
    Function GetBeam(Const inIndex: NativeInt): Boolean;
    Function GetMaxindex: NativeInt;
    Function GetSplitter(Const inIndex: NativeInt): Boolean;
    Function GetSplitterHit(Const inIndex: NativeInt): Boolean;
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Function SplittersHit: NativeInt;
    Property Beam[Const inIndex: NativeInt]: Boolean Read GetBeam Write SetBeam;
    Property MaxIndex: NativeInt Read GetMaxIndex;
    Property Splitter[Const inIndex: NativeInt]: Boolean Read GetSplitter Write SetSplitter;
    Property SplitterHit[Const inIndex: NativeInt]: Boolean Read GetSplitterHit;
  End;

  TManifoldSimulator = Class
  strict private
    _levels: TObjectList<TManifoldLevel>;
    Function GetLevel(Const inLevel: NativeInt): TManifoldLevel;
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Function NewLevel: TManifoldLevel;
    Function TotalSplittersHit: NativeInt;
    Property Level[Const inLevel: NativeInt]: TManifoldLevel Read GetLevel; Default;
  End;

Implementation

Function TManifoldLevel.SplittersHit: NativeInt;
Var
  a: NativeInt;
Begin
  Result := 0;

  For a := 0 To Self.MaxIndex Do
    If Self.SplitterHit[a] Then
      Inc(Result);
End;

//
// TManifoldLevel
//

Constructor TManifoldLevel.Create;
Begin
  inherited;

  _beams := TList<NativeInt>.Create;
  _splitters := TList<NativeInt>.Create;
End;

Destructor TManifoldLevel.Destroy;
Begin
  FreeAndNil(_beams);
  FreeANdNil(_splitters);

  inherited;
end;

Function TManifoldLevel.GetBeam(Const inIndex: NativeInt): Boolean;
Begin
  Result := _beams.Contains(inindex);
End;

Function TManifoldLevel.GetMaxindex: NativeInt;
Var
  indexes: TArray<NativeInt>;
Begin
  indexes := _beams.ToArray + _splitters.ToArray;

  TArray.Sort<NativeInt>(indexes);

  Result := indexes[High(indexes)];
End;

Function TManifoldLevel.GetSplitter(Const inIndex: NativeInt): Boolean;
Begin
  Result := _splitters.Contains(inIndex);
End;

Function TManifoldLevel.GetSplitterHit(Const inIndex: NativeInt): Boolean;
Begin
  Result := Self.Beam[inIndex] And Self.Splitter[inIndex];
End;

Procedure TManifoldLevel.SetBeam(Const inIndex: NativeInt; Const inBeam: Boolean);
Begin
  If Not inBeam Then
    _beams.Remove(inIndex)
  Else If Not _beams.Contains(inIndex) Then
    _beams.Add(inIndex);
End;

Procedure TManifoldLevel.SetSplitter(Const inIndex: NativeInt; Const inSplitter: Boolean);
Begin
  If Not inSplitter Then
    _splitters.Remove(inIndex)
  Else If Not _splitters.Contains(inIndex) Then
  Begin
    _splitters.Add(inIndex);

    If Self.SplitterHit[inIndex] Then
    Begin
      If inIndex > 0 Then
        Self.Beam[inIndex - 1] := True;

      Self.Beam[inIndex + 1] := True;
    End;
  End;
End;

//
// TManifoldSimulator
//

Constructor TManifoldSimulator.Create;
Begin
  inherited;

  _levels := TObjectList<TManifoldLevel>.Create;
End;

Destructor TManifoldSimulator.Destroy;
Begin
  FreeAndNil(_levels);

  inherited;
End;

Function TManifoldSimulator.GetLevel(Const inLevel: NativeInt): TManifoldLevel;
Begin
  Result := _levels[inLevel];
End;

Function TManifoldSimulator.NewLevel: TManifoldLevel;
Var
  a: NativeInt;
Begin
  Result := _levels[_levels.Add(TManifoldLevel.Create)];

  // If we have a previous level available, copy beams
  If _levels.Count > 1 Then
    For a := 0 To _levels[_levels.Count - 2].MaxIndex Do
      Result.Beam[a] := _levels[_levels.Count - 2].Beam[a] And Not _levels[_levels.Count - 2].Splitter[a];
End;

Function TManifoldSimulator.TotalSplittersHit: NativeInt;
Var
  level: TManifoldLevel;
Begin
  Result := 0;

  For level In _levels Do
    Result := Result + level.SplittersHit;
End;

End.
