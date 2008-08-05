{*******************************************************************************
                                TreeListView
  Diese Komponente ist eine Mischung zwischen der "record"-Ansicht von TListView
  und der Baumansicht von TTreeView.
  Im wesentlichen  wird ein Baum angezeigt, wobei f�r  jede Zeile  im Baum,  in
  Spalten  zus�tzliche Informationen angezeigt werden k�nnen. Jeder Eintrag in
  den einzelnen Spalten kann unabh�ngig von den anderen formatiert werden.

  Das Copyright liegt alleinig bei Benito van der Zander, alias BeniBela
                                   benibela@aol.com
                                   www.benibela.de

  Die Komponente steht unter der:
  This component is licenced under the terms of the:
     Creative Commons Attribution-NonCommercial-ShareAlike 2.0 Licence
     
  Zusammenfassung:
    - Sie m�ssen den Urheber angeben
    - Sie d�rfen die Komponente nicht f�r kommerzielle Zwecke benutzen
    - Die Komponente darf nur unter denselben Lizenzbedingungen ver�ffentlicht 
      und ver�ndert werden.

  Summary:
    - You must give the original author credit.
    - You may not use this work for commercial purposes.
    - If you alter, transform, or build upon this work, you may distribute the 
      resulting work only under a licence identical to this one.
*******************************************************************************}

unit TreeListView;
{$ifdef fpc}
  {$mode delphi}
{$endif}
{$ifdef clr}
  {$UNSAFECODE ON}
{$endif}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,comctrls,stdctrls,Menus,math
  {$ifdef clr},types{$endif};

type
  {$TYPEINFO ON}
  //Forward
  TTreeListRecordItem=class;
  TTreeListItem=class;
  TW32TreeListView = class;

  TImageTyp=(itNone,itListIndex,itBitmap);
  TObjectList= class(TList)
    public
      //Events
      OnChanging:TNotifyEvent;
      OnChange:TNotifyEvent;

      procedure BeginEdit;
      procedure EndEdit;

      function AddObject(Item: TObject): Integer;
      procedure InsertObject(Index: Integer; Item: TObject);
      function RemoveObject(Item: TObject): Integer;

      procedure Clear; override;
      procedure Delete(Index: Integer);
      procedure Exchange(Index1, Index2: Integer);
      function Expand: TList;
      procedure Move(CurIndex, NewIndex: Integer);
      procedure Pack;
      procedure Sort(Compare: TListSortCompare);

      procedure FreeObjects;

      procedure Assign(list:TList);

      constructor create;
      destructor destroy;override;
    protected
      freeing:boolean;
      editing:boolean;

      //Eventausl�ser
      procedure DoChanging;virtual;
      procedure DoChange;virtual;

      function Add(Item: TObject): Integer;
      procedure Insert(Index: Integer; Item: TObject);
      function Remove(Item: TObject): Integer;
  end;

  TRealItemCounting=set of (ricCountCollapsedsubItems{,ricCountExpandItems,ricCountEndNodes});

  { TTreeListItems }
  TTreeListItemCompare = function (i1, i2: TTreeListItem): longint of object;
  TTreeListItems=class(TObjectList)
  private
    procedure Put(Index: Integer; const AValue: TTreeListItem);
  protected
    F_Parent:TtreeListItem;
    F_TreeListView:tw32TreeListView;
    constructor create(parent:TTreeListItem;const TreeListView:Tw32treelistview);
    function Get(Index: Integer): TTreeListItem; inline;
  public
    procedure Sort(CompareFunc: TTreeListItemCompare);
    function Add:TTreelistItem;overload;
    function Add(caption:string):TTreelistItem;overload;
    function Add(Parent:TTreeListItem):TTreelistItem;overload;
    function Add(Parent:TTreeListItem;caption:string):TTreelistItem;overload;
    function GetRealItemCount(const countTyp:TRealItemCounting ) :integer;
    function GetItemWithRealIndex(index:integer):TTreeListItem;
    function RealIndexOf(const item:ttreeListItem;const countTyp:TRealItemCounting):integer;

    function FindItemWithText(caption: string): TTreeListItem;
    function FindItemWithRecordText(pos: longint; text: string):TTreeListItem;

    property Items[Index: Integer]: TTreeListItem read Get write Put; default;
  end;

  { TRecordItemList }

  TRecordItemList=class(TObjectList)
  private
    Owner: TTreeListItem;
    function Get(Index: Integer): TTreeListRecordItem;
    procedure Put(Index: Integer; const AValue: TTreeListRecordItem);
  public
    property Items[Index: Integer]: TTreeListRecordItem read Get write Put; default;
    function Add:TTreeListRecordItem;overload;
    function Add(s: string):TTreeListRecordItem;overload;
    procedure AddItem(recordItem: TTreeListRecordItem);
  end;


  { TTreeListRecordItem }

  TTreeListRecordItem=class(TPersistent)
    protected
      F_Parent: TTreeListItem;
      F_Text:string;
      F_Index:Longint;
      {F_HotTrackFont:TFont;
      F_HotTrack:boolean;
      F_ParentHotTrack:boolean;
      F_ParentHotTrackFont:boolean; }
      procedure SetText(caption:string);
    public
      procedure selectFont(listView:TW32TreeListView);
      //procedure PaintTo(const listView:TW32TreeListView;x:integer;const y,xColumn:integer;const parentItem:TTreeListItem);

      function GetNecessaryWidth(listView:TW32TreeListView=nil): longint;

      constructor create(aparent:TTreeListItem);overload;
      constructor create(aparent:TTreeListItem;caption:string);overload;
      destructor destroy;override;
    published
      property Text:string read F_Text write setText;
  end;

  TExpandItemEvent = procedure (Sender: TObject; Item: TTreeListItem);
  TTreeListItem=class(TPersistent)
  private
    function GetText: string;
    procedure SetText(const AValue: string);
    protected
      F_IndexOrBitmap:cardinal;
      F_ImageTyp:TImageTyp;
      F_SubItems:TTreeListItems;
      F_RecordItems:TRecordItemList;
      F_Expanded,F_Selected,F_MouseSelected:boolean;

      F_Indent:integer; //Gibt an, wieoft, das Item einger�ckt wurde, diese Eigenschaft wird von PaintTo und GetItemAtPosWithIndentSet gesetzt, und muss *nicht* stimmmen

      F_Parent:Ttreelistitem;
      F_TreeListView:TW32TreeListView;

  //   F_ParentFont:boolean;
  //    F_Font:TFont;
      function GetExtendingButtonPos: longint;

      procedure DoChange;
      procedure DoChanging;

      procedure SetSelected(newSelected: boolean);

      procedure SetSubItems(const value:TtreeListItems);
      procedure SetRecordItems(const value:TRecordItemList);
      procedure SetExpand(const expanded:boolean);

      function GetRecordItemsText(i: Integer): string;
      procedure SetRecordItemsText(i: Integer; const AValue: string);
    public
      Tag:longint;

      //Create
      constructor create(const parent:TTreeListItem;const TreeListView:Tw32treelistview);overload;
      constructor create(const parent:TTreeListItem;const TreeListView:Tw32treelistview;const ACaption:string);overload;

      function getBounds(column: longint):TRect; //-1 => whole line
      function GetItemAtPos(const listView:TW32TreeListView;const TestY:integer;var startY:integer):TTreeListItem;
      function GetItemAtPosWithIndentSet(const listView:TW32TreeListView;const TestY,Indent:integer;var startY:integer):TTreeListItem;
      function GetRecordItemAtPos(const listView:TW32TreeListView;const TestX:integer):TTreeListRecordItem;

      function GetMaxColumnWidth(const id:longint): longint;

      procedure Expand;
      procedure Collapse;


      function GetNextItemIgnoringChildren:TTreeListItem;
      //function GetNextItem:TTreeListItem; deprecated use nextvisibleitem
      //function GetPrevItem:TTreeListItem;
      function GetLastVisibleSubSubItem:TTreeListItem; //Gibt das sichtbare unterster Item, des untersten Items, des untersten Items, des untersten Items..., des untersten SubItems zu�ck.
      function GetLastSubSubItem:TTreeListItem; //Gibt das unterster Item, des untersten Items, des untersten Items, des untersten Items, des untersten Items, des untersten Items..., des untersten SubItems zu�ck.
      //if the item doesn't exists the current item is returned!
      function GetNextVisibleItem(Delta:longint=1):TTreeListItem;
      function GetPrevVisibleItem(Delta:longint=1):TTreeListItem;
      function GetNextItem():TTreeListItem;
      function GetPrevItem():TTreeListItem;


      property Parent:TTreeListItem read F_parent;
      property TreeListView:Tw32TreeListView read F_TreeListview;
      function ParentItems: TTreeListItems;
      
      procedure PaintTo(const listView:TW32TreeListView;var y:integer;const xColumn:integer;const last:boolean);

      //Destroy
      destructor destroy;override;

      function SeemsSelected:boolean;
      property Indent:integer read F_Indent;
      property Expanded:boolean read F_expanded write SetExpand;

      property RecordItemsText[i: Integer]:string read GetRecordItemsText write SetRecordItemsText;
    published
      property RecordItems:TRecordItemList read F_RecordItems write SetRecordItems;
      property SubItems:TTreeListItems read F_SubItems write SetSubItems;
      property IndexOrBitmap:cardinal read F_indexOrBitmap write F_indexOrBitmap;
      property Text:string read GetText write SetText;
      property ImageTyp:TImageTyp read F_ImageTyp write F_ImageTyp;
      property Selected: boolean read F_Selected write SetSelected;
//      property Font:TFont read F_Font write SetFont
  end;

  TTreeListInternOptions=set of (tlioDisablePainting, tlioDeleting, tlioUpdating);
  TExpandMode=(emExpandByClick,emExpandByDoubleClick,emExpandNot);
  TLineMode=(lmNone,lmSolid,lmDot);
  TCustomDrawEventTyp=(cdetPrePaint,cdetPostPaint);
  TCustomBackgroundDrawEvent=procedure (sender:TObject;eventTyp_cdet:TCustomDrawEventTyp;var defaultDraw:Boolean) of object;
  TCustomItemDrawEvent=procedure (sender:TObject;eventTyp_cdet:TCustomDrawEventTyp;item:TTreeListItem;xpos,ypos,xColumn:integer;lastItem:boolean;var defaultDraw:Boolean) of object;
  TCustomRecordItemDrawEvent=procedure (sender:TObject;eventTyp_cdet:TCustomDrawEventTyp;parentItem:TTreeListItem;RecordItem:TTreeListRecordItem;xpos,ypos,xColumn:integer;var defaultDraw:Boolean) of object;
  TItemEvent=procedure (sender:TObject;item:TTreeListItem) of object;
  TRecordItemEvent=procedure (sender:TObject;parentItem:TTreeListItem;item:TTreeListRecordItem) of object;
  TCompareTreeListItemsEvent=procedure (sender: TObject; item1, item2: TTreeListItem; var result: longint)of object;
  TUserSortItemsEvent=procedure (sender: TObject; var sortColumn: longint; var invertSorting: boolean) of object;

  { TW32TreeListView }
  {$ifndef fpc}
  TEventHeaderControl=THeaderControl;
  {$else}
  TEventHeaderControl=TCustomHeaderControl;
  {$endif}

  TW32TreeListView = class(TCustomControl)
  protected
    { Protected-Deklarationen}
    InternOptions_tlio:TTreeListInternOptions;
    RedrawBlock: longint;

    StartX:integer;
    LastItems:array[0..31] of boolean; //Gibt an, ob unter dem entsprechenden Item eine Linie gezeichnet werden soll, damit ist es nicht m�glich mehr als 32 RecordItems zu machen.

    F_Sorted: boolean;
    F_SortColumn: longint;
    F_SortColumnInverted: boolean;
    F_OnCompareItems: TCompareTreeListItemsEvent;
    F_OnUserSortItems: TUserSortItemsEvent;

    F_Items:TTreeListItems;
    F_Header:THeaderControl;
    F_HeaderColumnPopupMenu: TPopupMenu;
    F_VScroll:TScrollBar;
    F_HScroll:TScrollBar;
    F_RowHeight:integer;
    F_ImageList:TImageList;

    F_ExpandMode:TExpandMode;

    //Selection
    F_MultiSelect:boolean;
    F_SelCount: longint;
    F_Focused: TTreeListItem;
    F_BaseSelect: TTreeListItem; //last item selected without shift


    //appearance
    F_TreeSectionPos: TRect;
    
    F_HotTrackFont:TFont;
    F_HotTrackSubTextItems:boolean;

    F_SelectedFont:TFont;
    F_SelectHotTrackFont:TFont;
    F_SelectBackColor:TColor;

    F_ButtonColor:TColor;
    F_BgColor:TColor;

    F_Striped:boolean;
    F_StripedOddColor:TColor;
    F_StripedEvenColor:TColor;
    F_StripInvisibleItems: boolean;

    F_HorizontalLines:TLineMode;
    F_HorizontalLineColor:TColor;
    F_VerticalLines:TLineMode;
    F_VerticalLineColor:TColor;
    F_RootLines:TLineMode;
    F_RootLineColor:TColor;

    //Headerevents
    {$ifdef FPC}
    F_HeaderSectionResize:TCustomSectionNotifyEvent;
    F_HeaderSectionTrack:TCustomSectionTrackEvent;
    {$else}
    F_HeaderSectionResize:TSectionNotifyEvent;
    F_HeaderSectionTrack:TSectionTrackEvent;
    {$endif}
    //Events

    //Scrollbarevents
    F_VScrollBarChange:TNotifyEvent;
    F_HScrollBarChange:TNotifyEvent;
    F_MouseWheelDelta: longint;

    //CustomDrawEvents
    F_CustomBgDraw:TCustomBackgroundDrawEvent;
    F_CustomItemDraw:TCustomItemDrawEvent;
    F_CustomRecordItemDraw:TCustomRecordItemDrawEvent;

    //Inputevents
    F_RealClickPos, F_RealMousePos: TPoint;
    F_ClickedItem: TTreeListItem;
    F_MouseSelecting: boolean;
    F_ClickAtItem:TItemEvent;
