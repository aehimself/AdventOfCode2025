Unit uInventoryManager;

Interface

Uses System.Generics.Collections, System.SysUtils, uIngredientRange;

Type
  TInventoryManager = Class
  strict private
    _available: TList<TIngredientID>;
    _fresh: TObjectList<TIngredientRange>;
    Function GetAvailableIngredients: TArray<TIngredientID>;
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Procedure AddAvailable(Const inAvailable: TIngredientID);
    Procedure AddFresh(Const inFreshString: String);
    Function IsFresh(Const inIngredient: TIngredientID): Boolean;
    Function TotalFreshIngredients: UInt64;
    Property AvailableIngredients: TArray<TIngredientID> Read GetAvailableIngredients;
  End;

  EInventoryManagerException = Class(Exception);

Implementation

//
// TInventoryManager
//

Procedure TInventoryManager.AddAvailable(Const inAvailable: TIngredientID);
Begin
  _available.Add(inAvailable);
End;

Procedure TInventoryManager.AddFresh(Const inFreshString: String);
Var
  range, newrange: TIngredientRange;
  freshstart, freshend: TIngredientID;
  adjusted: Boolean;
  a: NativeInt;
Begin
  If inFreshString.CountChar('-') <> 1 Then
    Raise EInventoryManagerException.Create('Invalid fresh ingredient line!');

  freshstart := TIngredientID.Parse(inFreshString.Substring(0, inFreshString.IndexOf('-')));
  freshend := TIngredientID.Parse(inFreshString.Substring(inFreshString.IndexOf('-') + 1));

  If freshstart > freshend Then
    Raise EInventoryManagerException.Create('Invalid fresh ingredient range!');

  Repeat
    adjusted := False;

    For range In _fresh Do
    Begin
      // If the new range is already contained in the current one, no need to add it

      If range.Contains(freshstart) And range.Contains(freshend) Then
        Exit;

      If range.Contains(freshstart) Then
      Begin
        // The start of the new range is contained in the current one so adjust the starting position one after
        // it's end

        freshstart := range.RangeEnd + 1;

        adjusted := True;
      End
      Else If range.Contains(freshend) Then
      Begin
        // The end of the new range is contained in the current one so adjust the ending position one before
        // it's start

        freshend := range.RangeStart - 1;

        adjusted := True;
      End;

      If freshend < freshstart Then
        Exit;
    End;
  Until Not adjusted;

  newrange := TIngredientRange.Create(freshstart, freshend);

  // The new range is ready to be added to the list. One final check, if the new range contains one or more
  // existing ones, remove them

  For a := _fresh.Count - 1 DownTo 0 Do
    If _fresh[a].InRange(newrange) Then
      _fresh.Delete(a);

  _fresh.Add(newrange);
End;

Constructor TInventoryManager.Create;
Begin
  inherited;

  _available := TList<TIngredientID>.Create;
  _fresh := TObjectList<TIngredientRange>.Create;
End;

Destructor TInventoryManager.Destroy;
Begin
  FreeAndNil(_available);
  FreeAndNil(_fresh);

  inherited;
End;

Function TInventoryManager.GetAvailableIngredients: TArray<TIngredientID>;
Begin
  Result := _available.ToArray;
End;

Function TInventoryManager.IsFresh(Const inIngredient: TIngredientID): Boolean;
Var
  range: TIngredientRange;
Begin
  Result := False;

  For range In _fresh Do
  Begin
    Result := range.Contains(inIngredient);

    If Result Then
      Break;
  End;
End;

Function TInventoryManager.TotalFreshIngredients: UInt64;
Var
  range: TIngredientRange;
Begin
  Result := 0;

  For range In _fresh Do
    Result := Result + range.Length;
End;

End.
