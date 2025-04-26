{$SCOPEDENUMS ON}

unit Lexer;

interface

uses
  Classes,    // TFileStream
  SysUtils,   // FileExists

  EscCodes,
  CompilerMessage;

type
  TToken = (CommentStart, CommentEnd);

  TLexer = class
  private
    FCurrentFilePath: string;
    FCurrentFile: string;

    FCurrentFileAbsolutePos: integer;
    FCurrentFileLine, FCurrentFileLineOffset: integer;
    
    FCurrentChar, FPreviousChar: char;

    FCurrentToken: TToken;
    
    procedure GetNextChar;
    procedure Error(const Message: string; const Details: string);
    procedure Error(const Message: string); overload;
  public
    constructor Create(const FilePath: string);
    procedure GetNextToken;

    property CurrentFile: string read FCurrentFile;
    property CurrentToken: TToken read FCurrentToken;
  end;

const
  TokenValue: array[TToken] of string = (
    '/*', // CommentStart
    '*/'  // CommentEnd
  );

implementation

function IsSpace(const C: char): boolean; inline;
begin result := (C in [' ', EscCodes.Tab, EscCodes.LF, EscCodes.CR]); { space, tab, LF, CR } end;



function IsAlpha(const C: char): boolean; inline;
begin result := (C in ['A'..'Z', 'a'..'z']); end;

function IsAlnum(const C: char): boolean; inline;
begin result := (IsAlpha(C) or (C in ['0'..'9'])); end;

{----------------------------------------------------------}

constructor TLexer.Create(const FilePath: string);
var
  FileStream: TFileStream;
begin
  if not SysUtils.FileExists(FilePath) then
  begin
    CompilerMessage.Error('Failed to open file ' + FilePath);
  end;

  FileStream := TFileStream.Create(FilePath, fmOpenRead);
  System.SetLength(self.FCurrentFile, FileStream.Size);
  FileStream.ReadBuffer(self.FCurrentFile[1], FileStream.Size);

  FileStream.Free();

  self.FCurrentFilePath := FilePath;

  self.FCurrentFileAbsolutePos := 1;
  self.FCurrentFileLine := 1;
  self.FCurrentFileLineOffset := 1;

  self.FCurrentChar := self.FCurrentFile[1];
  self.FPreviousChar := #0;
end;

procedure TLexer.GetNextChar;
begin
  if self.FCurrentFileAbsolutePos >= System.Length(self.FCurrentFile) then
    self.Error('Unexpected EOF');

  self.FCurrentFileAbsolutePos += 1;
  if self.FCurrentChar = EscCodes.NewLine then
  begin
    self.FCurrentFileLine += 1;
    self.FCurrentFileLineOffset := 1;
  end
  else
    self.FCurrentFileLineOffset += 1;

  self.FPreviousChar := self.FCurrentChar;
  self.FCurrentChar := self.FCurrentFile[self.FCurrentFileAbsolutePos];
end;

procedure TLexer.GetNextToken;
begin
  repeat
    while IsSpace(self.FCurrentChar) do
        self.GetNextChar;

    { Check comments }
    if self.FPreviousChar + self.FCurrentChar = '/*' then
    begin
      CompilerMessage.Log('Comment occured, skipping...');
      System.WriteLn('Pos: ', self.FCurrentFileAbsolutePos);
      while self.FPreviousChar + self.FCurrentChar <> '*/' do
        self.GetNextChar;
      CompilerMessage.Log('End of comment');
      System.WriteLn('Pos: ', self.FCurrentFileAbsolutePos);
      break;
    end
    else
    begin
      self.GetNextChar;
    end;
  until false { or self.FCurrentFileAbsolutePos >= System.Length(self.FCurrentFile) };
end;

procedure TLexer.Error(const Message: string; const Details: string);
begin
  Write(self.FCurrentFilePath, ':', self.FCurrentFileLine, ':', self.FCurrentFileLineOffset, ':' + EscCodes.Tab);
  CompilerMessage.Error(Message, Details);
end;

procedure TLexer.Error(const Message: string); overload;
begin
  self.Error(Message, 'No details');
end;

end.