//    F_ItemCollapsed:TItemEvent;
 //   F_ItemExpanded:TItemEvent;
    F_ClickAtRecordItem:TRecordItemEvent;
    F_OnSelect:TItemEvent;
    F_OnExpandItem: TItemEvent;
    F_OnItemsSorted: TNotifyEvent;

    PaintEvenItem:boolean;


    //Ereignissaus�sungen
    function DoCustomBackgroundDrawEvent (eventTyp_cdet:TCustomDrawEventTyp):boolean;
    function DoCustomItemDrawEvent(eventTyp_cdet:TCustomDrawEventTyp;item:TTreeListItem;xpos,ypos,xColumn:integer;lastItem:boolean):boolean;
    function DoCustomRecordItemDrawEvent(eventTyp_cdet:TCustomDrawEventTyp;parentItem:TTreeListItem;RecordItem:TTreeListRecordItem;xpos,ypos,xColumn:integer):boolean;

    procedure removeSelection(list: TTreeListItems);
    procedure removeMouseSelection(list: TTreeListItems);
    procedure setMouseSelection(list: TTreeListItems);
    procedure SetMultiSelect(value: boolean);
    procedure DoSelect(item: TTreeListItem);virtual;
    procedure selectRange(a,b: TTreeListItem;mouseSelect:boolean=false);

    //Kommunikationsroutinen (Set- und Getfunktionen)
    procedure SetItems(const value:TTreeListItems);
    procedure SetFocused(const AValue: TTreeListItem);
    procedure SetSelected(const AValue: TTreeListItem);

    function GetColumnsDragable: boolean;
    procedure SetColumnsDragable(const AValue: boolean);

    procedure SetTopPos(const i:integer);
    function GetTopPos:integer;

    procedure SetSortColumn(const AValue: longint);
    procedure SetSorted(const AValue: boolean);

    procedure SetColumns(const value:THeaderSections);
    function GetColumns: THeaderSections;
    function GetColumnFromOriginalIndex(i:longint):THeaderSection;

    procedure setImageList(const images:TImageList);

    procedure SetRowHeight(const newHeight:integer);

    procedure SetHotTrackSubTextItems(const value:boolean);

    //Sonstiges
    function RealControlHeight(c: Twincontrol): longint;
    function RealClientHeight: longint;
    procedure DrawAlignDotLine(x,y:integer;const x2,y2:integer;const color:TColor);
    function CompareItems(i1, i2: TTreeListItem): longint;

    procedure BeginMultipleUpdate;
    procedure EndMultipleUpdate;

    //Interne Kommunikation mit Unterkomponenten
    procedure _GeneralEvent(Sender: TObject);
    procedure _HeaderSectionTrack( HeaderControl: TEventHeaderControl;  Section: THeaderSection;  Width: Integer;  State: TSectionTrackState);
    procedure _HeaderSectionResize( HeaderControl: TEventHeaderControl;  Section: THeaderSection);
    procedure _HeaderSectionClick( HeaderControl: TEventHeaderControl;  Section: THeaderSection);
    procedure _HeaderSectionDblClick( HeaderControl: TEventHeaderControl;  Section: THeaderSection);
    procedure _HeaderSectionEndDrag(Sender: TObject);
    procedure ColumnPopupMenuClick(Sender: TObject);
    procedure _HScrollChange(Sender: TObject);
    procedure _VScrollChange(Sender: TObject);

    procedure UpdateScrollBarPos;
  public
    { Public-Deklarationen}
    ToolTips: boolean;
    doubleBuffer:TBitmap;

    hotTrackedRecordItem:TTreeListRecordItem;
    property selCount: longint read F_SelCount;
    property multiSelect: boolean read F_MultiSelect write SetMultiSelect;
    property focused:TTreeListItem read F_Focused write SetFocused;
    property Selected:TTreeListItem read F_Focused write SetSelected;
    property SortColumn: longint read F_SortColumn write SetSortColumn;

    procedure UpdateScrollSize;

    //Create
    constructor create(aowner:TComponent);override;

    function GetItemAtPos(const y:integer):TTreeListItem;
    function GetItemAtPosWithIndentSet(const y:integer):TTreeListItem;
    function GetRecordItemAtPos(const x,y:integer):TTreeListRecordItem;

    procedure SetHotTrackFont(const value:TFont);
    procedure SetSelectedFont(const value:TFont);
    procedure SetSelectHotTrackFont(const value:TFont);

    //Items
    procedure BeginUpdate;
    procedure EndUpdate;
    function VisibleRowCount:longint;
    procedure sort;
    procedure ensureVisibility(item: TTreeListItem);

    //Header
    function ColumnFromOriginalIndex(index: longint):  THeaderSection;
    procedure createUserColumnVisibilityPopupMenu();
      //these methodes allow to save only certain properties in contrast to
      //a normal twriter;  order and visible reading requires FPC
    function serializeColumnWidths: string;
    function serializeColumnOrder: string;
    function serializeColumnVisibility: string;
    procedure deserializeColumnWidths(s: string);
    procedure deserializeColumnOrder(s: string);
    procedure deserializeColumnVisibility(s: string);


    //Messages
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure WndProc(var message:TMessage);override;

    //Ausgaberoutinen
    procedure Paint;override;

    //Destroy
    destructor destroy;override;

    property TopPos:integer read GetTopPos write SetTopPos;

  published
    { Published-Deklarationen }
    {-------------------------------START Ereignisse---------------------------}
    property ColumnsDragable: boolean read GetColumnsDragable write SetColumnsDragable;
    
    //Sortierungsereignisse
    property Sorted: boolean read F_Sorted write SetSorted;
    property OnCompareItems: TCompareTreeListItemsEvent read F_OnCompareItems write F_OnCompareItems;
    property OnUserSortItemsEvent: TUserSortItemsEvent read F_OnUserSortItems write F_OnUserSortItems;
    property OnItemsSortedEvent: TNotifyEvent read F_OnItemsSorted write F_OnItemsSorted;

    //Scrollbarereignisse
    property OnVScrollBarChange:TNotifyEvent read F_VScrollBarChange write F_VScrollBarChange;
    property OnHScrollBarChange:TNotifyEvent read F_HScrollBarChange write F_HScrollBarChange;

    //CustomDrawEvents
    property OnCustomBgDraw:TCustomBackgroundDrawEvent read F_CustomBgDraw write F_CustomBgDraw;
    property OnCustomItemDraw:TCustomItemDrawEvent read F_CustomItemDraw write F_CustomItemDraw;
    property OnCustomRecordItemDraw:TCustomRecordItemDrawEvent read F_CustomRecordItemDraw write F_CustomRecordItemDraw;

    //Inputevents
    property OnClickAtRecordItem:TRecordItemEvent read F_ClickAtRecordItem write F_ClickAtRecordItem;
    property OnClickAtItem:TItemEvent read F_ClickAtItem write F_ClickAtItem;
    property OnSelect:TItemEvent read F_OnSelect write F_OnSelect;
    property OnExpandItem: TItemEvent read F_OnExpandItem write F_OnExpandItem;
//   property OnItemCollapsed:TItemEvent read F_ItemCollapsed write F_ItemCollapsed;
  //  property OnItemExpanded:TItemEvent read F_ItemExpanded write F_ItemExpanded;

    //Header-Ereignisse
    {$ifdef FPC}
    property OnHeaderSectionResize:TCustomSectionNotifyEvent read F_HeaderSectionResize write F_HeaderSectionResize;
    property OnHeaderSectionTrack:TCustomSectionTrackEvent read F_HeaderSectionTrack write F_HeaderSectionTrack;
    {$else}
    property OnHeaderSectionResize:TSectionNotifyEvent read F_HeaderSectionResize write F_HeaderSectionResize;
    property OnHeaderSectionTrack:TSectionTrackEvent read F_HeaderSectionTrack write F_HeaderSectionTrack;
    {$endif}


    //Freigeben von TWinControlereignissen
    property OnDockDrop;
	   property OnDockOver ;
    property OnEnter     ;
    property OnExit       ;
    property OnGetSiteInfo ;
    property OnKeyDown      ;
    property OnKeyPress      ;
    property OnKeyUp          ;
    property OnMouseWheel      ;
    property OnMouseWheelDown   ;
    property OnMouseWheelUp      ;
    property OnUnDock             ;

    //Freigeben von TControl-Ereignissen
    {$ifndef fpc}property OnCanResize;{$endif}
    property OnClick                ;
    property OnConstrainedResize     ;
    property OnDblClick               ;
    property OnDragDrop                 ;
    property OnDragOver                  ;
    property OnEndDock                    ;
    property OnEndDrag                     ;
    property OnMouseDown                    ;
    property OnMouseMove                     ;
    property OnMouseUp                        ;
    property OnResize                          ;
    property OnStartDock                        ;
    property OnStartDrag                         ;

{--------------------------------ENDE Ereignisss---------------------------}

    //Header-Eigenschaften
    property Columns:THeaderSections read GetColumns write SetColumns;

    property RowHeight:integer read F_RowHeight write SetRowHeight;

    property Images:TImageList read F_ImageList write setImageList;

    property HorizontalLineMode:TLineMode read F_HorizontalLines write F_HorizontalLines;
    property HorizontalLineColor:TColor read F_HorizontalLineColor write F_HorizontalLineColor;
    property VerticalLineMode:TLineMode read F_VerticalLines write F_VerticalLines;
    property VerticalLineColor:TColor read F_VerticalLineColor write F_VerticalLineColor;
    property RootLineMode:TLineMode read F_RootLines write F_RootLines;
    property RootLineColor:TColor read F_RootLineColor write F_RootLineColor;

    property ExpandMode:TExpandMode read F_ExpandMode write F_ExpandMode;
    property HotTrackSubTextItems:Boolean read F_HotTrackSubTextItems write SetHotTrackSubTextItems;

    property HotTrackFont:TFont read F_HotTrackFont write SetHotTrackFont;
    property Font;
    property SelectedFont:TFont read F_SelectedFont write SetSelectedFont;
    property SelectHotTrackFont:TFont read F_SelectHotTrackFont write SetSelectHotTrackFont;

    property Striped:boolean read F_Striped write F_Striped;
    property StripedOddColor:TColor read F_StripedOddColor write F_StripedOddColor;
    property StripedEvenColor:TColor read F_StripedEvenColor write F_StripedEvenColor;
    property StripInvisibleItems: boolean read F_StripInvisibleItems write F_StripInvisibleItems;

    property SelectBackColor:TColor read F_SelectBackColor write F_SelectBackColor;
    property ButtonColor:TColor read F_ButtonColor write F_ButtonColor;
    property BackGroundColor:TColor read F_BgColor write F_BgColor;

    property Items:TTreeListItems read F_Items write SetItems;

    property BorderWidth;
    {$ifndef fpc}property BevelWidth;
    property BevelEdges;
    property BevelInner default bvLowered;
    property BevelOuter default bvLowered;
    property BevelKind default bkTile; {$endif}
    property TabStop default true;
    property TabOrder;

    //Freigeben von TControl
    property Align;
    property Anchors;
    property Constraints;
    property DragCursor;
    property DragKind   ;
    property DragMode    ;
    property Hint         ;
    property ShowHint      ;

  end;
  TTreeListView = TW32TreeListView;

