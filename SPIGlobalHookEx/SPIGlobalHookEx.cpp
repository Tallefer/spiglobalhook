
#include "stdafx.h"

#include <shlobj.h>
#include <windows.h>
#include <stdio.h>

static int OkTestExeHwnd = 99999;
static HINSTANCE ihinstDLL = 0;
static HWND ExeHwnd = 0;
static UINT CBT_MSG,DEBUG_MSG,FOREGROUNDIDLE_MSG,GETMESSAGE_MSG,KEYBOARD_MSG,MOUSE_MSG,
MSGFILTER_MSG,SHELL_MSG,HOOK_GUI_MSG, KEYBOARDLL_MSG, MOUSELL_MSG;
static HHOOK HHOOKA,HHOOKB,HHOOKC,HHOOKD,HHOOKE,HHOOKF,HHOOKG,HHOOKH, HHOOKI, HHOOKJ;

LRESULT CALLBACK WINAPI CBTProc(int nCode,WPARAM wParam,LPARAM lParam);
LRESULT CALLBACK WINAPI DebugProc(int nCode,WPARAM wParam,LPARAM lParam);
LRESULT CALLBACK WINAPI ForegroundIdleProc(int nCode,WPARAM wParam,LPARAM lParam);
LRESULT CALLBACK WINAPI GetMsgProc(int nCode,WPARAM wParam,LPARAM lParam);
LRESULT CALLBACK WINAPI KeyboardProc(int nCode,WPARAM wParam,LPARAM lParam);
LRESULT CALLBACK WINAPI MouseProc(int nCode,WPARAM wParam,LPARAM lParam);
LRESULT CALLBACK WINAPI MessageProc(int nCode,WPARAM wParam,LPARAM lParam);
LRESULT CALLBACK WINAPI ShellProc(int nCode,WPARAM wParam,LPARAM lParam);

LRESULT CALLBACK WINAPI KeyboardLLProc(int nCode,WPARAM wParam,LPARAM lParam);
LRESULT CALLBACK WINAPI MouseLLProc(int nCode,WPARAM wParam,LPARAM lParam);

HWND GetExeHwnd();
void AtExitHookExW(void);

//#define __cplusplus
//#ifdef __cplusplus
extern "C"
{
//#endif
	__declspec(dllexport) HHOOK WINAPI DllWindowsHookExW(UINT idHook);
	__declspec(dllexport) BOOL WINAPI DllGetModuleFileNameW(LPWSTR &iMsgBuffer);
//#ifdef __cplusplus
}
//#endif
//
extern "C"
BOOL WINAPI DllMain(HANDLE hinstDLL,DWORD dwReason, LPVOID lpvReserved)
{

	if (dwReason == DLL_PROCESS_ATTACH)
	{

		ihinstDLL = (HINSTANCE) hinstDLL;
		WCHAR MsgBuffer[600];
		GetModuleFileNameW((HMODULE) hinstDLL,MsgBuffer,sizeof(MsgBuffer));
		HOOK_GUI_MSG = RegisterWindowMessageW(MsgBuffer);
		CBT_MSG = RegisterWindowMessageW(L"CBT_MSG");
		DEBUG_MSG = RegisterWindowMessageW(L"DEBUG_MSG");
		FOREGROUNDIDLE_MSG = RegisterWindowMessageW(L"FOREGROUNDIDLE_MSG");
		GETMESSAGE_MSG = RegisterWindowMessageW(L"GETMESSAGE_MSG");
		KEYBOARD_MSG = RegisterWindowMessageW(L"KEYBOARD_MSG");
		MOUSE_MSG = RegisterWindowMessageW(L"MOUSE_MSG");
		MSGFILTER_MSG = RegisterWindowMessageW(L"MSGFILTER_MSG");
		SHELL_MSG = RegisterWindowMessageW(L"SHELL_MSG");

		KEYBOARDLL_MSG = RegisterWindowMessageW(L"KEYBOARDLL_MSG");
		MOUSELL_MSG = RegisterWindowMessageW(L"MOUSELL_MSG");
		atexit(AtExitHookExW);

	}

	return 1;
}


