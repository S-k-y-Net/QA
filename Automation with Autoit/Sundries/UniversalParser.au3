; универсальный парсер версии ПО - "бета"
; Функции:
; 1 Поиск и замена одной строки в файле
; 2 Поиск и замена символов в строке по регулярным выражениям
; 3 Поиск и замена текста по шаблону считанному из файла
; 4 Поиск и замена символов или строки в повторяющихся строках
;=============================================================================================

#include <Constants.au3>
#include <File.au3>
#include <Array.au3>

; ============================================================================================
; _ReplaceLine()
; This function finds and replaces the line in the file
; Example:(original text) 	{Line 1} Abracadabra
;							{Line 2} Baaaaaaaaaa
;							{Line 3} Ceeeeeeeeee
;	_ReplaceLine("test.txt", 2, "EEEEEEEEEEE") or _ReplaceLine("test.txt", "Baaaaaaaaaa", "EEEEEEEEEE")
;         (output text)     {Line 1} Abracadabra
;							{Line 2} EEEEEEEEEEE
;							{Line 3} Ceeeeeeeeee
; FUNCTION NUMBER IN CMD - "1"

; Errors:  1020  - File dosn't exist or invalid path
;          1030  - Line with this number not found
;          1040  -

Func _ReplaceLine($FilePath, $sLine, $sText)

	Local $vVariable
	Local $flag = 0
	Local $vArrayOfData[3]
	Local $i = 0

; If the second parameter is integer
	if IsInt($sLine) Then

		$flag = 1

		$hFile = FileOpen($FilePath, 0)

		While 1

			$vVariable = FileReadLine($hFile)

			if @error = -1 Then ExitLoop

			ReDim $vArrayOfData[$i+1]

			$vArrayOfData[$i] = $vVariable

			$i += 1

		WEnd

		FileClose($hFile)

		if $sLine > UBound($vArrayOfData) - 1 Then

			MsgBox(64,"Error", "Line with this number not found: error 1030")
			Exit

		EndIf

		$vArrayOfData[$sLine - 1] = $sText

		$hFile = FileOpen($FilePath, 2)

		For $i = 0 to UBound($vArrayOfData) - 1

			FileWriteLine($hFile, $vArrayOfData[$i])

		Next

	EndIf

; If the second parameter is string
	if $flag = 0 Then

		$hFile = FileOpen($FilePath, 0)


			$vVariable = FileRead($hFile)


			if StringRegExp($vVariable, $sLine) Then

				$vVariable = StringRegExpReplace($vVariable,$sLine,$sText)

			EndIf


		FileClose($hFile)

		$hFile = FileOpen($FilePath, 2)

		FileWrite($hFile,$vVariable)

		FileClose($hFile)

	EndIf

EndFunc

; ============================================================================================
; _RegExpReplace
; This function finds and replaces the line was matches for regular expression
; Example:(original text) 	{Line 1} IP is 10.2.3.4
;							{Line 2} scene 4
;							{Line 3} addres mountane str h4 245
;	_ReplaceLine("test.txt", "scene"&"[1-9], "10")
;         (output text)     {Line 1} IP is 10.2.3.4
;							{Line 2} scene 10
;							{Line 3} addres mountane str h4 245
; FUNCTION NUMBER IN CMD - "2"

; Errors:  1020  - File dosn't exist or invalid path
;          1030  - There are no matches for this regular expression
;          1040  -

Func _RegExpReplace($FilePath, $RexExp, $sText)

	Local $vReg

	$vReg = FileRead(@ScriptDir&"\"&$FilePath)





EndFunc