procedure Register;

implementation

const HeaderItemDistance=2; //Distance between Header and first drawn item
      LEFT_TEXT_PADDING=3;
      LINE_DISTANCE=15;
      EXPANDING_BUTTON_WIDTH=9;
{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{
################################################################################
================================================================================
////////////////////////////////////////////////////////////////////////////////
--------------------------------------------------------------------------------
................................TObjectList.....................................
--------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
================================================================================
################################################################################
}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}

constructor TObjectList.create;
begin
  inherited;
  editing:=false;
  freeing:=false;
end;

procedure TObjectList.BeginEdit;
begin
  editing:=true;
  DoChanging;
end;

procedure TObjectList.EndEdit;
begin
  DoChange;
  editing:=false;
end;

//Neu mit Objekten
function TObjectList.AddObject(Item: TObject): Integer;
begin
  result:=add(item);
end;

procedure TObjectList.InsertObject(Index: Integer; Item: TObject);
begin
  Insert(index,item);
end;

function TObjectList.RemoveObject(Item: TObject): Integer;
begin
  result:=remove(item);
end;

//Eventbearbeitung
procedure TObjectList.DoChanging;
begin
  if Assigned(OnChanging) then OnChanging(self);
end;

procedure TObjectList.DoChange;
begin
  if Assigned(OnChange) then OnChange(self);
end;

//Eventausl�ser
function TObjectList.Add(Item: TObject): Integer;
begin
  if not editing then
    DoChanging;
  result:=inherited add(item);
  if not editing then
    DoChange;
end;
procedure TObjectList.Clear;
var i:longint;
begin
  if not editing then
    DoChanging;
  FreeObjects;
  count:=0;
  if not editing then
    DoChange;
end;
procedure TObjectList.Delete(Index: Integer);
begin
  if not editing then
    DoChanging;
  inherited;
  if not editing then
    DoChange;
end;
procedure TObjectList.Exchange(Index1, Index2: Integer);
begin
  if not editing then
    DoChanging;
  inherited;
  if not editing then
    DoChange;
end;
function TObjectList.Expand: TList;
begin
  if not editing then
    DoChanging;
  result:=inherited expand;
  if not editing then
    DoChange;
end;
procedure TObjectList.Insert(Index: Integer; Item: TObject);
begin
  if not editing then
    DoChanging;
  inherited insert(index,item);
  if not editing then
    DoChange;
end;
procedure TObjectList.Move(CurIndex, NewIndex: Integer);
begin
  if not editing then
    DoChanging;
  inherited;
  if not editing then
    DoChange;
end;
procedure TObjectList.Pack;
begin
  if not editing then
    DoChanging;
  inherited;
  if not editing then
    DoChange;
end;
function TObjectList.Remove(Item: TObject): Integer;
begin
  if not editing then
    DoChanging;
  item.free;
  result:=inherited remove(item);
  if not editing then
    DoChange;
end;
procedure TObjectList.Sort(Compare: TListSortCompare);
begin
  if not editing then
    DoChanging;
  inherited;
  if not editing then
    DoChange;
end;
procedure TObjectList.Assign(list:TList);
var i:integer;
begin
  Count:=list.Count;
  for i:=0 to Count-1 do
    Items[i]:=list.Items[i];
end;
procedure TObjectList.FreeObjects;
var i:integer;
begin
  freeing:=true;
//  DoChanging;
  for i:=0 to Count-1 do begin
    TObject(Items[i]).free;
    Items[i]:=nil;
  end;
  count:=0;
//  DoChange;
  freeing:=false;
end;
destructor TObjectList.destroy;
begin
  FreeObjects;
  inherited;
end;


{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{
################################################################################
================================================================================
////////////////////////////////////////////////////////////////////////////////
--------------------------------------------------------------------------------
...............................tTreeListItems...................................
--------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
================================================================================
################################################################################
}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}

procedure TTreeListItems.Put(Index: Integer; const AValue: TTreeListItem);
begin
  inherited put(Index, AValue);
end;

function TTreeListItems.Get(Index: Integer): TTreeListItem; {$ifdef fpc}inline;{$endif}
begin
  result:=TTreeListItem(inherited get(index));
end;

procedure TTreeListItems.Sort(CompareFunc: TTreeListItemCompare);
var temp: array of TTreeListItem;

  procedure mergeSort(f,t:longint);
  var i,a,b,d,p: longint;
  begin
    if f>=t then exit;
    d:=(f+t) div 2;
    mergeSort(f,d);
    mergeSort(d+1,t);
    {$ifdef fpc}
    system.move(List^[f],temp[f],(t-f+1)*sizeof(TTreeListItem));
    {$else}
    for i := f to t  do
      temp[i]:=TTreeListItem(List[i]);
    {$endif}
    p:=f;
    a:=f;
    b:=d+1;
    while (a<=d) and (b<=t) do begin
      if CompareFunc(temp[a],temp[b])<=0 then begin
        List[p]:=temp[a];
        inc(a);
      end else begin
        List[p]:=temp[b];
        inc(b);
      end;
      inc(p);
    end;
    if a<=d then begin
      f:=a;
      t:=d;
    end else if b<=t then f:=b
    else exit;
    {$ifdef fpc}
      system.move(temp[f],List[p],(t-f+1)*sizeof(TTreeListItem));
    {$else}
      for i := f to t  do
        List[i+p-f]:=temp[i];
    {$endif}
  end;
var i:longint;
begin
  //sort children
  for i:=0 to count-1 do
    Items[i].SubItems.Sort(CompareFunc);
  SetLength(temp,count);
  mergeSort(0,count-1);
end;

constructor TTreeListItems.create(parent:TTreeListItem;const TreeListView:Tw32treelistview);
begin
  inherited create;
  F_Parent:=parent;
  F_TreeListView:=TreeListView;
end;


function TTreeListItems.Add:TTreelistItem;
begin
  Result:=TTreeListItem.Create(F_Parent,F_TreeListView);
  Result.RecordItems.OnChanging:=OnChanging;
  Result.RecordItems.OnChange:=OnChange;
  Result.SubItems.OnChanging:=OnChanging;
  Result.SubItems.OnChange:=OnChange;
  inherited add(result);
end;

function TTreeListItems.Add(caption:string):TTreelistItem;
begin
  Result:=TTreeListItem.Create(F_Parent,F_TreeListView, caption);
  Result.RecordItems.OnChanging:=OnChanging;
  Result.RecordItems.OnChange:=OnChange;
  Result.SubItems.OnChanging:=OnChanging;
  Result.SubItems.OnChange:=OnChange;
  inherited add(result);
end;

function TTreeListItems.Add(Parent:TTreeListItem):TTreelistItem;
begin
  if Parent=nil then result:=Add
  else result:=Parent.SubItems.Add;
end;

function TTreeListItems.Add(Parent:TTreeListItem;caption:string):TTreelistItem;
begin
  result:=Add(Parent);
  result.Text:=caption;
end;

function tTreeListItems.GetRealItemCount(const countTyp:TRealItemCounting ) :integer;
var i:integer;
begin
  result:=1;
  if freeing then exit;
  for i:=0 to Count-1 do
    if ((TObject(items[i]) as TTreeListItem).expanded) or (ricCountCollapsedSubItems in countTyp) then
      result:= Result+TTreeListItem(items[i]).SubItems.GetRealItemCount(countTyp)
     else
      inc(result);
end;

function tTreeListItems.RealIndexOf(const item:ttreeListItem;const countTyp:TRealItemCounting):integer;
var pos:integer;
    gefunden:boolean;
  procedure RealIndexOfRek(const newself:TTreeListItem); //Durchsucht rekursiv alle SubListen der SubItems
  var i:integer;
  begin
    for i:=0 to newself.SubItems.Count-1 do begin
      inc(pos);
      if newself.SubItems[i]=item then begin
        gefunden:=true;
        break;
      end;
      if (TObject(newself.SubItems[i]) as TTreeListItem).Expanded or (ricCountCollapsedSubItems in counttyp) then
        RealIndexOfRek(newself.SubItems[i]);
      if gefunden then break;
    end;
  end;
var i:integer;
begin
  pos:=-1;
  gefunden:=false;
    for i:=0 to Count-1 do begin
      inc(pos);
      if Items[i]=item then begin
        gefunden:=true;
        break;
      end;
      if (TObject(Items[i]) as TTreeListItem).Expanded or (ricCountCollapsedSubItems in counttyp) then
        RealIndexOfRek(Items[i]);
      if gefunden then break;
    end;
  if gefunden then Result:=pos
  else Result:=-1;
end;

function TTreeListItems.FindItemWithText(caption: string): TTreeListItem;
var i:longint;
begin
  result:=nil;
  for i:=0 to count-1 do
    if Items[i].Text=caption then begin
      result:=Items[i];
      exit;
    end else begin
      result:=Items[i].SubItems.FindItemWithText(caption);
      if result<>nil then exit;
    end;
end;

function TTreeListItems.FindItemWithRecordText(pos: longint; text: string
  ): TTreeListItem;
var i:longint;
begin
  result:=nil;
  for i:=0 to count-1 do
    if Items[i].RecordItemsText[pos]=text then begin
      result:=Items[i];
      exit;
    end else begin
      result:=Items[i].SubItems.FindItemWithRecordText(pos,text);
      if result<>nil then exit;
    end;
end;

function tTreeListItems.GetItemWithRealIndex(index:integer):TTreeListItem;
  function GetItemWithRealIndexRek(const nself:TTreeListItems;var index:integer):TTreeListItem;
  var i:integer;
  begin
    result:=nil;
    for i:=0 to nself.count-1 do begin
      dec(index);
      if index=0 then begin result:=nself[i];exit;end
      else result:=GetItemWithRealIndexRek(TTreeListItem(nself[i]).SubItems,index);
    end;
  end;
var i:integer;
begin
  if index=-1 then begin
    result:=nil;
    exit;
  end;
  i:=index+1;
  result:=GetItemWithRealIndexRek(self,i);
end;


{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{
################################################################################
================================================================================
////////////////////////////////////////////////////////////////////////////////
--------------------------------------------------------------------------------
................................TRecordItemList....................................
--------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
================================================================================
################################################################################
}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}

function TRecordItemList.Get(Index: Integer): TTreeListRecordItem;
begin
  result:=TTreeListRecordItem(inherited Get(Index));
end;

procedure TRecordItemList.Put(Index: Integer;
  const AValue: TTreeListRecordItem);
begin
  inherited Put(Index, AValue);
end;

function TRecordItemList.Add:TTreeListRecordItem;
begin
  Result:=TTreeListRecordItem.create(owner);
  result.F_Index:=Count;
  inherited add(result);
end;

procedure TRecordItemList.AddItem(recordItem: TTreeListRecordItem);
begin
  inherited add(recordItem);
end;

function TRecordItemList.Add(s: string): TTreeListRecordItem;
begin
  result:=Add;
  result.Text:=s;
end;


{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{
################################################################################
================================================================================
////////////////////////////////////////////////////////////////////////////////
--------------------------------------------------------------------------------
............................TTreeListRecordItem.................................
--------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
================================================================================
################################################################################
}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}


procedure TTreeListRecordItem.SetText(caption: string);
begin
  F_Text:=caption;
  F_Parent.DoChange;
end;

procedure TTreeListRecordItem.selectFont(listView:TW32TreeListView);
begin
  if listView.hotTrackedRecordItem = self then begin
    if F_Parent.SeemsSelected then
     listView.Canvas.Font.Assign(listView.HotTrackFont)//SelectedHotTrackFont)
    else
     listView.Canvas.Font.Assign(listView.HotTrackFont);
   end else if F_Parent.SeemsSelected then
    listView.Canvas.Font.Assign(listView.SelectedFont)
   else
    listView.Canvas.Font.Assign(listView.Font);
