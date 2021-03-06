{*******************************************************************************
Name         : uMAF_DataStorage.pas
Coding by    : Helge Lange
Copyright    : (c)opyright 2007-2012 by Helge Lange
Info         : HelgeLange@maf-components.com
Website      : http://www.maf-components.com
Date         : 26.03.2007
Last Update  : 07.03.2017
Version      : 1.0.008
Purpose      : load/save of generic data
Last Changes :

1.0.008 (07.03.2017) -----------------------------------------------------------
- [ADD] In __RegisterAPI a bolean is used to determine if the API was already
        registered or not
1.0.007 (26.01.2012) -----------------------------------------------------------
- [ADD] now we can delete streams :)
1.0.006 (30.07.2010)------------------------------------------------------------
- [ADD] new class TmafDataStorageVarController, which can store global variables
        into the associated TmafDataStorage
1.0.005 (05.10.2009)------------------------------------------------------------
- [ADD] 2 events added, BeforeWrite and AfterRead, that will give access to the
        datastreams just read or about to be written, so that they can be
        manipulated with compression/decompression and/or encryption/decryption
1.0.004 (24.07.2009)------------------------------------------------------------
- [CHG] changed TmafDataStorage to inherit from TmafCustomManagerComponent
        therefore the obsolet HookAccessContainer stuff was deleted and we now
        use the ModuleController defined in the new CustomClass
1.0.003 (03.11.2008) -----------------------------------------------------------
- [CHG] ReadTemplate now sets Stream.Position to 0 after the stream is loaded
1.0.002 (03.10.2008) -----------------------------------------------------------
- [ADD] connection to HookAccessContainer to be in line with all other manager
        components
1.0.001 (26.03.2007) -----------------------------------------------------------
- initial version
*******************************************************************************}
unit uMAF_DataStorage;

interface

uses Windows, Classes, SysUtils, Dialogs,
     // Modular Application Framework Components units
     uMAF_Globals, uMAF_Tools, uMAF_Core, uMAF_CustomBaseDB, uMAF_VarController;

Type TDataStreamAction = procedure(Sender: TObject; DataStream: TStream) Of Object;

     TmafDataStorage = class(TmafCustomManagerComponent)
     private
       FsTableName : String;
       FnPrimaryID : Integer;
       FsCategory  : String;
       FsTemplateName : String;
       FpBaseDB : TmafCustomBaseDB;
       FpDataStream : TMemoryStream;
       FpTemplateNameList : TStringList;
       FAction : TDataStorageAction;
       FBeforeWrite,
       FAfterRead    : TDataStreamAction;
       FbAPIRegistered : Boolean;
       function __CheckRequirements: Boolean; // for designtime use
       function __CheckQueryToken(pQuery: PDataStorageQuery): Boolean;
       procedure __SetAction(const Value: TDataStorageAction);
       procedure __SetBaseDB(const Value: TmafCustomBaseDB);
       procedure __FreeQueryNames(pData: Pointer);
     protected
       procedure __RegisterAPI; override;
       procedure __OnEvent(SubHookID: Integer; QHS: pQHS; UserParam: Pointer; var ErrCode: Integer); override;
       function Read_DataStream(pQuery: PDataStorageQuery; bReadData: Boolean = True): Integer;
       function Write_DataStream(pQuery: PDataStorageQuery): Integer;
       function Delete_DataStream(pQuery: PDataStorageQuery): Integer;
     public
       constructor Create(AOwner: TComponent); override;
       destructor Destroy; override;
       procedure Loaded; override;
       function Query(pQueryToken: PDataStorageQuery): Integer;
     published
       property Action : TDataStorageAction read FAction write __SetAction stored False;
       property TableName : String read FsTableName write FsTableName;
       property BaseDB : TmafCustomBaseDB read FpBaseDB write __SetBaseDB;
       // display properties
       property PrimaryID : Integer read FnPrimaryID write FnPrimaryID stored False;
       property Category : String read FsCategory write FsCategory stored False;
       property DataName : String read FsTemplateName write FsTemplateName stored False;

       property BeforeWrite : TDataStreamAction read FBeforeWrite write FBeforeWrite;
       property AfterRead : TDataStreamAction read FAfterRead write FAfterRead;
     end;

     TmafDataStorageVarController = class(TmafCustomVarController)
     private
       FpDataStorageHandler : TmafDataStorage;
     public
     published
       property DataStorage : TmafDataStorage read FpDataStorageHandler write FpDataStorageHandler;
     end;