HHOOK WINAPI DllWindowsHookExW(UINT idHook)
{

	switch(	idHook )
	{
	case WH_CBT:
		if (HHOOKA) return 0;
		HHOOKA = SetWindowsHookExW(idHook,CBTProc,ihinstDLL,0);
		if (HHOOKA) return HHOOKA;
		break;
	case WH_DEBUG:
		if (HHOOKB) return 0;
		HHOOKB = SetWindowsHookExW(idHook,DebugProc,ihinstDLL,0);
		if (HHOOKB) return HHOOKB;
		break;
	case WH_FOREGROUNDIDLE:
		if (HHOOKC) return 0;
		HHOOKC = SetWindowsHookExW(idHook,ForegroundIdleProc,ihinstDLL,0);
		if (HHOOKC) return HHOOKC;
		break;
	case WH_GETMESSAGE:
		if (HHOOKD) return 0;
		HHOOKD = SetWindowsHookExW(idHook,GetMsgProc,ihinstDLL,0);
		if (HHOOKD) return HHOOKD;
		break;
	case WH_KEYBOARD:
		if (HHOOKE) return 0;
		HHOOKE = SetWindowsHookExW(idHook,KeyboardProc,ihinstDLL,0);
		if (HHOOKE) return HHOOKE;
		break;
	case WH_MOUSE:
		if (HHOOKF) return 0;
		HHOOKF = SetWindowsHookExW(idHook,MouseProc,ihinstDLL,0);
		if (HHOOKF) return HHOOKF;
		break;
	case WH_MSGFILTER:
		if (HHOOKG) return 0;
		HHOOKG = SetWindowsHookExW(idHook,MessageProc,ihinstDLL,0);
		if (HHOOKG) return HHOOKG;
		break;
	case WH_SHELL:
		if (HHOOKH) return 0;
		HHOOKH = SetWindowsHookExW(idHook,ShellProc,ihinstDLL,0);
		if (HHOOKH) return HHOOKH;
		break;
	case WH_KEYBOARD_LL:
		if (HHOOKI) return 0;
		HHOOKI = SetWindowsHookExW(idHook,KeyboardLLProc,ihinstDLL,0);
		if (HHOOKI) return HHOOKI;
		break;
	case WH_MOUSE_LL:
		if (HHOOKJ) return 0;
		HHOOKJ = SetWindowsHookExW(idHook,MouseLLProc,ihinstDLL,0);
		if (HHOOKJ) return HHOOKJ;
		break;
	default:
		return 0;
		break;
	}

	return 0;

}

BOOL WINAPI DllGetModuleFileNameW(LPWSTR &iMsgBuffer)
{
	if (GetModuleFileNameW((HMODULE) ihinstDLL,iMsgBuffer,600) != 0) return 1;
	return 0;
}

LRESULT CALLBACK WINAPI CBTProc(int nCode,WPARAM wParam,LPARAM lParam)
{

	if (!(ExeHwnd)) ExeHwnd = GetExeHwnd();
	if (!(ExeHwnd)) return CallNextHookEx(HHOOKA,nCode,wParam,lParam);

	SendMessage(ExeHwnd,CBT_MSG,1,GetCurrentProcessId());
	SendMessage(ExeHwnd,CBT_MSG,2,nCode);
	SendMessage(ExeHwnd,CBT_MSG,3,wParam);

	INT RT = SendMessage(ExeHwnd,CBT_MSG,4,lParam);
	if (RT)
	{
		return RT;
	} else {
		return CallNextHookEx(HHOOKA,nCode,wParam,lParam);
	}

}

LRESULT CALLBACK WINAPI DebugProc(int nCode,WPARAM wParam,LPARAM lParam)
{

	if (!(ExeHwnd)) ExeHwnd = GetExeHwnd();
	if (!(ExeHwnd)) return CallNextHookEx(HHOOKB,nCode,wParam,lParam);

	SendMessage(ExeHwnd,DEBUG_MSG,1,GetCurrentProcessId());
	SendMessage(ExeHwnd,DEBUG_MSG,2,nCode);
	SendMessage(ExeHwnd,DEBUG_MSG,3,wParam);

	INT RT = SendMessage(ExeHwnd,DEBUG_MSG,4,lParam);
	if (RT)
	{
		return RT;
	} else {
		return CallNextHookEx(HHOOKB,nCode,wParam,lParam);
	}

}

