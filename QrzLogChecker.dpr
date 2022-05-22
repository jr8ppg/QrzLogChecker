program QrzLogChecker;



uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Progress in 'Progress.pas' {formProgress};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'QRZ LogChecker';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
