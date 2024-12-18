#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

BOOL isRunAsAdmin();
void runAsAdmin();

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {

//    if (!isRunAsAdmin()) {
//        runAsAdmin();
//        exit(0);
//    }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  HWND hwnd = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"flix");
  if (hwnd != NULL) {
      ::ShowWindow(hwnd, SW_NORMAL);
      ::SetForegroundWindow(hwnd);
      return EXIT_FAILURE;
  }
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);



  if (!window.Create(L"flix", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}


BOOL isRunAsAdmin() {
    BOOL isRunAsAdmin = FALSE;
    HANDLE hToken = NULL;
    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &hToken))
    {
        return FALSE;
    }
    TOKEN_ELEVATION tokenEle;
    DWORD dwRetLen = 0;
    if (GetTokenInformation(hToken, TokenElevation, &tokenEle, sizeof(tokenEle), &dwRetLen))
    {
        if (dwRetLen == sizeof(tokenEle))
        {
            isRunAsAdmin = tokenEle.TokenIsElevated;
        }
    }
    CloseHandle(hToken);
    return isRunAsAdmin;
}

void runAsAdmin() {
    WCHAR czFileName[1024] = { 0 };
    GetModuleFileName(NULL, czFileName, _countof(czFileName) - 1);
    SHELLEXECUTEINFO  EI;
    memset(&EI, 0, sizeof(EI));
    EI.cbSize = sizeof(SHELLEXECUTEINFO);
    EI.lpVerb = TEXT("runas");
    EI.fMask = 0x00000040;
    EI.lpFile = czFileName;
    EI.nShow = SW_SHOW;
    ShellExecuteEx(&EI);
}


