;; ScreenLockWindow
;; usage: ScreenLockWindow /f controlfile /p showpic

#AutoIt3Wrapper_UseX64=N
#AutoIt3Wrapper_Res_File_Add=stop_sign.jpg, rt_rcdata, rs_stop_jpg

#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <Timers.au3>
#include <GDIPlus.au3>
#include "Array.au3"
#include <Misc.au3>

#Include "GlobalHookEx.au3"
#include <resources.au3>


OnAutoItExitRegister("UnlockSystem")
;;-------------------------------------------------------------
$usage = _
  'ScreenLockWindow' & @CRLF & @CRLF & _ 
  'Usage: ScreenLockWindow.exe /f[k] controlfile /p pic /k controlkeys /a[k|c|m|n|r] SendCmdWhenActive /e[k|c|m|n|r] SendCmdWhenDisative' & @CRLF & @CRLF & _ 
  '          if controlfile exists, pup window; otherwise, hide window.' & @CRLF & _ 
  '          if /fk, exit process when control file not exists.' & @CRLF & _ 
  '          control keys are used to terminate process. If not specified, default keys will be used.' & @CRLF & _ 
  '          /ak or /ac "title":"CMDKEY"    title and CMDKEY must be quoted and in autoit format.' & @CRLF & _ 
  '          k for key, c for command, m for sending message, n for menu command, r for running application' & @CRLF & _ 
  '          if /ar, SendCmdWhenActive is a application filename' & @CRLF & _ 
  'Eg. ScreenLockWindow.exe /f "C:\controlfile\stop" /p stop_sign.jpg /k 0x23-0x24 /ar prelockscreen /er postlockscreen'
;;
;; Note that keyboard will be locked when window is popped up. if no controlkeys specified, default END-NUMLOCK is used.
;;

;;-------------------------------------------------------------

; 0x1b escape, 0x23 end, 0x24 home
$controlkeys = _ArrayCreate(2, int("0x23"), int("0x24")) ;  escape ; home 
$curkey = 1

$controlfile = "D:\shopfloor\stop"
$fk = false             ; kill process if control file not exists
$screenpic = "stop_sign.jpg"
Enum $LS_LOCKED = 1, $LS_UNLOCKING = 2, $LS_UNLOCKED = 3, $LS_LOCKING = 4
$lockstate = 0 ; 1 locked, 2 unlocking, 3 unlocked, 4 locking

$aWinTitle = ""
$aCmdKey = ""
$bWinTitle = ""
$bCmdKey = ""
$ACmdType = "" ; "k", "c", "m", "n", "r"
$BCmdType = ""

Dim $hGUI, $hImage, $hGraphic

Global $hookKeysEnable = true
Global $hookMouseEnable = true

;;=================================================================
Func test()
	local $tagKEBOARDHOOKSTRUCT = "DWORD vkCode;DWORD scanCode;DWORD flags;DWORD time;ULONG_PTR dwExtraInfo"
	Local $tagDWORD = "DWORD a", $tagPTR = "ULONG_PTR a", $a, $b, $c
	$a = DllStructCreate($tagDWORD)
	$b = DllStructCreate($tagPTR)
	$c = DllStructCreate($tagKEBOARDHOOKSTRUCT)
	MsgBox(0, "size", " " & DllStructGetSize($a) & " " & DllStructGetSize($b) & " " & DllStructGetSize($c))
	
EndFunc

;test()
Main()
Func Main()
	if _Singleton("ScreenLockWindow",1) = 0 Then
		;Msgbox(0,"Warning","An occurence of ScreenLockWindow is already running")
		Exit
	EndIf

	If $CmdLine[0] = 0 Then
		MsgBox(0, "Usage", $usage)
	Else
		ParseArg()
		MainFunc()
	EndIf
EndFunc

