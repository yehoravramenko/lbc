unit EscCodes;

interface

const
{$IFDEF WINDOWS}
  NewLine = #13#10;    // Windows '\r\n' alternative in Pascal
{$ELSE}
  NewLine = #10;       // '\n' alternative in Pascal
{$ENDIF}  
  Tab = #9;             // '\t' alternative in Pascal
  CR = #13;             // '\r' alternative in Pascal
  LF = #10;             // '\r' alternative in Pascal

implementation

end.