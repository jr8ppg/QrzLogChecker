{
  Q R Z L o g C h e c k e r

  COPYRIGHT (c) 2022 JR8PPG

  このサービス（ソフトウェア）は、総務省 電波利用ホームページのWeb-API 機能を
  利用して取得した情報をもとに作成しているが、サービスの内容は総務省によって
  保証されたものではありません。

  This software is released under the MIT License.
}
unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.JSON, System.StrUtils, System.Math,
  Vcl.ComCtrls, Vcl.ExtCtrls, System.IniFiles,
  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc, System.Generics.Collections,
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    StatusBar1: TStatusBar;
    editLoginID: TEdit;
    Label3: TLabel;
    editPassword: TEdit;
    editSessionKey: TEdit;
    Label4: TLabel;
    buttonLogin: TButton;
    memoResult: TMemo;
    Label6: TLabel;
    editCabrilloFile: TEdit;
    buttonCabrilloQuery: TButton;
    OpenDialog1: TOpenDialog;
    groupParameters: TGroupBox;
    buttonCabrilloFileRef: TButton;
    Label7: TLabel;
    editClusterFile: TEdit;
    buttonClusterFileRef: TButton;
    OpenDialog2: TOpenDialog;
    groupSites: TGroupBox;
    radioQrzCom: TRadioButton;
    radioQrzcqCom: TRadioButton;
    buttonLogClear: TButton;
    buttonLogCopy: TButton;
    groupMultiCheck: TGroupBox;
    radioMultiNone: TRadioButton;
    radioMultiZone: TRadioButton;
    radioMultiState: TRadioButton;
    groupUserInfo: TGroupBox;
    checkShowPassword: TCheckBox;
    chckShowProcessTime: TCheckBox;
    NetHTTPClient1: TNetHTTPClient;
    NetHTTPRequest1: TNetHTTPRequest;
    procedure buttonLoginClick(Sender: TObject);
    procedure buttonCabrilloQueryClick(Sender: TObject);
    procedure buttonCabrilloFileRefClick(Sender: TObject);
    procedure buttonClusterFileRefClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure buttonLogClearClick(Sender: TObject);
    procedure buttonLogCopyClick(Sender: TObject);
    procedure checkShowPasswordClick(Sender: TObject);
  private
    { Private 宣言 }
    FClusterList: TStringList;
    procedure LoadClusterLog(strFilename: string);
    function FindClusterLog(strCallsign: string): string;
    function QueryOneStation(strSessionKey: string; strCallsign: string; var strCountry, strCQZone, strITUZone, strState: string): Boolean;
    function GetXmlNode(start_node: IXMLNode; tagname: string; name: string): IXMLNode;
    function LicenseLookup(strCallsign: string; fCheckAround: Boolean; var strError: string): Boolean;
    procedure EnableAllItems(fEnable: Boolean);
    procedure LoadSettings();
    procedure SaveSettings();
  public
    { Public 宣言 }
  end;

function RemovePortable(strCallsign: string): string;
function IsDomestic(strCallsign: string): Boolean;
function LD_dp(str1, str2: string): Integer;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Progress;

procedure TForm1.buttonLogClearClick(Sender: TObject);
begin
   memoResult.Clear();
end;

procedure TForm1.buttonLogCopyClick(Sender: TObject);
begin
   memoResult.SelectAll();
   memoResult.CopyToClipboard();
end;

procedure TForm1.buttonLoginClick(Sender: TObject);
var
   strQuery: string;
   strResponse: string;
   xmldoc: TXMLDocument;
   rootnd: IXMLNode;
   sessionnode: IXMLNode;
   infonode: IXMLNode;
   res: IHttpResponse;