end;
     (*
procedure TTreeListRecordItem.PaintTo(const listView:TW32TreeListView;x:integer;const y,xColumn:integer;const parentItem:TTreeListItem);
var i:integer;
    ausgabeRect:TRect;
    textStyle: TTextStyle;
begin
  ausgabeRect.Left:=x+3;
  ausgabeRect.Right:=x+listView.F_Header.Sections[xColumn+1].Width-2{+listView.StartX};
  ausgabeRect.Top:=y;
  ausgabeRect.Bottom:=y+listView.RowHeight;
  listView.Canvas.brush.Style:=bsClear;

  DrawText(listView.Canvas.Handle,pchar(text),length(text),ausgabeRect,DT_LEFT or DT_NOPREFIX or DT_SINGLELINE or DT_VCENTER or DT_WORD_ELLIPSIS);
end;*)

function TTreeListRecordItem.GetNecessaryWidth(listView:TW32TreeListView=nil): longint;
var i:integer;
begin
  if listView=nil then listView:=F_Parent.F_TreeListView;
  selectFont(listView);
  Result:=listView.Canvas.TextWidth(Text);
end;

constructor TTreeListRecordItem.create(aparent:TTreeListItem);
begin
  inherited create;
  F_Parent:=aparent;
end;

constructor TTreeListRecordItem.create(aparent:TTreeListItem; caption: string);
begin
  inherited create;
  F_Parent:=aparent;
  SetText(caption);
end;

destructor TTreeListRecordItem.destroy;
begin
  inherited destroy;
end;

{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{
################################################################################
================================================================================
////////////////////////////////////////////////////////////////////////////////
--------------------------------------------------------------------------------
...............................TTreeListItem....................................
--------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
================================================================================
################################################################################
}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}

//Create
constructor TTreeListItem.create(const Parent:TTreeListItem;const TreeListView:TW32TreeListView);
begin
  create(Parent,TreeListView,'');
end;

constructor TTreeListItem.create(const Parent:TTreeListItem;const TreeListView:TW32TreeListView;const ACaption:string);
begin
  inherited create;
  F_Parent:=parent;
  F_RecordItems:=TRecordItemList.create;
  F_RecordItems.Owner:=self;
  F_RecordItems.Add(ACaption);
  F_SubItems:=TTreeListItems.create(self,TreeListView);
  F_Indent:=-1;
  F_TreeListView:=TreeListView;
  f_Selected:=false;
  Expanded:=true;
end;

function TTreeListItem.getBounds(column: longint): TRect;
begin
  result.Top:=(F_TreeListView.Items.RealIndexOf(self,[]))*F_TreeListView.RowHeight+F_TreeListView.TopPos;
  result.bottom:=Result.top+F_TreeListView.RowHeight;
  if column=-1 then begin
    result.Left:=0;
    Result.right:=F_TreeListView.Width;
  end else begin
    Result.left:=TreeListView.ColumnFromOriginalIndex(column).Left;
    Result.right:=result.left+TreeListView.ColumnFromOriginalIndex(column).Width;
    Result.Left:=Result.Left+LEFT_TEXT_PADDING;
  end;
end;

function TTreeListItem.GetRecordItemsText(i: Integer): string;
begin
  if i<RecordItems.Count then result:=RecordItems[i].Text
  else result:='';
end;

procedure TTreeListItem.SetRecordItemsText(i: Integer; const AValue: string);
var j:longint;
begin
  if i<RecordItems.Count then RecordItems[i].Text:=AValue
  else begin
    for j:=RecordItems.Count to i-1 do RecordItems.Add('');
    RecordItems.Add(AValue);
  end;
end;

function TTreeListItem.GetText: string;
begin
  if RecordItems.Count>0 then result:=RecordItems[0].Text
  else result:='';
end;

procedure TTreeListItem.SetText(const AValue: string);
begin
  if RecordItems.Count>0 then RecordItems[0].Text:=AValue
  else RecordItems.Add(AValue);
end;

function TTreeListItem.GetExtendingButtonPos: longint;
begin
  result:=TreeListView.F_TreeSectionPos.left+(F_Indent+1)*LINE_DISTANCE-10;
end;

procedure TTreeListItem.DoChange;
begin
  RecordItems.DoChange;
end;
procedure TTreeListItem.DoChanging;
begin
  RecordItems.DoChanging;
end;

procedure TTreeListItem.SetSelected(newSelected: boolean);
begin
  if Selected = newSelected then exit;
  F_Selected:=newSelected;
  if F_Selected then begin
    if not TreeListView.multiSelect then TreeListView.focused:=self;
    TreeListView.F_SelCount:=TreeListView.F_SelCount+1;
  end else TreeListView.F_SelCount:=TreeListView.F_SelCount-1;
  TreeListView.DoSelect(self);
  DoChange;
end;

function TTreeListItem.SeemsSelected: boolean;
begin
  if TreeListView.F_MouseSelecting then result:=Selected xor F_MouseSelected
  else result:=Selected;
end;

//Set-Funktion
procedure TTreeListItem.SetRecordItems(const value:TRecordItemList);
begin
  F_RecordItems.Assign(value);
end;

procedure TTreeListItem.SetExpand(const expanded:boolean);
begin
  if expanded then expand else Collapse;
end;

procedure TTreeListItem.Expand;
begin
  DoChanging;
  F_Expanded:=true;
  if assigned(TreeListView.F_OnExpandItem) then TreeListView.F_OnExpandItem(TreeListView,self);
  DoChange;
end;
procedure TTreeListItem.Collapse;
begin
  DoChanging;
  F_Expanded:=false;
//  if assigned(F_OnCollapsed) then F_OnCollapsed(self);
  DoChange;
end;


procedure TTreeListItem.SetSubItems(const value: TtreeListItems);
begin
  F_SubItems.Assign(value);
end;


//Hinweis: starty wird nicht ver�ndert, wenn das Item an der gesuchten Stelle ist
function TTreeListItem.GetItemAtPos(const listView:TW32TreeListView;const TestY:integer;var startY:integer):TTreeListItem;
var i:integer;
begin
  result:=nil;
  if (TestY>startY)and(TestY<startY+listView.RowHeight) then begin
    result:=self;
    exit;
  end;
  startY:=startY+listView.RowHeight;
  if Expanded then
    for i:=0 to SubItems.Count-1 do begin
      result:=(TObject(SubItems[i]) as TTreeListItem).GetItemAtPos(listView,TestY,startY);
      if result<>nil then exit;
    end ;
end;

function TTreeListItem.GetItemAtPosWithIndentSet(const listView:TW32TreeListView;const TestY,Indent:integer;var startY:integer):TTreeListItem;
var i:integer;
begin
  F_Indent:=Indent;
  result:=nil;
  if (TestY>startY)and(TestY<startY+listView.RowHeight) then begin
    result:=self;
    exit;
  end;
  startY:=startY+listView.RowHeight;
  for i:=0 to SubItems.Count-1 do begin
    result:=(TObject(SubItems[i]) as TTreeListItem).GetItemAtPosWithIndentSet(listView,TestY,indent + 1,startY);
    if result<>nil then exit;
  end;
end;

function TTreeListItem.GetRecordItemAtPos(const listView:TW32TreeListView;const TestX:integer):TTreeListRecordItem;
var i,x:integer;
begin
  Result:=nil;
  x:=0;
  for i:=0 to min(listView.F_Header.Sections.Count-1,RecordItems.Count-1) do begin
    if TestX<x then exit;
    if (x+listView.F_Header.Sections[i].Width>TestX) then begin
      {$ifdef fpc}
      result:=RecordItems[listView.F_Header.Sections[i].OriginalIndex];
      {$else}
      result:=RecordItems[i];
      {$endif}
      exit;
    end;
    x:=x+listView.F_Header.Sections[i].Width;
  end;
end;

function TTreeListItem.GetMaxColumnWidth(const id: longint): longint;
var i,temp:longint;
begin
  if id=0 then result:=RecordItems[0].GetNecessaryWidth()+LINE_DISTANCE*F_Indent+13+LEFT_TEXT_PADDING
  else if id<RecordItems.Count then result:=RecordItems[id].GetNecessaryWidth()
  else result:=0;
  for i:=0 to SubItems.Count-1 do begin
    temp:=SubItems[i].GetMaxColumnWidth(id);
    if temp>result then result:=temp;
  end;
end;

//Gibt das n�chste Item zur�ck, dass auf der gleichen Ebene ist, gibt es kein solches, wird rekursiv das n�chste Item zur�ckgegeben, dass auf einer kleinere Ebene hat
function TTreeListItem.GetNextItemIgnoringChildren: TTreeListItem;
var temp:integer;
begin
  if (parent=nil) then begin
    temp:=TreeListView.Items.IndexOf(self);
    if temp<TreeListView.Items.Count-1 then Result:=TreeListView.Items[temp+1]
    else Result:=nil;
  end else begin
    temp:=Parent.SubItems.IndexOf(self);
    if temp<Parent.SubItems.Count-1 then Result:=parent.SubItems[temp+1]
    else result:=parent.GetNextItemIgnoringChildren;
  end;
end;

{function TTreeListItem.GetNextItem:TTreeListItem;
var temp:integer;
begin
  result:=self;
  if (SubItems.Count>0)and(expanded) then Result:=SubItems[0]
  else if Self.Parent=nil then begin
    temp:=Self.TreeListView.Items.IndexOf(self);
    if temp<Self.TreeListView.Items.Count-1 then Result:=Self.TreeListView.Items[temp+1];
  end else Result:=GetNextItemIgnoringChildren;
end;

function TTreeListItem.GetPrevItem:TTreeListItem;
var temp:integer;
begin
  result:=self;
  if self.Parent=nil then begin
    temp:=Self.TreeListView.Items.IndexOf(self);
    if temp>0 then Result:=(TObject(Self.TreeListView.items[temp-1]) as TTreeListItem).GetLastSubSubItem;
  end else begin
    temp:=Self.Parent.SubItems.IndexOf(self);
    if temp=0 then result:=self.parent
    else result:=(TObject(self.parent.SubItems[temp-1])as TTreeListItem).GetLastSubSubItem;
  end;
end;}

function TTreeListItem.GetLastVisibleSubSubItem:TTreeListItem;
begin
  result:=self;
  while (result.SubItems.Count<>0)and(result.Expanded) do
    Result:=Result.SubItems[Result.SubItems.count-1];
end;

function TTreeListItem.GetLastSubSubItem: TTreeListItem;
begin
  result:=self;
  while (result.SubItems.Count<>0) do
    Result:=Result.SubItems[Result.SubItems.count-1];
end;

function TTreeListItem.GetNextVisibleItem(Delta: longint=1): TTreeListItem;
var next: TTreeListItem;
begin
  if Delta<0 then begin
    result:=GetPrevVisibleItem(-Delta);
    exit;
  end;
  Result:=self;
  while delta>0 do begin
    if (result.SubItems.Count>0) and (result.Expanded) then
      next:=result.SubItems[0]
    else begin
      next:=result.GetNextItemIgnoringChildren;
      if next=nil then next:=result;
      if next=result then exit;
    end;
    result:=next;
    dec(delta,1);
  end;
end;

function TTreeListItem.GetPrevVisibleItem(Delta: longint): TTreeListItem;
var temp:longint;
begin
  if Delta<0 then begin
    result:=GetNextVisibleItem(-Delta);
    exit;
  end;
  Result:=self;
  while delta>0 do begin
    if result.Parent=nil then begin
      temp:=result.TreeListView.Items.IndexOf(result);
      if temp>0 then Result:=result.TreeListView.Items[temp-1].GetLastVisibleSubSubItem;
    end else begin
      temp:=Result.Parent.SubItems.IndexOf(Result);
      if temp=0 then result:=result.parent
      else result:=result.parent.SubItems[temp-1].GetLastVisibleSubSubItem;
    end;
    dec(Delta);
  end
end;

function TTreeListItem.GetNextItem(): TTreeListItem;
begin
  if SubItems.Count>0 then result:=SubItems[0]
  else result:=GetNextItemIgnoringChildren;
  if result=nil then result:=self;
end;