implementation

{$IFDEF Tracer} uses uMAF_Tracer; {$ENDIF}

const MAX_EVENTS = 4;

var ManagerEvents : array[1..MAX_EVENTS] of Integer = (
      HM_LOAD_TEMPLATE,
      HM_SAVE_TEMPLATE,
      HM_GET_TEMPLATE_ID,
      HM_DELETE_TEMPLATE);


{ TmafTemplate }

constructor TmafDataStorage.Create(AOwner: TComponent);
begin
  inherited;
  FbAPIRegistered := False;
  ManagerType := MT_TEMPLATE_MANAGER;
  FsTableName := 'MAF_DataStorage';
  FnPrimaryID := 0;
  FsCategory  := '';
  FsTemplateName := '';
  FpDataStream := TMemoryStream.Create;
  FpTemplateNameList := TStringList.Create;
  ManagerOptions := [];
end;

destructor TmafDataStorage.Destroy;
begin
  FreeAndNil(FpTemplateNameList);
  FreeAndNil(FpDataStream);
  inherited;
end;

procedure TmafDataStorage.Loaded;
begin
  inherited;
  __RegisterAPI;
end;

function TmafDataStorage.__CheckQueryToken(pQuery: PDataStorageQuery): Boolean;
begin
  Result := (pQuery^.aObj <> nil);
  If Result Then
    Case pQuery^.Action Of
      taRead,
      taWrite     : Result := ((pQuery^.nID > 0) Or ((pQuery^.sCategory <> '') And (pQuery^.sName <> '')));
      taListNames : Result := (pQuery^.sCategory <> EmptyStr);
      taDelete,
      taGetID     : Result := ((pQuery^.sCategory <> '') And (pQuery^.sName <> ''));
    end;  //  --  Case pQuery^.Action Of
end; // __CheckQueryToken

function TmafDataStorage.__CheckRequirements: Boolean;
begin
  Result := ((FpBaseDB <> nil) And
             (TableName <> ''));
  // ok, we have the basics, now let's see, if we could find a single template
  If Result Then
    Result := ((FnPrimaryID > 0) Or ((FsCategory <> '') And (FsTemplateName <> '')));
  If Not Result Then
    Raise EComponentError.Create('TmafDataStorage: Cannot read data (ID='+IntToStr(FnPrimaryID)+', Category="'+FsCategory+'", Name="'+FsTemplateName+'") without proper parameter from Table "'+FsTableName+'" !');
end;

procedure TmafDataStorage.__OnEvent(SubHookID: Integer; QHS: pQHS; UserParam: Pointer; var ErrCode: Integer);
begin
  Case SubHookID Of
    HM_DELETE_TEMPLATE,
    HM_GET_TEMPLATE_ID,
    HM_LOAD_TEMPLATE,
    HM_SAVE_TEMPLATE    : ErrCode := Query(PDataStorageQuery(UserParam));
    Else inherited __OnEvent(SubHookID, QHS, UserParam, ErrCode);
  end;  //  --  Case SubHookID Of
end;

procedure TmafDataStorage.__RegisterAPI;
var i : Integer;
begin
  inherited;
  if Not FbAPIRegistered then begin
    If Assigned(ModuleController) Then begin
      For i := 1 To MAX_EVENTS Do
        ModuleController.RegisterSubHookEvent(ManagerEvents[i], __OnEvent);
      FbAPIRegistered := True;
    end;
  end;
end;

procedure TmafDataStorage.__SetAction(const Value: TDataStorageAction);
begin
  FAction := Value;
  If __CheckRequirements Then begin

  end;
end;

function TmafDataStorage.Query(pQueryToken: PDataStorageQuery): Integer;
begin
  {$IFDEF Tracer}
    MAFTracer.Enter('TmafDataStorage.Query');
  {$ENDIF}
  // Queries made through method TmafDataStorage.Query won't fire Events !
  If Not __CheckQueryToken(pQueryToken) Then begin
    Result := ERR_PARAM_FAILURE;
