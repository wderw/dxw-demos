unit Unit1;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
// definicje typów wskaźników do funkcji z DLL
  TDXW_InitWindow = function(hWnd: HWND): Integer; stdcall;
  TDXW_SetTargetWindow = procedure(TargetWindow: Integer); stdcall;
  TDXW_Demo3D = procedure(); stdcall;
  TDXW_DemoLines = procedure(numberOfLines: Integer); stdcall;
  TDXW_ReleaseDxwResources = procedure; stdcall;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CreateConsole;
  private
    // uchwyt do DLL
    DLLHandle: HMODULE;
    // wskaźniki do funkcji
    DXW_InitWindow: TDXW_InitWindow;
    DXW_SetTargetWindow: TDXW_SetTargetWindow;
    DXW_Demo3D: TDXW_Demo3D;
    DXW_DemoLines: TDXW_DemoLines;
    DXW_ReleaseDxwResources: TDXW_ReleaseDxwResources;
    DXWWindowID1: Integer;
    DXWWindowID2: Integer;
    DXWWindowID3: Integer;
    DXWWindowID4: Integer;
    function LoadDll: Boolean;
    function LoadFunctions: Boolean;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


// ładowanie DLL
function TForm1.LoadDll: Boolean;
begin
  Result := False;
  DLLHandle := LoadLibrary('../../../lib/dxw.dll');

  if DLLHandle = 0 then
  begin
    MessageBox(Handle, 'Failed to load dxw.dll', 'Error', MB_ICONERROR or MB_OK);
    Exit;
  end;

  Result := True;
end;


// ładowanie funkcji z dll
function TForm1.LoadFunctions: Boolean;
begin
  Result := False;

  @DXW_InitWindow := GetProcAddress(DLLHandle, 'DXW_InitWindow');                    // inicjalizacja okna i uzyskanie ID
  @DXW_SetTargetWindow := GetProcAddress(DLLHandle, 'DXW_SetTargetWindow');          // ustawianie aktualnego okna po ID
  @DXW_Demo3D := GetProcAddress(DLLHandle, 'DXW_DemoRT');                            // demo start

  if not Assigned(DXW_InitWindow) or
     not Assigned(DXW_SetTargetWindow) or
     not Assigned(DXW_Demo3D) then
  begin
    MessageBox(Handle, 'Failed to load one or more functions from dxw.dll', 'Error', MB_ICONERROR or MB_OK);
    FreeLibrary(DLLHandle);
    Exit;
  end;

  Result := True;
end;

procedure TForm1.CreateConsole;
var
  StdOut: THandle;
begin
  AllocConsole;  // Funkcja win32 do szybkiej alokacji konsoli
  StdOut := GetStdHandle(STD_OUTPUT_HANDLE);

  // Przekieruj wyjscie standardowe do konsoli
  if StdOut <> INVALID_HANDLE_VALUE then
  begin
    AssignFile(Output, '');
    Rewrite(Output);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // otwórz konsolę do przeglądania logów z dll
  CreateConsole;
  Writeln('[application log] hello from delphi!');

  if not LoadDll then
    Exit;

  if not LoadFunctions then
    Exit;

  // inicjalizacja zasobów directx
  DXWWindowID1 := DXW_InitWindow(Panel1.Handle);
  // start demo na okno 1,2,3,4
  DXW_SetTargetWindow(DXWWindowID1);
  DXW_Demo3D();

  DXWWindowID2 := DXW_InitWindow(Panel2.Handle);
  DXW_SetTargetWindow(DXWWindowID2);
  DXW_Demo3D();


  DXWWindowID3 := DXW_InitWindow(Panel3.Handle);
  DXW_SetTargetWindow(DXWWindowID3);
  DXW_Demo3D;

  DXWWindowID4 := DXW_InitWindow(Panel4.Handle);
  DXW_SetTargetWindow(DXWWindowID4);
  DXW_Demo3D;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  //if Assigned(DXW_ReleaseDxwResources) then
  //  DXW_ReleaseDxwResources;

  if DLLHandle <> 0 then
    FreeLibrary(DLLHandle);
end;

end.
