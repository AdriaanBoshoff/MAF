object fModuleController_Editor: TfModuleController_Editor
  Left = 0
  Top = 0
  Caption = 'Module Controller Editor'
  ClientHeight = 443
  ClientWidth = 727
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 727
    Height = 443
    ActivePage = tsModuleController
    Align = alClient
    TabOrder = 0
    object tsModuleController: TTabSheet
      Caption = 'Module Controller'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lvData: TListView
        Left = 0
        Top = 0
        Width = 719
        Height = 186
        Align = alClient
        Columns = <
          item
            Caption = 'HookID'
            Width = 70
          end
          item
            Caption = 'SubHookID'
            Width = 70
          end
          item
            Caption = 'Data Definition'
            Width = 140
          end
          item
            Caption = 'Action'
            Width = 120
          end
          item
            Caption = 'Description'
            Width = 240
          end
          item
            Caption = 'uID'
            Width = 60
          end>
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnColumnClick = lvDataColumnClick
        OnCompare = lvDataCompare
        OnSelectItem = lvDataSelectItem
      end
      object PageControl2: TPageControl
        Left = 0
        Top = 186
        Width = 719
        Height = 229
        ActivePage = TabSheet1
        Align = alBottom
        TabOrder = 1
        object TabSheet1: TTabSheet
          Caption = 'Hook Data'
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Label9: TLabel
            Left = 11
            Top = 14
            Width = 60
            Height = 13
            Caption = 'Description :'
          end
          object Label5: TLabel
            Left = 359
            Top = 57
            Width = 69
            Height = 13
            Caption = 'Data Defnition'
          end
          object btnDelete: TButton
            Left = 512
            Top = 160
            Width = 129
            Height = 25
            Caption = 'Delete'
            Enabled = False
            TabOrder = 0
            OnClick = btnDeleteClick
          end
          object btnNew: TButton
            Left = 512
            Top = 123
            Width = 129
            Height = 25
            Caption = 'New'
            TabOrder = 1
            OnClick = btnNewClick
          end
          object edDescription: TEdit
            Left = 77
            Top = 12
            Width = 564
            Height = 21
            TabOrder = 2
            OnExit = eHookIDExit
          end
          object GroupBox3: TGroupBox
            Left = 11
            Top = 48
            Width = 334
            Height = 137
            Caption = ' Hook Data '
            TabOrder = 3
            object Label3: TLabel
              Left = 20
              Top = 28
              Width = 35
              Height = 13
              Caption = 'HookID'
            end
            object Label4: TLabel
              Left = 20
              Top = 52
              Width = 53
              Height = 13
              Caption = 'SubHookID'
            end
            object Label6: TLabel
              Left = 20
              Top = 78
              Width = 30
              Height = 13
              Caption = 'Action'
            end
            object cbAction: TComboBox
              Left = 144
              Top = 74
              Width = 174
              Height = 21
              Style = csDropDownList
              TabOrder = 0
              OnChange = eHookIDExit
              Items.Strings = (
                'Route Through'
                'Create Window'
                'Return Data'
                'Create Enum Window'
                'CreateWindowShow'
                'CreateWindowShowModal'
                'Create Enum Window Modal')
            end
            object eSubHookID: TEdit
              Left = 144
              Top = 47
              Width = 174
              Height = 21
              TabOrder = 1
              OnExit = eHookIDExit
            end
            object eHookID: TEdit
              Left = 144
              Top = 20
              Width = 174
              Height = 21
              TabOrder = 2
              OnExit = eHookIDExit
            end
            object cbUseDataBlock: TCheckBox
              Left = 20
              Top = 101
              Width = 297
              Height = 17
              Hint = 
                'If this Option is checked, the Data Definition will be added in ' +
                'QHS^.pDataBlock when a SubHook is called'
              Alignment = taLeftJustify
              Caption = 'Add Data Definition to QueryHandlerStruct on call'
              TabOrder = 3
              OnExit = eHookIDExit
            end
          end
          object cbDataDefinition: TComboBox
            Left = 359
            Top = 76
            Width = 282
            Height = 21
            Style = csDropDownList
            TabOrder = 4
            OnChange = cbDataDefinitionChange
          end
        end
        object tsDataDefs: TTabSheet
          Caption = 'Data Definition'
          ImageIndex = 1
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Label8: TLabel
            Left = 355
            Top = 40
            Width = 47
            Height = 13
            Caption = 'Edit Value'
          end
          object Label7: TLabel
            Left = 15
            Top = 16
            Width = 106
            Height = 13
            Caption = 'Data Definition Details'
          end
          object Label12: TLabel
            Left = 355
            Top = 76
            Width = 53
            Height = 13
            Caption = 'Media type'
            Visible = False
          end
          object FpEditBox: TEdit
            Left = 419
            Top = 35
            Width = 218
            Height = 21
            TabOrder = 0
            OnChange = FpEditBoxChange
          end
          object lvDataDefs: TListView
            Left = 15
            Top = 35
            Width = 322
            Height = 154
            Columns = <
              item
                Caption = 'Name'
                Width = 120
              end
              item
                Caption = 'Value'
                Width = 180
              end>
            TabOrder = 1
            ViewStyle = vsReport
            OnSelectItem = lvDataDefsSelectItem
          end
          object cbMediaType: TComboBox
            Left = 419
            Top = 70
            Width = 218
            Height = 21
            Style = csDropDownList
            ItemIndex = 0
            TabOrder = 2
            Text = 'String'
            Visible = False
            OnChange = cbMediaTypeChange
            Items.Strings = (
              'String'
              'Picture'
              'SQL')
          end
          object gpPreview: TGroupBox
            Left = 419
            Top = 104
            Width = 218
            Height = 85
            Caption = 'Preview'
            TabOrder = 3
            Visible = False
            object lPreviewLabel: TLabel
              Left = 12
              Top = 24
              Width = 203
              Height = 53
              AutoSize = False
              WordWrap = True
            end
            object Image1: TImage
              Left = 144
              Top = 15
              Width = 64
              Height = 64
              Transparent = True
            end
          end
          object btnSelectMediaItem: TButton
            Left = 356
            Top = 164
            Width = 46
            Height = 25
            Caption = 'Select'
            TabOrder = 4
            Visible = False
            OnClick = btnSelectMediaItemClick
          end
        end
      end
    end
    object tsTokenEditor: TTabSheet
      Caption = 'Data Definitions Editor'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label1: TLabel
        Left = 3
        Top = 5
        Width = 29
        Height = 13
        Caption = 'Token'
      end
      object Label2: TLabel
        Left = 3
        Top = 213
        Width = 63
        Height = 13
        Caption = 'Token details'
      end
      object lvToken: TListView
        Left = 3
        Top = 24
        Width = 534
        Height = 177
        Columns = <
          item
            Caption = 'ID'
            Width = 70
          end
          item
            Caption = 'Name'
            Width = 300
          end>
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = lvTokenSelectItem
      end
      object lvTokenDetails: TListView
        Left = 3
        Top = 232
        Width = 534
        Height = 137
        Columns = <
          item
            Caption = 'Name'
            Width = 250
          end
          item
            Caption = 'Value'
            Width = 200
          end>
        TabOrder = 1
        ViewStyle = vsReport
        OnSelectItem = lvTokenDetailsSelectItem
      end
      object btnToken_Delete: TButton
        Left = 560
        Top = 176
        Width = 99
        Height = 25
        Caption = 'Delete'
        Enabled = False
        TabOrder = 2
        OnClick = btnToken_DeleteClick
      end
      object btnToken_Edit: TButton
        Left = 560
        Top = 145
        Width = 99
        Height = 25
        Caption = 'Edit'
        Enabled = False
        TabOrder = 3
        OnClick = btnToken_NewEditClick
      end
      object btnToken_New: TButton
        Left = 560
        Top = 112
        Width = 99
        Height = 25
        Caption = 'New'
        TabOrder = 4
        OnClick = btnToken_NewEditClick
      end
      object btnTokenDetails_Delete: TButton
        Left = 560
        Top = 344
        Width = 99
        Height = 25
        Caption = 'Delete'
        Enabled = False
        TabOrder = 5
        OnClick = btnTokenDetails_DeleteClick
      end
      object btnTokenDetails_Edit: TButton
        Left = 560
        Top = 313
        Width = 99
        Height = 25
        Caption = 'Edit'
        Enabled = False
        TabOrder = 6
        OnClick = btnTokenDetails_NewEditClick
      end
      object btnTokenDetails_New: TButton
        Left = 560
        Top = 282
        Width = 99
        Height = 25
        Caption = 'New'
        TabOrder = 7
        OnClick = btnTokenDetails_NewEditClick
      end
    end
    object tsImportExport: TTabSheet
      Caption = 'Import / Export'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBox1: TGroupBox
        Left = 16
        Top = 16
        Width = 249
        Height = 233
        Caption = ' Data Definitions '
        TabOrder = 0
        object clbDataDefs: TCheckListBox
          Left = 16
          Top = 24
          Width = 217
          Height = 161
          ItemHeight = 13
          TabOrder = 0
        end
        object btnDataDef_Import: TButton
          Left = 16
          Top = 191
          Width = 106
          Height = 25
          Caption = 'Import XML'
          TabOrder = 1
          OnClick = btnDataDef_ImportClick
        end
        object btnDataDef_Export: TButton
          Left = 128
          Top = 191
          Width = 105
          Height = 25
          Caption = 'Export XML'
          TabOrder = 2
          OnClick = btnDataDef_ExportClick
        end
      end
    end
    object tsModuleInstall: TTabSheet
      Caption = 'Module Install'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lvInstall: TListView
        Left = 3
        Top = 16
        Width = 670
        Height = 201
        Checkboxes = True
        Columns = <
          item
            Caption = 'HookID'
            Width = 70
          end
          item
            Caption = 'SubHookID'
            Width = 70
          end
          item
            Caption = 'Description'
            Width = 350
          end
          item
            Caption = 'Install Position'
            Width = 150
          end>
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnClick = lvInstallClick
        OnSelectItem = lvInstallSelectItem
      end
      object GroupBox2: TGroupBox
        Left = 3
        Top = 232
        Width = 430
        Height = 177
        Caption = ' Install Options '
        TabOrder = 1
        object Label10: TLabel
          Left = 13
          Top = 108
          Width = 69
          Height = 13
          Caption = 'Install Position'
        end
        object Label11: TLabel
          Left = 13
          Top = 144
          Width = 112
          Height = 13
          Caption = 'Relative unique HookID'
        end
        object Label13: TLabel
          Left = 13
          Top = 33
          Width = 62
          Height = 13
          Caption = 'Install Action'
        end
        object Label14: TLabel
          Left = 13
          Top = 72
          Width = 47
          Height = 13
          Caption = 'Unique ID'
        end
        object cbInstallPosition: TComboBox
          Left = 263
          Top = 104
          Width = 145
          Height = 21
          Style = csDropDownList
          ItemIndex = 0
          TabOrder = 0
          Text = 'hidLast'
          OnChange = cbInstallPositionChange
          Items.Strings = (
            'hidLast'
            'hidFirst'
            'hidBefore'
            'hidAfter'
            'hidOverwrite')
        end
        object ed_uID: TEdit
          Left = 263
          Top = 140
          Width = 145
          Height = 21
          TabOrder = 1
          OnChange = ed_uIDChange
        end
        object cbInstallAction: TComboBox
          Left = 263
          Top = 28
          Width = 145
          Height = 21
          Style = csDropDownList
          Enabled = False
          ItemIndex = 0
          TabOrder = 2
          Text = 'Add SubHook'
          OnChange = cbInstallActionChange
          Items.Strings = (
            'Add SubHook'
            'Delete SubHook')
        end
        object eduID: TEdit
          Left = 263
          Top = 68
          Width = 145
          Height = 21
          TabOrder = 3
          OnChange = ed_uIDChange
        end
      end
      object btnDeleteInstallToken: TButton
        Left = 520
        Top = 352
        Width = 139
        Height = 25
        Caption = 'Delete'
        TabOrder = 2
        OnClick = btnDeleteInstallTokenClick
      end
      object Button2: TButton
        Left = 520
        Top = 312
        Width = 139
        Height = 25
        Caption = 'Add'
        Enabled = False
        TabOrder = 3
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Statistik / Info'
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBox4: TGroupBox
        Left = 16
        Top = 16
        Width = 357
        Height = 101
        Caption = ' SubHook Statistik '
        TabOrder = 0
        object Label15: TLabel
          Left = 16
          Top = 24
          Width = 47
          Height = 13
          Caption = 'SubHooks'
        end
        object Label16: TLabel
          Left = 16
          Top = 56
          Width = 43
          Height = 13
          Caption = 'Next uID'
        end
        object Label17: TLabel
          Left = 308
          Top = 24
          Width = 37
          Height = 13
          Caption = 'Label17'
        end
        object Label18: TLabel
          Left = 308
          Top = 56
          Width = 37
          Height = 13
          Caption = 'Label18'
        end
      end
    end
  end
  object XML: TXMLDocument
    Left = 448
    DOMVendorDesc = 'MSXML'
  end
  object SD: TSaveDialog
    DefaultExt = '*.xml'
    Filter = 'XML Files|*.xml|All Files|*.*'
    Left = 504
  end
  object OD: TOpenDialog
    DefaultExt = '*.xml'
    Filter = 'XML Files|*.xml|All Files|*.*'
    Left = 544
  end
end