LRESULT CALLBACK WINAPI ForegroundIdleProc(int nCode,WPARAM wParam,LPARAM lParam)
{

	if (!(ExeHwnd)) ExeHwnd = GetExeHwnd();
	if (!(ExeHwnd)) return CallNextHookEx(HHOOKC,nCode,wParam,lParam);

	SendMessage(ExeHwnd,FOREGROUNDIDLE_MSG,1,GetCurrentProcessId());
	SendMessage(ExeHwnd,FOREGROUNDIDLE_MSG,2,nCode);
	SendMessage(ExeHwnd,FOREGROUNDIDLE_MSG,3,wParam);

	INT RT = SendMessage(ExeHwnd,FOREGROUNDIDLE_MSG,4,lParam);
	if (RT)
	{
		return RT;
	} else {
		return CallNextHookEx(HHOOKC,nCode,wParam,lParam);
	}

}

LRESULT CALLBACK WINAPI GetMsgProc(int nCode,WPARAM wParam,LPARAM lParam)
{

	if (!(ExeHwnd)) ExeHwnd = GetExeHwnd();
	if (!(ExeHwnd)) return CallNextHookEx(HHOOKD,nCode,wParam,lParam);

	SendMessage(ExeHwnd,GETMESSAGE_MSG,1,GetCurrentProcessId());
	SendMessage(ExeHwnd,GETMESSAGE_MSG,2,nCode);
	SendMessage(ExeHwnd,GETMESSAGE_MSG,3,wParam);

	INT RT = SendMessage(ExeHwnd,GETMESSAGE_MSG,4,lParam);
	if (RT)
	{
		return RT;
	} else {
		return CallNextHookEx(HHOOKD,nCode,wParam,lParam);
	}
}


LRESULT CALLBACK WINAPI KeyboardProc(int nCode,WPARAM wParam,LPARAM lParam)
{

	if (!(ExeHwnd)) ExeHwnd = GetExeHwnd();
	if (!(ExeHwnd)) return CallNextHookEx(HHOOKE,nCode,wParam,lParam);

	SendMessage(ExeHwnd,KEYBOARD_MSG,1,GetCurrentProcessId());
	SendMessage(ExeHwnd,KEYBOARD_MSG,2,nCode);
	SendMessage(ExeHwnd,KEYBOARD_MSG,3,wParam);

	INT RT = SendMessage(ExeHwnd,KEYBOARD_MSG,4,lParam);
	if (RT)
	{
		return RT;
	} else {
		return CallNextHookEx(HHOOKE,nCode,wParam,lParam);
	}

}

LRESULT CALLBACK WINAPI KeyboardLLProc(int nCode,WPARAM wParam,LPARAM lParam)
{

	if (!(ExeHwnd)) ExeHwnd = GetExeHwnd();
	if (!(ExeHwnd)) return CallNextHookEx(HHOOKI,nCode,wParam,lParam);

	//KBDLLHOOKSTRUCT *pkh = (KBDLLHOOKSTRUCT *) lParam;
	//WCHAR buf[128]=L"aa";
	//if (nCode==HC_ACTION) {
	//	BOOL         bCtrlKeyDown = GetAsyncKeyState(VK_CONTROL)>>((sizeof(SHORT) * 8) - 1);
	//	swprintf(buf, L"KeyboardProc | vkCode:%d flags:%d", pkh->vkCode, pkh->flags);
	//	OutputDebugStringW(buf);
	//}

	SendMessage(ExeHwnd,KEYBOARDLL_MSG,1,GetCurrentProcessId());
	SendMessage(ExeHwnd,KEYBOARDLL_MSG,2,nCode);
	SendMessage(ExeHwnd,KEYBOARDLL_MSG,3,wParam);

	INT RT = SendMessage(ExeHwnd,KEYBOARDLL_MSG,4,lParam);
	if (RT)
	{
		return RT;
	} else {
		return CallNextHookEx(HHOOKI,nCode,wParam,lParam);
	}

}