function TTreeListItem.GetPrevItem(): TTreeListItem;
var temp:longint;
begin
  result:=self;
  if result.Parent=nil then begin
    temp:=result.TreeListView.Items.IndexOf(result);
    if temp>0 then Result:=result.TreeListView.Items[temp-1].GetLastSubSubItem;
  end else begin
    temp:=Result.Parent.SubItems.IndexOf(Result);
    if temp=0 then result:=result.parent
    else result:=result.parent.SubItems[temp-1].GetLastSubSubItem;
  end;
  if result=nil then result:=self;
end;

function TTreeListItem.ParentItems: TTreeListItems;
begin
  if Parent = nil then result:=TreeListView.Items
  else result:=Parent.SubItems;
end;

procedure TTreeListItem.PaintTo(const listView:TW32TreeListView;var y:integer;const xColumn:integer;const last:boolean);
var i,yold,realPos,recordId:integer;
    defaultDraw:boolean;
    rec:Trect;
  procedure drawTextRect(s:string;x:longint);
  var temp: TRect;
  begin
    temp:=rec;
    temp.left:=x;
    {$IFDEF CLR}
    DrawText(listview.canvas.Handle,s,length(s),
             temp,DT_LEFT or DT_NOPREFIX or DT_SINGLELINE or DT_VCENTER or DT_WORD_ELLIPSIS);
    {$ELSE}
    DrawText(listview.canvas.Handle,pchar(s),length(s),
             temp,DT_LEFT or DT_NOPREFIX or DT_SINGLELINE or DT_VCENTER or DT_WORD_ELLIPSIS);
    {$ENDIF}
  end;
  procedure drawTreeColumnText;
  var textStartX: longint;
  begin
    textStartX:=Rec.Left+LEFT_TEXT_PADDING+xColumn*LINE_DISTANCE+listview.startx;
    if (ImageTyp<>itNone) then begin
      case ImageTyp of
        itListIndex:
          if listView.Images<>nil then begin
            listView.Images.draw(listView.Canvas,textStartX,rec.Top,IndexOrBitmap);
            drawTextRect(Text,textStartX+listView.Images.Width+LEFT_TEXT_PADDING);
          end;
        itBitmap:
          if (TObject(IndexOrBitmap)<>nil)and(TObject(IndexOrBitmap)is TBitmap) then begin
            listView.Canvas.Draw(textStartX,rec.top,TBitmap(TObject(IndexOrBitmap)));
            drawTextRect(Text,textStartX+TBitmap(TObject(IndexOrBitmap)).Width+LEFT_TEXT_PADDING);
          end;
      end;
    end else
      drawTextRect(Text,textStartX);
  end;
  procedure drawTreeColumn;
  var i,tempX:longint;
      tempColor:TColor;
  begin
    tempX:=rec.left;
    if listView.RootLineMode <> lmNone then begin
      //draw vertical item lines (not ending items)
      tempX:=tempX+LINE_DISTANCE div 2+1;
      for i:=0 to xColumn do begin
        if tempx>rec.right then break;
        if listView.LastItems[i] then
          if listView.RootLineMode=lmDot then
            listView.DrawAlignDotLine(tempX,yold,tempX,y-1,listView.F_RootLineColor)
           else with listView.canvas do begin
             pen.color:=listView.F_RootLineColor;
             pen.Style:=psSolid;
             MoveTo(tempX,yold);
             LineTo(tempX,y);
           end;
        tempX:=tempX+LINE_DISTANCE;
      end;

      tempX:=tempX-LINE_DISTANCE div 2-3;

      //draw vertical item lines (ending items)
      case listView.RootLineMode of
        lmDot:  begin
          listView.DrawAlignDotLine(tempX-5,yold+listView.RowHeight div 2,min(tempX,rec.right),yold + listView.RowHeight div 2,listView.F_RootLineColor);
          listView.DrawAlignDotLine(tempX-5,yold,tempX-5,yold+listView.RowHeight div 2,listView.F_RootLineColor);
        end;
        lmSolid: with listView.canvas do begin
           pen.color:=listView.F_RootLineColor;
           pen.Style:=psSolid;
           MoveTo(tempX-5,yold+listView.RowHeight div 2);
           LineTo(min(tempX,rec.right),yold + listView.RowHeight div 2);
             MoveTo(tempX-5,yold);
             LineTo(tempX-5,yold+listView.RowHeight div 2);
         end;
      end;
    end;

    if not defaultDraw then exit;

    if (yold>listView.F_Header.Height)
       and(rec.right-rec.left>EXPANDING_BUTTON_WIDTH)
       and(SubItems.Count>0)  then begin
      tempX:=GetExtendingButtonPos;
      tempColor:=listView.Canvas.brush.Color;
      listView.Canvas.pen.Style:=psSolid;
      listView.Canvas.pen.Color:=clBlack;
      listView.Canvas.brush.Style:=bsSolid;
      listView.Canvas.brush.Color:=listView.ButtonColor;
      //draw expanding/de button
      listView.canvas.Rectangle(tempX,yold+listView.RowHeight div 2-5,tempX+9,yold+listView.RowHeight div 2+4);
      listView.canvas.moveTo(tempX+2,yold+listView.RowHeight div 2-1); //draw ---
      listView.canvas.LineTo(tempX+7,yold+listView.RowHeight div 2-1);
      if not Expanded then begin                                   //draw  |   also -|-
        listView.canvas.moveTo(tempX+4,yold+listView.RowHeight div 2-3);
        listView.canvas.LineTo(tempX+4,yold+listView.RowHeight div 2+2);
      end;
      listView.Canvas.brush.Color:=tempColor;
    end;
  end;
begin
  listView.LastItems[xColumn]:=not last;
  if y>listView.ClientHeight-listView.F_HScroll.Height then exit;
  listView.PaintEvenItem:=not listView.PaintEvenItem;
  if listView.StripInvisibleItems and not Expanded then
    if (SubItems.GetRealItemCount([ricCountCollapsedSubItems]) and $1=0) then
      listView.PaintEvenItem:=not listView.PaintEvenItem;
  F_Indent:=xColumn;
  //item bg color/font
  if SeemsSelected then begin
    listView.Canvas.Brush.color:=listView.SelectBackColor;
    listView.Canvas.Brush.style:=bsSolid;
  end else if listView.Striped then begin
    listView.canvas.Brush.Style:=bsSolid;
    if listView.PaintEvenItem then listView.canvas.Brush.Color:=listView.StripedEvenColor
    else listView.canvas.Brush.Color:=listView.StripedOddColor;
  end else listView.Canvas.Brush.style:=bsClear;
  defaultDraw:=listView.DoCustomItemDrawEvent(cdetPrePaint,self,0,y,xColumn,last); //event handling
  yold:=y;
  y:=y+listView.RowHeight;
  if defaultDraw then
    if y>listView.F_Header.Height then begin
      //clearing
      listView.Canvas.FillRect(rect(0,yold,listView.ClientWidth-listview.f_vscroll.width,y));

      rec.top:=yold;
      rec.Bottom:=y;

      //draw text
      for i:=0 to listView.F_Header.Sections.Count-1 do begin
        {$IFDEF LCL}
          recordId:=listView.F_Header.Sections[i].OriginalIndex;
        {$ELSE}
          recordId:=i;
        {$ENDIF}
        if recordId>RecordItems.Count-1 then continue;
        rec.left:=listView.F_Header.Sections[i].Left-listView.F_HScroll.Position;
        rec.right:=rec.left+listView.F_Header.Sections[i].Width;
        RecordItems[recordId].selectFont(listView);
        if listView.DoCustomRecordItemDrawEvent(cdetPrePaint,self,RecordItems[recordId],rec.left,rec.top,recordId) then begin
          if recordId=0 then begin
            drawTreeColumnText;
            drawTreeColumn;
          end else
            drawTextRect(RecordItems[recordId].Text,rec.Left+LEFT_TEXT_PADDING);
          if not listView.DoCustomRecordItemDrawEvent(cdetPostPaint,self,RecordItems[recordId],rec.left,rec.top,recordId) then
            break;
        end;
      end;

      //draw focus rect
      if listView.focused = self then
        DrawFocusRect( listView.Canvas.Handle,rect(0,yold,listView.ClientWidth-listView.F_VScroll.Width,y));

      //draw horizontal separation lines
      case listView.HorizontalLineMode of
        lmSolid: with listView.canvas do begin
                   pen.color:=listView.F_HorizontalLineColor;
                   pen.Style:=psSolid;
                   MoveTo(0,y-1);
                   LineTo(ListView.ClientWidth-ListView.F_VScroll.Width,y-1);
                 end;
        lmDot:   listView.DrawAlignDotLine(0,y-1,ListView.ClientWidth-ListView.F_VScroll.Width,y-1,listView.F_HorizontalLineColor);
      end;
    end;

  //draw sub items
  if (SubItems.Count=0) then
    listView.DoCustomItemDrawEvent(cdetPostPaint,self,0,yold,xColumn,last) //event handling
   else
    if (Expanded)and(listView.DoCustomItemDrawEvent(cdetPostPaint,Self,0,yold,xColumn,last)) then
      for i:=0 to SubItems.Count-1 do
        (TObject(SubItems[i]) as TTreeListItem).PaintTo(listView,y,xColumn+1,i=SubItems.Count-1);

end;

//Destroy
destructor TTreeListItem.destroy;
begin
  if self=TreeListView.focused then TreeListView.focused:=nil;
  if Selected then TreeListView.f_selCount-=1;
  F_RecordItems.free;
  F_SubItems.free;
  inherited;
end;


{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{
################################################################################
================================================================================
////////////////////////////////////////////////////////////////////////////////
--------------------------------------------------------------------------------
..............................TW32TreeListView..................................
--------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////////
================================================================================
################################################################################
}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}

//Create
constructor TW32TreeListView.create(aowner:TComponent);
begin
  inherited;
  F_Items:=TTreeListItems.Create(nil,self);
  F_Items.OnChange:=_GeneralEvent;
  F_Items.freeing:=false;

  ToolTips:=true;
  doubleBuffer:=TBitmap.create;

  //Fonts
  F_HotTrackFont:=TFont.create;
  F_HotTrackFont.Color:=clBlue;
  F_HotTrackFont.Style:=[fsBold,fsUnderline];

  F_SelectHotTrackFont:=TFont.create;
  F_SelectHotTrackFont.Color:=clHighlightText;
  F_SelectHotTrackFont.Style:=[fsBold,fsUnderline];

  F_SelectedFont:=TFont.create;
  F_SelectedFont.Color:=clHighlightText;
  F_SelectedFont.Style:=[];

  Font.Color:=clWindowText;
  Font.Style:=[];

  //Backcolors
  F_SelectBackColor:=clHighlight;
  F_BgColor:=clWindow;
  F_ButtonColor:=clWindow;

  F_StripedOddColor:=clWindow;
  F_StripedEvenColor:= $00E0FFFF;
  F_Striped:=true;

  //Linien
  F_RootLines:=lmDot;
  F_RootLineColor:=clWindowFrame;
  F_HorizontalLines:=lmNone;
  F_HorizontalLineColor:=clWindowFrame;
  F_VerticalLines:=lmDot;
  F_VerticalLineColor:=clWindowFrame;

  InternOptions_tlio:=[];

  width:=200;
  Height:=200;

  {$ifndef fpc}
  BevelInner:=bvLowered;
  BevelOuter:=bvLowered;
  BevelKind:=bkTile;
  {$endif}
  TabStop:=true;

  //Headercontrol initialisieren
  F_Header:=THeaderControl.create(self);
  F_Header.Align:=alNone;
  F_Header.parent:=Self;
  F_Header.Visible:=true;
  with F_Header.Sections.Add do begin
    Caption:='';
    Width:=1000;
  end;
  F_Header.Left:=0;
  F_Header.Width:=10000;
  {$ifdef fpc}
  if font.Height=0 then
    F_Header.Height:=13+2*GetSystemMetrics(SM_CYEDGE)
   else
    F_Header.Height:=abs(font.height)+2*GetSystemMetrics(SM_CYEDGE);
  {$endif}
  F_Header.OnSectionTrack:=_HeaderSectionTrack;
  F_Header.OnSectionResize:=_HeaderSectionResize;
  F_Header.OnSectionClick:=_HeaderSectionClick;
  {$ifdef lcl}F_Header.OnSectionSeparatorDblClick:=_HeaderSectionDblClick();{$endif}
  F_Header.OnSectionEndDrag:=_HeaderSectionEndDrag;
  

  //Scrollbar initialisieren
  F_VScroll:=TScrollbar.create(self);
  F_VScroll.parent:=self;
  F_VScroll.Enabled:=false;
  F_VScroll.Visible:=true;
  F_VScroll.Kind:=sbVertical;
  F_VScroll.OnChange:=_VScrollChange;
  F_VScroll.TabStop:=false;
 // F_VScroll.Ctl3D


  //Scrollbar initialisieren
  F_HScroll:=TScrollbar.create(self);
  F_HScroll.parent:=self;
  F_HScroll.Enabled:=false;
  F_HScroll.Visible:=true;
  F_HScroll.Kind:=sbHorizontal;
  F_HScroll.Left:=0;
  F_HScroll.SmallChange:=5;
  F_HScroll.OnChange:=_HScrollChange;
  F_HScroll.TabStop:=false;

  RowHeight:=F_Header.Height-2*GetSystemMetrics(SM_CYEDGE);
