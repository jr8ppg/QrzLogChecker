unit Progress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TformProgress = class(TForm)
    buttonAbort: TButton;
    ProgressBar1: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure buttonAbortClick(Sender: TObject);
  private
    { Private êÈåæ }
    FAbort: Boolean;
    function GetMaxCount(): Integer;
    procedure SetMaxCount(v: Integer);
  public
    { Public êÈåæ }
    property IsAbort: Boolean read FAbort;
    property MaxCount: Integer read GetMaxCount write SetMaxCount;
    procedure StepIt();
    procedure Reset();
  end;

implementation

{$R *.dfm}

procedure TformProgress.FormCreate(Sender: TObject);
begin
   Reset();
end;

procedure TformProgress.buttonAbortClick(Sender: TObject);
begin
   FAbort := True;
end;

procedure TformProgress.StepIt();
begin
   ProgressBar1.StepIt();
end;

procedure TformProgress.Reset();
begin
   FAbort := False;
   ProgressBar1.Position := 0;
end;

function TformProgress.GetMaxCount(): Integer;
begin
   Result := ProgressBar1.Max;
end;

procedure TformProgress.SetMaxCount(v: Integer);
begin
   ProgressBar1.Max := v;
end;

end.
