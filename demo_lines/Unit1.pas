unit Unit1;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
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
    DLLHandle: HMODULE;
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

function TForm1.LoadDll: Boolean;
begin
  Result := False;
  DLLHandle := LoadLibrary('dxw.dll');

  if DLLHandle = 0 then
  begin
    MessageBox(Handle, 'Failed to load dxw.dll', 'Error', MB_ICONERROR or MB_OK);
    Exit;
  end;

  Result := True;
end;

function TForm1.LoadFunctions: Boolean;
begin
  Result := False;

  DXW_InitWindow := GetProcAddress(DLLHandle, 'DXW_InitWindow');
  DXW_SetTargetWindow := GetProcAddress(DLLHandle, 'DXW_SetTargetWindow');
  DXW_DemoLines := GetProcAddress(DLLHandle, 'DXW_DemoLines');
  DXW_ReleaseDxwResources := GetProcAddress(DLLHandle, 'DXW_ReleaseDxwResources');

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

  DXWWindowID := DXW_InitWindow(Panel1.Handle);

  DXW_SetTargetWindow(DXWWindowID);
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
