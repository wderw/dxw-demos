object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'rysowanie 2d'
  ClientHeight = 683
  ClientWidth = 946
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 937
    Height = 667
    Caption = 'Panel1'
    TabOrder = 0
    object Button1: TButton
      Left = 824
      Top = 608
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end
