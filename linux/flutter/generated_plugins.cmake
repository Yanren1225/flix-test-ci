#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
  clipboard_watcher
  desktop_drop
  file_selector_linux
  local_notifier
  open_dir_linux
  pasteboard
  screen_capturer_linux
  screen_retriever
  sqlite3_flutter_libs
  tray_manager
  uri_content
  url_launcher_linux
  window_manager
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
  simple_native_image_compress
)

set(PLUGIN_BUNDLED_LIBRARIES)

foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${plugin}/linux plugins/${plugin})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${plugin}_bundled_libraries})
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${ffi_plugin}/linux plugins/${ffi_plugin})
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${ffi_plugin}_bundled_libraries})
endforeach(ffi_plugin)
