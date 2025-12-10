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
    Function GetProblem(Const inProblemIndex: NativeInt): THomeworkProblem;
    Function GetProblemCount: NativeInt;
    Function GetResults: TNumber;
  public
    Constructor Create; ReIntroduce;
    Destructor Destroy; Override;
    Procedure AddHomeworkLine(inHomeworkLine: String);
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

Procedure THomeworkSolver.AddHomeworkLine(inHomeworkLine: String);
Begin
  If (_problems.Count = 0) Or inHomeworkLine.IsEmpty Then
  Begin
    _problems.Add(THomeworkProblem.Create);

    If inHomeworkLine.IsEmpty Then
      Exit;
  End;

  If inHomeworkLine.EndsWith('+') Or inHomeworkLine.EndsWith('*') Then
  Begin
    If inHomeworkLine.EndsWith('+') Then
      _problems[_problems.Count - 1].ArithmeticOperation := aoAddition
    Else If inHomeworkLine.EndsWith('*') Then
      _problems[_problems.Count - 1].ArithmeticOperation := aoMultiplication
    Else
      Raise EHomeworkSolverException.Create('Unknown arithmetic operator found!');

    inHomeworkLine := inHomeworkLine.Substring(0, inHomeworkLine.Length - 1);
  End;

  _problems[_problems.Count - 1].AddNumber(TNumber.Parse(inHomeworkLine));
End;

End.
