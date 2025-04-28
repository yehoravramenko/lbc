{$SCOPEDENUMS ON}

unit Lexer;

interface

uses
  Classes,    // TFileStream
  SysUtils,   // FileExists

  EscCodes,
  CompilerMessage;

type
  TToken = (Identifier, ParenOpen, ParenClose, CurlyBracketOpen, CurlyBracketClose);

  TLexer = class
  private
    FCurrentFilePath: string;
    FCurrentFile: string;

    FCurrentAbsolutePos: integer;
    FCurrentLine, FCurrentLineOffset: integer;
    
    FCurrentChar, FPreviousChar: char;

    // FCurrentToken: TToken;

    FTokenString: string;
    FTokenInt: integer;
    
    function IsNewLine: boolean;
    function GetNextChar: integer;

    procedure Error(const Message: string; const Details: string);
    procedure Error(const Message: string); overload;
  public
    constructor Create(FilePath: string);
    function GetNextToken: TToken;

    property CurrentFile: string read FCurrentFile;

    property TokenString: string read FTokenString;
    property TokenInt: integer read FTokenInt;
  end;

implementation

function IsSpace(const C: char): boolean; inline;
begin result := (C in [' ', EscCodes.Tab, EscCodes.LF, EscCodes.CR]); end;

function IsAlpha(const C: char): boolean; inline;
begin result := (C in ['A'..'Z', 'a'..'z']); end;

function IsAlnum(const C: char): boolean; inline;
begin result := (IsAlpha(C) or (C in ['0'..'9'])); end;

{----------------------------------------------------------}

constructor TLexer.Create(FilePath: string);
var
  FileStream: TFileStream;
begin
  if not SysUtils.FileExists(FilePath) then
  begin
    if SysUtils.FileExists(FilePath + '.b') then
    begin
      FilePath += '.b';
    end
    else
    begin 
      CompilerMessage.Error('Failed to open file ' + FilePath);
    end;
  end;

  FileStream := TFileStream.Create(FilePath, fmOpenRead);
  System.SetLength(self.FCurrentFile, FileStream.Size);
  FileStream.ReadBuffer(self.FCurrentFile[1], FileStream.Size);

  FileStream.Free();

  self.FCurrentFilePath := FilePath;

  self.FCurrentAbsolutePos := 0;
  self.FCurrentLine := 1;
  self.FCurrentLineOffset := 0;
end;

function TLexer.IsNewLine: boolean;
begin
{$IFDEF WINDOWS}
  result := (self.FPreviousChar + self.FCurrentChar = EscCodes.NewLine);
{$ELSE}
  result := (self.FCurrentChar = EscCodes.NewLine);
{$ENDIF}
end;

function TLexer.GetNextChar: integer;
begin
  if self.FCurrentAbsolutePos >= System.Length(self.FCurrentFile) then
    exit(-1);

  self.FCurrentAbsolutePos += 1;
  if self.IsNewLine then
  begin
    self.FCurrentLine += 1;
    self.FCurrentLineOffset := 1;
  end
  else
    self.FCurrentLineOffset += 1;

  self.FPreviousChar := self.FCurrentChar;
  self.FCurrentChar := self.FCurrentFile[self.FCurrentAbsolutePos];
  result := 0;
end;

function TLexer.GetNextToken: TToken;
var
  StartingLine: integer;
begin
  repeat
    repeat
      self.GetNextChar;
    until not IsSpace(self.FCurrentChar);

    { Check comments }
    if self.FPreviousChar + self.FCurrentChar = '/*' then
    begin
      StartingLine := self.FCurrentLine;
      while self.FPreviousChar + self.FCurrentChar <> '*/' do
      begin
        if self.GetNextChar = -1 then
          self.Error('Unexpected EOF', 'Did you forget to insert */ after line ' + StartingLine.ToString + '?');
      end;
      break;
    end;

    if IsAlpha(self.FCurrentChar) then
    begin
      repeat
        self.FTokenString += self.FCurrentChar;
        self.GetNextChar;
      until not IsAlnum(self.FCurrentChar);
      result := TToken.Identifier;
      exit;
    end;
  until false { or self.FCurrentAbsolutePos >= System.Length(self.FCurrentFile) };
end;

procedure TLexer.Error(const Message: string; const Details: string);
begin
  System.Write(self.FCurrentFilePath, ':', self.FCurrentLine, ':', self.FCurrentLineOffset + 1, ':' + EscCodes.Tab);
  CompilerMessage.Error(Message, Details);
end;

procedure TLexer.Error(const Message: string); overload;
begin
  self.Error(Message, 'No details');
end;

end.
