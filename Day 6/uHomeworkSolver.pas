Unit uHomeworkSolver;

Interface

Uses System.Generics.Collections, System.SysUtils;

Type
  TNumber = UInt64;

  TArithmeticOperation = (aoAddition, aoMultiplication);

  THomeworkProblem = Class
  strict private
    _arithmeticoperation: TArithmeticOperation;
    _numbers: TList<TNumber>;
    Function GetResult: TNumber;
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Procedure AddNumber(Const inNumber: TNumber);
    Property ArithmeticOperation: TArithmeticOperation Read _arithmeticoperation Write _arithmeticoperation;
    Property Result: TNumber Read GetResult;
  End;

  THomeworkSolver = Class
  strict private
    _problems: TObjectList<THomeworkProblem>;
    Procedure AddArithmeticOperations(Const inArithmeticOperations: TArray<TArithmeticOperation>);
    Procedure AddNumbers(Const inNumbers: TArray<TNumber>);
    Function GetProblem(Const inProblemIndex: NativeInt): THomeworkProblem;
    Function GetProblemCount: NativeInt;
    Function GetResults: TNumber;
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Procedure AddHomeworkLine(Const inHomeworkLine: String);
    Property Problem[Const inProblemIndex: NativeInt]: THomeworkProblem Read GetProblem; Default;
    Property ProblemCount: NativeInt Read GetProblemCount;
    Property Results: TNumber Read GetResults;
  End;

  EHomeworkSolverException = Class(Exception);

Implementation

//
// THomeworkProblem
//

Procedure THomeworkProblem.AddNumber(Const inNumber: TNumber);
Begin
  _numbers.Add(inNumber);
End;

Constructor THomeworkProblem.Create;
Begin
  inherited;

  _numbers := TList<TNumber>.Create;
End;

Destructor THomeworkProblem.Destroy;
Begin
  FreeAndNil(_numbers);

  inherited;
End;

Function THomeworkProblem.GetResult: TNumber;
Var
  a: NativeInt;
Begin
  If _numbers.Count = 0 Then
    Result := 0
  Else
  Begin
    Result := _numbers[0];

    For a := 1 To _numbers.Count - 1 Do
      Case _arithmeticoperation Of
        aoAddition:
          Result := Result + _numbers[a];
        aoMultiplication:
          Result := Result * _numbers[a];
        Else
          Raise ENotImplemented.Create('Arithmetic operation is not implemented yet!');
      End;
  End;
End;

//
// THomeworkSolver
//

Constructor THomeworkSolver.Create;
Begin
  inherited;

  _problems := TObjectList<THomeworkProblem>.Create;
End;

Destructor THomeworkSolver.Destroy;
Begin
  FreeAndNil(_problems);

  inherited;
End;

Function THomeworkSolver.GetProblem(Const inProblemIndex: NativeInt): THomeworkProblem;
Begin
  Result := _problems[inProblemIndex];
End;

Function THomeworkSolver.GetProblemCount: NativeInt;
Begin
  Result := _problems.Count;
End;

Function THomeworkSolver.GetResults: TNumber;
Var
  a: NativeInt;
Begin
  Result := 0;

  For a := 0 To _problems.Count - 1 Do
    Result := Result + _problems[a].Result;
End;

Procedure THomeworkSolver.AddArithmeticOperations(Const inArithmeticOperations: TArray<TArithmeticOperation>);
Var
  a: NativeInt;
Begin
  If Length(inArithmeticOperations) <> _problems.Count Then
    Raise EHomeworkSolverException.Create('Arithmetic operation and problem amount differs!');

  For a := 0 To _problems.Count - 1 Do
    _problems[a].ArithmeticOperation := inArithmeticOperations[a];
End;

Procedure THomeworkSolver.AddHomeworkLine(Const inHomeworkLine: String);
Var
  temp: TArray<String>;
  numbers: TArray<TNumber>;
  aops: TArray<TArithmeticOperation>;
  dummy: TNumber;
  a: NativeInt;
Begin
  temp := inHomeworkLine.Split([' '], TStringSplitOptions.ExcludeEmpty);

  If Length(temp) = 0 Then
    Exit;

  If _problems.Count = 0 Then
    For a := Low(temp) To High(temp) Do
      _problems.Add(THomeworkProblem.Create);

  If TNumber.TryParse(temp[0], dummy) Then
  Begin
    SetLength(numbers, Length(temp));

    For a := Low(temp) To High(temp) Do
      numbers[a] := TNumber.Parse(temp[a]);

    Self.AddNumbers(numbers);
  End
  Else If (temp[0] = '+') Or (temp[0] = '*') Then
  Begin
    SetLength(aops, Length(temp));

    For a := Low(temp) To High(temp) Do
      If temp[a] = '+' Then
        aops[a] := aoAddition
      Else If temp[a] = '*' Then
        aops[a] := aoMultiplication
      Else
        Raise EHomeworkSolverException.Create('Unknown arithmetic operator found!');

    Self.AddArithmeticOperations(aops);
  End
End;

Procedure THomeworkSolver.AddNumbers(const inNumbers: TArray<TNumber>);
Var
  a: NativeInt;
Begin
  If Length(inNumbers) <> _problems.Count Then
    Raise EHomeworkSolverException.Create('Number and problem amount differs!');

  For a := 0 To _problems.Count - 1 Do
    _problems[a].AddNumber(inNumbers[a]);
End;

End.
