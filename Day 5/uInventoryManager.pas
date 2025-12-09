Unit uInventoryManager;

Interface

Uses System.Generics.Collections, System.SysUtils;

Type
  TIngredientID = UInt64;

  TIngredientRange = TPair<TIngredientID, TIngredientID>;

  TInventoryManager = Class
  strict private
    _available: TList<TIngredientID>;
    _fresh: TList<TIngredientRange>;
    Function GetAvailableIngredients: TArray<TIngredientID>;
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Procedure AddAvailable(Const inAvailable: TIngredientID);
    Procedure AddFresh(Const inFreshString: String);
    Function IsFresh(Const inIngredient: TIngredientID): Boolean;
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
  freshstart, freshend: TIngredientID;
Begin
  If inFreshString.CountChar('-') <> 1 Then
    Raise EInventoryManagerException.Create('Invalid fresh ingredient line!');

  freshstart := TIngredientID.Parse(inFreshString.Substring(0, inFreshString.IndexOf('-')));
  freshend := TIngredientID.Parse(inFreshString.Substring(inFreshString.IndexOf('-') + 1));

  If freshstart > freshend Then
    Raise EInventoryManagerException.Create('Invalid fresh ingredient range!');

  _fresh.Add(TIngredientRange.Create(freshstart, freshend));
End;

Constructor TInventoryManager.Create;
Begin
  inherited;

  _available := TList<TIngredientID>.Create;
  _fresh := TList<TIngredientRange>.Create;
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
    Result := (inIngredient >= range.Key) And (inIngredient <= range.Value);

    If Result Then
      Break;
  End;
End;

End.
