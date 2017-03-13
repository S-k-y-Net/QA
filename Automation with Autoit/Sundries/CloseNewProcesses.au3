#include <Constants.au3>
#include <Array.au3>

Dim $MyFavoriteProcesses = ["notepad.exe", "Process2", "Process3 ..."] ;имена процессов, которые нельзя закрывать например notepad.exe

$ProcessOldList = ProcessList()

;MsgBox(64,"SSS","SSSS")
;здесь твой код

$ProcessNewList = ProcessList()

for $i = 1 to UBound($ProcessNewList) - 1

	$processFound = 0

	for $j = 1 to UBound($ProcessOldList) - 1

		if $ProcessOldList[$j][0] = $ProcessNewList[$i][0]  then

			$processFound = 1;

		EndIf

	Next

	For $u = 0 to UBound($MyFavoriteProcesses) - 1

		if $MyFavoriteProcesses[$u] = $ProcessNewList[$i][0] Then

			$processFound = 1

		EndIf

	Next



	if $processFound = 0 then

			ProcessClose($ProcessNewList[$i][1])

	EndIf

Next