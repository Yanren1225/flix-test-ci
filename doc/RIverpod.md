Controller 层使用 Riverpod_generator 生成的 NotifierProvider 实现，将 Notifier 直接作为 Controller。具体可参考 `lib/theme/theme.dart`，其中做出以下约束：

* 如果 Controller 需要异步初始化：  

a、_innerInit 中不能使用 ref 读取其他 Provider，如果需要依赖则直接在 build 中 watch   
b、只有 keepAlive 为 true 的 Controller 才能使用异步初始化  
c、异步初始化需要给加载态，然后再异步方法中更新状态  
d、异步初始化需要在 View 层添加闪屏页，可参考 下文 介绍  

```dart

@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  late Future<void> _init;

  ThemeController() {
    _init = Future.microtask(() {
      _innerInit();
    });
  }
  
  @override
  ThemeConfig build() {
    // 加载态
    return ThemeConfig.none;
  }

  Future<void> _innerInit() async {
    // 初始化代码，这里不能使用 ref 读取或观察其他 Provider，因为可能目标 Controller 还未初始化成功
    // 加载后使用 state = XX 来更新状态
  }
  // 其他业务代码
}
```

* 需要新增 of 和 watch 静态方法来方便调用处调用和阅读，其中 of 返回 Notifier，watch 返回 State

```dart
@Riverpod()
class ThemeController extends _$ThemeController {

  static ThemeController of(WidgetRef ref) =>
      ref.watch(themeControllerPod.notifier);

  static ThemeConfig watch(WidgetRef ref) =>
      ref.watch(themeControllerPod);
  
  // 其他业务代码
}
```

* 对于多状态的合并可以使用方法方式的 Riverpod

```dart
@Riverpod()
Target combineAB(CombineABRef ref){
  final a = ref.watch(APod); // 另外一个方法方式的 Riverpod
  final b = BController.watch(ref); // Notifier
  // 将 a 和 b 合并为 目标类型并返回
}
```