#Include <WinAPI.au3>
OnAutoItExitRegister("CleanupHookEx")
Global $HookExW = 0 , $iGuiHwnd = 0 ,$HOOK_GUI_MSG = 0 , $OkTestExeHwnd = 99999
Global $CBT_MSG = 0,$DEBUG_MSG = 0 ,$FOREGROUNDIDLE_MSG = 0,$GETMESSAGE_MSG = 0,$KEYBOARD_MSG = 0, $KEYBOARDLL_MSG = 0
Global $MOUSE_MSG = 0,$MSGFILTER_MSG = 0,$SHELL_MSG = 0, $MOUSELL_MSG =0
Global $HookHandleCBTProc,$HookHandleDebugProc,$HookHandleForegroundIdleProc,$HookHandleGetMsgProc, _
$HookHandleKeyboardProc,$HookHandleMouseProc,$HookHandleMessageProc,$HookHandleShellProc, $HookHandleKeyboardLLProc, $HookHandleMouseLLProc
Global $PROCIDA,$PROCIDB,$PROCIDC,$PROCIDD,$PROCIDE,$PROCIDF,$PROCIDG,$PROCIDH, $PROCIDI, $PROCIDJ
Global $CODEA,$CODEB,$CODEC,$CODED,$CODEE,$CODEF,$CODEG,$CODEH, $CODEI, $CODEJ
Global $WPARAMA,$WPARAMB,$WPARAMC,$WPARAMD,$WPARAME,$WPARAMF,$WPARAMG,$WPARAMH, $WPARAMI, $WPARAMJ
Global $LPARAMA,$LPARAMB,$LPARAMC,$LPARAMD,$LPARAME,$LPARAMF,$LPARAMG,$LPARAMH, $LPARAMI, $LPARAMJ

;SetWindowsHookEx
;http://msdn.microsoft.com/en-us/library/ms644990%28VS.85%29.aspx
;SetWindowsHookEx can be used to inject a DLL into another process. A 32-bit DLL cannot be injected
;into a 64-bit process, and a 64-bit DLL cannot be injected into a 32-bit process. If an application
;requires the use of hooks in other processes, it is required that a 32-bit application call
;SetWindowsHookEx to inject a 32-bit DLL into 32-bit processes, and a 64-bit application call
;SetWindowsHookEx to inject a 64-bit DLL into 64-bit processes. The 32-bit and 64-bit DLLs must
;have different names.



