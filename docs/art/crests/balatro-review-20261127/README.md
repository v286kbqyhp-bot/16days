# Balatro 收藏卡牌渲染核查

核查日期：2026-11-27。用户要求使用 GitHub 上的 REA skill，判断 Balatro 收藏中卡牌效果是否使用「纯色底图＋法线贴图」。

## 结论

本机 Balatro 1.0.1o-FULL 的「收藏 → 版本」中，普通、闪箔、镭射、多彩、负片使用同一张小丑彩图，通过不同 shader 计算色彩和覆盖效果。已核对的这条卡牌绘制流程不读取法线贴图，不是基于表面法线和灯光方向的实时照明。

卡牌原图本身包含像素明暗。动态闪光没有固化在 PNG 中，而是由 shader 在运行时计算。要复用其效果路线，不要求先把原图做成纯固有色，也不要求制作 normal map。若本项目仍要求金属凹凸随场景灯光变化，底色＋法线是另一项独立需求，不能标作 Balatro 原实现。

## REA 来源与执行

- 官方仓库：https://github.com/morluto/rea
- 已读取 skill：`.agents/skills/reverse-engineer-anything/SKILL.md`，metadata version 63。
- 下载的仓库提交：`54a6f08ecb22e1fb6751702f3195735249d07f89`。
- 实际执行工具：本机 npm 缓存中的 REA CLI 6.4.0，用该版本自身 `--help` 确认命令后执行 `inspect-artifact` 和 `extract-artifact`。没有把阅读 skill 等同于完成 MCP 安装。
- 运行环境：ChatGPT bundled Node v24.22.3。未配置新 MCP、未安装原生反编译引擎。
- 目标：`/Users/a488/Library/Application Support/Steam/steamapps/common/Balatro/Balatro.app/Contents/Resources/Balatro.love`。
- SHA-256：`48c7a0791796a969d2cd0891ebdc9922b2988eb5aaad8ad7a72775a02772e24e`。
- REA 识别为 ZIP；304 个成员，加根节点共 305 个 artifact 节点。
- 检查 Evidence：`ev_2b7d32dccba5f2d193a17bf37997ed524d37253161b1be10ecff3e8ccaefa231`，完整结果见 [rea-inspection.json](rea-inspection.json)。
- 提取 Evidence：`ev_b591276d646f6cec0d2e781af940c969be46553ff6d533600578a4a925b90b01`，完整结果见 [rea-extraction.json](rea-extraction.json)。
- 提取后的 Lua、shader 与 PNG 用普通文件工具阅读和目视核对。这部分是人工沿代码路径分析，不伪称为 REA 的自动代码结论。游戏原文件未改动，游戏贴图和源码未复制进本项目资产。

## 证据链

以下路径和行号对应该 SHA-256 的游戏包成员；不是本项目代码。

| 核查项 | 观察与位置 | 结论类别 |
| --- | --- | --- |
| 收藏页的五张牌 | `functions/UI_definitions.lua:3840` 的 `create_UIBox_your_collection_editions` 按 base、foil、holo、polychrome、negative 建立卡牌并设置 edition | 静态事实 |
| 相同基础彩图 | `game.lua:658` 起的 edition 定义均指向 Joker atlas 的同一位置；已目视读取 `resources/textures/1x/Jokers.png`，该图有现成像素明暗 | 静态事实＋图像观察 |
| 运行时效果参数 | `card.lua:4349` 将旋转、真实时间、弹动和倾斜量组合传入 shader；第二个值是真实时间 | 静态事实 |
| 基础绘制和 edition 覆盖 | `card.lua:4415` 起绘制原图，`card.lua:4452` 起分别叠加 holo、foil、polychrome、negative_shine | 静态事实 |
| 输入与贴图绑定 | `engine/sprite.lua:73` 的 `draw_shader` 发送鼠标位置、hovering、图集区域、图像尺寸、溶解值与 edition 参数，然后绘制原 sprite | 静态事实 |
| 闪箔 | `resources/shaders/foil.fs` 的 effect 读取原彩图，使用局部 UV、三角函数、半径与 edition 参数计算条纹和颜色／透明度变化 | 静态事实 |
| 镭射与多彩 | `resources/shaders/holo.fs`、`polychrome.fs` 的 effect 读取彩图，在 HSL 空间结合程序场和时间参数修改颜色 | 静态事实 |
| 倾斜 | 这些 shader 的 position 函数使用鼠标偏移和 hovering 改变投影位置；不是通过法线图产生倾斜 | 静态事实 |
| 投影 | `card.lua:4359` 与 `engine/sprite.lua:76` 重绘偏移／缩放后的黑色轮廓；`dissolve.fs` 中 shadow 分支使用原 alpha 生成阴影 | 静态事实 |
| 实际界面 | 用 CUA 打开本机 Balatro，进入「收藏 → 版本」，检查五张牌并指向闪箔；画面可见倾斜、闪箔纹路及多彩变化 | UI 观察，截图留在本次聊天工具记录中 |

## 范围与剩余事项

已回答：本机该版本收藏卡牌的 edition 效果是否依赖法线贴图——不依赖。不是仅凭文件名没有 normal 就下结论，而是核对了调用链和 shader 的实际输入、采样与计算。

没有 GPU 抓帧，也未对游戏全部 shader、所有平台和未来版本作通用断言。REA 的静态包清单不代表运行观测；UI 操作单独记录。

纹章内容仍以作者《纹章设计文档》为准。新纯色／法线源件尚未制作，需先确认用户是继续要求真实灯光凹凸，还是选择已查证的 Balatro 卡面 shader 路线。该决定改变资产交付，不擅自替用户选择。

## 补充核查：盲注与卡牌版本的效果不同

用户继续要求查看盲注贴图，并询问各帧高光是否由 shader 生成。已核对同一游戏包中的 `resources/textures/1x/BlindChips.png` 与 `2x/BlindChips.png`，提取文件与包内字节一致。1x 文件 SHA-256：`07ea39f0bc44af8a634606d6c864f3617ce52148fab52c18b9acc4be310de9f3`。

- `game.lua:1010` 声明盲注基础单帧为 34×34 像素、每行 21 帧。
- 已目视查看原图：斜向高光出现在不同帧的不同位置，是现成图像内容。
- `engine/animatedsprite.lua` 的 `AnimatedSprite:animate()` 按时间计算帧索引，再通过 `setViewport` 横向切换图集区域。因此该扫光来自序列帧播放，不依赖法线实时照明。
- `functions/UI_definitions.lua` 的 `create_UIBox_your_collection_blinds()` 为盲注声明两个 dissolve 绘制步骤：阴影与本体；鼠标指向时将 hover_tilt 设为 3，移出时归零。战斗中的 `blind.lua:446` 也以 dissolve 绘制阴影和本体。
- 所以盲注不是「完全没有 shader」：现成帧负责高光动画，shader 仍参与溶解、投影和悬停倾斜。前面关于 foil/holo/polychrome 的结论只适用于收藏的「版本」卡牌，不能泛化到盲注。

以上为静态调用链与原始图像核对；本次未额外进入盲注收藏界面录制播放，也未宣称已经完成该项运行观测。
