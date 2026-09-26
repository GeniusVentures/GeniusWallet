#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter_windows.h>
#include <windows.h>

#include <algorithm>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command)
{
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent())
  {
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
  // Tall enough that the dashboard chart is not squeezed flat, but never
  // bigger than the monitor's work area. CreateAndShow scales this size by
  // the monitor's DPI, so the work area is converted to logical pixels first.
  RECT work{};
  ::SystemParametersInfo(SPI_GETWORKAREA, 0, &work, 0);
  const POINT at{static_cast<LONG>(origin.x), static_cast<LONG>(origin.y)};
  const double scale =
      FlutterDesktopGetDpiForMonitor(
          ::MonitorFromPoint(at, MONITOR_DEFAULTTONEAREST)) /
      96.0;
  const auto fit = [scale](unsigned wanted, LONG available) {
    const LONG logical = static_cast<LONG>(available / scale) - 20;
    return logical > 0 ? std::min(wanted, static_cast<unsigned>(logical))
                       : wanted;
  };
  Win32Window::Size size(fit(1440, work.right - work.left),
                         fit(900, work.bottom - work.top));
  if (!window.CreateAndShow(L"Genius Wallet", origin, size))
  {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0))
  {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
