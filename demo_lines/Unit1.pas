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
    FDLLHandle: HMODULE;
    FDXW_InitWindow: TDXW_InitWindow;
    FDXW_SetTargetWindow: TDXW_SetTargetWindow;
    FDXW_DemoLines: TDXW_DemoLines;
    FDXW_ReleaseDxwResources: TDXW_ReleaseDxwResources;
    FDXWWindowID: Integer;
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
  FDLLHandle := LoadLibrary('dxw.dll');

  if FDLLHandle = 0 then
  begin
    MessageBox(Handle, 'Failed to load dxw.dll', 'Error', MB_ICONERROR or MB_OK);
    Exit;
  end;

  Result := True;
end;

function TForm1.LoadFunctions: Boolean;
begin
  Result := False;

  FDXW_InitWindow := GetProcAddress(FDLLHandle, 'DXW_InitWindow');
  FDXW_SetTargetWindow := GetProcAddress(FDLLHandle, 'DXW_SetTargetWindow');
  FDXW_DemoLines := GetProcAddress(FDLLHandle, 'DXW_DemoLines');
  FDXW_ReleaseDxwResources := GetProcAddress(FDLLHandle, 'DXW_ReleaseDxwResources');

  if not Assigned(FDXW_InitWindow) or
     not Assigned(FDXW_SetTargetWindow) or
     not Assigned(FDXW_DemoLines) or
     not Assigned(FDXW_ReleaseDxwResources) then
  begin
    MessageBox(Handle, 'Failed to load one or more functions from dxw.dll', 'Error', MB_ICONERROR or MB_OK);
    FreeLibrary(FDLLHandle);
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

  FDXWWindowID := FDXW_InitWindow(Panel1.Handle);

  FDXW_SetTargetWindow(FDXWWindowID);
  FDXW_DemoLines(1000000);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
//  if Assigned(FDXW_ReleaseDxwResources) then
//    FDXW_ReleaseDxwResources;

  if FDLLHandle <> 0 then
    FreeLibrary(FDLLHandle);
end;

end.