Func ParseArg()
	Local $v, $i
	$fk = false
	$controlfile = GetArgValue("/f")
	if $controlfile = "" Then
		$controlfile = GetArgValue("/fk")
		if $controlfile = "" Then
		Else
			$fk = True
		EndIf
	EndIf
	
	$screenpic = GetArgValue("/p")
	
	$v = GetArgValue("/k")
	if $v = "" Then
		;$controlkeys = _ArrayCreate(0)
	Else
		$v = StringSplit($v, "-")
		ReDim $controlkeys[$v[0]+1]
		$controlkeys[0] = $v[0]
		For $i = 1 to $v[0]
			$controlkeys[$i] = int($v[$i])
		Next
	EndIf

	;-- parse /a 
	$v = GetArgValue("/ak")
	if $v = "" Then
		$v = GetArgValue("/ac")
		if $v <> "" then $ACmdType = "c"
	Else
		$ACmdType = "k"
		$v = StringSplit($v, ":")
		if $v[0] = 2 then
			$aWinTitle = $v[1]; StringMid($v[1], 2, StringLen($v[1])-2)
			$aCmdKey = $v[2]; StringMid($v[2], 2, StringLen($v[2])-2)
		Else
		EndIf
	EndIf
	$v = GetArgValue("/ar")
	if $v = "" Then
	Else
		$ACmdType = "r"
		$aCmdKey = $v
	EndIf
	;MsgBox(0, $aWinTitle, $aCmdKey)
	;-- parse /b
	$v = GetArgValue("/ek")
	if $v = "" Then
		$v = GetArgValue("/ec")
		if $v <> "" then $BCmdType = "c"
	Else
		$BCmdType = "k"
		$v = StringSplit($v, ":")
		if $v[0] = 2 then
			$bWinTitle = $v[1]; StringMid($v[1], 2, StringLen($v[1])-2)
			$bCmdKey = $v[2] ; StringMid($v[2], 2, StringLen($v[2])-2)
		Else
		EndIf
	EndIf
	$v = GetArgValue("/er")
	if $v = "" Then
	Else
		$BCmdType = "r"
		$bCmdKey = $v
	EndIf
	;MsgBox(0, $bWinTitle, $bCmdKey)
EndFunc

Func GetArgValue($param)
	Local $i
	For $i = 1 to $CmdLine[0]
		If $param = $CmdLine[$i] then 
			return $CmdLine[$i+1]
		Else
		EndIf
	Next
	return ""
EndFunc

Func InitDlg()
	_GDIPlus_StartUp()
    $hGUI =GUICreate("ScreenLockWindow", @DesktopWidth,@DesktopHeight,0,0,BitAND($WS_POPUP, BitNOT($WS_BORDER), BitNOT($WS_CAPTION)))
	if $screenpic = "" Then
		$hImage = _ResourceGetAsImage("rs_stop_jpg")
	Else
		$hImage   = _GDIPlus_ImageLoadFromFile($screenpic)
	EndIf
	$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)
	if $controlkeys[0] > 0 then GUIRegisterMsg($WM_KEYDOWN, "MY_WM_KEYDOWN")
	GUIRegisterMsg($WM_PAINT, "MY_WM_PAINT")
	
	return InitHook()
EndFunc

Func FinalizeDlg()
	; Clean up resources
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_ShutDown()
    GUIDelete()
	UnLockSystem()
EndFunc

Func MainFunc()
    Local $msg
	
	if 0 = InitDlg() Then
		FinalizeDlg()
		return 0
	EndIf
	
	If $controlfile = "" Then
		GUISetState(@SW_SHOW, $hGUI)
		LockSystem()
	Else
		_Timer_SetTimer($hGUI, 500, "My_Timer")
	EndIf
	
    While 1
        $msg = GUIGetMsg()       
    WEnd
    FinalizeDlg()
EndFunc

; Draw PNG image
Func MY_WM_PAINT($hWnd, $Msg, $wParam, $lParam)
	local $tRect 
    _WinAPI_RedrawWindow($hGUI, 0, 0, $RDW_UPDATENOW)
     $tRect = _WinAPI_GetClientRect($hGUI)

    _GDIPlus_GraphicsDrawImageRect($hGraphic, $hImage, 0, 0, DllStructGetData($tRect, "Right")-DllStructGetData($tRect, "Left"), DllStructGetData($tRect, "Bottom")-DllStructGetData($tRect, "Top"))
    _WinAPI_RedrawWindow($hGUI, 0, 0, $RDW_VALIDATE)
    Return $GUI_RUNDEFMSG
EndFunc


