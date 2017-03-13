#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Fileversion=1.0.0.13
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Array.au3>
#include <File.au3>
#include <StringConstants.au3>

if $CmdLine[0] <> 3 Then
	$PathToFile = @ScriptDir&"\"
else
	$PathToFile = $CmdLine[3]&"\"
EndIf
if $CmdLine[0] = 0 Then
	ConsoleWrite("Не заданы параметры для парсинга")
	Exit
endif
$hFile = FileOpen($PathToFile&"AssemblyInfo.cs",0)
$sText = FileRead($PathToFile&"AssemblyInfo.cs") ;Читаем файл
ConsoleWrite(@extended&@CRLF)

$aLines = StringSplit($sText, @CRLF, 1) ;Разбиваем текст на строки, строки помещаем в массив
FileClose($hFile)
ConsoleWrite(@error&@CRLF)
DIM $arr[1][4]
Global $arrversion
Dim $CommandLine
$i = 0
$j = 0
$string = ''
If $hFile = -1 Then
    MsgBox(4096, "Ошибка", "Невозможно открыть файл.")
    Exit
EndIf

for $i = 1 to $CmdLine[0]
	ConsoleWrite($CmdLine[$i]&@CRLF)
Next
;_ArrayDisplay($aLines,"GGG")
$i = 1
if $CmdLine[0] <> 0 Then
	;ConsoleWrite("FFFF")
While 1
	if $i = UBound($aLines) then ExitLoop
	ConsoleWrite($i&@CRLF)
    $sLine = $aLines[$i]
    If @error = -1 Then ExitLoop
		if StringInStr($sLine,$CmdLine[2]) Then
			ConsoleWrite("Found1"&@CRLF)
			While 1
				$sLine = $aLines[$i]

				if $i = UBound($aLines) then ExitLoop
					if StringInStr($sLine, "AssemblyVersion") Then
						_FileWriteToLine($PathToFile&"AssemblyInfo.cs",$i,'[assembly: AssemblyVersion("'&$CmdLine[1]&'")]',True)
						$hFile = FileOpen($PathToFile&"AssemblyInfo.cs",0)
						ConsoleWrite("Fonud2"&@CRLF)
						;if StringRegExp($sLine, "[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3}\.[0-9]{1,5}") Then
							;$gReg = StringRegExp($sLine, "[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,3}\.[0-9]{1,5}", 1)
							;$arrversion = $gReg[0]
							;$sReg= StringSplit($gReg[0],".")
							;	for $j = 1 to $sReg[0]
								;	$arr[0][$j-1] = $sReg[$j]
							;	Next

							ExitLoop(2)

					EndIf
				$i += 1
			WEnd
		EndIf
	$i += 1
WEnd
EndIf
$i=0

;----------------------------------------------------------------------------------------------------------------------------

;$dFile = FileOpen("..\workspace\Inno scripts\OwenLogic.iss",0)

;While 1
 ;   $sLine = FileReadLine($dFile)
;	$i=$i+1
 ;   If @error = -1 Then ExitLoop
;	if StringInStr($sLine, "#define FULLVERSION") Then
;		$string = "#define FULLVERSION '"&$arrversion&"'"
;		_FileWriteToLine("..\workspace\Inno scripts\OwenLogic.iss",$i,$string,True)
;	 EndIf
;	if StringInStr($sLine, "#define VERSION") Then
;		$string = "#define VERSION '"&$arr[0][0]&"."&$arr[0][1]&"."&$arr[0][2]&"'"
;		_FileWriteToLine("..\workspace\Inno scripts\OwenLogic.iss",$i,$string,True)
;	EndIf
;	if StringInStr($sLine, "#define BUILD") Then
;		$string = "#define BUILD '"&$arr[0][3]&"'"
;		_FileWriteToLine("..\workspace\Inno scripts\OwenLogic.iss",$i,$string,True)
;	EndIf
;WEnd
;For $i=0 to $g
;	For $j=0 to $sReg[0]-1
;	$Line=$arrversion
;	$a=FileWriteLine($dFile,$Line)

;	Next
;Next
;FileClose($dFile)


;------------------------------------------------------------------------------------------------------------------