end;

procedure TW32TreeListView.SetFocused(const AValue: TTreeListItem);
begin
  if AValue=F_Focused then exit;
  if tlioDeleting in InternOptions_tlio then exit;
  F_Focused:=AValue;
  DoSelect(F_Focused);
  if focused<>nil then
    ensureVisibility(focused);

  paint;
  {*RowHeight+TopPos+F_Header.Height;
  if temp-rowHeight<F_Header.Height then
    F_VScroll.Position:=min(F_VScroll.Position-1,F_VScroll.Position+(temp-F_Header.Height-rowHeight-3) div RowHeight);
  if temp>ClientHeight-F_HScroll.Height then
    F_VScroll.Position:=max(F_VScroll.Position+1,F_VScroll.Position+((temp-ClientHeight+F_HScroll.Height+F_Header.Height) div RowHeight));}
end;

procedure TW32TreeListView.SetSelected(const AValue: TTreeListItem);
begin
  if AValue = Selected then exit;
  BeginMultipleUpdate;
  removeSelection(items);
  if Avalue<>nil then
    AValue.Selected:=true;
  SetFocused(AValue);
  EndMultipleUpdate;
end;

procedure TW32TreeListView.SetSortColumn(const AValue: longint);
begin
  if SortColumn=AValue then exit;
  F_SortColumn:=AValue;
  F_SortColumnInverted:=false;
  if F_Sorted then sort;
end;

procedure TW32TreeListView.SetSorted(const AValue: boolean);
begin
  if F_Sorted=AValue then exit;
  F_Sorted:=AValue;
  if F_Sorted then sort;
end;

function TW32TreeListView.GetColumnsDragable: boolean;
begin
  Result:=F_Header.DragReorder;
end;

procedure TW32TreeListView.SetColumnsDragable(const AValue: boolean);
begin
  F_Header.DragReorder:=AValue;
end;

procedure TW32TreeListView.ColumnPopupMenuClick(Sender: TObject);
var mi: TMenuItem;
begin
  if not (sender is tmenuitem) then exit;
  mi:=TMenuItem(sender);
  if (mi.tag<0) or (mi.tag>=Columns.Count) then exit;
  mi.Checked:=not mi.Checked;
  Columns[mi.Tag].visible:=mi.Checked;
  Paint;
end;

function TW32TreeListView.DoCustomBackgroundDrawEvent (eventTyp_cdet:TCustomDrawEventTyp):boolean;
begin
  Result:=true;
  if assigned(F_CustomBgDraw) then F_CustomBgDraw(self,eventTyp_cdet,result);
end;
function TW32TreeListView.DoCustomItemDrawEvent(eventTyp_cdet:TCustomDrawEventTyp;item:TTreeListItem;xpos,ypos,xColumn:integer;lastItem:boolean):boolean;
begin
  Result:=true;
  if assigned(F_CustomItemDraw) then F_CustomItemDraw(self,eventTyp_cdet,item,xpos,ypos,xColumn,lastItem,result);
end;
function TW32TreeListView.DoCustomRecordItemDrawEvent(eventTyp_cdet:TCustomDrawEventTyp;parentItem:TTreeListItem;RecordItem:TTreeListRecordItem;xpos,ypos,xColumn:integer):boolean;
begin
  Result:=true;
  if assigned(F_CustomRecordItemDraw) then F_CustomRecordItemDraw(self,eventTyp_cdet,parentItem,recordItem,xpos,ypos,xColumn,result);
end;

procedure TW32TreeListView.removeSelection(list: TTreeListItems);
var i:longint;
begin
  BeginMultipleUpdate;
  for i:=0 to list.count-1 do begin
    list[i].Selected:=false;
    if list[i].SubItems.count>0 then removeSelection(list[i].SubItems);
  end;
  EndMultipleUpdate;
end;

procedure TW32TreeListView.removeMouseSelection(list: TTreeListItems);
var i:longint;
begin
  for i:=0 to list.count-1 do begin
    list[i].F_MouseSelected:=false;
    removeMouseSelection(list[i].SubItems);
  end;
end;

procedure TW32TreeListView.setMouseSelection(list: TTreeListItems);
var i:longint;
begin
  BeginMultipleUpdate;
  for i:=0 to list.count-1 do begin
    list[i].Selected:=list[i].Selected xor list[i].F_MouseSelected;
    list[i].F_MouseSelected:=false;
    setMouseSelection(list[i].SubItems);
  end;
  EndMultipleUpdate;
end;

procedure TW32TreeListView.SetMultiSelect(value: boolean);
begin
  F_MultiSelect:=value;
  if not F_MultiSelect then Selected:=focused;
end;

procedure TW32TreeListView.DoSelect(item: TTreeListItem);
begin
  if assigned(F_OnSelect) then
    F_OnSelect(self,item);
end;

//Kommunikationsroutinen (Set- und Getfunktionen)
procedure TW32TreeListView.SetItems(const value:TTreeListItems);
begin
  F_Items.Assign(value);
end;

procedure TW32TreeListView.SetTopPos(const i:integer);
begin
end;

function TW32TreeListView.GetTopPos:integer;
begin
  result:=HeaderItemDistance+F_Header.Height-F_VScroll.Position*RowHeight;
end;

procedure TW32TreeListView.SetColumns(const value:THeaderSections);
begin
  F_Header.Sections.Assign(value);
end;
function TW32TreeListView.GetColumns:THeaderSections;
begin
  Result:=F_Header.Sections;
end;

function TW32TreeListView.GetColumnFromOriginalIndex(i: longint
  ): THeaderSection;
var j:longint;
begin
  {$IFDEF LCL}
    for j:=0 to F_Header.Sections.count-1 do
      if F_Header.Sections[j].OriginalIndex=i then
        exit(F_Header.Sections[j]);
    result:=nil;
  {$ELSE}
    result:=F_Header.Sections[i];
  {$ENDIF}
end;

function TW32TreeListView.GetItemAtPos(const y:integer):TTreeListItem;
var i,startY:integer;
begin
  startY:=TopPos;
  result:=nil;
  for i:=0 to Items.Count-1 do begin
    result:=(TObject(Items[i]) as TTreeListItem).GetItemAtPos(self,y,startY);
    if result<>nil then exit;
  end;
end;

function TW32TreeListView.GetItemAtPosWithIndentSet(const y:integer):TTreeListItem;
var i,startY:integer;
begin
  startY:=TopPos;
  result:=nil;
  for i:=0 to Items.Count-1 do begin
    result:=(TObject(Items[i]) as TTreeListItem).GetItemAtPosWithIndentSet(self,y,0,startY);
    if result<>nil then exit;
  end;
end;

function TW32TreeListView.GetRecordItemAtPos(const x,y:integer):TTreeListRecordItem;
var item:TTreeListItem;
begin
  result:=nil;
  item:=getItemAtPos(y);
  if item<>nil then
   result:= item.GetRecordItemAtPos(self,x);

end;


procedure TW32TreeListView.SetHotTrackFont(const value:TFont);
begin
  F_HotTrackFont.Assign(value);
end;
procedure TW32TreeListView.SetSelectedFont(const value:TFont);
begin
  F_SelectedFont.Assign(value);
end;
procedure TW32TreeListView.SetSelectHotTrackFont(const value:TFont);
begin
  F_SelectHotTrackFont.Assign(value);
end;

procedure TW32TreeListView.BeginUpdate;
begin
  include(InternOptions_tlio,tlioUpdating)
end;

procedure TW32TreeListView.EndUpdate;
begin
  exclude(InternOptions_tlio,tlioUpdating);
  _GeneralEvent(self);
  if F_Sorted then sort;
end;

function TW32TreeListView.VisibleRowCount:longint;
begin
  if RowHeight=0 then result:=0
  else  result:=RealClientHeight div RowHeight;
end;

procedure TW32TreeListView.sort;
begin
  Items.Sort(CompareItems);
  if assigned(F_OnItemsSorted) then F_OnItemsSorted(self);
  Paint;
end;

procedure TW32TreeListView.ensureVisibility(item: TTreeListItem);
var rindex:longint;
    temp: TTreeListItem;
begin
  temp:=item.Parent;
  while temp<>nil do begin
    if not temp.Expanded then temp.Expand;
    temp:=temp.Parent;
  end;
  rindex:=Items.RealIndexOf(item,[]);
  if rindex<F_VScroll.Position then F_VScroll.Position:=rindex
  else if rindex>F_VScroll.Position+VisibleRowCount-1 then F_VScroll.Position:=rindex-VisibleRowCount+1;

end;

function TW32TreeListView.ColumnFromOriginalIndex(index: longint): THeaderSection;
var i:longint;
begin
  result:=nil;
  {$Ifdef FPC}
    for i:=0 to F_Header.Sections.count-1 do
      if F_Header.Sections[i].OriginalIndex = index then
        exit(F_Header.Sections[i]);
  {$ELSE}
    if index <Columns.count-1 then
      result:=Columns[index];
  {$ENDIF}
end;

procedure TW32TreeListView.createUserColumnVisibilityPopupMenu();
var mi: TMenuItem;
    i:longint;
begin
  if F_HeaderColumnPopupMenu=nil then
    F_HeaderColumnPopupMenu:=TPopupMenu.Create(self);
  if F_Header.PopupMenu<>F_HeaderColumnPopupMenu then F_Header.PopupMenu:=F_HeaderColumnPopupMenu;
  F_HeaderColumnPopupMenu.Items.Clear;
  for i:=0 to Columns.count-1 do begin
    mi:=TMenuItem.Create(F_HeaderColumnPopupMenu);
    mi.OnClick:=ColumnPopupMenuClick;
    mi.Caption:=Columns[i].Text;
    mi.Checked:=Columns[i].visible;
    mi.tag:=i;
    F_HeaderColumnPopupMenu.Items.Add(mi);
  end;
end;

function TW32TreeListView.serializeColumnWidths: string;
var i:longint;
    vis:boolean;
    sec:THeaderSection;
begin
  Result:='';
  for i:=0 to F_Header.Sections.Count-1 do begin
    sec:=ColumnFromOriginalIndex(i);
    {$ifdef fpc}
      vis:=sec.Visible;
      if not vis then
        sec.Visible :=true;
    {$endif}
    result:=result+IntToStr(sec.Width)+',';
    {$ifdef fpc}
      if not vis then sec.Visible :=false;
    {$endif}
  end;
end;

function TW32TreeListView.serializeColumnOrder: string;
var i:longint;
begin
  result:='';
  for i:=0 to F_Header.Sections.Count-1 do
    result+= IntToStr(ColumnFromOriginalIndex(i).Index)+',';
end;

function TW32TreeListView.serializeColumnVisibility: string;
var i:longint;
begin
  result:='';
  for i:=0 to F_Header.Sections.count-1 do
    {$ifdef fpc}
    if not ColumnFromOriginalIndex(i).Visible then
      result+='-'
     else
     {$endif}result:=result+'+';
end;

procedure TW32TreeListView.deserializeColumnWidths(s: string);
var i:longint;
    sep: longint;
begin
  i:=0;
  while i<F_Header.Sections.Count do begin
    sep:=pos(',',s);
    if (sep=0) then break;
    ColumnFromOriginalIndex(i).Width:=StrToInt(trim(copy(s,1,sep-1)));
    delete(s,1,sep);
    inc(i);
  end;
