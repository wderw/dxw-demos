unit Unit1;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
// definicje typów wskaźników do funkcji z DLL
  TDXW_InitWindow = function(hWnd: HWND): Integer; stdcall;
  TDXW_SetTargetWindow = procedure(TargetWindow: Integer); stdcall;
  TDXW_DemoNRT = procedure(fi: Single); stdcall;
  TDXW_Present = procedure(WaitForVerticalSync: Integer); stdcall;
  TDXW_ReleaseDxwResources = procedure; stdcall;
  TDXW_ResizeWindow = procedure(width: Integer; height: Integer); stdcall;
  TDXW_IsInitialized = function(): Boolean; stdcall;

type
  TForm1 = class(TForm)
    CheckBox1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CreateConsole;
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AppIdle(Sender: TObject; var Done: Boolean);
  private
    // uchwyt do DLL
    DLLHandle: HMODULE;
    // wskaźniki do funkcji
    DXW_InitWindow: TDXW_InitWindow;
    DXW_SetTargetWindow: TDXW_SetTargetWindow;
    DXW_DemoNRT: TDXW_DemoNRT;
    DXW_Present: TDXW_Present;
    DXW_ReleaseDxwResources: TDXW_ReleaseDxwResources;
    DXW_ResizeWindow: TDXW_ResizeWindow;
    DXW_IsInitialized: TDXW_IsInitialized;
    DXWWindowID: Integer;
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

  DXW_InitWindow := GetProcAddress(DLLHandle, 'DXW_InitWindow');                    // inicjalizacja okna i uzyskanie ID
  DXW_SetTargetWindow := GetProcAddress(DLLHandle, 'DXW_SetTargetWindow');          // ustawianie aktualnego okna po ID
  DXW_DemoNRT := GetProcAddress(DLLHandle, 'DXW_DemoNRT');                          // demo start
  DXW_Present := GetProcAddress(DLLHandle, 'DXW_Present');                          // zamiana buforów
  DXW_ReleaseDxwResources := GetProcAddress(DLLHandle, 'DXW_ReleaseDxwResources');  // zwalnianie zasobów biblioteki
  DXW_ResizeWindow := GetProcAddress(DLLHandle, 'DXW_ResizeWindow');                    // zmiana wielkości okna dxw
  DXW_IsInitialized := GetProcAddress(DLLHandle, 'DXW_IsInitialized');              // czy okno już jest gotowe do rysowania

  if not Assigned(DXW_InitWindow) or
     not Assigned(DXW_SetTargetWindow) or
     not Assigned(DXW_DemoNRT) or
     not Assigned(DXW_Present) or
     not Assigned(DXW_ReleaseDxwResources) or
     not Assigned(DXW_ResizeWindow) then
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

  { inicjalizacja zasobów directx dla Panel1.
    Biblioteka generuje WindowID które zapisujemy }
  DXWWindowID := DXW_InitWindow(Form1.Handle);

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(DXW_ReleaseDxwResources) then
    DXW_ReleaseDxwResources;

  if DLLHandle <> 0 then
    FreeLibrary(DLLHandle);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
if DXW_IsInitialized = True
then
begin
  if checkBox1.Checked then
  begin
    DXW_ResizeWindow(ClientWidth, ClientHeight);
  end;

  DXW_DemoNRT(1.0);
  DXW_Present(1);
end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Application.OnIdle := AppIdle;
end;

procedure TForm1.AppIdle(Sender: TObject; var Done: Boolean);
begin
  Application.OnIdle := nil;

  DXW_DemoNRT(1.0);
  DXW_Present(1);
end;


end.