Func SetDllGlobalWindowsHookEx($IdHook,$GuiHwnd,$MsgFunction)
if Not IsHWnd($iGuiHwnd) Then $iGuiHwnd = $GuiHwnd
if Not $HookExW Then $HookExW = DllOpen("HookExW_x64.dll")
if Not $HookExW Or Not IsHWnd($iGuiHwnd) Then Return SetError(1,0,0)
if Not ($HOOK_GUI_MSG) Then
Local $RT = DllCall($HookExW,"BOOL","DllGetModuleFileNameW","WSTR*","")
If @error Or Not $RT[0] Then Return SetError(0,0,0)
$MsgBuffer = $RT[1]
$HOOK_GUI_MSG = RegisterWindowMessage($MsgBuffer)
if Not $HOOK_GUI_MSG Or Not GUIRegisterMsg($HOOK_GUI_MSG,"TestExeHwnd") Then Return SetError(2,0,0)
EndIf
Switch $idHook
Case $WH_CBT
$CBT_MSG = RegisterWindowMessage("CBT_MSG")
if Not $CBT_MSG Or Not GUIRegisterMsg($CBT_MSG,$MsgFunction) Then Return SetError(3,0,0)
Case $WH_DEBUG
$DEBUG_MSG = RegisterWindowMessage("DEBUG_MSG")
if Not $DEBUG_MSG Or Not GUIRegisterMsg($DEBUG_MSG,$MsgFunction) Then Return SetError(3,0,0)
Case $WH_FOREGROUNDIDLE
$FOREGROUNDIDLE_MSG = RegisterWindowMessage("FOREGROUNDIDLE_MSG")
if Not $FOREGROUNDIDLE_MSG Or Not GUIRegisterMsg($FOREGROUNDIDLE_MSG,$MsgFunction) Then Return SetError(3,0,0)
Case $WH_GETMESSAGE
$GETMESSAGE_MSG = RegisterWindowMessage("GETMESSAGE_MSG")
if Not $GETMESSAGE_MSG Or Not GUIRegisterMsg($GETMESSAGE_MSG,$MsgFunction) Then Return SetError(3,0,0)
Case $WH_KEYBOARD
$KEYBOARD_MSG = RegisterWindowMessage("KEYBOARD_MSG")
if Not $KEYBOARD_MSG Or Not GUIRegisterMsg($KEYBOARD_MSG,$MsgFunction) Then Return SetError(3,0,0)
Case $WH_KEYBOARD_LL
$KEYBOARDLL_MSG = RegisterWindowMessage("KEYBOARDLL_MSG")
if Not $KEYBOARDLL_MSG Or Not GUIRegisterMsg($KEYBOARDLL_MSG,$MsgFunction) Then Return SetError(3,0,0)
Case $WH_MOUSE
$MOUSE_MSG = RegisterWindowMessage("MOUSE_MSG")
if Not $MOUSE_MSG Or Not GUIRegisterMsg($MOUSE_MSG,$MsgFunction) Then Return SetError(3,0,0)
Case $WH_MOUSE_LL
$MOUSELL_MSG = RegisterWindowMessage("MOUSELL_MSG")
if Not $MOUSELL_MSG Or Not GUIRegisterMsg($MOUSELL_MSG,$MsgFunction) Then Return SetError(3,0,0)
Case $WH_MSGFILTER
$MSGFILTER_MSG = RegisterWindowMessage("MSGFILTER_MSG")
if Not $MSGFILTER_MSG Or Not GUIRegisterMsg($MSGFILTER_MSG,$MsgFunction) Then Return SetError(3,0,0)
Case $WH_SHELL
$SHELL_MSG = RegisterWindowMessage("SHELL_MSG")
if Not $SHELL_MSG Or Not GUIRegisterMsg($SHELL_MSG,$MsgFunction) Then Return SetError(3,0,0)
Case Else
Return SetError(4,0,0)
EndSwitch

Local $RT = DllCall($HookExW,"handle","DllWindowsHookExW","UINT",$IdHook)
If @error Or Not $RT[0] Then Return SetError(5,0,0)

Switch $idHook
Case $WH_CBT
$HookHandleCBTProc = $RT[0]
Case $WH_DEBUG
$HookHandleDebugProc = $RT[0]
Case $WH_FOREGROUNDIDLE
$HookHandleForegroundIdleProc = $RT[0]
Case $WH_GETMESSAGE
$HookHandleGetMsgProc = $RT[0]
Case $WH_KEYBOARD
$HookHandleKeyboardProc = $RT[0]
Case $WH_KEYBOARD_LL
$HookHandleKeyboardLLProc = $RT[0]
Case $WH_MOUSE
$HookHandleMouseProc = $RT[0]
Case $WH_MOUSE_LL
$HookHandleMouseLLProc = $RT[0]
Case $WH_MSGFILTER
$HookHandleMessageProc = $RT[0]
Case $WH_SHELL
$HookHandleShellProc = $RT[0]
EndSwitch

Return SetError(0,0,$RT[0])

EndFunc

Func TestExeHwnd($hWnd,$Msg,$wParam,$lParam)
Return $OkTestExeHwnd
EndFunc

Func RegisterWindowMessage($lpString)
$RT = DllCall("User32.dll","int","RegisterWindowMessageW","WSTR",$lpString)
if @error Then Return SetError(1,0,0)
Return SetError(_WinAPI_GetLastError(),0,$RT[0])
EndFunc

