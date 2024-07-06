# 关于颜色的说明

首先需要的颜色都在 lib/theme/color.json 下面，添加颜色的时候记得在 `light` 和 `dark` 下面都要添加，然后运行 `dart run ./theme/generate_theme_extensions.dart` 就会生成新的 `theme_extensions.dart` 文件，最后在使用的时候直接 `Theme.of(context).flixColors.background.primary` 这样就行了，是有类型补全提示的。
