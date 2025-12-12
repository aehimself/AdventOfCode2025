Unit uManifoldMapper;

Interface

Uses System.Generics.Collections;

Type
  TManifoldItem = Class
  strict private
    _children: TList<TManifoldItem>;
    _col: NativeInt;
    _row: NativeInt;
    _stepstoend: UInt64;
    Function GetChildren: TArray<TManifoldItem>;
  public
    Constructor Create(Const inRow, inCol: NativeInt); ReIntroduce;
    Destructor Destroy; Override;
    Procedure AddChild(Const inChild: TManifoldItem);
    Property Children: TArray<TManifoldItem> Read GetChildren;
    Property Col: NativeInt Read _col;
    Property Row: NativeInt Read _row;
    Property StepsToEnd: UInt64 Read _stepstoend Write _stepstoend;
  End;

  TManifoldStartPosition = Class(TManifoldItem);

  TManifoldWire = Class(TManifoldItem);

  TManifoldSplitter = Class(TManifoldItem);

  TManifoldItemArray = TArray<TManifoldItem>;

  TManifoldMapper = Class
  strict private
    _collector: TObjectList<TManifoldItem>;
    _map: TArray<TManifoldItemArray>;
    Function RecursivePathCount(Const inItemRow, inItemCol: NativeInt):UInt64;
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Procedure AddLevel(Const inLevel: String);
    Function SplitterCount: NativeInt;
    Function MaximumPathCount: Uint64;
  End;

Implementation

Uses System.SysUtils;

//
// TManifoldItem
//

Procedure TManifoldItem.AddChild(Const inChild: TManifoldItem);
Begin
  If Not _children.Contains(inChild) Then
    _children.Add(inChild);
End;

Constructor TManifoldItem.Create(Const inRow, inCol: NativeInt);
Begin
  inherited Create;

  _children := TList<TManifoldItem>.Create;
  _col := inCol;
  _row := inRow;
  _stepstoend := 0;
End;

Destructor TManifoldItem.Destroy;
Begin
  FreeAndNil(_children);

  inherited;
End;

Function TManifoldItem.GetChildren: TArray<TManifoldItem>;
Begin
  Result := _children.ToArray;
End;

//
// TManifoldMapper
//

Constructor TManifoldMapper.Create;
Begin
  inherited;

  _collector := TObjectList<TManifoldItem>.Create;
  _map := nil;
End;

Destructor TManifoldMapper.Destroy;
Begin
  FreeAndNil(_collector);

  inherited;
End;

Function TManifoldMapper.MaximumPathCount: UInt64;
Var
  a: NativeInt;
Begin
  Result := 0;

  If _map = nil Then
    Exit;

  For a := Low(_map[0]) To High(_map[0]) Do
    If _map[0][a] Is TManifoldStartPosition Then
      Result := Result + RecursivePathCount(0, a);
End;

Function TManifoldMapper.RecursivePathCount(Const inItemRow, inItemCol: NativeInt): UInt64;
Var
  child: TManifoldItem;
  children: TManifoldItemArray;
  item: TManifoldItem;
Begin
  item := _map[inItemRow][inItemCol];

  Result := item.StepsToEnd;

  If Result <> 0 Then
    Exit;

  children := item.Children;

  If Length(children) = 0 Then
    Result := 1
  Else
  Begin
    For child In children Do
      Result := Result + RecursivePathCount(child.Row, child.Col);

    WriteLn(item.Row.ToString + ', ' + item.Col.ToString + ': ' + item.ClassName + ' -> ' + Result.ToString);
  End;

  item.StepsToEnd := Result;
End;

function TManifoldMapper.SplitterCount: NativeInt;
Var
  a, b: Integer;
Begin
  Result := 0;

  For a := Low(_map) To High(_map) Do
    For b := Low(_map[a]) To High(_map[a]) Do
      If _map[a][b] Is TManifoldSplitter Then
        Inc(Result);
End;

Procedure TManifoldMapper.AddLevel(Const inLevel: String);
Var
  a, currlevel: NativeInt;
  item: TManifoldItem;
Begin
  SetLength(_map, Length(_map) + 1);
  currlevel := High(_map);
  SetLength(_map[currlevel], inLevel.Length);

  For a := 0 To inLevel.Length - 1 Do
  Begin
    item := nil;

    Case inLevel.Chars[a] Of
      'S':
        item := TManifoldStartPosition.Create(currlevel, a);
      '^':
        If (currlevel > 0) And (_map[currlevel - 1][a] <> nil) Then
        Begin
          // A splitter is only active IF there is an item (possibly a wire) on the previous level

          item := TManifoldSplitter.Create(currlevel, a);
          _map[currlevel - 1][a].AddChild(item);
        End;
      '.':
      Begin
        If currlevel > 0 Then
        Begin
          // Is there a wire right above this position?
          If (_map[currlevel - 1][a] Is TManifoldWire) Or ((_map[currlevel - 1][a] Is TManifoldStartPosition)) Then
          Begin
            item := TManifoldWire.Create(currlevel, a);
            _map[currlevel - 1][a].AddChild(item);
          End;

          // Is there a splitter above, to the left of this position?
          If (a > 0) And (_map[currlevel - 1][a - 1] Is TManifoldSplitter) Then
          Begin
            item := TManifoldWire.Create(currlevel, a);
            _map[currlevel - 1][a - 1].AddChild(item);
          End;

          // Is there a splitter above, to the right of this position?
          If (a < Length(_map[currlevel - 1]) - 1) And (_map[currlevel - 1][a + 1] Is TManifoldSplitter) Then
          Begin
            item := TManifoldWire.Create(currlevel, a);
            _map[currlevel - 1][a + 1].AddChild(item);
          End;
        End;
      End;
    End;

    _map[currlevel][a] := item;

    If Assigned(item) Then
      _collector.Add(item);
  End;
End;

End.
