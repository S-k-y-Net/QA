#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compile_Both=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Array.au3>
#include <File.au3>
#include <StringConstants.au3>
$hFile = FileOpen("AssemblyInfo.cs",0)
DIM $arr[1][4]
Global $arrversion
$i = 0
$j = 0
$string = ''
If $hFile = -1 Then
    MsgBox(4096, "Ошибка", "Невозможно открыть файл.")
    Exit
EndIf
While 1
    $sLine = FileReadLine($hFile)
    If @error = -1 Then ExitLoop
		if StringInStr($sLine,"akYtec ALP") Then
			While 1
				$sLine = FileReadLine($hFile)
				If @error = -1 Then ExitLoop
					if StringInStr($sLine, "AssemblyVersion") Then
						if StringRegExp($sLine, "[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3}\.[0-9]{1,5}") Then
							$gReg = StringRegExp($sLine, "[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3}\.[0-9]{1,5}", 1)
							$arrversion = $gReg[0]
							$sReg= StringSplit($gReg[0],".")
								for $j = 1 to $sReg[0]
									$arr[0][$j-1] = $sReg[$j]
								Next
						EndIf
					EndIf
			WEnd
		EndIf

WEnd
FileClose($hFile)
$i=0
$dFile = FileOpen("test.iss",0)
While 1
    $sLine = FileReadLine($dFile)
	$i=$i+1
    If @error = -1 Then ExitLoop
	if StringInStr($sLine, "#define FULLVERSION") Then
		$string = "#define FULLVERSION '"&$arrversion&"'"
		_FileWriteToLine("C:\ServerCI\.hudson\jobs\Owen Logic\workspace\Inno scripts\OwenLogic.iss",$i,$string,True)
	 EndIf
	if StringInStr($sLine, "#define VERSION") Then
		$string = "#define VERSION '"&$arr[0][0]&"."&$arr[0][1]&"."&$arr[0][2]&"'"
		_FileWriteToLine("C:\ServerCI\.hudson\jobs\Owen Logic\workspace\Inno scripts\OwenLogic.iss",$i,$string,True)
	EndIf
	if StringInStr($sLine, "#define BUILD") Then
		$string = "#define BUILD '"&$arr[0][3]&"'"
		_FileWriteToLine("C:\ServerCI\.hudson\jobs\Owen Logic\workspace\Inno scripts\OwenLogic.iss",$i,$string,True)
	EndIf
WEnd
;For $i=0 to $g
;	For $j=0 to $sReg[0]-1
;	$Line=$arrversion
;	$a=FileWriteLine($dFile,$Line)

;	Next
;Next
FileClose($dFile)
_FileWriteToLine("C:\Users\m.rasulzoda\Documents\scripts_autoit\version.txt",1,$arrversion,True)
_FileWriteToLine("build.txt",1,$arr[0][3],True)