end;

procedure TW32TreeListView.deserializeColumnOrder(s: string);
var i:longint;
    sep: longint;
    tempOrder: array[0..20] of longint;
begin
{$ifdef fpc}
  //setting random index can changes other ones, therefore they will be set ascending
  //setlength(tempOrder,F_Header.Sections.Count);
  for i:=0 to high(tempOrder) do
    tempOrder[i]:=i;
  i:=0;
  while i<F_Header.Sections.Count do begin
    sep:=pos(',',s);
    if (sep=0) then break;
    tempOrder[i]:=StrToInt(trim(copy(s,1,sep-1)));
    delete(s,1,sep);
    inc(i);
  end;
  for i:=0 to F_Header.Sections.count-1 do
    ColumnFromOriginalIndex(tempOrder[i]).Index:=i;
{$endif}
end;

procedure TW32TreeListView.deserializeColumnVisibility(s: string);
var i:longint;
begin
{$ifdef fpc}
  for i:=0 to min(length(s)-1,F_Header.Sections.Count-1) do
    ColumnFromOriginalIndex(i).Visible:=s[i+1]='+';
{$endif}
end;

procedure TW32TreeListView.setImageList(const images:TImageList);
begin
  F_ImageList:=images;
end;

procedure TW32TreeListView.SetRowHeight(const newHeight:integer);
begin
  if newHeight and $1=$1 then F_RowHeight:=newHeight+1
  else F_RowHeight:=newHeight;
end;

procedure TW32TreeListView.SetHotTrackSubTextItems(const value:boolean);
begin
//  if value then hotTrackedTextItem:=
//  else hotTrackedTextItem:=nil;
  F_HotTrackSubTextItems:=value;
end;

function TW32TreeListView.RealControlHeight(c: Twincontrol): longint;
var r:TRect;
begin
  GetWindowRect(c.Handle,r);
  result:=r.bottom-r.top;
end;

function TW32TreeListView.RealClientHeight: longint;
begin
  result:=ClientHeight-RealControlHeight(F_Header)-HeaderItemDistance;
  if F_HScroll.Visible then result:=result-RealControlHeight(F_HScroll);
end;

procedure TW32TreeListView.DrawAlignDotLine(x,y:integer;const x2,y2:integer;const color:TColor);
var dc:HDC;
     F_HeaderHeight:integer;
begin
  dc:=Canvas.Handle;
  F_HeaderHeight:=F_Header.Height;
  if y2<F_HeaderHeight then exit;
  if y<F_HeaderHeight then y:=F_HeaderHeight;
  {$R-}
  if x=x2 then begin
    while (y<=y2) do begin
      SetPixel(dc,x,y,color);
      inc(y,2);
    end;
  end else begin
    while (x<=x2) do begin
      SetPixel(dc,x,y,color);
      inc(x,2);
    end;
  end;
end;

function TW32TreeListView.CompareItems(i1, i2: TTreeListItem): longint;
var t1,t2:string;
    v1, v2: longint;
begin
  if assigned(F_OnCompareItems) then begin
    result:=0;
    F_OnCompareItems(self,i1,i2,result);
   end else begin
    t1:=i1.RecordItemsText[F_SortColumn];
    t2:=i2.RecordItemsText[F_SortColumn];
    if TryStrToInt(t1,v1) and TryStrToInt(t2,v2) then begin
      if v1<v2 then result:=-1
      else if v1>v2 then result:=1
      else result:=0;
    end else result:=CompareText(t1,t2);
  end;
  if F_SortColumnInverted then result:=-result;
end;

procedure TW32TreeListView.BeginMultipleUpdate;
begin
  inc(RedrawBlock);
end;

procedure TW32TreeListView.EndMultipleUpdate;
begin
  dec(RedrawBlock);
  if RedrawBlock=0 then _GeneralEvent(Self);
end;

//Interne Kommunikation mit Unterkomponenten
procedure TW32TreeListView._GeneralEvent(Sender: TObject);
begin
  if not HandleAllocated then exit;
  UpdateScrollBarPos;
  UpdateScrollSize;
  paint;
end;

procedure TW32TreeListView._HeaderSectionTrack(HeaderControl: TEventHeaderControl; Section: THeaderSection; Width: Integer; State: TSectionTrackState);
begin
  UpdateScrollSize;
  if assigned(F_HeaderSectionTrack) then F_HeaderSectionTrack(HeaderControl,Section,Width,State);
  paint;
end;
procedure TW32TreeListView._HeaderSectionResize(HeaderControl: TEventHeaderControl; Section: THeaderSection);
begin
  UpdateScrollSize;
  if assigned(F_HeaderSectionResize) then F_HeaderSectionResize(HeaderControl,Section);
  paint;
end;

procedure TW32TreeListView._HeaderSectionClick(HeaderControl: TEventHeaderControl; Section: THeaderSection);
var NewSortColumn,i:Longint;
    cursor: TPoint;
begin
  if not F_Sorted then exit;
  if Section=nil then begin
    GetCursorPos(cursor);
    cursor:=HeaderControl.ScreenToClient(cursor);
    for i := 0 to HeaderControl.Sections.Count - 1 do
      if (HeaderControl.Sections[i].Left<cursor.x)and
        (HeaderControl.Sections[i].right>cursor.x) then begin
          section:=HeaderControl.Sections[i];
          break;
        end;
    if Section=nil  then exit;
  end;
  {$IFDEF LCL}
  NewSortColumn:=Section.OriginalIndex;
  {$ELSE}
  NewSortColumn:=Section.Index;
  {$ENDIF}
  if F_SortColumn=NewSortColumn then F_SortColumnInverted:=not F_SortColumnInverted
  else begin
    F_SortColumn:=NewSortColumn;
    F_SortColumnInverted:=false;
  end;
  if assigned(F_OnUserSortItems) then F_OnUserSortItems(self,F_SortColumn,F_SortColumnInverted);
  sort;
end;

procedure TW32TreeListView._HeaderSectionDblClick(
  HeaderControl: TEventHeaderControl; Section: THeaderSection);
var i,w,maxw:longint;
begin
  maxw:=0;
  for i:=0 to items.count-1 do begin
    {$ifdef fpc}
    w:=Items[i].GetMaxColumnWidth(section.OriginalIndex);
    {$else}
    w:=Items[i].GetMaxColumnWidth(section.index);
    {$endif}
    if w>maxw then maxw:=w;
  end;
  if maxw+5>section.Width then section.width:=maxw+5
  else if Section.width+10>maxw+5 then section.width:=maxw+5;
end;

procedure TW32TreeListView._HeaderSectionEndDrag(Sender: TObject);
begin
  _GeneralEvent(Sender);
end;

procedure TW32TreeListView._HScrollChange(Sender: TObject);
begin
  UpdateScrollBarPos;
//  UpdateScrollSize;
  if assigned(F_HScrollBarChange) then F_VScrollBarChange(F_HScroll);
  paint;
end;

procedure TW32TreeListView._VScrollChange(Sender: TObject);
begin
  UpdateScrollBarPos;
//  UpdateScrollSize;
  if assigned(F_VScrollBarChange) then F_VScrollBarChange(F_VScroll);
  paint;
end;

procedure TW32TreeListView.UpdateScrollBarPos;
begin
  if (tlioDeleting in InternOptions_tlio) or
     (tlioUpdating in InternOptions_tlio) or
     (RedrawBlock>0) then exit;
  F_Header.left:=-F_HScroll.Position;

  F_VScroll.Left:=ClientWidth-F_VScroll.Width;
  F_VScroll.Top:=F_Header.Height;
  F_VScroll.Height:=ClientHeight-F_VScroll.Top-F_HScroll.Height;

  F_HScroll.Top:=ClientHeight-F_HScroll.Height;
  F_HScroll.Width:=ClientWidth-F_VScroll.Width;
end;

procedure TW32TreeListView.selectRange(a, b: TTreeListItem;mouseSelect:boolean=false);
var meetA, meetB: boolean;
  procedure setSelection(list: TTreeListItems);
  var i:longint;
  begin
    for i:=0 to list.count-1 do begin
      if meetB then begin
        if mouseSelect then list[i].F_MouseSelected:=false
        else list[i].Selected:=false
      end else if meetA or (list[i]=a) then begin
        meetA:=true;
        if mouseSelect then list[i].F_MouseSelected:=true
        else list[i].Selected:=true;
        if list[i]=b then meetB:=true;
      end;
      setSelection(list[i].SubItems);
    end;
  end;

var temp: TTreeListItem;
begin
  if items.count=0 then exit;
  if a=nil then a:=items[0];
  if b=nil then b:=items[items.count-1];
  if items.RealIndexOf(a,[ricCountCollapsedsubItems])>items.RealIndexOf(b,[ricCountCollapsedsubItems]) then begin
    temp:=a;
    a:=b;
    b:=temp;
  end;
  BeginMultipleUpdate;
  meetA:=false;
  meetB:=false;
  try
    setSelection(Items);
  finally
    EndMultipleUpdate;
  end;
end;

procedure TW32TreeListView.UpdateScrollSize;
var i,j:integer;
begin
  if (tlioDeleting in InternOptions_tlio) or
     (tlioUpdating in InternOptions_tlio) or
     (RedrawBlock>0) then exit;
  i:=Items.GetRealItemCount([])-VisibleRowCount; //Anzahl der nicht anzeigbaren Items
  if i-1>F_VScroll.Min then begin
    //F_VScroll.Enabled:=false;
    F_VScroll.Enabled:=true;
    F_VScroll.Max:=i-1;
    F_VScroll.PageSize:=VisibleRowCount;
    F_VScroll.LargeChange:=VisibleRowCount;
  end else begin
    //F_VScroll.Enabled:=true;
    F_VScroll.Position:=0;
    F_VScroll.Enabled:=false;
  end;
  //F_VScroll.PageSize:=(ClientHeight-F_HScroll.Height*3-F_Header.Height) div (F_VScroll.Max - F_VScroll.Min + 1);

  j:=0;
  for i:=0 to F_Header.Sections.Count-1 do begin
    j:=j+F_Header.Sections[i].Width;
  end;
  i:=j-width+F_VScroll.Width;
  if i>0 then begin
    F_HScroll.Enabled:=true;
    F_HScroll.max:=i;
    F_HScroll.PageSize:=F_HScroll.width;
    F_HScroll.LargeChange:=F_HScroll.width;
  end else begin
    //F_HScroll.Enabled:=true;
    F_HScroll.Position:=0;
    F_HScroll.Enabled:=false;
  end;
end;

//Messages
procedure TW32TreeListView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (AComponent=F_ImageList) and (Operation=opRemove) then
    F_ImageList:=nil;
  inherited;
end;

procedure TW32TreeListView.WndProc(var message:TMessage);
var tempRecordItem:TTreeListRecordItem;
    itemAtPos,nextToFocus: TTreeListItem;
    shiftState: TShiftState;
    cursorPos: tpoint;
