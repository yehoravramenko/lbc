program LBC;

uses
  EscCodes,
  Lexer;

var
  Lex: TLexer;

begin
  if System.ParamCount() = 0 then
  begin
    System.WriteLn('LBC - Lovely B Compiler' + EscCodes.NewLine + 'v0.0.0');
    System.WriteLn(EscCodes.NewLine + 'Usage: lbc <filename>(.b) <options>');
    System.Halt(-1);
  end;

  Lex := TLexer.Create(System.ParamStr(1));
  Lex.GetNextToken;
  System.WriteLn(Lex.TokenString);

  // repeat
    
  // until false;
end.