Func MY_WM_KEYDOWN($hwnd, $msgId, $wparam, $lparam)
	;ConsoleWrite("KeyDown: " & $wParam & " " & $lParam & @CR)
	if $controlkeys[0] = 0 then return $GUI_RUNDEFMSG
		
	If $wparam = $controlkeys[$curkey] Then
		If $curkey = $controlkeys[0] Then
			FinalizeDlg()
			Exit
		Else
			$curkey = $curkey + 1
		EndIf
	Else
		$curkey = 1
	EndIf

	Return $GUI_RUNDEFMSG
EndFunc

Func My_Timer($hWnd, $Msg, $iIDTimer, $dwTime)
	; if control file exists, show window; otherwise, hide window
	if $controlfile = "" then Return
	UpdateLockState()
		
	If FileExists($controlfile) Then
		If $LS_UNLOCKED = $lockstate or 0 = $lockstate Then
			;-- lock screen
			$lockstate = $LS_LOCKING
			SendCmdKey($aWinTitle, $aCmdKey, $ACmdType)
		Else
		EndIf
	ElseIf $fk Then
		FinalizeDlg()
		Exit
	Else
		If $LS_LOCKED = $lockstate Then
			;-- unlock screen
			$lockstate = $LS_UNLOCKING
			GUISetState(@SW_HIDE, $hGUI)
			UnLockSystem()
		ElseIf 0 = $lockstate Then
			$lockstate = $LS_UNLOCKED
			GUISetState(@SW_HIDE, $hGUI)
			UnLockSystem()
		Else
		EndIf
	EndIf
EndFunc

Func UpdateLockState()
	Switch $lockstate
	Case $LS_LOCKING
		GUISetState(@SW_SHOW, $hGUI)
		LockSystem()
		$lockstate = $LS_LOCKED
		;MsgBox(0, "MSg", "LOCKED")
	Case $LS_LOCKED
		WinActivate("ScreenLockWindow")
		WinSetOnTop("ScreenLockWindow", "", 1)
	Case $LS_UNLOCKING
		SendCmdKey($bWinTitle, $bCmdKey, $BCmdType)
		$lockstate = $LS_UNLOCKED
		;MsgBox(0, "MSg", "UNLOCKED")
	Case $LS_UNLOCKED
	EndSwitch
EndFunc

Func SendCmdKey($title, $key, $CmdType)
	if $key = "" Then
	Else
		if $CmdType = "k" Then
			ControlSend($title, "", $key, "cmd")
		ElseIf $CmdType = "c" Then
			if not $title = "" then 
				WinActivate($title)
				;WinWaitActive($title,0.2)
			Else
			EndIf
			Send($key)
		ElseIf $CmdType = "r" Then
			RunWait($key)
		Else
		EndIf
	EndIf
EndFunc

Func InitHook()
	$HookHandleI = SetDllGlobalWindowsHookEx($WH_KEYBOARD_LL,$hGUI,"KeyboardLLProc")
	if not $HookHandleI Then 
		MsgBox(0, "Error", "Failed to hook KeyboardLLProc err=" & @error)
		return 0
	EndIf
	$HookHandleJ = SetDllGlobalWindowsHookEx($WH_MOUSE_LL,$hGUI,"MouseLLProc")
	if not $HookHandleJ Then 
		MsgBox(0, "Error", "Failed to hook MouseLLProc err=" & @error)
		return 0;
	EndIf
	return 1
EndFunc
Func LockSystem()
	HookKey(1)
	DisableTaskMgr(1)
EndFunc
Func UnlockSystem()
	HookKey(0)
	DisableTaskMgr(0)
EndFunc
Func HookKey($yes)
	if $yes = 1 then 
		$hookKeysEnable = True
		$hookMouseEnable = True
	Else
		$hookKeysEnable = False
		$hookMouseEnable = False
	EndIf
	return 
EndFunc

Func DisableTaskMgr($yes)
	RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableTaskMgr", "REG_DWORD", $yes)
EndFunc

