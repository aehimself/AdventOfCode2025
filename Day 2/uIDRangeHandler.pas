Unit uIDRangeHandler;

Interface

Uses System.SysUtils, System.Generics.Collections;

Type
  TID = UInt64;

  TIDRange = Class
  strict private
    _banner: String;
    _ids: TArray<TID>;
    _rangeend: TID;
    _rangestart: TID;
    Function StringToID(Const inString: String): TID;
  public
    Constructor Create(Const inBanner: String);
    Property Banner: String Read _banner;
    Property IDs: TArray<TID> Read _ids;
    Property RangeEnd: TID Read _rangeend;
    Property RangeStart: TID Read _rangestart;
  End;

  TIDRangeHandler = Class
  strict private
    _idranges: TObjectList<TIDRange>;
    Function GetRange(Const inIndex: NativeInt): TIDRange;
    Function GetRangeCount: NativeInt;
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Procedure AddRange(Const inIDRange: String);
    Property Range[Const inIndex: NativeInt]: TIDRange Read GetRange; Default;
    Property RangeCount: NativeInt Read GetRangeCount;
  End;

  EIDRangeException = Class(Exception);

Implementation

//
// TIDRange
//

Constructor TIDRange.Create(Const inBanner: String);
Var
  ids: TList<TID>;
  id: TID;
Begin
  inherited Create;

  _banner := inBanner;

  If _banner.CountChar('-') <> 1 Then
    Raise EIDRangeException.Create('No valid ID range is specified!');


  _rangestart := StringToID(_banner.Substring(0, _banner.IndexOf('-')));
  _rangeend := StringToID(_banner.Substring(_banner.IndexOf('-') + 1));

  ids := TList<TID>.Create;
  Try
    For id := _rangestart To _rangeend Do
      ids.Add(id);

    _ids := ids.ToArray;
  Finally
    FreeAndNil(ids);
  End;
End;

Function TIDRange.StringToID(Const inString: String): TID;
Begin
  If (inString.Length = 0) Or (inString.Chars[0] = '0') Then
    Raise EIDRangeException.Create('inString is NOT a valid ID!');

  Result := TID.Parse(inString);
End;

//
// TIDRangeHandler
//

Procedure TIDRangeHandler.AddRange(Const inIDRange: String);
Begin
  _idranges.Add(TIDRange.Create(inIDRange));
End;

Constructor TIDRangeHandler.Create;
Begin
  inherited;

  _idranges := TObjectList<TIDRange>.Create;
End;

Destructor TIDRangeHandler.Destroy;
Begin
  FreeAndNil(_idranges);

  inherited;
End;

Function TIDRangeHandler.GetRange(Const inIndex: NativeInt): TIDRange;
Begin
  Result := _idranges[inIndex];
End;

Function TIDRangeHandler.GetRangeCount: NativeInt;
Begin
  Result := _idranges.Count;
End;

End.
