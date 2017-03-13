#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GUIListView.au3>
#include <ListViewConstants.au3>
#include <File.au3>
 #include <Array.au3>
 #include <Misc.au3>
 Global $iDouble_Click_Event = False
Global $iOne_Click_Event = False
Global $item
#Region ### START Koda GUI section ### Form=d:\autoit\iteration1-short.kxf
$Form1_1 = GUICreate("Form1", 615, 438, 193, 131)
$MenuItem3 = GUICtrlCreateMenu("&File")
$MenuItem5 = GUICtrlCreateMenuItem("Open", $MenuItem3)
$MenuItem4 = GUICtrlCreateMenuItem("Save", $MenuItem3)
$MenuItem6 = GUICtrlCreateMenuItem("Save Ass...", $MenuItem3)
$MenuItem7 = GUICtrlCreateMenuItem("Close", $MenuItem3)
$MenuItem2 = GUICtrlCreateMenu("&Edit*")
$MenuItem8 = GUICtrlCreateMenuItem("Copy*", $MenuItem2)
$MenuItem10 = GUICtrlCreateMenuItem("Paste*", $MenuItem2)
$MenuItem9 = GUICtrlCreateMenuItem("Cut*", $MenuItem2)
$MenuItem1 = GUICtrlCreateMenu("&Configure*")
$MenuItem11 = GUICtrlCreateMenuItem("Choose target", $MenuItem1)
$MenuItem12 = GUICtrlCreateMenuItem("Choose FB", $MenuItem1)
$MenuItem13 = GUICtrlCreateMenuItem("Create FB*", $MenuItem1)
$MenuItem14 = GUICtrlCreateMenu("&Help")
$Listbox1 = GUICtrlCreateList("", 16, 24, 201, 233)
$hListView = GUICtrlCreateList("", 224, 24, 201, 233)
$Button1 = GUICtrlCreateButton("Компилировать файлы", 360, 336, 123, 25)
$Button2 = GUICtrlCreateButton("Закрыть", 504, 336, 91, 25)
$Combo1 = GUICtrlCreateCombo("Выберите таргет ПЛК", 432, 24, 145, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
GUICtrlSetData($Combo1, "ПЛК 110 - 24.Р-М")
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
$PathData=@ScriptDir
$Listdata=_FileListToArray(@ScriptDir,'*.asm')
for $i = 1 to $Listdata[0]
	;$item[$i]=GUICtrlCreateListViewItem($Listdata[$i],$hListView)
	GUICtrlSetData($hListView,$Listdata[$i]&@CRLF,$i)
Next


While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $MenuItem5
			_OpenFile()
		Case $Button2
			Exit
		Case $Button1
			;_CompileFile()
		Case $MenuItem4
			_Save()


	EndSwitch
	If $iDouble_Click_Event Then
        $iDouble_Click_Event = 0
        ToolTip("Double Click")
		EndIf
WEnd
Func _OpenFile()
	Local $FileOpenDialog=FileOpenDialog("Открыть",@ScriptDir&"\","Текст(*.txt)")
EndFunc
Func _Close()
	Exit
EndFunc

Func _Save()
	Local $SaveDialog=FileSaveDialog("Сохранить",@ScriptDir,"Текст(*.txt)")
EndFunc

Func _ChooseFB()
	Local $ChooseFB
EndFunc
;Func _ControlList()
;	if  then
Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
    Local $hWndFrom, $iIDFrom, $iCode, $tNMHDR, $hWndListView = $hListView
    If Not IsHWnd($hListView) Then $hWndListView = GUICtrlGetHandle($hListView)

    $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)
    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")

    Switch $hWndFrom
        Case $hWndListView
            Switch $iCode
                Case $NM_CLICK
                    $iOne_Click_Event = True
                Case $NM_DBLCLK
                    $iDouble_Click_Event = True
            EndSwitch
    EndSwitch

    Return $GUI_RUNDEFMSG
EndFunc
