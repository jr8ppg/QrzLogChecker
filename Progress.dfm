object formProgress: TformProgress
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Progress'
  ClientHeight = 86
  ClientWidth = 295
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object buttonAbort: TButton
    Left = 104
    Top = 53
    Width = 81
    Height = 25
    Caption = 'Abort'
    TabOrder = 0
    OnClick = buttonAbortClick
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 16
    Width = 279
    Height = 25
    Step = 1
    TabOrder = 1
  end
end
