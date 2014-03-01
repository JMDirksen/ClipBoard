#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=clipboard.ico
#AutoIt3Wrapper_Res_Comment=ClipBoard
#AutoIt3Wrapper_Res_Description=ClipBoard
#AutoIt3Wrapper_Res_Fileversion=1.0.0.4
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Run_Tidy=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Array.au3>

AutoItSetOption("MustDeclareVars", 1)
AutoItSetOption("TrayMenuMode", 3)
AutoItSetOption("TrayOnEventMode", 1)
OnAutoItExitRegister("exitScript")
TraySetToolTip("ClipBoard")

Dim $clipNew, $clipOld
Dim $clipItem[15]

;$trayItem[..][0] is the Value
;$trayItem[..][1] is the Text
;$trayItem[..][2] is the ID
Dim $trayItem[17][3]
$trayItem[15][1] = ""
$trayItem[16][1] = "Exit"

buildTrayMenu()

While 1
	checkForClipChange()
	Sleep(500)
WEnd

Func checkForClipChange()
	Dim $text, $search
	$clipNew = ClipGet()

	;for debugging
	If $clipNew == "debugdebug" Then
		_ArrayDisplay($trayItem, "$trayItem")
		_ArrayDisplay($clipItem, "$clipItem")
		$clipNew = "a"
		$clipOld = "a"
		ClipPut("a")
	EndIf

	;compare to last value
	If Not ($clipNew == $clipOld) Then
		$clipOld = $clipNew
		;Check if the value is already in the tray menu
		$search = _ArraySearch($clipItem, $clipNew)
		If $search = -1 Then
			;add to the menu
			If StringLen(StringStripWS(StringReplace($clipNew, Chr(13), " "), 7)) > 0 Then
				_ArrayPush($clipItem, $clipNew)
				buildTrayMenu()
				TrayItemSetState($trayItem[14][2], 1)
			EndIf
		Else
			;check this item in the menu
			clearChecks()
			TrayItemSetState($trayItem[$search][2], 1)
		EndIf
	EndIf
EndFunc   ;==>checkForClipChange

Func clearChecks()
	For $i = 0 To UBound($trayItem) - 1
		TrayItemSetState($trayItem[$i][2], 4)
	Next
EndFunc   ;==>clearChecks

Func buildTrayMenu()
	Dim $value, $text
	;clipItems -> trayItems
	For $id = 0 To UBound($clipItem) - 1
		$trayItem[$id][0] = $clipItem[$id]
		$text = StringStripWS(StringReplace($clipItem[$id], Chr(13), " "), 7)
		If StringLen($text) > 50 Then
			$trayItem[$id][1] = StringLeft($text, 47) & "..."
		Else
			$trayItem[$id][1] = $text
		EndIf
	Next

	;clear trayMenu
	For $id = 0 To UBound($trayItem) - 1
		TrayItemDelete($trayItem[$id][2])
	Next

	;trayItems -> trayMenu
	For $id = 0 To UBound($trayItem) - 1
		$trayItem[$id][2] = TrayCreateItem($trayItem[$id][1])
		TrayItemSetOnEvent(-1, "itemClick")
	Next
EndFunc   ;==>buildTrayMenu

Func itemClick()
	Dim $item
	$item = _ArraySearch($trayItem, @TRAY_ID, 0, 0, 0, 0, 1, 2)
	If $item = 16 Then Exit
	$clipOld = $trayItem[$item][0]
	ClipPut($trayItem[$item][0])

	;uncheck all tray items
	For $i = 0 To UBound($trayItem) - 1
		TrayItemSetState($trayItem[$i][2], 4)
	Next
	;check clicked item
	TrayItemSetState($trayItem[$item][2], 1)

EndFunc   ;==>itemClick

Func exitScript()
EndFunc   ;==>exitScript
