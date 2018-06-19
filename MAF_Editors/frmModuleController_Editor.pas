unit frmModuleController_Editor;

interface

{$I ..\MAF_Base\MAFramework.inc}

uses Windows, Messages, SysUtils, Variants, Classes,
     {$IFDEF VER230}
     VCL.StdCtrls, VCL.ExtCtrls, VCL.Graphics, VCL.Controls, VCL.Forms, VCL.Dialogs, VCL.ComCtrls, VCL.CheckLst,
     {$ELSE}
     StdCtrls, ExtCtrls, Graphics, Controls, Forms, Dialogs, ComCtrls, CheckLst,
     {$ENDIF}
     xmldom, XMLIntf, XMLDoc, msxmldom,
  {$IFDEF PNGimage} PNGimage, {$ENDIF}
  // Modular Application Framework Components units
  {$IFDEF Package_Build} frmConfiguration, {$ENDIF}
  {$IFDEF CodeSite} CodeSiteLogging, {$ENDIF}
  uMAF_ModuleController, uMAF_ModuleController_DataHelper, uMAF_Globals,
  uXMLSynchro, uMAF_HookManager_Helper, uMAF_ResourceManager, uMAF_ResourceClient;

type
  TfModuleController_Editor = class(TForm)
    PageControl1: TPageControl;
    tsModuleController: TTabSheet;
    tsTokenEditor: TTabSheet;
    lvToken: TListView;
    lvTokenDetails: TListView;
    Label1: TLabel;
    Label2: TLabel;
    btnToken_Delete: TButton;
    btnToken_Edit: TButton;
    btnToken_New: TButton;
    btnTokenDetails_Delete: TButton;
    btnTokenDetails_Edit: TButton;
    btnTokenDetails_New: TButton;
    lvData: TListView;
    tsImportExport: TTabSheet;
    XML: TXMLDocument;
    GroupBox1: TGroupBox;
    clbDataDefs: TCheckListBox;
    btnDataDef_Import: TButton;
    btnDataDef_Export: TButton;
    SD: TSaveDialog;
    OD: TOpenDialog;
    tsModuleInstall: TTabSheet;
    lvInstall: TListView;
    GroupBox2: TGroupBox;
    cbInstallPosition: TComboBox;
    Label10: TLabel;
    Label11: TLabel;
    ed_uID: TEdit;
    btnDeleteInstallToken: TButton;
    Button2: TButton;
    PageControl2: TPageControl;
    TabSheet1: TTabSheet;
    tsDataDefs: TTabSheet;
    btnDelete: TButton;
    btnNew: TButton;
    FpEditBox: TEdit;
    Label8: TLabel;
    lvDataDefs: TListView;
    Label7: TLabel;
    edDescription: TEdit;
    Label9: TLabel;
    GroupBox3: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    cbAction: TComboBox;
    eSubHookID: TEdit;
    eHookID: TEdit;
    cbDataDefinition: TComboBox;
    Label5: TLabel;
    Label12: TLabel;
    cbMediaType: TComboBox;
    gpPreview: TGroupBox;
    lPreviewLabel: TLabel;
    btnSelectMediaItem: TButton;
    Image1: TImage;
    cbInstallAction: TComboBox;
    Label13: TLabel;
    Label14: TLabel;
    eduID: TEdit;
    cbUseDataBlock: TCheckBox;
    TabSheet2: TTabSheet;
    GroupBox4: TGroupBox;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    procedure btnToken_NewEditClick(Sender: TObject);
    procedure btnToken_DeleteClick(Sender: TObject);
    procedure btnTokenDetails_NewEditClick(Sender: TObject);
    procedure btnTokenDetails_DeleteClick(Sender: TObject);
    procedure lvTokenSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvTokenDetailsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure eHookIDExit(Sender: TObject);
    procedure cbDataDefinitionChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvDataDefsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure FpEditBoxChange(Sender: TObject);
    procedure lvDataSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure btnDataDef_ExportClick(Sender: TObject);
    procedure btnDataDef_ImportClick(Sender: TObject);
    procedure lvDataColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvDataCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure lvInstallSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lvInstallClick(Sender: TObject);
    procedure cbInstallPositionChange(Sender: TObject);
    procedure ed_uIDChange(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure cbMediaTypeChange(Sender: TObject);
    procedure btnSelectMediaItemClick(Sender: TObject);
    procedure btnDeleteInstallTokenClick(Sender: TObject);
    procedure cbInstallActionChange(Sender: TObject);
  private
    LastColumnSorted : Integer;
    LastSort : Byte;
    RC : TmafResourceClient;
    function __Get_DataRecord(SubHookID: Integer): PDataRecord;
    function __Get_InstallRecord(SubHookID: Integer): PMAFInstallToken;
    procedure __Load_EditorData(pData: PDataRecord);
    procedure __Fill_DataView(aSelected: PDataRecord = nil);
    procedure __Fill_DataDefsView(aToken: TmafModuleControllerDataTypes);
    procedure __Fill_DataTokenView;
    procedure __Fill_DataTokenDetailsView(aToken: TmafModuleControllerDataTypes);
    procedure __Fill_ImportExport_DataTokenView;
    procedure __Fill_InstallView;
    procedure __Select_DataDefs(nDataID: Integer);
    procedure __Synchronize_With_XML;
    procedure ResourceManagerUnknownImageType(Sender: TObject;  Extension: string; aStream: TMemoryStream; var Image: TGraphic);
  public
    pMC : TmafModuleController;
    bModified : Boolean;
  end;

implementation

uses frmEditName_Generic, frmEditDataDef, uMAF_Core, uMAF_Tools,
     uMAF_ResourceManager_Helper;

{$R *.dfm}

procedure TfModuleController_Editor.FormDestroy(Sender: TObject);
begin
  lvDataDefs.OnSelectItem := nil;
  RC.Free;
end;

procedure TfModuleController_Editor.FormShow(Sender: TObject);
begin
  RC := TmafResourceCLient.Create(Self);
  LastColumnSorted := -1;
  __Fill_DataTokenView;
  __Fill_DataView;
  __Fill_ImportExport_DataTokenView;
  __Synchronize_With_XML;
  __Fill_InstallView;
  Label18.Caption := IntToStr(pMC.Current_uID);
  Label17.Caption := IntTostr(pMC.Data.Count);
end;

procedure TfModuleController_Editor.FpEditBoxChange(Sender: TObject);
var pData : PDataToken;
begin
  If lvDataDefs.Selected <> nil Then begin
    lvDataDefs.Selected.SubItems.Strings[0] := FpEditBox.Text;
    pData := PDataToken(lvDataDefs.Selected.Data);
    Case pData^.aType Of
      sdtInteger   : Integer(pData^.pData^) := StrToIntDef(FpEditBox.Text, 0);
      sdtDateTime  : TDateTime(pData^.pData^) := StrToDateTimeDef(FpEditBox.Text, Now);
      sdtInt64     : Int64(pData^.pData^) := StrToInt64Def(FpEditBox.Text, 0);
      sdtString    : begin
                       FreePChar(PChar(pData^.pData));
                       pData^.nLength := StrToPChar(FpEditBox.Text, PChar(pData^.pData));
                     end;
      sdtMediaItem : PmafMediaItem(pData^.pData)^.MediaID := StrToIntDef(FpEditBox.Text, 0);
    end;
    bModified := True;
  end;
end;

procedure TfModuleController_Editor.__Fill_DataView(aSelected: PDataRecord = nil);
var i : Integer;
    LI : TListItem;
    pData : PDataRecord;
    aToken : TmafModuleControllerDataTypes;
    pIT : PMAFInstallToken;
begin
  eHookID.Text := '';
  eSubHookID.Text := '';
  cbAction.ItemIndex := 0;         // "Route Through" - entry
  cbDataDefinition.ItemIndex := 0; // "No Data" - entry
  lvDataDefs.Items.Clear;

  lvData.Items.BeginUpdate;
  lvData.Selected := nil;
  lvData.Items.Clear;
  For i := 0 To pMC.Data.Count - 1 Do begin
    pData := PDataRecord(pMC.Data.Items[i]);
    pIT := __Get_InstallRecord(pData^.SubHookID);
    If Not Assigned(pIT) Then begin
      pIT := __Create_InstallToken(iaInsert);
      pIT^.nHookID := pData^.HookID;
      pIT^.nSubHookID := pData^.SubHookID;
      pMC.InstallData.Add(pIT);
    end;
    LI := lvData.Items.Add;
    LI.Caption := IntToStr(pData^.HookID);
    LI.SubItems.Add(IntToStr(pData^.SubHookID));
    aToken := pMC.GetDataDef(pData^.DataID);
    If aToken <> nil Then LI.SubItems.Add(aToken.TokenName)
                     Else LI.SubItems.Add('No Data');
    Case pData^.Action Of
      daRouteThrough     : LI.SubItems.Add('Route Through');
      daCreateWindow     : LI.SubItems.Add('Create Window');
      daReturnData       : LI.SubItems.Add('Return Data');
      daCreateEnumWindow : LI.SubItems.Add('Create Enum Window');
      daCreateWindowShow : LI.SubItems.Add('Create Window Show');
      daCreateWindowShowModal : LI.SubItems.Add('Create Window ShowModal');
    end;  //  --  Case pData^.Action Of
    LI.SubItems.Add(pData^.Description);
    LI.SubItems.Add(IntToStr(pData^.uID));
    LI.Data := pData;
    If pData = aSelected Then begin
      lvData.Selected := LI;
      lvData.Selected.MakeVisible(False);
    end;
  end;  //  --  For i := 0 To pMC.Data.Count - 1 Do
  lvData.Items.EndUpdate;
end;

procedure TfModuleController_Editor.__Load_EditorData(pData: PDataRecord);
begin
  If pData = nil Then
    Exit;

  eHookID.Text := IntToStr(pData^.HookID);
  eSubHookID.Text := IntToStr(pData^.SubHookID);
  Case pData^.Action Of
    daRouteThrough     : cbAction.ItemIndex := 0;
    daCreateWindow     : cbAction.ItemIndex := 1;
    daReturnData       : cbAction.ItemIndex := 2;
    daCreateEnumWindow : cbAction.ItemIndex := 3;
    daCreateWindowShow : cbAction.ItemIndex := 4;
    daCreateWindowShowModal : cbAction.ItemIndex := 5;
  end;  //  --  Case pData^.Action Of
  edDescription.Text := pData^.Description;
  cbUseDataBlock.Checked := pData^.bUseDatablock;
  __Select_DataDefs(pData^.DataID);
end;

procedure TfModuleController_Editor.__Select_DataDefs(nDataID: Integer);
var i : Integer;
begin
  cbDataDefinition.ItemIndex := 0;
  For i := 0 To cbDataDefinition.Items.Count - 1 Do
    If cbDataDefinition.Items.Objects[i] <> nil Then
      If TmafModuleControllerDataTypes(cbDataDefinition.Items.Objects[i]).TokenID = nDataID Then begin
        cbDataDefinition.ItemIndex := i;
        Break;
      end;
  If cbDataDefinition.ItemIndex > 0 Then
    __Fill_DataDefsView(TmafModuleControllerDataTypes(cbDataDefinition.Items.Objects[i]))
  Else
    lvDataDefs.Items.Clear;
end;

procedure TfModuleController_Editor.__Fill_DataDefsView(aToken: TmafModuleControllerDataTypes);
var i : Integer;
    LI : TListItem;
    pDataDefs : PRecordDef;
    pData : PDataToken;
begin
  lvDataDefs.Items.BeginUpdate;
  lvDataDefs.Selected := nil;
  lvDataDefs.Items.Clear;
  If aToken <> nil Then begin
    For i := 0 To aToken.Token.Count - 1 Do begin
      pDataDefs := PRecordDef(aToken.Token.Items[i]);
      LI := lvDataDefs.Items.Add;
      LI.Caption := pDataDefs^.sName;
      pData := PDataToken(PDataRecord(lvData.Selected.Data)^.FpDataTokens.Items[i]);
      Case pData^.aType Of
        sdtInteger   : LI.SubItems.Add(IntToStr(Integer(pData^.pData^)));
        sdtDateTime  : LI.SubItems.Add(DateTimeToStr(TDateTime(pData^.pData^)));
        sdtInt64     : LI.SubItems.Add(IntToStr(Int64(pData^.pData^)));
        sdtString    : LI.SubItems.Add(String(PChar(pData^.pData)));
        sdtMediaItem : LI.SubItems.Add(IntToStr(PmafMediaItem(pData^.pData)^.MediaID));
      end;
      LI.Data := pData;
    end;
  end;
  lvDataDefs.Items.EndUpdate;
end;

procedure TfModuleController_Editor.__Fill_DataTokenView;
var i : Integer;
    aToken : TmafModuleControllerDataTypes;
    Sel : TObject;
    LI : TListItem;
begin
  lvToken.Items.BeginUpdate;
  lvToken.Selected := nil;
  lvToken.Items.Clear;
  For i := 0 To pMC.DataDefs.Count - 1 Do begin
    aToken := TmafModuleControllerDataTypes(pMC.DataDefs.Items[i]);
    LI := lvToken.Items.Add;
    LI.Caption := IntToStr(aToken.TokenID);
    LI.SubItems.Add(aToken.TokenName);
    LI.Data := aToken;
  end;  //  --  For i := 0 To pMC.DataDefs.Count - 1 Do
  lvToken.Items.EndUpdate;
  // and now filling the combobox
  If cbDataDefinition.Items.Count > 0 Then Sel := cbDataDefinition.Items.Objects[cbDataDefinition.ItemIndex]
                                      Else Sel := nil;
  cbDataDefinition.Items.BeginUpdate;
  cbDataDefinition.Items.Clear;
  cbDataDefinition.Items.AddObject('No Data', nil);
  For i := 0 To pMC.DataDefs.Count - 1 Do begin
    aToken := TmafModuleControllerDataTypes(pMC.DataDefs.Items[i]);
    cbDataDefinition.Items.AddObject(aToken.TokenName, aToken);
  end;
  If cbDataDefinition.Items.IndexOfObject(Sel) > -1 Then
    cbDataDefinition.ItemIndex := cbDataDefinition.Items.IndexOfObject(Sel)
  Else
    cbDataDefinition.ItemIndex := 0;  // "no data" - entry
  cbDataDefinition.Items.EndUpdate;
end;

procedure TfModuleController_Editor.__Fill_ImportExport_DataTokenView;
var i : Integer;
    aToken : TmafModuleControllerDataTypes;
begin
  clbDataDefs.Items.Clear;
  For i := 0 To pMC.DataDefs.Count - 1 Do begin
    aToken := TmafModuleControllerDataTypes(pMC.DataDefs.Items[i]);
    clbDataDefs.Items.AddObject(aToken.TokenName, TObject(aToken));
  end;  //  --  For i := 0 To pMC.DataDefs.Count - 1 Do
end;

procedure TfModuleController_Editor.__Fill_InstallView;
var i : Integer;
    LI : TListItem;
    pData : PmafInstallToken;
    pDR : PDataRecord;
begin
  lvInstall.Items.BeginUpdate;
  lvInstall.Items.Clear;
  For i := 0 To pMC.InstallData.Count - 1 Do begin
    pData := PmafInstallToken(pMC.InstallData.Items[i]);
    LI := lvInstall.Items.Add;
    LI.Caption := IntToStr(pData^.nHookID);
    LI.SubItems.Add(IntToStr(pData^.nSubHookID));
    pDR := __Get_DataRecord(pData^.nSubHookID);
    If Assigned(pDR) Then LI.SubItems.Add(pDR^.Description)
                     Else LI.SubItems.Add('');
    Case pData^.InsertDir Of
      hidFirst     : LI.SubItems.Add('hidFirst');
      hidLast      : LI.SubItems.Add('hidLast');
      hidBefore    : LI.SubItems.Add('hidBefore');
      hidAfter     : LI.SubItems.Add('hidAfter');
      hidOverwrite : LI.SubItems.Add('hidOverwrite');
      Else LI.SubItems.Add('');
    end;
    LI.Checked := (pData^.bActive > 0);
    LI.Data := pData;
  end;
  lvInstall.Items.EndUpdate;
end;

function TfModuleController_Editor.__Get_DataRecord(SubHookID: Integer): PDataRecord;
var i : Integer;
begin
  Result := nil;
  For i := 0 To pMC.Data.Count - 1 Do
    If PDataRecord(pMC.Data.Items[i])^.SubHookID = SubHookID Then begin
      Result := PDataRecord(pMC.Data.Items[i]);
      Break;
    end;
end;

function TfModuleController_Editor.__Get_InstallRecord(SubHookID: Integer): PMAFInstallToken;
var i : Integer;
begin
  Result := nil;
  For i := 0 To pMC.InstallData.Count - 1 Do
    If PMAFInstallToken(pMC.InstallData.Items[i])^.nSubHookID = SubHookID Then begin
      Result := PMAFInstallToken(pMC.InstallData.Items[i]);
      Break;
    end;
end;

procedure TfModuleController_Editor.__Fill_DataTokenDetailsView(aToken: TmafModuleControllerDataTypes);
var i : Integer;
    pData : PRecordDef;
    LI : TListItem;
begin
  lvTokenDetails.Selected := nil;
  If aToken = nil Then begin
    lvTokenDetails.Items.Clear;
    Exit;
  end;  //  --  If aToken = nil Then
  lvTokenDetails.Items.BeginUpdate;
  lvTokenDetails.Items.Clear;
  For i := 0 To aToken.Token.Count - 1 Do begin
    pData := PRecordDef(aToken.Token.Items[i]);
    LI := lvTokenDetails.Items.Add;
    LI.Caption := pData^.sName;
    Case pData^.aType Of
      sdtInteger   : LI.SubItems.Add('Integer');
      sdtDateTime  : LI.SubItems.Add('DateTime');
      sdtInt64     : LI.SubItems.Add('Int64');
      sdtString    : LI.SubItems.Add('String');
      sdtMediaItem : LI.SubItems.Add('MediaItem');
    end;  //  --  Case pData^.aType Of
    LI.Data := pData;
  end;  //  --  For i := 0 To aToken.Token.Count - 1 Do
  lvTokenDetails.Items.EndUpdate;
end;

procedure TfModuleController_Editor.ed_uIDChange(Sender: TObject);
var pToken : PMAFInstallToken;
begin
  If lvInstall.Selected <> nil Then
    If lvInstall.Selected.Data <> nil Then begin
      pToken := PMAFInstallToken(lvInstall.Selected.Data);
      If Sender = ed_uID Then begin
        pToken^.nRelative_uID := StrToIntDef(ed_uID.Text, 0);
        pToken^.uID := pToken^.nRelative_uID; // if we overwrite an UniqueID, we automatically have that uID
        eduID.Text := IntToStr(pToken^.uID);
      end;
      If Sender = eduID Then
        pToken^.uID := StrToIntDef(eduID.Text, 0);
    end;
end;

procedure TfModuleController_Editor.eHookIDExit(Sender: TObject);
var pData : PDataRecord;
    aToken : TmafModuleControllerDataTypes;
    pIT : PmafInstallToken;
begin
  If lvData.Selected <> nil Then begin
    pData := PDataRecord(lvData.Selected.Data);

    pIT := PmafInstallToken(lvData.Selected.SubItems.Objects[0]);
    If pIT = nil Then begin
      ShowMessage('create install token');
      pIT := __Create_InstallToken(iaInsert);
      lvData.Selected.SubItems.Objects[0] := TObject(pIT);
      pMC.InstallData.Add(pIT);
    end;

    pData^.HookID := StrToIntDef(eHookID.Text, 0);
    pData^.SubHookID := StrToIntDef(eSubHookID.Text, 0);
    If cbDataDefinition.Items.Count > 0 Then begin
      If cbDataDefinition.Items.Objects[cbDataDefinition.ItemIndex] <> nil Then
        pData^.DataID := TmafModuleControllerDataTypes(cbDataDefinition.Items.Objects[cbDataDefinition.ItemIndex]).TokenID
      Else
        pData^.DataID := 0;
    end;  //  --  If cbDataDefinition.Items.Count > 0 Then
    Case cbAction.ItemIndex Of
      0 : pData^.Action := daRouteThrough;
      1 : pData^.Action := daCreateWindow;
      2 : pData^.Action := daReturnData;
      3 : pData^.Action := daCreateEnumWindow;
      4 : pData^.Action := daCreateWindowShow;
      5 : pData^.Action := daCreateWindowShowModal;
      6 : pData^.Action := daCreateEnumWindowModal;
    end;  //  --  Case cbAction.ItemIndex Of
    pData^.Description := edDescription.Text;
    pData^.bUseDatablock := cbUseDataBlock.Checked;

    lvData.Selected.Caption := IntToStr(pData^.HookID);
    lvData.Selected.SubItems.Strings[0] := IntToStr(pData^.SubHookID);
    aToken := pMC.GetDataDef(pData^.DataID);
    If aToken <> nil Then lvData.Selected.SubItems.Strings[1] := aToken.TokenName
                     Else lvData.Selected.SubItems.Strings[1] := 'No Data';
    Case pData^.Action Of
      daRouteThrough     : lvData.Selected.SubItems.Strings[2] := 'Route Through';
      daCreateWindow     : lvData.Selected.SubItems.Strings[2] := 'Create Window';
      daReturnData       : lvData.Selected.SubItems.Strings[2] := 'Return Data';
      daCreateEnumWindow : lvData.Selected.SubItems.Strings[2] := 'Create Enum Window';
      daCreateWindowShow : lvData.Selected.SubItems.Strings[2] := 'Create Window Show';
      daCreateWindowShowModal : lvData.Selected.SubItems.Strings[2] := 'Create Window ShowModal';
    end;  //  --  Case pData^.Action Of
    lvData.Selected.SubItems.Strings[3] := pData^.Description;
    lvData.Selected.SubItems.Strings[4] := IntToStr(pData^.uID);

{    pIT := PmafInstallToken(lvData.Selected.SubItems.Objects[0]);
    If pIT = nil Then begin
      pIT := __Create_InstallToken(iaInsert);
      lvData.Selected.SubItems.Objects[0] := TObject(pIT);
      pMC.InstallData.Add(pIT);
    end; }
    pIT^.nHookID := pData^.HookID;
    pIT^.nSubHookID := pData^.SubHookID;
    pIT^.bActive := 1;

    bModified := True;
  end;  //  --  If lvData.Selected <> nil Then
end;

procedure TfModuleController_Editor.cbDataDefinitionChange(Sender: TObject);
var aToken : TmafModuleControllerDataTypes;
    pData : PDataRecord;
begin
  If lvData.Selected = nil Then
    Exit;

  aToken := TmafModuleControllerDataTypes(cbDataDefinition.Items.Objects[cbDataDefinition.ItemIndex]);
  pData := PDataRecord(lvData.Selected.Data);
  __Set_Data(pData, aToken);
  __Fill_DataDefsView(aToken);
  eHookIDExit(Sender);
end;

procedure TfModuleController_Editor.cbInstallActionChange(Sender: TObject);
begin
  Case cbInstallAction.ItemIndex Of
    0 : begin  // add subhook
          cbInstallPosition.Enabled := True;
          ed_uID.Enabled := False;
        end;
    1 : begin
          cbInstallPosition.Enabled := False;
          ed_uID.Enabled := True;
        end;
  end;
end;

procedure TfModuleController_Editor.cbInstallPositionChange(Sender: TObject);
begin
  ed_uID.Enabled := (cbInstallPosition.ItemIndex > 1);
  If lvInstall.Selected <> nil Then begin
    Case cbInstallPosition.ItemIndex Of
     0 : PmafInstallToken(lvInstall.Selected.Data)^.InsertDir := hidLast;
     1 : PmafInstallToken(lvInstall.Selected.Data)^.InsertDir := hidFirst;
     2 : PmafInstallToken(lvInstall.Selected.Data)^.InsertDir := hidBefore;
     3 : PmafInstallToken(lvInstall.Selected.Data)^.InsertDir := hidAfter;
     4 : PmafInstallToken(lvInstall.Selected.Data)^.InsertDir := hidOverwrite;
    end;
    lvInstall.Selected.SubItems.Strings[2] := cbInstallPosition.Text;
    If cbInstallPosition.ItemIndex < 2 Then
      PmafInstallToken(lvInstall.Selected.Data)^.nRelative_uID := 0;
    eduID.Enabled := (cbInstallPosition.ItemIndex <> 4);
  end;
end;

procedure TfModuleController_Editor.cbMediaTypeChange(Sender: TObject);
var pData : PDataToken;
begin
  If lvDataDefs.Selected <> nil Then begin
    lvDataDefs.Selected.SubItems.Strings[0] := FpEditBox.Text;
    pData := PDataToken(lvDataDefs.Selected.Data);
    Case pData^.aType Of
      sdtMediaItem : PmafMediaItem(pData^.pData)^.MediaType := Byte(cbMediaType.ItemIndex + 1);
    end;
    bModified := True;
  end;
end;

procedure TfModuleController_Editor.btnToken_NewEditClick(Sender: TObject);
var EditFrm : TfEditName_Generic;
    aToken : TmafModuleControllerDataTypes;
begin
  EditFrm := TfEditName_Generic.Create(Self);
  EditFrm.Caption := 'Enter a name...';
  Editfrm.Label1.Caption := 'New name :';

  If Sender = btnToken_Edit Then begin
    aToken := TmafModuleControllerDataTypes(lvToken.Selected.Data);
    EditFrm.eHookDesc.Text := aToken.TokenName;
  end else
    aToken := nil;

  If EditFrm.ShowModal = mrOk Then begin
    bModified := True;
    If aToken = nil Then begin
      aToken := TmafModuleControllerDataTypes.Create;
      aToken.TokenID := pMC.DataDefs_HighID + 1;
      pMC.DataDefs.Add(aToken);
    end;
    aToken.TokenName := EditFrm.eHookDesc.Text;
    __Fill_DataTokenView;
    __Fill_ImportExport_DataTokenView;
  end;  //  --  If EditFrm.ShowModal = mrOk Then
  FreeAndNil(EditFrm);
end;

procedure TfModuleController_Editor.btnDeleteInstallTokenClick(Sender: TObject);
var pData : PmafInstallToken;
    idx : Integer;
begin
  If lvInstall.Selected <> nil Then begin
    pData := PmafInstallToken(lvInstall.Selected.Data);
    idx := pMC.InstallData.IndexOf(pData);
    If idx > -1 Then
      pMC.InstallData.Delete(idx);
    __Free_InstallToken(pData);
    __Fill_InstallView;
  end;
end;

procedure TfModuleController_Editor.btnSelectMediaItemClick(Sender: TObject);
var AType: TResourceFileType;
    nID : Cardinal;
    pData : PDataToken;
begin
  nID := 0;
  Case cbMediaType.ItemIndex Of
    0 : aType := rftString;
    1 : aType := rftMedia;
    2 : aType := rftSQL;
    Else aType := rftUnknown;
  end;
  pData := PDataToken(lvDataDefs.Selected.Data);
  If PmafMediaItem(pData^.pData)^.MediaID > 0 Then
    nID := PmafMediaItem(pData^.pData)^.MediaID;
  nID := FpProjectSettings.__ShowResourceEditor(nID, AType);
  PmafMediaItem(pData^.pData)^.MediaID := nID;
  FpEditBox.Text := IntToStr(nID);
  lvDataDefsSelectItem(lvDataDefs, lvDataDefs.Selected, True);
end;

procedure TfModuleController_Editor.btnToken_DeleteClick(Sender: TObject);
var aToken : TmafModuleControllerDataTypes;
    i, nTokenID : Integer;
begin
  aToken := TmafModuleControllerDataTypes(lvToken.Selected.Data);

  // first we remove the data definition from all data records and set those to "no data"
  // although we loose the assigned data.. but what can we do, if the user wants to delete...
  nTokenID := aToken.TokenID;
  For i := 0 To pMC.Data.Count - 1 Do
    If PDataRecord(pMC.Data.Items[i])^.DataID = nTokenID Then
      __Set_Data(PDataRecord(pMC.Data.Items[i]), nil);

  // It can be, that there is a entry selected, that uses the data we're going to delete
  // so we had already updated the data definitions, so nobody uses the one we're deleting
  // and we can assume, that now it's safe to reload the view
  If lvData.Selected <> nil Then
    __Fill_DataView(PDataRecord(lvData.Selected));

  // deleting from the Import/Export List
  For i := clbDataDefs.Items.Count - 1 DownTo 0 Do
    If clbDataDefs.Items.Objects[i] = aToken Then begin
      clbDataDefs.Items.Delete(i);
      Break;
    end;  //  --  If clbDataDefs.Items.Objects[i] = aToken Then


  i := pMC.DataDefs.IndexOf(aToken);
  FreeAndNil(aToken);
  pMC.DataDefs.Delete(i);
  bModified := True;
  __Fill_DataTokenView;
end;

procedure TfModuleController_Editor.lvTokenSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  btnToken_Delete.Enabled := (lvToken.Selected <> nil);
  btnToken_Edit.Enabled := (lvToken.Selected <> nil);
  btnTokenDetails_New.Enabled := (lvToken.Selected <> nil);
  If ((Item <> nil) And (Selected)) Then
    __Fill_DataTokenDetailsView(TmafModuleControllerDataTypes(Item.Data))
  Else
    lvTokenDetails.Items.Clear;
end;

procedure TfModuleController_Editor.ResourceManagerUnknownImageType(Sender: TObject; Extension: string; aStream: TMemoryStream; var Image: TGraphic);
begin
  {$IFDEF PNGImage}
  If Extension = '.png' Then
    {$IFDEF Unicode}
    Image := TPNGimage.Create;
    {$ELSE}
    Image := TPNGObject.Create;
    {$ENDIF}
  {$ENDIF}
end;

procedure TfModuleController_Editor.btnTokenDetails_NewEditClick(Sender: TObject);
var EditFrm : TfEditDataDef;
    aToken : TmafModuleControllerDataTypes;
    pToken : PRecordDef;
    pData : PDataToken;
    i : Integer;
begin
  aToken := TmafModuleControllerDataTypes(lvToken.Selected.Data);
  If aToken = nil Then
    Exit;

  EditFrm := TfEditDataDef.Create(Self);
  If Sender = btnTokenDetails_Edit Then begin
    pToken := PRecordDef(lvTokenDetails.Selected.Data);
    EditFrm.eName.Text := pToken^.sName;
    Case pToken^.aType Of
      sdtInteger   : EditFrm.cbDataType.ItemIndex := 0;
      sdtDateTime  : EditFrm.cbDataType.ItemIndex := 1;
      sdtInt64     : EditFrm.cbDataType.ItemIndex := 2;
      sdtString    : EditFrm.cbDataType.ItemIndex := 3;
      sdtMediaItem : EditFrm.cbDataType.ItemIndex := 4;
    end;  //  --  Case pToken^.aType Of
    EditFrm.pToken^.sName := pToken^.sName;
    EditFrm.pToken^.aType := pToken^.aType;
    EditFrm.cbDataType.Enabled := False;          // atm. we can't change the data type
  end else  //  --  If Sender = btnTokenDetails_Edit Then
    pToken := EditFrm.pToken;
  If EditFrm.ShowModal = mrOk Then begin
    bModified := True;
    If Sender = btnTokenDetails_Edit Then begin
      pToken^.sName := EditFrm.pToken^.sName;
      pToken^.aType := EditFrm.pToken^.aType;
    end else
      aToken.Token.Add(pToken);
    For i := 0 To pMC.Data.Count - 1 Do begin
      If aToken.TokenID = PDataRecord(pMC.Data.Items[i])^.DataID Then begin
        pData := __Create_DataToken(pToken^.aType);
        PDataRecord(pMC.Data.Items[i])^.FpDataTokens.Add(pData);
      end;
    end;

    __Fill_DataTokenDetailsView(aToken);
  end;  //  --  If EditFrm.ShowModal = mrOk Then
  FreeAndNil(EditFrm);
end;

procedure TfModuleController_Editor.btnTokenDetails_DeleteClick(Sender: TObject);
var pToken : PRecordDef;
    aToken : TmafModuleControllerDataTypes;
    i, nPos : Integer;
    pData : PDataToken;
begin
  aToken := TmafModuleControllerDataTypes(lvToken.Selected.Data);
  pToken := PRecordDef(lvTokenDetails.Selected.Data);
  nPos := aToken.Token.IndexOf(pToken);
  aToken.Token.Delete(aToken.Token.IndexOf(pToken));
  __Fill_DataTokenDetailsView(aToken);
  For i := 0 To pMC.Data.Count - 1 Do
    If aToken.TokenID = PDataRecord(pMC.Data.Items[i])^.DataID Then begin
      pData := PDataToken(PDataRecord(pMC.Data.Items[i])^.FpDataTokens.Items[nPos]);
      PDataRecord(pMC.Data.Items[i])^.FpDataTokens.Delete(nPos);
      __Free_DataToken(pData);
    end;
  bModified := True;
end;

procedure TfModuleController_Editor.lvDataColumnClick(Sender: TObject; Column: TListColumn);
begin
  If LastColumnSorted = Column.Index Then begin
    If LastSort = 1 Then LastSort := 2
                    Else LastSort := 1;
  end else begin
    LastSort := 1;
    LastColumnSorted := Column.Index;
  end;
  lvData.AlphaSort;
end;

procedure TfModuleController_Editor.lvDataCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  If LastColumnSorted = 0 Then   // sorting by Caption
    Compare := Not (CompareText(Item1.Caption, Item2.Caption))
  else                           // sorting by SubItems
    Compare := CompareText(Item1.SubItems.Strings[LastColumnSorted-1], Item2.SubItems.Strings[LastColumnSorted-1]);
  If LastSort mod 2 = 0 Then
    Compare := Not Compare;
end;

procedure TfModuleController_Editor.lvDataDefsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var RM : TmafResourceManager;
//    AGraphic : TGraphic;
begin
  RM := nil;
  FpEditBox.Enabled := Selected;
  If Selected Then begin
    FpEditBox.Text := Item.SubItems.Strings[0];
    If PDataToken(Item.Data)^.aType = sdtMediaItem Then begin
      Label12.Visible := True;
      cbMediaType.Visible := True;
      Case PmafMediaItem(PDataToken(Item.Data)^.pData)^.MediaType Of
        1 : cbMediaType.ItemIndex := 0;  // String
        2 : cbMediaType.ItemIndex := 1;  // Picture
        3 : cbMediaType.ItemIndex := 2;  // SQL
        Else begin
               cbMediaType.ItemIndex := 0;  // String
               PmafMediaItem(PDataToken(Item.Data)^.pData)^.MediaType := 1;
             end;
      end;
      btnSelectMediaItem.Visible := True;
      gpPreview.Visible := True;
      If Not bRunMode Then begin
        RM := TmafResourceManager.Create(nil);
        RM.OnUnknownImageType := ResourceManagerUnknownImageType;
        RM.FileResource.ResourceFile := FpProjectSettings.FileResName;
        RM.StringResource.ResourceFile := FpProjectSettings.StringResName;
        RM.SQLResource.ResourceFile := FpProjectSettings.SQLResName;
        ResManPtr := Pointer(RM);
        RC.bLocalMode := True;
      end;
      Image1.Picture.Free;
      Image1.Picture := TPicture.Create;
      lPreviewLabel.Caption := '';
        Case cbMediaType.ItemIndex Of
          0 : begin
                lPreviewLabel.Visible := True;
                Image1.Visible := False;
                lPreviewLabel.Caption := RC.GetString(PmafMediaItem(PDataToken(Item.Data)^.pData)^.MediaID);
              end;
          1 : begin
                lPreviewLabel.Visible := False;
                Image1.Visible := True;
                If RC.GetGraphic(PmafMediaItem(PDataToken(Item.Data)^.pData)^.MediaID, Image1) <> nil Then
                  Image1.Stretch := ((Image1.Picture.Graphic.Width > Image1.Width) And (Image1.Picture.Graphic.Height > Image1.Height));
              end;
          2 : begin
                lPreviewLabel.Visible := True;
                Image1.Visible := False;
                lPreviewLabel.Caption := RC.GetSQL(PmafMediaItem(PDataToken(Item.Data)^.pData)^.MediaID);
              end;
        end;
      If Not bRunMode Then begin
        RM.Free;
        ResManPtr := nil;
      end;
    end else begin
      Label12.Visible := False;
      cbMediaType.Visible := False;
      btnSelectMediaItem.Visible := False;
      gpPreview.Visible := False;
    end;
  end Else
    FpEditBox.Text := '';
end;

procedure TfModuleController_Editor.lvDataSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var pData : PmafInstallToken;
begin
  If ((Selected) And (Item <> nil)) Then begin
    btnDelete.Enabled := True;
    pData := __Get_InstallRecord(PDataRecord(Item.Data)^.SubHookID);
    Item.SubItems.Objects[0] := TObject(pData);  // we hide the install data for that item in the objects of the sub items
    __Load_EditorData(PDataRecord(Item.Data));
  end else
    btnDelete.Enabled := False;
end;

procedure TfModuleController_Editor.lvInstallClick(Sender: TObject);
var i : Integer;
    pIT : PmafInstallToken;
begin
  For i := 0 To lvInstall.Items.Count - 1 Do begin
    pIT := PmafInstallToken(lvInstall.Items.Item[i].Data);
    If lvInstall.Items.Item[i].Checked Then pIT^.bActive := 1
                                       Else pIT^.bActive := 0;
  end;
  bModified := True;
end;

procedure TfModuleController_Editor.lvInstallSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var pToken : PMAFInstallToken;
begin
  ed_uID.Enabled := False;
  If ((Selected) And (Item <> nil)) Then
    If Item.Data <> nil Then begin
      pToken := PMAFInstallToken(Item.Data);
      eduID.Text := IntToStr(pToken^.uID);
      Case pToken^.InsertDir Of
        hidLast      : cbInstallPosition.ItemIndex := 0;
        hidFirst     : cbInstallPosition.ItemIndex := 1;
        hidBefore    : cbInstallPosition.ItemIndex := 2;
        hidAfter     : cbInstallPosition.ItemIndex := 3;
        hidOverwrite : cbInstallPosition.ItemIndex := 4;
      end;
      ed_uID.Text := IntToStr(pToken^.nRelative_uID);
      ed_uID.Enabled := (cbInstallPosition.ItemIndex > 1);
    end;
end;

procedure TfModuleController_Editor.lvTokenDetailsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  btnTokenDetails_Delete.Enabled := (lvTokenDetails.Selected <> nil);
  btnTokenDetails_Edit.Enabled := (lvTokenDetails.Selected <> nil);
end;

procedure TfModuleController_Editor.btnNewClick(Sender: TObject);
var pData : PDataRecord;
begin
  pData := __Create_DataRecord;
  pMC.Data.Add(pData);
  __Fill_DataView(pData);
  bModified := True;
end;

procedure TfModuleController_Editor.__Synchronize_With_XML;
var XML_Data : TList;
    i, j : Integer;
    pDR : PDataRecord;
    pID, pID2 : PMAFInstallToken;
//    S : String;
begin
  {$IFDEF CodeSite}CodeSite.TraceMethod( Self, '__Synchronize_With_XML' );{$ENDIF}
  If bRunMode Then
    Exit;
  {$IFDEF Package_Build}
  If Not FpProjectSettings.EnableXMLSynchro Then
    Exit;
  XML.FileName := FpProjectSettings.XMLName;
  {$ELSE}
  XML.FileName := 'D:\Delphi\TCA\TCA_DFT.xml';
  {$ENDIF}
  If XML.FileName <> '' Then begin
    XML.Active := True;
    XML_Data := TList.Create;
    __EnumInstallModuleFunctions(XML, pMC.ModuleInfo.ModuleID, XML_Data);
//    __EnumRegisteredModuleFunctions(XML, pMC.ModuleInfo.ModuleID, XML_Data);

    j := 0;
    {$IFDEF CodeSite} CodeSite.Send(csmLevel4, 'XML_Data.Count', XML_Data.Count); {$ENDIF}
    For i := XML_Data.Count - 1 DownTo 0 Do begin
      pID := PMAFInstallToken(XML_Data.Items[i]);
      {$IFDEF CodeSite} CodeSite.Send(csmLevel4, 'SubHookId', pID^.nSubHookID); {$ENDIF}
      pDR := __Get_DataRecord(pID^.nSubHookID);
      If pDR = nil Then begin
        pDR := __Create_DataRecord;
        pDR^.uID := pID^.uID;
        pDR^.HookID := pID^.nHookID;
        pDR^.SubHookID := pID^.nSubHookID;
        pDR^.Description := String(pID^.sDescription);
        pMC.Data.Add(pDR);  // we add it
        Inc(j);
      end else begin
        pDR^.uID := pID^.uID;
        pDR^.HookID := pID^.nHookID;
        pDR^.Description := String(pID^.sDescription);
      end;
      pID2 := __Get_InstallRecord(pID^.nSubHookID);
      If pID2 <> nil Then begin                   // if we have the record..
        pID2^.nCodeGroupID := pID^.nCodeGroupID;  // we update the data with the ones from the DFT
        pID2^.uID := pID^.uID;
        pID2^.nHookID := pID^.nHookID;
        pID2^.bActive := pID^.bActive;
        __Free_InstallToken(pID);
      end else
        pMC.InstallData.Add(pID);
//      XML_Data.Delete(i);
    end;  //  --  For i := XML_Data.Count - 1 DownTo 0 Do
    XML_Data.Clear;
    XML_Data.Free;
    If j > 0 Then begin
      MessageDlg('Importing ' + IntToStr(j) + ' Hooks from XMLSynchro...', mtInformation, [mbOk], 0);
      __Fill_DataView;   // we rebuild the view
      __Fill_InstallView;
      bModified := True;
      pMC.__ReCalc_uID;
    end;

{      For j := 0 to lvData.Items.Count - 1 Do begin
        pDR := PDataRecord(lvData.Items.Item[j].Data);
        If ((pDR^.HookID = pID^.nHookID) And (pDR^.SubHookID = pID^.nSubHookID)) Then begin
          S := String(pID^.sDescription);
          // check if the description changed and the DFT description is <> ''
          If ((pDR^.Description <> S) And (S <> '')) Then begin
            pDR^.Description := S;       // we take the one from the DFT
            bModified := True;
          end;
          __Free_InstallToken(pID);
          XML_Data.Delete(i);
          Break;
        end;  //  --  If ((pDR^.HookID = pSH^.HookID) And (pDR^.SubHookID = pSH^.SubHookID)) Then
      end;  //  --  For j := 0 to lvData.Items.Count - 1 Do
    end;  //  --  For i := XML_Data.Count - 1 DownTo 0 Do
    If XML_Data.Count > 0 Then begin
      bModified := True;
      MessageDlg('Importing ' + IntToStr(XML_Data.Count) + ' Hooks from XMLSynchro...', mtInformation, [mbOk], 0);
      While XML_Data.Count > 0 Do begin
        pDR := __Create_DataRecord;
        pDR^.HookID := PERPInstallToken(XML_Data.Items[0])^.nHookID;
        pDR^.SubHookID := PERPInstallToken(XML_Data.Items[0])^.nSubHookID;
        pDR^.Description := String(PERPInstallToken(XML_Data.Items[0])^.sDescription);
        pMC.Data.Add(pDR);  // we add it
        pMC.InstallData.Add(XML_Data.Items[0]);
{        pDR := PDataRecord(XML_Data.Items[0]);
        pID := __Create_InstallToken(iaInsert);
        pID^.uID := pDR^. }
{        XML_Data.Delete(0);               // .. and remove it it from that list
      end;  //  --  While XML_Data.Count > 0 Do
      __Fill_DataView;   // we rebuild the view only if there were new items added
      __Fill_InstallView;
    end;  //  --  If XML_Data.Count > 0 Then       }
  end;  //  --  If XML.FileName <> '' Then
end;

procedure TfModuleController_Editor.btnDataDef_ExportClick(Sender: TObject);
var aNode, bNode, cNode : IXMLNode;
    i, j, nCount : Integer;
    aToken : TmafModuleControllerDataTypes;
begin
  If SD.Execute{$IFDEF D9+}(WindowHandle){$ENDIF} Then begin
    nCount := 0;
    XML.Active := True;
    XML.ChildNodes.Clear;
    aNode := XML.AddChild('DataDefinitions');
    For i := 0 To clbDataDefs.Items.Count - 1 Do begin
      If Not clbDataDefs.Checked[i] Then
        Continue;
      bNode := aNode.AddChild('DataDef');
      aToken := TMafModuleControllerDataTypes(clbDataDefs.Items.Objects[i]);
      bNode.Attributes['ID'] := aToken.TokenID;
      bNode.Attributes['Name'] := aToken.TokenName;
      For j := 0 To aToken.Token.Count - 1 Do begin
        cNode := bNode.AddChild('Data');
        cNode.Attributes['TokenName'] := PRecordDef(aToken.Token.Items[j])^.sName;
        cNode.Attributes['TokenValue'] := PRecordDef(aToken.Token.Items[j])^.aType;
      end;  //  --  For j := 0 To aToken.Token.Count - 1 Do
      Inc(nCount);
    end;  //  --  For i := 0 To pMC.DataDefs.Count - 1 Do
    XML.SaveToFile(SD.FileName);
    MessageDlg(IntToStr(nCount) + ' data definition(s) exported.', mtInformation, [mbOk], 0);
  end;  //  --  If SD.Execute(WindowHandle) Then
end;

procedure TfModuleController_Editor.btnDataDef_ImportClick(Sender: TObject);
var aNode, bNode : IXMLNode;
    i, j, nCount : Integer;
    aToken : TMafModuleControllerDataTypes;
    S : String;
    bFound : Boolean;
    pRD : PRecordDef;
begin
  If OD.Execute{$IFDEF D9+}(WindowHandle){$ENDIF} Then begin
    nCount := 0;
    XML.FileName := OD.FileName;
    XML.Active := True;
    For i := 0 To XML.DocumentElement.ChildNodes.Count - 1 Do begin
      aNode := XML.DocumentElement.ChildNodes.Nodes[i];
      S := aNode.Attributes['Name'];
      bFound := False;
      For j := 0 To clbDataDefs.Items.Count - 1 Do
        If clbDataDefs.Items.Strings[j] = S Then begin
          bFound := True;
          Break;
        end;  //  --  If clbDataDefs.Items.Strings[j] = S Then
      If Not bFound Then begin
        aToken := TMafModuleControllerDataTypes.Create;
        aToken.TokenID := pMC.DataDefs_HighID + 1;  // wen cannot use the ID from the XML as it could be already in use
        aToken.TokenName := S;
        For j := 0 To aNode.ChildNodes.Count - 1 Do begin
          bNode := aNode.ChildNodes.Nodes[j];
          pRD := __Create_RecordDef;
          pRD^.sName := bNode.Attributes['TokenName'];
          pRD^.aType := bNode.Attributes['TokenValue'];
          aToken.Token.Add(pRD);
        end;  //  --  For j := 0 To aNode.ChildNodes.Count - 1 Do
        pMC.DataDefs.Add(aToken);
        Inc(nCount);
      end;  //  --  If Not bFound Then
    end;  //  --  For i := 0 To XML.DocumentElement.ChildNodes.Count - 1 Do
    MessageDlg(IntToStr(nCount) + ' data definition(s) imported.', mtInformation, [mbOk], 0);
    XML.Active := False;
    If nCount > 0 Then begin
      __Fill_ImportExport_DataTokenView;
      __Fill_DataTokenView;
    end;
  end;  //  --  If OD.Execute(WindowHandle) Then
end;

procedure TfModuleController_Editor.btnDeleteClick(Sender: TObject);
var pData : PDataRecord;
    pID : PMAFInstallToken;
    i, idx : Integer;
begin
  If lvData.Selected <> nil Then begin
    pData := PDataRecord(lvData.Selected.Data);
    // first the InstallData
    For i := pMC.InstallData.Count - 1 DownTo 0 Do begin
      pID := PmafInstallToken(pMC.InstallData.Items[i]);
      If pID^.nSubHookID = pData^.SubHookID Then begin
        pMC.InstallData.Delete(i);
        __Free_InstallToken(pID);
        Break;
      end;
    end;
    // and now the real data
    idx := pMC.Data.IndexOf(pData);
    If idx > -1 Then
      pMC.Data.Delete(idx);
    __Free_DataRecord(pData);
    // and now the ListView item
    idx := lvData.Items.IndexOf(lvData.Selected);
    lvData.Selected := nil;
    If idx > -1 Then
      lvData.Items.Delete(idx);
  end;
end;

end.