begin
  nextToFocus:=nil;
  case message.Msg of
    WM_GETDLGCODE:  message.Result:=DLGC_WANTARROWS or DLGC_WANTCHARS;
    WM_MOUSEWHEEL: if F_VScroll.Visible and F_VScroll.Enabled then begin
      F_MouseWheelDelta:=F_MouseWheelDelta+TWMMouseWheel(message).WheelDelta;
      if (F_MouseWheelDelta<=-120) or (F_MouseWheelDelta>=120) then begin
        F_VScroll.Position:=F_VScroll.Position-F_MouseWheelDelta div 120;
        F_MouseWheelDelta:=0;
      end;
    end;
    WM_MOUSEMOVE: begin
      inherited;
      shiftState:=KeyDataToShiftState(TWMMouseMove(message).Keys);
      if (F_ClickedItem<>nil) and (MK_LBUTTON and message.wParam <> 0) and
         (multiSelect) then begin
        F_RealMousePos:=point(TWMMouseMove(message).XPos+F_HScroll.Position,
                              TWMMouseMove(message).YPos+F_VScroll.Position);
        if not F_MouseSelecting then begin
          F_MouseSelecting:=sqr(F_RealClickPos.x-F_RealMousePos.x)+
                            sqr(F_RealClickPos.y-F_RealMousePos.y)>100 ;
        end;
        if F_MouseSelecting then begin
          itemAtPos:=GetItemAtPos(TWMMouseMove(message).YPos);
          if F_ClickedItem.Selected then begin
            F_ClickedItem.F_MouseSelected:=true;
            F_ClickedItem.Selected:=false;
          end;
          if itemAtPos<>nil then selectRange(F_ClickedItem,itemAtPos,true);
        end;
      end;

      tempRecordItem:=GetRecordItemAtPos(TWMMouseMove(message).XPos,TWMMouseMove(message).YPos);
      if tempRecordItem<>nil then begin
        if ToolTips then
          if (GetColumnFromOriginalIndex(tempRecordItem.F_Index)<>nil) and
            (tempRecordItem.GetNecessaryWidth(self)+10>GetColumnFromOriginalIndex(tempRecordItem.F_Index).Width) then begin
            hint:=tempRecordItem.Text;
            ShowHint:=true;
          end else ShowHint:=false;
      end;
      IF HotTrackSubTextItems THEN
        if tempRecordItem<>hotTrackedRecordItem then begin
          hotTrackedRecordItem:=tempRecordItem;
          if hotTrackedRecordItem<>nil then Cursor:=crHandPoint
          else Cursor:=crDefault;
          paint;
        end;
    end;
    WM_LBUTTONDOWN: begin
      shiftState:=KeyDataToShiftState(TWMLBUTTONDOWN(message).Keys);
      F_RealClickPos:=point(TWMLBUTTONDOWN(message).XPos+F_HScroll.Position,TWMLBUTTONDOWN(message).YPos+F_VScroll.Position);
      SetFocus;
      itemAtPos:=GetItemAtPos(TWMLBUTTONDOWN(message).YPos);
      if (itemAtPos<>nil) and
         (TWMLBUTTONDOWN(message).XPos<itemAtPos.GetExtendingButtonPos+9) and
         (TWMLBUTTONDOWN(message).XPos>itemAtPos.GetExtendingButtonPos) then begin
        itemAtPos.Expanded:=not itemAtPos.Expanded;
        if itemAtPos=focused then paint;
      end;
      if (itemAtPos<>nil)and(assigned (F_ClickAtItem)) then F_ClickAtItem(self,itemAtPos);
      if (itemAtPos<>nil)and(assigned (F_ClickAtRecordItem)) then begin
        tempRecordItem:=itemAtPos.GetRecordItemAtPos(self,TWMLBUTTONDOWN(message).XPos);
        if tempRecordItem<>nil then
          F_ClickAtRecordItem(self,itemAtPos,tempRecordItem);
      end;
      nextToFocus:=itemAtPos;
      F_ClickedItem:=itemAtPos;
      if multiSelect and (nextToFocus<>nil) and (ssCtrl in shiftState) then
        nextToFocus.Selected:=not nextToFocus.Selected;
      inherited;
    end;
    WM_LBUTTONUP: begin
      if F_MouseSelecting then begin
        F_ClickedItem:=nil;
        F_MouseSelecting:=false;
        setMouseSelection(Items);
        paint;
      end;
      inherited;
    end;
    WM_KEYDOWN: begin
      shiftState:=KeyDataToShiftState(TWMKeyDown(message).KeyData);
      case TWMKeyDown(message).CharCode of
        VK_UP:
          if focused=nil then nextToFocus:=Items[0]
          else nextToFocus:=focused.GetPrevVisibleItem;
        VK_DOWN:
          if focused<>nil then nextToFocus:=focused.GetNextVisibleItem()
          else if items.count>0 then nextToFocus:=Items[0];//items.count-1];

        VK_HOME:
          if items.count>0 then nextToFocus:=Items[0];

        VK_END:
          if items.count>0 then nextToFocus:=Items[items.count-1].GetLastVisibleSubSubItem;

        VK_PRIOR:
          if focused<>nil then nextToFocus:=focused.GetPrevVisibleItem(VisibleRowCount)
          else if items.count>0 then nextToFocus:=Items[0];

        VK_NEXT:
          if focused<>nil then nextToFocus:=focused.GetNextVisibleItem(VisibleRowCount)
          else if items.count>0 then nextToFocus:=Items[items.count-1];

        VK_RIGHT:
          if focused<>nil then begin
            if not focused.Expanded then focused.Expand;
            if focused.SubItems.Count>0 then nextToFocus:=focused.SubItems[0]
            else nextToFocus:=focused;
          end;

        VK_LEFT:
          if focused<>nil then begin
            if (focused.Expanded) and (focused.SubItems.Count>0) then focused.Collapse
            else if focused.Parent<>nil then nextToFocus:=focused.Parent;
            if nextToFocus=nil then nextToFocus:=focused;
          end;

        VK_BACK:
          if (focused<>nil) and (focused.Parent<>nil) then nextToFocus:=focused.Parent;

        VK_SPACE:
          if (focused <> nil) and (ssCtrl in shiftState) then begin
            if ssShift in shiftState then Selected:=focused
            else focused.Selected:=not focused.Selected;
            F_BaseSelect:=focused;
          end;
        else inherited;
      end;
    end;
    WM_SETFOCUS:    begin
                      Paint;
                      inherited;
                    end;
    WM_KILLFOCUS:   begin
                      paint;
                      inherited;
                    end;
    WM_SIZE:        begin
                      UpdateScrollBarPos;
                      UpdateScrollSize;
                      paint;
                      inherited;
                    end;
    WM_PAINT:       begin
                      if tlioDeleting in InternOptions_tlio then begin
                        inherited;
                        exit;
                      end;
                      include(InternOptions_tlio,tlioDisablePainting);
                      try
                        inherited;
                      finally
                        exclude(InternOptions_tlio,tlioDisablePainting);
                      end;
                      paint;
                    end;
    WM_ERASEBKGND: message.Result:=1;
    WM_RBUTTONUP: begin
      GetCursorPos(cursorPos);
      if assigned(PopupMenu) then PopupMenu.PopUp(cursorPos.x,cursorPos.Y)
      else inherited;
    end;
    WM_KEYUP:
      if (TWMKeyUp(message).CharCode = VK_APPS) and assigned(PopupMenu) then begin
        GetCursorPos(cursorPos);
        PopupMenu.PopUp(cursorPos.X,cursorPos.y)
      end else inherited;
    else inherited;
  end;
  if nextToFocus<>nil then begin //select or focus
    if not multiSelect or (shiftState=[]) then begin
      Selected:=nextToFocus;
      F_BaseSelect:=Selected;
    end else if shiftState=[ssCtrl] then focused:=nextToFocus
    else if ssShift in shiftState then begin
      F_Focused:=nextToFocus;
      SelectRange(F_BaseSelect,nextToFocus);
      ensureVisibility(nextToFocus);
    end;
  end;
    
end;

//Ausgaberoutinen
procedure TW32TreeListView.Paint;
  function srect(x1,y1,x2,y2:longint):trect;
  begin
    if y1<y2 then begin
      result.top:=y1;
      result.Bottom:=y2;
    end else begin
      result.Bottom:=y1;
      result.top:=y2;
    end;
    if x1<x2 then begin
      result.Left:=x1;
      result.Right:=x2;
    end else begin
      result.Right:=x1;
      result.Left:=x2;
    end;
  end;
var i,ypos,xpos:integer;
 //   doubleBuffer:Tbitmap;
    oldHandle:Thandle;
    defaultDraw:boolean;
begin
  //if (tlioUpdating in InternOptions_tlio) then exit;
  //windows.Beep(1000,100);
  if (tlioUpdating in InternOptions_tlio) or
     (tlioDisablePainting in InternOptions_tlio) or
     (tlioDeleting in InternOptions_tlio) or
     (f_items=nil) or (f_items.freeing) or
     (RedrawBlock>0) then exit;
//  windows.Beep(1000,100);
  //F_VScroll.Repaint;
  //F_HScroll.Repaint;
  {$IFDEF LCL}
    for i:=0 to F_Header.Sections.Count-1 do
      if F_Header.Sections[i].OriginalIndex=0 then begin
        F_TreeSectionPos:=rect(F_Header.Sections[i].Left-F_HScroll.Position,0,F_Header.Sections[i].Right-F_HScroll.Position,0);
        break;
      end;
  {$ELSE}
    F_TreeSectionPos:=rect(F_Header.Sections[0].Left-F_HScroll.Position,0,F_Header.Sections[0].Right-F_HScroll.Position,0);
  {$ENDIF}
  PaintEvenItem:=true;
  doubleBuffer.SetSize(Width,Height);
  //if Canvas.Handle=0 then exit;
  //canvas.Lock;
  try
    //doubleBuffer.Canvas.Lock;
    oldHandle:=Canvas.Handle;
    try
      with Canvas do begin
        //Background
        defaultDraw:=DoCustomBackgroundDrawEvent(cdetPrePaint);
        if defaultDraw then begin
          pen.Style:=psClear;
          brush.Style:=bsSolid;
          brush.Color:=clBtnFace;
          Rectangle(ClientWidth-F_VScroll.Width,ClientHeight-F_HScroll.Height,ClientWidth+1,ClientHeight+1);

          Handle:=doubleBuffer.Canvas.Handle; //Canvas verbiegen, mit z.B.: Canvas.LineTo wird nun in den Buffer gezeichnet

          pen.Style:=psClear;
          brush.Style:=bsSolid;
          brush.color:=F_BgColor;

//        Rectangle(handle,0,F_Header.Height,ClientWidth-F_VScroll.Width,ClientHeight-F_HScroll.Height);
          FillRect(rect(0,F_Header.Height,ClientWidth-F_VScroll.Width,ClientHeight-F_HScroll.Height));


        end;
        //Items
        ypos:=TopPos;
        if RootLineMode <> lmNone then StartX:=13
        else StartX:=3;
        xpos:=startx-F_HScroll.Position;
        for i:=0 to Items.count-1 do begin
          (TObject(Items[i]) as TTreeListItem).PaintTo(self,ypos,0,i = Items.count-1);
  //        if i=Items.count-2 then
//           DrawAlignDotLine(xpos-5,max(TopPos,f_header.height),xpos-5,ypos+RowHeight div 2,clBlack);
        end;
        //Lines
        if defaultDraw then begin
          xpos:=-F_HScroll.Position;
          for i:=0 to F_Header.Sections.Count-1 do begin
            inc(xpos,F_Header.Sections[i].Width);
            case VerticalLineMode of
              lmSolid: begin
                         pen.color:=VerticalLineColor;
                         pen.Style:=psSolid;
                         MoveTo(xpos,F_Header.Height);
                         LineTo(xpos,ClientHeight-F_HScroll.Height);
                       end;
              lmDot:   DrawAlignDotLine(xpos,F_Header.Height,xpos,ClientHeight-F_HScroll.Height,VerticalLineColor);
            end;
          end;
        end;
        if F_MouseSelecting then
          DrawFocusRect(srect(F_RealClickPos.x-F_HScroll.Position,F_RealClickPos.y-F_VScroll.Position,
                              F_RealMousePos.x-F_HScroll.Position,F_RealMousePos.y-F_VScroll.Position));
        DoCustomBackgroundDrawEvent(cdetPostPaint);
        Handle:=oldHandle; //Handle zur�ckbiegen, nun wird wieder ins Steuerelement gezeichnez
        CopyRect(rect(0,F_Header.Height,ClientWidth-F_VScroll.Width,ClientHeight-F_HScroll.Height),doubleBuffer.canvas,rect(0,F_Header.Height,ClientWidth-F_VScroll.Width,ClientHeight-F_HScroll.Height)); //DoubleBuffer ausgeben
      end;
    finally
      canvas.Handle:=oldHandle;
      //doubleBuffer.Canvas.Unlock;
      {doubleBuffer.free;}
    end;
  finally
    //canvas.Unlock;
  end;
end;

//Destroy
destructor TW32TreeListView.destroy;
begin
  Include(InternOptions_tlio,tlioDeleting);
  F_HotTrackFont.free;
  F_SelectHotTrackFont.free;
  F_SelectedFont.free;

  F_HScroll.free;
  F_VScroll.free;
  if F_HeaderColumnPopupMenu<>nil then F_HeaderColumnPopupMenu.free;
  F_Header.free;
  F_Items.free;
  DoubleBuffer.Free;
  inherited;
end;
procedure Register;
begin
  RegisterComponents('BeniBela', [TW32TreeListView]);
end;

end.







