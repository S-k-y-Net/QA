global $Pause, $hWnd, $GuiActive, $hWnd0
$Pause=true
$GuiActive=True

Func GiveHWND()
$hWnd = WinGetHandle("[ACTIVE]")
MsgBox(4096,"",$hWnd)
$Pause=False
Return $Pause
Return $hWnd
EndFunc
Func WinRefresh()
    $hWnd0 = WinGetHandle("[ACTIVE]")
    WinActivate($hWnd)
    Send("{F5}")
    Sleep(3000)
    WinActivate($hWnd0)
EndFunc
Func ExitProgram()
    Exit 0
EndFunc
$Form1_1 = GUICreate("��������������", 334, 249, 204, 125)
$Label1 = GUICtrlCreateLabel("1. ���������� ����, ������� ����� ���������", 16, 8, 240, 17)
$Label2 = GUICtrlCreateLabel("2 �������� ESC, ����� �������� ����������", 16, 24, 236, 17)
$Label3 = GUICtrlCreateLabel("3 �������� Pause/Break, ����� ����� �������� ���� ", 16, 40, 269, 17)
$Label4 = GUICtrlCreateLabel("4 �������� END, ����� ��������� ������ �������", 16, 56, 280, 17)
$Button1 = GUICtrlCreateButton("Close", 208, 168, 75, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
While $GuiActive=True

while $Pause=True
    HotKeySet('{ESC}', "GiveHWND")
    HotKeySet("{End}","ExitProgram")
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $Button1
            $GuiActive=False
            ExitProgram()

    EndSwitch
WEnd
While $Pause=False
    HotKeySet("{Pause}", "WinRefresh")
    HotKeySet("{End}","ExitProgram")
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $Button1
            $GuiActive=False
            ExitProgram()

    EndSwitch
WEnd

WEnd