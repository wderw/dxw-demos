unit Unit1;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
// definicje typów wskaŸników do funkcji z DLL
  TDXW_InitWindow = function(hWnd: HWND): Integer; stdcall;
  TDXW_SetTargetWindow = procedure(TargetWindow: Integer); stdcall;
  TDXW_ReleaseDxwResources = procedure; stdcall;
  TDXW_D2D_BeginDrawFunc = procedure; stdcall;
  TDXW_D2D_EndDrawFunc = procedure; stdcall;
  TDXW_D2D_ClearFunc = procedure(R, G, B, A: Single); stdcall;
  TDXW_D2D_DrawLineFunc = procedure(x0, y0, x1, y1: Single); stdcall;
  TDXW_D2D_SetScaleFunc = procedure(X, Y: Single); stdcall;
  TDXW_D2D_SetRotationFunc = procedure(Angle: Single); stdcall;
  TDXW_D2D_SetTranslationFunc = procedure(X, Y: Single); stdcall;
  TDXW_D2D_RecalculateTransformMatrixFunc = procedure; stdcall;
  TDXW_D2D_DrawTextFunc = procedure(Text: PWideChar; Left, Top, Right, Bottom: Single); stdcall;
  TDXW_D2D_FillRectangleFunc = procedure(Left, Top, Right, Bottom : Single); stdcall;
  TDXW_PresentFunc = procedure(WaitForVerticalSync: Integer); stdcall;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    // uchwyt do DLL
    DLLHandle: HMODULE;
    // wskaŸniki do funkcji
    DXW_InitWindow: TDXW_InitWindow;
    DXW_SetTargetWindow: TDXW_SetTargetWindow;
    DXW_ReleaseDxwResources: TDXW_ReleaseDxwResources;
    DXW_D2D_BeginDraw: TDXW_D2D_BeginDrawFunc;
    DXW_D2D_EndDraw: TDXW_D2D_EndDrawFunc;
    DXW_D2D_Clear: TDXW_D2D_ClearFunc;
    DXW_D2D_SetScale: TDXW_D2D_SetScaleFunc;
    DXW_D2D_SetRotation: TDXW_D2D_SetRotationFunc;
    DXW_D2D_SetTranslation: TDXW_D2D_SetTranslationFunc;
    DXW_D2D_RecalculateTransformMatrix: TDXW_D2D_RecalculateTransformMatrixFunc;
    DXW_D2D_DrawText: TDXW_D2D_DrawTextFunc;
    DXW_D2D_FillRectangle: TDXW_D2D_FillRectangleFunc;
    DXW_Present: TDXW_PresentFunc;

    DXWWindowID: Integer;
    function LoadDll: Boolean;
    function LoadFunctions: Boolean;
    procedure CreateConsole;
  public
  end;

var
  Form1: TForm1;
  alfa, fi : Single;

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

  @DXW_InitWindow := GetProcAddress(DLLHandle, 'DXW_InitWindow');                    // inicjalizacja okna i uzyskanie ID
  @DXW_SetTargetWindow := GetProcAddress(DLLHandle, 'DXW_SetTargetWindow');          // ustawianie aktualnego okna po ID
  @DXW_ReleaseDxwResources := GetProcAddress(DLLHandle, 'DXW_ReleaseDxwResources');  // zwalnianie zasobów biblioteki
  @DXW_Present := GetProcAddress(DLLHandle, 'DXW_Present');

  @DXW_D2D_BeginDraw := GetProcAddress(DLLHandle, 'DXW_D2D_BeginDraw');
  @DXW_D2D_EndDraw := GetProcAddress(DLLHandle, 'DXW_D2D_EndDraw');
  @DXW_D2D_Clear := GetProcAddress(DLLHandle, 'DXW_D2D_Clear');
  @DXW_D2D_SetScale := GetProcAddress(DLLHandle, 'DXW_D2D_SetScale');
  @DXW_D2D_SetRotation := GetProcAddress(DLLHandle, 'DXW_D2D_SetRotation');
  @DXW_D2D_SetTranslation := GetProcAddress(DLLHandle, 'DXW_D2D_SetTranslation');
  @DXW_D2D_RecalculateTransformMatrix := GetProcAddress(DLLHandle, 'DXW_D2D_RecalculateTransformMatrix');
  @DXW_D2D_DrawText := GetProcAddress(DLLHandle, 'DXW_D2D_DrawText');
  @DXW_D2D_FillRectangle := GetProcAddress(DLLHandle, 'DXW_D2D_FillRectangle');

  if not Assigned(DXW_InitWindow) or
     not Assigned(DXW_SetTargetWindow) or
     not Assigned(DXW_ReleaseDxwResources) then
  begin
    MessageBox(Handle, 'Failed to load one or more functions from dxw.dll', 'Error', MB_ICONERROR or MB_OK);
    FreeLibrary(DLLHandle);
    Exit;
  end;

  Result := True;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  // rysowanie
  DXW_D2D_BeginDraw();
  DXW_D2D_Clear(0, 0, 0, 1);

  alfa := alfa + 0.1;
  fi := fi + 5;

  DXW_D2D_SetScale(Sin(alfa) / 2 + 1, Cos(alfa) / 2 + 1);
  DXW_D2D_SetRotation(fi);
  DXW_D2D_SetTranslation(400, 300);
  DXW_D2D_RecalculateTransformMatrix();
  DXW_D2D_FillRectangle(-150, -150, 150, 150);
  DXW_D2D_DrawText(PWideChar('animacja nrt sterowana timerem'), 0, 0, 150, 150);

  DXW_D2D_EndDraw();
  DXW_Present(1);
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
  // otwórz konsolê do przegl¹dania logow z dll
  CreateConsole;
  Writeln('[application log] hello from delphi!');

  if not LoadDll then
    Exit;

  if not LoadFunctions then
    Exit;

  { inicjalizacja zasobów directx dla Panel1.
    Biblioteka generuje WindowID które zapisujemy }
  DXWWindowID := DXW_InitWindow(Panel1.Handle);

  // od tego momentu wszystkie dalsze wywo³ania funkcji DXW dotycz¹ okna na Panel1
  DXW_SetTargetWindow(DXWWindowID);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(DXW_ReleaseDxwResources) then
    DXW_ReleaseDxwResources; // wywal zasoby directx

  if DLLHandle <> 0 then
    FreeLibrary(DLLHandle);
end;

end.