Func MouseLLProc($hWnd,$Msg,$ParamNo,$Param)
	Switch $ParamNo
		Case 1
			$PROCIDJ = $Param
			Return 0
		Case 2
			$CODEJ = $Param
			Return 0
		Case 3
			$WPARAMJ = $Param
			Return 0
		Case 4
			$LPARAMJ = $Param
		Case Else
		Return 0
	EndSwitch
	if $ParamNo <> 4 Then Return 0 
	if not $hookMouseEnable Then return 0
	Local $CODE = $PROCIDJ, $wParam = $WPARAMJ, $lParam = $LPARAMJ
	
	local $MOUSELLHOOK_Struct = Read_Lparama_FromProcessMemory($Msg,$PROCIDJ,$LPARAMJ)
	local $x, $y
	$x = DllStructGetData($MOUSELLHOOK_Struct, 1)
	$y = DllStructGetData($MOUSELLHOOK_Struct, 2)
	;dbgstring("Hooked MouseLLProc (" & $x & "," & $y & ")" )
	return 1
EndFunc

Func KeyboardLLProc($hWnd,$Msg,$ParamNo,$Param)
	Switch $ParamNo
		Case 1
			$PROCIDI = $Param
			Return 0
		Case 2
			$CODEI = $Param
			Return 0
		Case 3
			$WPARAMI = $Param
			Return 0
		Case 4
			$LPARAMI = $Param
		Case Else
		Return 0
	EndSwitch
	if $ParamNo <> 4 Then Return 0 
	if not $hookKeysEnable Then return 0
		
	local $KEYBOARDHOOKSTRUCT_Struct = Read_Lparama_FromProcessMemory($Msg,$PROCIDI,$LPARAMI)
	if @error Then
		MsgBox(0, "Error", "Failed to read LParam " & @extended)
		return 0
	Else
		;MsgBox(0, "lParam Size", DllStructGetSize($KEYBOARDHOOKSTRUCT_Struct))
	EndIf

	Local $CODE = $PROCIDI, $wParam = $WPARAMI, $lParam = $LPARAMI
	Local $HC_ACTION = 0, $VK_CONTROL=0x11, $ALT_MASK = BitShift(0x2000, 8), $VK_TAB=0x09, $VK_ESC=0x1B, $VK_LWIN=0x5B, $VK_RWIN=0x5C
	Local $vkCode, $flags, $ctlDown
	;;
	if $CODEI = $HC_ACTION Then ; $HC_ACTION Then
		$ctlDown = BitAND(_WinAPI_GetAsyncKeyState($VK_CONTROL), 0x8000)
		$vkCode = DllStructGetData($KEYBOARDHOOKSTRUCT_Struct, "vkCode")
		if @error Then MsgBox(0, "Error", "get vkCode")
		$flags = DllStructGetData($KEYBOARDHOOKSTRUCT_Struct, "flags")
		if @error Then MsgBox(0, "Error", "get flags")
		Local $s ="Keys {vkCode:"& $vkCode & ", flags:" & $flags & "} "
		if $ctlDown <> 0 then $s &= " Control Down| "
		If $vkCode = $VK_TAB then $s &= "Tab| "
		If BitAND($flags, $ALT_MASK) <> 0 then $s &= "Alt| "
		If $vkCode = $VK_ESC then $s &= "Esc| "
		If $vkCode = $VK_LWIN then $s &= "LWin| "
		If $vkCode = $VK_RWIN then $s &= "RWin| "
		dbgstring($s)
			
		If $vkCode = $VK_TAB or BitAND($flags, $ALT_MASK) <> 0 Then return 1    ; Alt+Tab
		If $vkCode = $VK_ESC and $ctlDown <> 0 Then return 1                     ; Ctl+Esc
		If $vkCode = $VK_ESC and BitAND($flags, $ALT_MASK) <> 0 Then return 1    ; Alt+ESC
		If $vkCode = $VK_LWIN or $vkCode = $VK_RWIN Then return 1                ; LeftWin or RightWin
	Else
		;MsgBox(0, "KeyboardProc", "hooked")
	EndIf

	Return 0
EndFunc

Func dbgstring($msg, $error=@error, $extended=@extended, $ScriptLineNumber=@ScriptLineNumber)
    Local $out = "(" & $ScriptLineNumber & ")(" & $error & ")(" & $extended & ") := " & $msg 
    ;Output to application attaching a console to the script engine
    ConsoleWrite($msg & @CRLF)
    ;Output to debugger (dbgview.exe)
    DllCall("kernel32.dll", "none", "OutputDebugString", "str", $out)
EndFunc