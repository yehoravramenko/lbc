unit CompilerMessage;

interface

uses
  Crt,        // TextColor

  EscCodes;

procedure Log(const Message: string);

procedure Error(const Message: string; const Details: string);
procedure Error(const Message: string); overload;

implementation

procedure Log(const Message: string);
begin
  Crt.TextColor(Crt.Green);
  System.Write('LOG:' + EscCodes.Tab);
  Crt.TextColor(Crt.White);

  System.WriteLn(Message);
end;

procedure Error(const Message: string; const Details: string);
begin
  Crt.TextColor(Crt.Red);
  System.Write('ERROR:' + EscCodes.Tab);
  Crt.TextColor(Crt.White);

  System.WriteLn(Message + EscCodes.NewLine + EscCodes.Tab + Details);

  System.Halt(-1);
end;

procedure Error(const Message: string); overload;
begin
  Error(Message, 'No details');
end;

end.