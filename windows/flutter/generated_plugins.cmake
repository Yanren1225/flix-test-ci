#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
  bonsoir_windows
  clipboard_watcher
  connectivity_plus
  desktop_drop
  downloadsfolder
  file_selector_windows
  firebase_core
  flutter_desktop_sleep
  local_notifier
  open_dir_windows
  pasteboard
  permission_handler_windows
  screen_capturer_windows
  screen_retriever
  share_plus
  sqlite3_flutter_libs
  tray_manager
  uri_content
  url_launcher_windows
  video_player_win
  window_manager
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
  simple_native_image_compress
)

set(PLUGIN_BUNDLED_LIBRARIES)

foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${plugin}/windows plugins/${plugin})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${plugin}_bundled_libraries})
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${ffi_plugin}/windows plugins/${ffi_plugin})
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${ffi_plugin}_bundled_libraries})
endforeach(ffi_plugin)