begin
   //MSXML6_ProhibitDTD := False;

   xmldoc := TXMLDocument.Create(Self);
   try
   try
      if radioQrzCom.Checked = True then begin
         strQuery := 'https://xmldata.qrz.com/xml/current/'
      end
      else begin
         strQuery := 'https://ssl.qrzcq.com/xml';
      end;

      strQuery := strQuery + '?username=' + editLoginID.Text + ';password=' + editPassword.Text;

      res := NetHTTPRequest1.Get(strQuery);
      strResponse := res.ContentAsString();

      xmldoc.DOMVendor := GetDOMVendor('MSXML');
      xmldoc.XML.Text := strResponse;
      xmldoc.Active := True;

      rootnd := xmldoc.DocumentElement;

      sessionnode := GetXmlNode(rootnd, 'Session', '');
      infonode := GetXmlNode(sessionnode, 'Key', '');
      if infonode <> nil then begin
         editSessionKey.Text := infonode.Text;
      end
      else begin  // ERROR
         infonode := GetXmlNode(sessionnode, 'Error', '');
         raise Exception.Create(infonode.Text);
      end;


      EnableAllItems(False);
   except
      on E: Exception do begin
         MessageBox(Handle, PChar(E.Message), PChar(Application.Title), MB_OK or MB_ICONEXCLAMATION);
      end;
   end;
   finally
      xmldoc.Free;
   end;
end;

//00000000011111111112222222222333333333344444444445555555555666666666677777777779
//12345678901234567890123456789012345678901234567890123456789012345678901234567890
//QSO: 21030 CW 2018-11-24 0001 JH8YOH        599 25     CW4MAX        599 13     1

procedure TForm1.buttonCabrilloQueryClick(Sender: TObject);
var
   TXT: TStringList;
   filename: string;
   strCallsign: string;
   strCallsign2: string;
   i: Integer;
   dwTick: DWORD;
   dwTick2: DWORD;
   fResult: Boolean;
   strError: string;
   strMsg: string;
   progress: TformProgress;
   nOK, nNG, nJA: Integer;
   strPartial: string;
   nPartial: Integer;
   strCountry, strCQZone, strITUZone, strState: string;
   strRcvdZone: string;
   strZoneInfo: string;
   strMulti: string;
   nMultiMisMatch: Integer;
