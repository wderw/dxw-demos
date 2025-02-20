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
  TDXW_D2D_ResetTransformMatrixFunc = procedure; stdcall;
  TDXW_D2D_DrawTextFunc = procedure(Text: PWideChar; Left, Top, Right, Bottom: Single); stdcall;
  TDXW_PresentFunc = procedure(WaitForVerticalSync: Integer); stdcall;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
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
    DXW_D2D_DrawLine: TDXW_D2D_DrawLineFunc;
    DXW_D2D_SetScale: TDXW_D2D_SetScaleFunc;
    DXW_D2D_SetRotation: TDXW_D2D_SetRotationFunc;
    DXW_D2D_SetTranslation: TDXW_D2D_SetTranslationFunc;
    DXW_D2D_RecalculateTransformMatrix: TDXW_D2D_RecalculateTransformMatrixFunc;
    DXW_D2D_ResetTransformMatrix: TDXW_D2D_ResetTransformMatrixFunc;
    DXW_D2D_DrawText: TDXW_D2D_DrawTextFunc;
    DXW_Present: TDXW_PresentFunc;

    DXWWindowID: Integer;
    function LoadDll: Boolean;
    function LoadFunctions: Boolean;
    procedure CreateConsole;
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

  @DXW_InitWindow := GetProcAddress(DLLHandle, 'DXW_InitWindow');                    // inicjalizacja okna i uzyskanie ID
  @DXW_SetTargetWindow := GetProcAddress(DLLHandle, 'DXW_SetTargetWindow');          // ustawianie aktualnego okna po ID
  @DXW_ReleaseDxwResources := GetProcAddress(DLLHandle, 'DXW_ReleaseDxwResources');  // zwalnianie zasobów biblioteki
  @DXW_Present := GetProcAddress(DLLHandle, 'DXW_Present');

  @DXW_D2D_BeginDraw := GetProcAddress(DLLHandle, 'DXW_D2D_BeginDraw');
  @DXW_D2D_EndDraw := GetProcAddress(DLLHandle, 'DXW_D2D_EndDraw');
  @DXW_D2D_Clear := GetProcAddress(DLLHandle, 'DXW_D2D_Clear');
  @DXW_D2D_DrawLine := GetProcAddress(DLLHandle, 'DXW_D2D_DrawLine');
  @DXW_D2D_SetScale := GetProcAddress(DLLHandle, 'DXW_D2D_SetScale');
  @DXW_D2D_SetRotation := GetProcAddress(DLLHandle, 'DXW_D2D_SetRotation');
  @DXW_D2D_SetTranslation := GetProcAddress(DLLHandle, 'DXW_D2D_SetTranslation');
  @DXW_D2D_RecalculateTransformMatrix := GetProcAddress(DLLHandle, 'DXW_D2D_RecalculateTransformMatrix');
  @DXW_D2D_ResetTransformMatrix := GetProcAddress(DLLHandle, 'DXW_D2D_ResetTransformMatrix');
  @DXW_D2D_DrawText := GetProcAddress(DLLHandle, 'DXW_D2D_DrawText');

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

procedure TForm1.Button1Click(Sender: TObject);
begin
  // od tego momentu wszystkie dalsze wywo³ania funkcji DXW dotycz¹ okna na Panel1
  DXW_SetTargetWindow(DXWWindowID);

  // rysowanie
  DXW_D2D_BeginDraw();                  // rozpocznij rysowanie 2D
  DXW_D2D_Clear(0, 0, 0, 1);            // wyczysc caly obszar kontrolki r,g,b,A (1 = pelny kolor, 0 = pelna przezroczystosc)

  DXW_D2D_DrawText(PWideChar('Hello from Delphi'), 50, 50, 200, 200);  // left, top, right, bottom

  DXW_D2D_SetScale(2.0, 3.0);           // skala               (S)
  DXW_D2D_SetRotation(15);              // obrot (w stopniach) (R)
  DXW_D2D_SetTranslation(200, 200);     // przesuniecie        (T)
  DXW_D2D_RecalculateTransformMatrix(); // przelicz polaczona macierz transformacji zgodnie ze wzorem: Transform = T * R * S
                                        // od tego momentu wszystkie wektory mno¿one s¹ przez macierz transformacji

  DXW_D2D_DrawText(PWideChar('Hello from Delphi 2'), 50, 50, 200, 200); // jeszcze raz ten sam tekst ale po na³o¿eniu transformacji

  DXW_D2D_ResetTransformMatrix();       // resetuje wszystkie macierze
  DXW_D2D_DrawText(PWideChar('Hello from Delphi 3'), 150, 150, 300, 300); // po zresetowaniu transformacji

  DXW_D2D_DrawLine(0, 0, Panel1.Width, Panel1.Height);  // narysuj linie bez zadnych dodatkowych transformacji

  DXW_D2D_EndDraw();                    // zakoncz rysowanie 2D
  DXW_Present(1);                       // wszystko do tej pory bylo rysowane na 2 buforze, dopiero present zamienia bufory miejscami i wyswietla
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
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(DXW_ReleaseDxwResources) then
    DXW_ReleaseDxwResources;

  if DLLHandle <> 0 then
    FreeLibrary(DLLHandle);
end;

end.
