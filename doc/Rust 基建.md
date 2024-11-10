## 整体架构

为了统一 Rust 二进制库的各种依赖版本和 Rust_Bridge 本身的版本。将 Flix 所有 Rust 代码和相关 Dart 胶水层作为一个 Plugin 供主项目依赖。后续所有和 Rust 相关的代码都需要下沉到该项目。

```
/Flix
    /flix_rust                              // flix rust plugin 目录
        /rust                               // rust 代码
            /src
                /image_compress             // 缩略图生成相关代码
                    /mod.rs 
                /scrcpy                     // 投屏相关代码
                    /mod.rs
            /Cargo.toml                     // Cargo 配置文件
        /lib                                // Flutter 胶水层
            /image_compress.dart            // export src/rust/image_compress 相关代码
            /scrcpy.dart                    // export src/rust/scrcpy 相关代码
            /src/rust
                /image_compress             // flutter_rust_bridge 生成的对应 Crate::image_compress 的胶水层代码
                /scrcpy                     // flutter_rust_bridge 生成的对应 Crate::scrcpy 的胶水层代码
        /flutter_rust_bridge.yaml           // flutter_rust_bridge 配置文件，配置需要生成代码的 Crate

    /lib                                    // 主项目代码
    /pubspec.yaml                           // 主项目依赖文件，其中依赖了 flix_rust plugin
```

## 添加 Crate

如果需要拓展一个需要 rust 层的 Crate ，首先确定 Crate，假设为 scrcpy 。 

1. 添加 Rust 代码  

创建文件夹 `/flix_rust/rust/src/rust/scrcpy`，新建 `mod.rs`，然后在该目录下写对应的功能代码，最后在 `mod.rs` 里导出。  
同时可以在 `Cargo.toml` 里添加 rust 的依赖，这里需要版本统一因此所有 rust 模块公用依赖配置。

2. 添加 flutter_rust_bridge 配置

在 `/flix_rust/flutter_rust_bridge.yaml` 文件里添加你的 Crate ：

```yaml
rust_input: crate::image_compress, crate::scrcpy
rust_root: rust/
dart_output: lib/src/rust
```

3. 生成胶水层代码

cd 到 flix_rust 目录，并执行 `flutter_rust_bridge_codegen generate` 命令，执行后会在 `flix_rust/lib/src/scrcpy` 下生成胶水层文件。

4. 导出胶水层文件

在 `flix_rust/lib` 下创建文件 `flix_rust/lib/scrcpy.dart` ，并在其中 `export` 相关的胶水层代码。