begin
   TXT := TStringList.Create();
   TXT.StrictDelimiter := True;

   progress := TformProgress.Create(Self);
   try
      filename := editCabrilloFile.Text;
      if FileExists(filename) = False then begin
         Exit;
      end;

      TXT.LoadFromFile(filename);
      progress.MaxCount := TXT.Count;
      progress.Show();

      nOK := 0;
      nNG := 0;
      nJA := 0;
      nPartial := 0;
      nMultiMisMatch := 0;

      memoResult.Clear();
      memoResult.Lines.Add('begin - ' + FormatDateTime('yyyy/mm/dd hh:mm:ss', Now));

      memoResult.Lines.Add('Cluster Log loading ');
      dwTick := GetTickCount();
      LoadClusterLog(editClusterFile.Text);
      dwTick := GetTickCount() - dwTick;
      memoResult.Lines.Add('Cluster Log loaded ' + IntToStr(FClusterList.Count) + ' records '+ IntToStr(dwTick) + ' ms');
      memoResult.Lines.Add('------- cut line from here -------');

      for i := 0 to TXT.Count - 1 do begin
         if progress.IsAbort = True then begin
            memoResult.Lines.Add('***aborted***');
            Break;
         end;

         if Copy(TXT[i], 1, 4) <> 'QSO:' then begin
            Continue;
         end;

         strCallsign := Trim(Copy(TXT[i], 56, 10));
         strRcvdZone := RightStr('00' + Trim(Copy(TXT[i], 74, 2)), 2);

         strCallsign2 := RemovePortable(strCallsign);

         dwTick := GetTickCount();
         fResult := QueryOneStation(editSessionKey.Text, strCallsign2, strCountry, strCQZone, strITUZone, strState);
         dwTick := GetTickCount() - dwTick;
         dwTick2 := 0;

         if radioMultiZone.Checked = True then begin
            strMulti := strCQZone;
         end
         else if radioMultiState.Checked = True then begin
            strMulti := strState;
         end
         else begin
            strMulti := '';
         end;

         if fResult = True then begin
            IF strMulti <> '' then begin
               if strRcvdZone = strMulti then begin
                  strZoneInfo := 'OK' + #09;
               end
               else begin
                  strZoneInfo := 'Mismatch' + #09 + strMulti;
                  Inc(nMultiMisMatch);
               end;
            end
            else begin
               strZoneInfo := #09;
            end;

            strMsg := 'OK' + #09 + #09 + strZoneInfo;
            Inc(nOK);
         end
         else begin
            strZoneInfo := #09;

            if IsDomestic(strCallsign2) = True then begin
               Inc(nJA);

               dwTick2 := GetTickCount();
               fResult := LicenseLookup(strCallsign2, False, strError);
               dwTick2 := GetTickCount() - dwTick2;

               if fResult = True then begin
                  strMsg := 'OK(JA)' + #09 + #09 + strZoneInfo;
                  Inc(nOK);
               end
               else begin
                  strMsg := 'NG(JA)' + #09 + #09 + strZoneInfo;
                  Inc(nNG);
               end;
            end
            else begin
               dwTick2 := GetTickCount();
               strPartial := FindClusterLog(strCallsign2);
               dwTick2 := GetTickCount() - dwTick2;

               if strPartial = strCallsign2 then begin
                  strMsg := 'OK(D=0)' + #09 + #09 + strZoneInfo;
                  Inc(nOK);
               end
               else if strPartial <> '' then begin
                  strMsg := 'OK(D=1)' + #09 + strPartial + #09 + strZoneInfo;
                  Inc(nPartial);
               end
               else begin
                  strMsg := 'NG' + #09 + #09 + strZoneInfo;
                  Inc(nNG);
               end;
            end;
         end;

         if chckShowProcessTime.Checked = True then begin
            strMsg := strMsg + #09 + IntToStr(dwTick) + ' ms';
            if dwTick2 > 0 then begin
               strMsg := strMsg + ' + ' + IntToStr(dwTick2) + ' ms';
            end;
         end;

         memoResult.Lines.Add(strCallsign + #09 + strMsg);
         progress.StepIt();

         Application.ProcessMessages();
      end;
      progress.Hide();

      memoResult.Lines.Add('------- cut line up to here -------');
      memoResult.Lines.Add('end - ' + FormatDateTime('yyyy/mm/dd hh:mm:ss', Now));
      memoResult.Lines.Add('OK:' + IntToStr(nOK));
      memoResult.Lines.Add('NG:' + IntToStr(nNG));
      memoResult.Lines.Add('JA:' + IntToStr(nJA));
      memoResult.Lines.Add('N+1:' + IntToStr(nPartial));
      memoResult.Lines.Add('TOTAL:' + IntToStr(TXT.Count));
      memoResult.Lines.Add('Multi Mismatch:' + IntToStr(nMultiMisMatch));
   finally
      TXT.Free();
      progress.Release();
   end;
end;

procedure TForm1.checkShowPasswordClick(Sender: TObject);
begin
   if checkShowPassword.Checked then begin
      editPassword.PasswordChar := #0;
   end
   else begin
      editPassword.PasswordChar := '*';
   end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   FClusterList := TStringList.Create();
   FClusterList.Duplicates := dupIgnore;
   FClusterList.Sorted := True;

   LoadSettings();

   EnableAllItems(True);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
   FClusterList.Free();
   SaveSettings();
end;

procedure TForm1.buttonCabrilloFileRefClick(Sender: TObject);
begin
   if OpenDialog1.Execute(Self.Handle) = False then begin
      Exit;
   end;

   editCabrilloFile.Text := OpenDialog1.FileName;
end;

procedure TForm1.buttonClusterFileRefClick(Sender: TObject);
begin
   if OpenDialog2.Execute(Self.Handle) = False then begin
      Exit;
   end;

   editClusterFile.Text := OpenDialog2.FileName;
end;

function TForm1.QueryOneStation(strSessionKey: string; strCallsign: string; var strCountry, strCQZone, strITUZone, strState: string): Boolean;
var
   strQuery: string;
   strResponse: string;
   xmldoc: TXMLDocument;
   rootnd: IXMLNode;
   callnd: IXMLNode;
   node: IXMLNode;
   res: IHttpResponse;
begin
   xmldoc := TXMLDocument.Create(Self);
   try
      strCallsign := UpperCase(Trim(strCallsign));
      if strCallsign = '' then begin
         Result := False;
         Exit;
      end;

      strCountry := '';
      strCQZone := '';
      strITUZone := '';
      strState := '';

      if radioQrzCom.Checked = True then begin
         strQuery := 'https://xmldata.qrz.com/xml/current/'
      end
      else begin
         strQuery := 'https://ssl.qrzcq.com/xml';
      end;

      strQuery := strQuery + '?s=' + strSessionKey + ';callsign=' + strCallsign;

      // http照会
      res := NetHTTPRequest1.Get(strQuery);
      strResponse := res.ContentAsString();

      strResponse := StringReplace(strResponse, '&', '&amp;', [rfReplaceAll]);

      xmldoc.DOMVendor := GetDOMVendor('MSXML');
      xmldoc.XML.Text := strResponse;
      xmldoc.Active := True;

      rootnd := xmldoc.DocumentElement;

      node := GetXmlNode(rootnd, 'Session', '');
      node := GetXmlNode(node, 'Error', '');
      if node <> nil then begin
         Result := False;
         Exit;
      end;

      callnd := GetXmlNode(rootnd, 'Callsign', '');
      node := GetXmlNode(callnd, 'call', '');

      if node.Text = strCallsign then begin
         Result := True;

         if radioQrzCom.Checked = True then begin  // QRZ.COM
            node := GetXmlNode(callnd, 'dxcc', '');
            if Assigned(node) then begin
               strCountry := node.Text;
            end;

            node := GetXmlNode(callnd, 'cqzone', '');
            if Assigned(node) then begin
               strCQZone := RightStr('00' + Trim(node.Text), 2);
            end;

            node := GetXmlNode(callnd, 'ituzone', '');
            if Assigned(node) then begin
               strITUZone := RightStr('00' + Trim(node.Text), 2);
            end;

            node := GetXmlNode(callnd, 'state', '');
            if Assigned(node) then begin
               strState := node.Text;
            end;
         end
         else begin  // QRZCQ.COM
            node := GetXmlNode(callnd, 'country', '');
            if Assigned(node) then begin
               strCountry := node.Text;
            end;

            node := GetXmlNode(callnd, 'cq', '');
            if Assigned(node) then begin
               strCQZone := RightStr('00' + Trim(node.Text), 2);
            end;

            node := GetXmlNode(callnd, 'itu', '');
            if Assigned(node) then begin
               strITUZone := RightStr('00' + Trim(node.Text), 2);
            end;

            // QRZCQ.COMのCQ ZONE 05,17,23はあてにならない
            if (strCQZone = '00') or (strCQZone = '05') or (strCQZone = '17') or (strCQZone = '23') then begin
               strCQZone := '';
               strITUZone := '';
            end;
         end;
      end
      else begin
         Result := False;
      end;
   finally
      xmldoc.Free;
   end;
end;

function TForm1.GetXmlNode(start_node: IXMLNode; tagname: string; name: string): IXMLNode;
var
   i: integer;
begin
   if start_node = nil then begin
      Result := nil;
      Exit;
   end;

   for i := 0 to start_node.ChildNodes.Count - 1 do begin
      if name = '' then begin
         if (start_node.ChildNodes[i].NodeName = tagname) then begin
            Result := start_node.ChildNodes[i];
            Exit;
         end;
      end
      else begin
         if (start_node.ChildNodes[i].NodeName = tagname) and (start_node.ChildNodes[i].Attributes['Name'] = name) then begin
            Result := start_node.ChildNodes[i];
            Exit;
         end;
      end;
      if start_node.ChildNodes[i].HasChildNodes = True then begin
         Result := GetXmlNode(start_node.ChildNodes[i], tagname, name);
         if Result <> nil then begin
            Exit;
         end;
      end;
   end;

   Result := nil;
end;

// ----------------------------------------------------------------------------

function TForm1.LicenseLookup(strCallsign: string; fCheckAround: Boolean; var strError: string): Boolean;

var
   strPrefix: string;
   nArea: Integer;
   strQuery: string;
   strResponse: string;
   IT: string;
   so: TJSONObject;
   musen: TJSONArray;
   musen_info: TJSONObject;
   list_info: TJSONObject;
   totalCount: Integer;
   lastUpdate: string;
   i: Integer;
   strName: string;
   strCall: string;
   Index: Integer;
   slJson: TStringList;
   strPrefix2: string;
   res: IHttpResponse;
const
   query_string = 'https://www.tele.soumu.go.jp/musen/list?ST=1&DA=0&SC=1&DC=1&OF=2&OW=AT';
begin
   slJson := TStringList.Create();
   try
   try
      strPrefix := Copy(strCallsign, 1, 3);
      nArea := StrToIntDef(Copy(strCallsign, 3, 1), -1);

      // コールサインに５文字以上入力されている場合は周辺コールチェック可
      if (Length(strCallsign) >= 5) and (fCheckAround = True) then begin
         strCallsign := Copy(strCallsign, 1, 5);
      end;

      // １エリア特別
      // https://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E3%81%AE%E5%91%BC%E5%87%BA%E7%AC%A6%E5%8F%B7#アマチュア局
      strPrefix2 := LeftStr(strPrefix, 2);
      if ((strPrefix2 = '7K') or
          (strPrefix2 = '7L') or
          (strPrefix2 = '7M') or
          (strPrefix2 = '7N')) and
         ((nArea >= 1) and (nArea <= 4)) then begin
            nArea := 1;
      end;

      // 沖縄特別
      // https://ja.wikipedia.org/wiki/%E6%97%A5%E6%9C%AC%E3%81%AE%E5%91%BC%E5%87%BA%E7%AC%A6%E5%8F%B7#cite_note-27
      // ^ 沖縄の指定枠は、一般的なアマチュア局の場合、JR6AA - NZ、JR6QUA - ZZZ、JS6AAA - ZZZ。
      if (nArea = 6) then begin
         if Length(strCallsign) = 5 then begin
            if (strCallsign >= 'JR6AA') and (strCallsign <= 'JR6NZ') then begin
               nArea := 16;
            end;
         end;
         if Length(strCallsign) = 6 then begin
            if ((strCallsign >= 'JR6QUA') and (strCallsign <= 'JR6ZZZ')) or
               ((strCallsign >= 'JS6AAA') and (strCallsign <= 'JS6ZZZ')) then begin
               nArea := 16;
            end;
         end;
      end;

      case nArea of
         1: IT := '&IT=A';
         2: IT := '&IT=C';
         3: IT := '&IT=E';
         4: IT := '&IT=F';
         5: IT := '&IT=G';
         6: IT := '&IT=H';
         7: IT := '&IT=I';
         8: IT := '&IT=J';
         9: IT := '&IT=D';
         0: IT := '&IT=B';
         16: IT := '&IT=O';      // 沖縄
         else IT := '';
      end;

      strQuery := query_string + IT + '&MA=' + strCallsign;

      // http照会
      res := NetHTTPRequest1.Get(strQuery);
      strResponse := res.ContentAsString();

      slJson.Text := strResponse;
      //slJson.SaveToFile('http_response.txt');

      so := TJSONObject(TJSONObject.ParseJSONValue(strResponse));
      musen_info := TJSONObject(so.Get('musenInformation').JsonValue);
      totalCount := StrToIntDef(musen_info.Get('totalCount').JsonValue.Value, 0);
      lastUpdate := musen_info.Get('lastUpdateDate').JsonValue.Value;
      if totalCount = 0 then begin   // データ無し
         strError := '';
         Result := False;
         Exit;
      end;

      musen := TJSONArray(so.Get('musen').JsonValue);

      for i:= 0 to Min(totalCount, 100) - 1 do begin
         list_info := TJSONObject(musen.Items[i]);
         list_info := TJSONObject(list_info.Pairs[0].JsonValue);

         strName := list_info.Get('name').JsonValue.Value;
         Index := Pos('（', strName);
         strCall := Copy(strName, Index + 1);
         strName := Copy(strName, 1, Index - 1);

         Index := Pos('）', strCall);
         strCall := Copy(strCall, 1, Index - 1);

         if strCall = strCallsign then begin
            Result := True;
            Exit;
         end;
      end;

      strError := '';
      Result := False;
   except
      on E: Exception do begin
         Result := False;
         strError := E.Message;
      end;
   end;
   finally
      slJson.Free();
   end;
end;

function RemovePortable(strCallsign: string): string;
var
   n: Integer;
   strLeft, strRight: string;
begin
   n := Pos('/', strCallsign);
   if n = 0 then begin
      Result := strCallsign;
      Exit;
   end;

   strLeft := Copy(strCallsign, 1, n - 1);
   strRight := Copy(strCallsign, n + 1);

   if Length(strLeft) >= Length(strRight) then begin
      Result := strLeft;
   end
   else begin
      Result := strRight;
   end;
end;

// JA1–JS1, 7J1, 8J1–8N1, 7K1–7N4
// JA2–JS2, 7J2, 8J2–8N2
// JA3–JS3, 7J3, 8J3–8N3
// JA4–JS4, 7J4, 8J4–8N4
// JA5–JS5, 7J5, 8J5–8N5
// JA6–JS6, 7J6, 8J6–8N6
// JA7–JS7, 7J7, 8J7–8N7
// JA8–JS8, 7J8, 8J8–8N8
// JA9–JS9, 7J9, 8J9–8N9
// JA0–JS0, 7J0, 8J0–8N0
function IsDomestic(strCallsign: string): Boolean;
var
   S1: Char;
   S2: Char;
   S3: Char;
begin
   S1 := strCallsign[1];
   S2 := strCallsign[2];
   S3 := strCallsign[3];

   if S1 = 'J' then begin
      if (S2 >= 'A') and (S2 <= 'S') then begin
         Result := True;
         Exit;
      end;
   end;

   if (S1 = '7') and (S2 = 'J') then begin
      Result := True;
      Exit;
   end;

   if S1 = '7' then begin
      if (S2 >= 'K') and (S2 <= 'N') then begin
         if (S3 >= '1') and (S3 <= '4') then begin
            Result := True;
            Exit;
         end;
      end;
   end;

   if S1 = '8' then begin
      if (S2 >= 'J') and (S2 <= 'N') then begin
         Result := True;
         Exit;
      end;
   end;

   Result := False;
end;

// 動的計画法でのレーベンシュタイン距離の計算
function LD_dp(str1, str2: string): Integer;
var
   n1, n2: Integer;
   i: Integer;
   j: Integer;
   d: array[0..100, 0..100] of Integer;
begin
   n1 := Length(str1);
   n2 := Length(str2);

   if (n1 > 100) or (n2 > 100) then begin
      Result := 100;
      Exit;
   end;

   for i := 0 to n1 do begin
      d[i][0] := i;
   end;

   for i := 0 to n2 do begin
      d[0][i] := i;
   end;

   for i := 1 to n1 do begin
      for j := 1 to n2 do begin
         d[i][j] := min(min(d[i - 1][j], d[i][j - 1]) + 1, d[i - 1][j - 1] + ifthen(str1[i] = str2[j], 0, 1));
      end;
   end;

   Result := d[n1][n2];
end;

//         11111111112222222222333333333344444444445555555555666666666677777777778
//12345678901234567890123456789012345678901234567890123456789012345678901234567890
//DX de SE0X-#:     7012.5  RK3QZ        CW 23 dB 31 WPM CQ             1423Z
//DX de LZ7AA-#:   14022.5  F4IDM        CW 13 dB 32 WPM CQ             1423Z
//DX de SP3UR:     14023.6  VO2NS        CQ 599                         1423Z

procedure TForm1.LoadClusterLog(strFilename: string);
var
   TXT: TextFile;
   strLine: string;
   strCallsign: string;
begin
   if FileExists(strFilename) = False then begin
      Exit;
   end;

   FClusterList.Clear();

   AssignFile(TXT, strFileName);
   Reset(TXT);

   while Eof(TXT) = False do begin
      ReadLn(TXT, strLine);

      if Copy(strLine, 1, 5) <> 'DX de' then begin
         Continue;
      end;

      strCallsign := RemovePortable(Trim(Copy(strLine, 27, 12)));

      FClusterList.Add(strCallsign);
   end;

   CloseFile(TXT);
end;

function TForm1.FindClusterLog(strCallsign: string): string;
var
   i: Integer;
   SL: TStringList;
   nDistance: Integer;
begin
   SL := TStringList.Create();
   try
      for i := 0 to FClusterList.Count - 1 do begin
         nDistance := LD_dp(FClusterList.Strings[i], strCallsign);
         if nDistance = 0 then begin
            SL.Clear();
            SL.Add(strCallsign);
            Exit;
         end;
         if nDistance = 1 then begin
            SL.Add(FClusterList.Strings[i]);
         end;
      end;
   finally
      Result := SL.CommaText;
      SL.Free();
   end;
end;

procedure TForm1.EnableAllItems(fEnable: Boolean);
begin
   groupSites.Enabled := fEnable;
   radioQrzCom.Enabled := fEnable;
   radioQrzCqCom.Enabled := fEnable;
   editLoginID.Enabled := fEnable;
   editPassword.Enabled := fEnable;
   checkShowPassword.Enabled := fEnable;
//   editSessionKey.Enabled := fEnable;
   buttonLogin.Enabled := fEnable;

   editCabrilloFile.Enabled := not fEnable;
   buttonCabrilloFileRef.Enabled := not fEnable;
   editClusterFile.Enabled := not fEnable;
   buttonClusterFileRef.Enabled := not fEnable;
//   groupMultiCheck.Enabled := not fEnable;
   radioMultiNone.Enabled := not fEnable;
   radioMultiZone.Enabled := not fEnable;
   radioMultiState.Enabled := not fEnable;
   buttonCabrilloQuery.Enabled := not fEnable;
   memoResult.Enabled := not fEnable;
   buttonLogClear.Enabled := not fEnable;
   buttonLogCopy.Enabled := not fEnable;
end;

procedure TForm1.LoadSettings();
var
   ini: TIniFile;
   n: Integer;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      n := ini.ReadInteger('SETTINGS', 'SITE', 0);
      case n of
         0: radioQrzCom.Checked := True;
         1: radioQrzCqCom.Checked := True;
      end;

      editLoginID.Text := ini.ReadString('SETTINGS', 'LoginID', '');

      editCabrilloFile.Text := ini.ReadString('SETTINGS', 'CabrilloFile', '');
      editClusterFile.Text := ini.ReadString('SETTINGS', 'ClusterLogFile', '');

      n := ini.ReadInteger('SETTINGS', 'MultiCheck', 0);
      case n of
         0: radioMultiNone.Checked := True;
         1: radioMultiZone.Checked := True;
         2: radioMultiState.Checked := True;
      end;

   finally
      ini.Free();
   end;
end;

procedure TForm1.SaveSettings();
var
   ini: TIniFile;
   n: Integer;
begin
   ini := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
   try
      n := 0;
      if radioQrzCom.Checked = True then n := 0;
      if radioQrzCqCom.Checked = True then n := 1;
      ini.WriteInteger('SETTINGS', 'SITE', n);

      ini.WriteString('SETTINGS', 'LoginID', editLoginID.Text);

      ini.WriteString('SETTINGS', 'CabrilloFile', editCabrilloFile.Text);
      ini.WriteString('SETTINGS', 'ClusterLogFile', editClusterFile.Text);

      n := 0;
      if radioMultiNone.Checked = True then n := 0;
      if radioMultiZone.Checked = True then n := 1;
      if radioMultiState.Checked = True then n := 2;
      ini.WriteInteger('SETTINGS', 'MultiCheck', n);
   finally
      ini.Free();
   end;
end;

end.