Func Read_Lparama_FromProcessMemory($Msg,$ProcessID,$LPARAMA)
Local $iSYNCHRONIZE = (0x00100000),$iSTANDARD_RIGHTS_REQUIRED = (0x000F0000)
Local $iPROCESS_ALL_ACCESS  = ($iSTANDARD_RIGHTS_REQUIRED + $iSYNCHRONIZE + 0xFFF)
Local $hProcess , $LparamaStruct , $LparamaStructPtr , $LparamaStructSize , $iRead
$hProcess = _WinAPI_OpenProcess($iPROCESS_ALL_ACCESS,False,$ProcessID)
if @error Then Return SetError(@error,1,$LparamaStruct)
Switch $Msg
Case $DEBUG_MSG
Local $tagDEBUGHOOKINFO = "DWORD idThread;DWORD idThreadInstaller;LPARAM lParam;WPARAM wParam;INT code"
$LparamaStruct = DllStructCreate($tagDEBUGHOOKINFO)
$LparamaStructSize = DllStructGetSize($LparamaStruct)
Case $GETMESSAGE_MSG
Local $tagMSG = "HWND hwnd;UINT message;WPARAM wParam;LPARAM lParam;DWORD time;INT X;INT Y"
$LparamaStruct = DllStructCreate($tagMSG)
$LparamaStructSize = DllStructGetSize($LparamaStruct)
Case $MOUSE_MSG
$tagMOUSEHOOKSTRUCT = "INT X;INT Y;HWND hwnd;UINT wHitTestCode;ULONG_PTR dwExtraInfo"
$LparamaStruct = DllStructCreate($tagMOUSEHOOKSTRUCT)
$LparamaStructSize = DllStructGetSize($LparamaStruct)
Case $MOUSELL_MSG
$tagMOUSELLHOOKSTRUCT = "LONG X;LONG Y;DWORD mouseData;DWORD flags;DWORD time;ULONG_PTR dwExtraInfo"
$LparamaStruct = DllStructCreate($tagMOUSELLHOOKSTRUCT)
$LparamaStructSize = DllStructGetSize($LparamaStruct)
Case $KEYBOARDLL_MSG
$tagKEBOARDHOOKSTRUCT = "DWORD vkCode;DWORD scanCode;DWORD flags;DWORD time;ULONG_PTR dwExtraInfo"
$LparamaStruct = DllStructCreate($tagKEBOARDHOOKSTRUCT)
$LparamaStructSize = DllStructGetSize($LparamaStruct)
Case $MSGFILTER_MSG
Local $tagMSG = "HWND hwnd;UINT message;WPARAM wParam;LPARAM lParam;DWORD time;INT X;INT Y"
$LparamaStruct = DllStructCreate($tagMSG)
$LparamaStructSize = DllStructGetSize($LparamaStruct)
EndSwitch
$LparamaStructPtr = DllStructGetPtr($LparamaStruct)
_WinAPI_ReadProcessMemory($hProcess,$LPARAMA,$LparamaStructPtr,$LparamaStructSize,$iRead)
Return SetError(@error,2,$LparamaStruct)
EndFunc

Func CleanupHookEx()
if ($HookHandleCBTProc) Then _WinAPI_UnhookWindowsHookEx($HookHandleCBTProc)
if ($HookHandleDebugProc) Then _WinAPI_UnhookWindowsHookEx($HookHandleDebugProc)
if ($HookHandleForegroundIdleProc) Then _WinAPI_UnhookWindowsHookEx($HookHandleForegroundIdleProc)
if ($HookHandleGetMsgProc) Then _WinAPI_UnhookWindowsHookEx($HookHandleGetMsgProc)
if ($HookHandleKeyboardProc) Then _WinAPI_UnhookWindowsHookEx($HookHandleKeyboardProc)
if ($HookHandleMouseProc) Then _WinAPI_UnhookWindowsHookEx($HookHandleMouseProc)
if ($HookHandleMessageProc) Then _WinAPI_UnhookWindowsHookEx($HookHandleMessageProc)
if ($HookHandleShellProc) Then _WinAPI_UnhookWindowsHookEx($HookHandleShellProc)

if ($HookHandleKeyboardLLProc) Then _WinAPI_UnhookWindowsHookEx($HookHandleKeyboardLLProc)
if ($HookHandleMouseLLProc) Then _WinAPI_UnhookWindowsHookEx($HookHandleMouseLLProc)
EndFunc

