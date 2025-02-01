unit Unit1;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
// definicje typów wskaŸników do funkcji z DLL
  TDXW_InitWindow = function(hWnd: HWND): Integer; stdcall;
  TDXW_SetTargetWindow = procedure(TargetWindow: Integer); stdcall;
  TDXW_DemoLines = procedure(LinesCount: Integer); stdcall;
  TDXW_ReleaseDxwResources = procedure; stdcall;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    // uchwyt do DLL
    DLLHandle: HMODULE;
    // wskaŸniki do funkcji
    DXW_InitWindow: TDXW_InitWindow;
    DXW_SetTargetWindow: TDXW_SetTargetWindow;
    DXW_DemoLines: TDXW_DemoLines;
    DXW_ReleaseDxwResources: TDXW_ReleaseDxwResources;
    DXWWindowID: Integer;
    function LoadDll: Boolean;
    function LoadFunctions: Boolean;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


// ³adowanie DLL
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


// ³adowanie funkcji z dll
function TForm1.LoadFunctions: Boolean;
begin
  Result := False;

  DXW_InitWindow := GetProcAddress(DLLHandle, 'DXW_InitWindow');                    // inicjalizacja okna i uzyskanie ID
  DXW_SetTargetWindow := GetProcAddress(DLLHandle, 'DXW_SetTargetWindow');          // ustawianie aktualnego okna po ID
  DXW_DemoLines := GetProcAddress(DLLHandle, 'DXW_DemoLines');                      // demo start
  DXW_ReleaseDxwResources := GetProcAddress(DLLHandle, 'DXW_ReleaseDxwResources');  // zwalnianie zasobów biblioteki

  if not Assigned(DXW_InitWindow) or
     not Assigned(DXW_SetTargetWindow) or
     not Assigned(DXW_DemoLines) or
     not Assigned(DXW_ReleaseDxwResources) then
  begin
    MessageBox(Handle, 'Failed to load one or more functions from dxw.dll', 'Error', MB_ICONERROR or MB_OK);
    FreeLibrary(DLLHandle);
    Exit;
  end;

  Result := True;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if not LoadDll then
    Exit;

  if not LoadFunctions then
    Exit;

  { inicjalizacja zasobów directx dla Panel1.
    Biblioteka generuje WindowID które zapisujemy }
  DXWWindowID := DXW_InitWindow(Panel1.Handle);

  // od tego momentu wszystkie dalsze wywo³ania funkcji DXW dotycz¹ okna na Panel1
  DXW_SetTargetWindow(DXWWindowID);

  // start demo
  DXW_DemoLines(1000000);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  //if Assigned(DXW_ReleaseDxwResources) then
  //  DXW_ReleaseDxwResources;

  if DLLHandle <> 0 then
    FreeLibrary(DLLHandle);
end;

end.