//    SHowMessage('error in QueryToken');
    {$IFDEF Tracer}
    MAFTracer.Leave;
    {$ENDIF}
    Exit;
  end;  //  --  If Not __CheckQueryToken(pQuery) Then

  {$IFDEF Tracer}
    MAFTracer.CheckPoint('pQueryToken ok');
  {$ENDIF}

  If ((FpBaseDB = nil) Or (FsTableName = EmptyStr)) Then begin
    Result := ERR_COMPONENT_SETUP_FAILURE;
//    SHowMessage('error in comp setup');
    {$IFDEF Tracer}
    MAFTracer.Leave;
    {$ENDIF}
    Exit;
  end;
  {$IFDEF Tracer}
    MAFTracer.CheckPoint('Parameter ok');
  {$ENDIF}
  // now we should have everything, let's have some action
  Case pQueryToken^.Action Of
    taRead  : Result := Read_DataStream(pQueryToken);
    taWrite : Result := Write_DataStream(pQueryToken);
    taGetID : Result := Read_DataStream(pQueryToken, False);
    taDelete: Result := Delete_DataStream(pQueryToken);
    Else Result := ERR_UNKNOWN_ERROR;
  end;  //  --  Case pQueryToken^.Action Of
  pQueryToken^.pFreeMemFunc := __FreeQueryNames;
  {$IFDEF Tracer}
    MAFTracer.Leave;
  {$ENDIF}
end;

procedure TmafDataStorage.__FreeQueryNames(pData: Pointer);
begin
  If Not Assigned(pData) Then
    Exit;
  If PDataStorageQuery(pData)^.sCategory <> nil Then
    FreePChar(PDataStorageQuery(pData)^.sCategory);
  If PDataStorageQuery(pData)^.sName <> nil Then
    FreePChar(PDataStorageQuery(pData)^.sName);
  PDataStorageQuery(pData)^.pFreeMemFunc := nil;
end;

function TmafDataStorage.Read_DataStream(pQuery: PDataStorageQuery; bReadData: Boolean): Integer;
var nID : Integer;
    sCategory, sName : String;
begin
  nID := pQuery^.nID;
  sCategory := String(pQuery^.sCategory);
  sName := String(pQuery^.sName);
  Result := FpBaseDB.ReadTemplate(TMemoryStream(pQuery^.aObj), nID, FsTableName, sCategory, sName, bReadData);
  If ((bReadData) And (Result = ERR_NO_ERROR)) Then
    If Assigned(FAfterRead) Then
      FAfterRead(Self, TStream(pQuery^.aObj));
  If Result = ERR_NO_ERROR Then begin
    pQuery^.nID := nID;
    If Assigned(pQuery^.pFreeMemFunc) Then
      pQuery^.pFreeMemFunc(pQuery);
    __Apply_DataStorageNames(sCategory, sName, pQuery);
  end;  //  --  If Result = ERR_NO_ERROR Then
  TMemoryStream(pQuery^.aObj).Position := 0;
end;

function TmafDataStorage.Write_DataStream(pQuery: PDataStorageQuery): Integer;
var nID : Integer;
    sCategory, sName : String;
begin
  nID := pQuery^.nID;
  sCategory := pQuery^.sCategory;
  sName := pQuery^.sName;
  If Assigned(FBeforeWrite) Then
    FBeforeWrite(Self, TStream(pQuery^.aObj));
  Result := FpBaseDB.WriteTemplate(TMemoryStream(pQuery^.aObj), nID, FsTableName, sCategory, sName);
  If Result = ERR_NO_ERROR Then begin
    pQuery^.nID := nID;
    If Assigned(pQuery^.pFreeMemFunc) Then
      pQuery^.pFreeMemFunc(pQuery);
    __Apply_DataStorageNames(sCategory, sName, pQuery);
  end;  //  --  If Result = ERR_NO_ERROR Then
end;

function TmafDataStorage.Delete_DataStream(pQuery: PDataStorageQuery): Integer;
var sCategory, sName : String;
begin
  sCategory := pQuery^.sCategory;
  sName := pQuery^.sName;
  FpBaseDB.DeleteTemplate(FsTableName, sCategory, sName);
  pQuery^.pFreeMemFunc(pQuery);
  Result := ERR_NO_ERROR;
end;

procedure TmafDataStorage.__SetBaseDB(const Value: TmafCustomBaseDB);
begin
  FpBaseDB := Value;
  If Assigned(FpBaseDB) Then begin
    FpBaseDB.DataStorageTable := FsTableName;
  end;
end;

end.
