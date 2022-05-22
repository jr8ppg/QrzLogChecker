object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'QRZ LogChecker'
  ClientHeight = 472
  ClientWidth = 694
  Color = clBtnFace
  Constraints.MinHeight = 500
  Constraints.MinWidth = 700
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #65325#65331' '#65328#12468#12471#12483#12463
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    694
    472)
  PixelsPerInch = 96
  TextHeight = 12
  object StatusBar1: TStatusBar
    Left = 0
    Top = 453
    Width = 694
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Width = 80
      end
      item
        Alignment = taCenter
        Width = 80
      end
      item
        Alignment = taCenter
        Width = 120
      end
      item
        Alignment = taCenter
        Width = 100
      end
      item
        Width = 50
      end>
  end
  object memoResult: TMemo
    Left = 8
    Top = 299
    Width = 678
    Height = 123
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 5
  end
  object buttonCabrilloQuery: TButton
    Left = 555
    Top = 244
    Width = 131
    Height = 49
    Anchors = [akTop, akRight]
    Caption = #12481#12455#12483#12463#38283#22987
    TabOrder = 4
    OnClick = buttonCabrilloQueryClick
  end
  object groupParameters: TGroupBox
    Left = 8
    Top = 150
    Width = 678
    Height = 88
    Anchors = [akLeft, akTop, akRight]
    Caption = #12497#12521#12513#12540#12479
    TabOrder = 2
    DesignSize = (
      678
      88)
    object Label6: TLabel
      Left = 8
      Top = 29
      Width = 80
      Height = 12
      Caption = 'Cabrillo'#12501#12449#12452#12523
    end
    object Label7: TLabel
      Left = 8
      Top = 61
      Width = 58
      Height = 12
      Caption = 'Cluster'#12525#12464
    end
    object editCabrilloFile: TEdit
      Left = 94
      Top = 26
      Width = 525
      Height = 20
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object buttonCabrilloFileRef: TButton
      Left = 625
      Top = 24
      Width = 47
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #21442#29031
      TabOrder = 1
      OnClick = buttonCabrilloFileRefClick
    end
    object editClusterFile: TEdit
      Left = 94
      Top = 58
      Width = 525
      Height = 20
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
    end
    object buttonClusterFileRef: TButton
      Left = 625
      Top = 56
      Width = 47
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #21442#29031
      TabOrder = 3
      OnClick = buttonClusterFileRefClick
    end
  end
  object groupSites: TGroupBox
    Left = 8
    Top = 8
    Width = 217
    Height = 49
    Caption = #20351#29992#12469#12452#12488
    TabOrder = 0
    object radioQrzCom: TRadioButton
      Left = 16
      Top = 16
      Width = 72
      Height = 21
      Caption = 'QRZ.COM'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object radioQrzcqCom: TRadioButton
      Left = 108
      Top = 16
      Width = 85
      Height = 21
      Caption = 'QRZCQ.COM'
      TabOrder = 1
    end
  end
  object buttonLogClear: TButton
    Left = 8
    Top = 428
    Width = 77
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Clear'
    TabOrder = 6
    OnClick = buttonLogClearClick
  end
  object buttonLogCopy: TButton
    Left = 91
    Top = 428
    Width = 77
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Copy'
    TabOrder = 7
    OnClick = buttonLogCopyClick
  end
  object groupMultiCheck: TGroupBox
    Left = 8
    Top = 244
    Width = 469
    Height = 49
    Caption = 'Multi'#12481#12455#12483#12463
    TabOrder = 3
    object radioMultiNone: TRadioButton
      Left = 16
      Top = 20
      Width = 101
      Height = 13
      Caption = 'Multi'#12398#29031#21512#28961#12375
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object radioMultiZone: TRadioButton
      Left = 137
      Top = 20
      Width = 137
      Height = 13
      Caption = 'Zone'#12434#29031#21512#65288'WW'#12394#12393#65289
      TabOrder = 1
    end
    object radioMultiState: TRadioButton
      Left = 285
      Top = 20
      Width = 165
      Height = 13
      Caption = 'State'#12434#29031#21512#65288'ARRL DX'#12394#12393#65289
      TabOrder = 2
    end
  end
  object groupUserInfo: TGroupBox
    Left = 8
    Top = 63
    Width = 678
    Height = 81
    Anchors = [akLeft, akTop, akRight]
    Caption = #12518#12540#12470#12540#24773#22577
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 23
      Width = 52
      Height = 12
      Caption = #12525#12464#12452#12531'ID'
    end
    object Label3: TLabel
      Left = 203
      Top = 23
      Width = 54
      Height = 12
      Caption = #12497#12473#12527#12540#12489
    end
    object Label4: TLabel
      Left = 16
      Top = 54
      Width = 70
      Height = 12
      Caption = #12475#12483#12471#12519#12531'KEY'
    end
    object buttonLogin: TButton
      Left = 607
      Top = 43
      Width = 65
      Height = 33
      Caption = #12525#12464#12452#12531
      TabOrder = 0
      OnClick = buttonLoginClick
    end
    object editLoginID: TEdit
      Left = 96
      Top = 20
      Width = 89
      Height = 20
      TabOrder = 1
    end
    object editPassword: TEdit
      Left = 272
      Top = 20
      Width = 217
      Height = 20
      AutoSize = False
      PasswordChar = '*'
      TabOrder = 2
    end
    object editSessionKey: TEdit
      Left = 96
      Top = 51
      Width = 393
      Height = 20
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 3
    end
    object checkShowPassword: TCheckBox
      Left = 495
      Top = 24
      Width = 101
      Height = 13
      Caption = #12497#12473#12527#12540#12489#34920#31034
      TabOrder = 4
      OnClick = checkShowPasswordClick
    end
  end
  object chckShowProcessTime: TCheckBox
    Left = 174
    Top = 432
    Width = 115
    Height = 13
    Caption = 'Show Process Time'
    TabOrder = 9
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.CBR'
    Filter = 'Cabrillo'#12501#12449#12452#12523'|*.CBR|'#12486#12461#12473#12488#12501#12449#12452#12523'|*.txt|'#12377#12409#12390#12398#12501#12449#12452#12523'|*.*'
    Left = 296
    Top = 376
  end
  object OpenDialog2: TOpenDialog
    DefaultExt = '.txt'
    Filter = #12486#12461#12473#12488#12501#12449#12452#12523'|*.txt|'#12497#12465#12483#12488#12501#12449#12452#12523'|*.pkt|'#12377#12409#12390#12398#12501#12449#12452#12523'|*.*'
    Left = 336
    Top = 376
  end
  object NetHTTPClient1: TNetHTTPClient
    UserAgent = 'Embarcadero URI Client/1.0'
    Left = 324
    Top = 20
  end
  object NetHTTPRequest1: TNetHTTPRequest
    Client = NetHTTPClient1
    Left = 372
    Top = 20
  end
end