LRESULT CALLBACK WINAPI MouseProc(int nCode,WPARAM wParam,LPARAM lParam)
{

	if (!(ExeHwnd)) ExeHwnd = GetExeHwnd();
	if (!(ExeHwnd)) return CallNextHookEx(HHOOKF,nCode,wParam,lParam);

	SendMessage(ExeHwnd,MOUSE_MSG,1,GetCurrentProcessId());
	SendMessage(ExeHwnd,MOUSE_MSG,2,nCode);
	SendMessage(ExeHwnd,MOUSE_MSG,3,wParam);
	INT RT = SendMessage(ExeHwnd,MOUSE_MSG,4,lParam);
	if (RT)
	{
		return RT;
	} else {
		return CallNextHookEx(HHOOKF,nCode,wParam,lParam);
	}

}
LRESULT CALLBACK WINAPI MouseLLProc(int nCode,WPARAM wParam,LPARAM lParam)
{

	if (!(ExeHwnd)) ExeHwnd = GetExeHwnd();
	if (!(ExeHwnd)) return CallNextHookEx(HHOOKJ,nCode,wParam,lParam);

	//tagMSLLHOOKSTRUCT *pMSH = (tagMSLLHOOKSTRUCT *) lParam;
	//WCHAR buf[128]=L"aa";
	//swprintf(buf, L"DLLMouseLLProc (%d, %d)", pMSH->pt.x, pMSH->pt.y);
	//OutputDebugString(buf);

	SendMessage(ExeHwnd,MOUSELL_MSG,1,GetCurrentProcessId());
	SendMessage(ExeHwnd,MOUSELL_MSG,2,nCode);
	SendMessage(ExeHwnd,MOUSELL_MSG,3,wParam);
	INT RT = SendMessage(ExeHwnd,MOUSELL_MSG,4,lParam);
	if (RT)
	{
		return RT;
	} else {
		return CallNextHookEx(HHOOKJ,nCode,wParam,lParam);
	}

}

LRESULT CALLBACK WINAPI MessageProc(int nCode,WPARAM wParam,LPARAM lParam)
{

	if (!(ExeHwnd)) ExeHwnd = GetExeHwnd();
	if (!(ExeHwnd)) return CallNextHookEx(HHOOKG,nCode,wParam,lParam);

	SendMessage(ExeHwnd,MSGFILTER_MSG,1,GetCurrentProcessId());
	SendMessage(ExeHwnd,MSGFILTER_MSG,2,nCode);
	SendMessage(ExeHwnd,MSGFILTER_MSG,3,wParam);

	INT RT = SendMessage(ExeHwnd,MSGFILTER_MSG,4,lParam);
	if (RT)
	{
		return RT;
	} else {
		return CallNextHookEx(HHOOKG,nCode,wParam,lParam);
	}

}

LRESULT CALLBACK WINAPI ShellProc(int nCode,WPARAM wParam,LPARAM lParam)
{

	if (!(ExeHwnd)) ExeHwnd = GetExeHwnd();
	if (!(ExeHwnd)) return CallNextHookEx(HHOOKH,nCode,wParam,lParam);

	SendMessage(ExeHwnd,SHELL_MSG,1,GetCurrentProcessId());
	SendMessage(ExeHwnd,SHELL_MSG,2,nCode);
	SendMessage(ExeHwnd,SHELL_MSG,3,wParam);

	INT RT = SendMessage(ExeHwnd,SHELL_MSG,4,lParam);
	if (RT)
	{
		return RT;
	} else {
		return CallNextHookEx(HHOOKH,nCode,wParam,lParam);
	}

}


HWND GetExeHwnd()
{

	HWND hwnd = NULL;
	do
	{
		hwnd = FindWindowEx(NULL,hwnd,NULL,NULL);
		if ((int) SendMessage(hwnd,HOOK_GUI_MSG,0,0) == OkTestExeHwnd) return hwnd;
	}
	while (hwnd != NULL);

	return 0;

}

void AtExitHookExW()
{
	if (HHOOKA) UnhookWindowsHookEx(HHOOKA);
	if (HHOOKB) UnhookWindowsHookEx(HHOOKB);
	if (HHOOKC) UnhookWindowsHookEx(HHOOKC);
	if (HHOOKD) UnhookWindowsHookEx(HHOOKD);
	if (HHOOKE) UnhookWindowsHookEx(HHOOKE);
	if (HHOOKF) UnhookWindowsHookEx(HHOOKF);
	if (HHOOKG) UnhookWindowsHookEx(HHOOKG);
	if (HHOOKH) UnhookWindowsHookEx(HHOOKH);

	if (HHOOKI) UnhookWindowsHookEx(HHOOKI);
	if (HHOOKI) UnhookWindowsHookEx(HHOOKJ);
}
