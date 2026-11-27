# 普通纹章正式原件与法线制作记录

2026-11-27。作者确认普通纹章并亲自在 Pixelorama 补齐底部八个像素，随后要求保存到资源目录、制作法线、实现类似 Balatro 的程序化扫光并 commit / push。此目录只保存本次普通纹章及公共圆盘模板，不包含此前被否决的草稿或第三方游戏原图。

## 作者原件

`crest_common_color.pxo` 直接从作者当前打开且未保存的 Pixelorama 画布另存，保留四层与所有手改。相对此前第九版，最终合成图新增 `(20..27,46)` 八个底部像素，颜色为 `#5c7779`，其他像素相同。坐标从零起算。

源件 SHA-256：`722bd2100331d20e33583592d98f5a9bf7d070f2864e1328aebe23b9d8e5fe38`。不得用旧稿的生成脚本覆盖这份作者原件。

## AI 辅助制作内容

Codex 依据作者确认的形状制作独立法线、高光强度遮罩、公共圆盘模板和扫光 shader。法线采用浅凸圆盘、径向倒角、四种明确指定方向的晶体切面；外缘单像素倒角继承既有图案轮廓。没有把彩色亮度作为高度，没有更改作者彩图。

- `crest_common_normal.pxo`：圆盘浅弧面、包边倒角、石英切面与外缘三层。
- `crest_common_highlight_mask.pxo`：底盘、包边、石英反光三层。
- `template_disc_color.pxo`：直接保留作者原件前两层，作为后续纹章的底盘模板。
- `template_disc_normal.pxo`：公共圆盘弧面与倒角两层。
- PNG 运行时资源和材质位于 `game/art/crests/`。

`build_crest_maps.gd` 是运行于 Pixelorama 1.2.4 原生环境的制作脚本，使用 Project / PixelLayer / PixelCel 与原生保存接口。它不是游戏运行入口，也不是普通 Godot 项目可直接运行的脚本。重建时设置 `CREST_REPO_ROOT`，在 Pixelorama 源工程初始化完成后实例化并调用 `run()`；读取作者原件但不覆盖它。后续若手工修改法线原件，重建前须先保留新版本。

工具版本：Pixelorama 1.2.4 源码 `f3cb9ab2065042ba6b31beee4204221ff9006d50`，Godot 4.7.2 标准版，macOS / Apple M5 / GL Compatibility。制作是通过 Pixelorama 原生接口执行的 AI 辅助绘制，不冒充逐点鼠标手绘。审阅图布局和 GIF 编码使用 Pillow，纹章资产本身未通过 Pillow 修改。

## 验证

- `tests/crest_maps_test.gd` 比较彩图与作者 PXO、圆盘与作者前两层、透明轮廓、法线单位长度、四向符号、灰度遮罩，并检查作者补回的八个像素。
- `tests/crest_render_preview.gd` 在实际 Godot 图形渲染器输出四向受光和 31 个扫光阶段，检查关闭高光时渲染与原图一致、扫光过程中 alpha 不变。
- `tests/crest_glint_live.tscn` 是独立交互审阅窗口：左原图，右循环扫光，空格暂停/继续，R 重播。不是正式游戏界面。
- `normal-maps-overview.png`：彩图 / 法线 / 遮罩。
- `normal-lighting-review.png`、`crest-common-glint.gif`：由实际 Godot 渲染帧排版、编码，非手工绘制的效果示意。

法线和 shader 是首版可调实现，扫光视觉最终由作者确认。正式游戏尚未接入这些新资源。
