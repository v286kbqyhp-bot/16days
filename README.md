# 守望题材战棋开发仓库

使用 Godot 4.7.2 标准版和 GDScript 开发的单人 Game Jam 战棋。玩家率队进入地精领地，保护水晶采集器，回营后缴税、配装并准备下次出征。游戏名待定，`16days` 是仓库名。

| 入口 | 用途 |
| --- | --- |
| [game/](game/) | 正式 Godot 工程。用编辑器导入 [game/project.godot](game/project.godot) |
| [tests/](tests/) | 无窗口运行的自动测试，独立于游戏资源目录 |
| [docs/design/](docs/design/) | 作者的策划、战斗流程图、开发日志和参考资料。从[游戏设计文档](docs/design/游戏设计文档.md)开始 |
| [AGENTS.md](AGENTS.md) | 开发约定、测试命令与设计同步方式 |
| [参赛要求与分工](docs/requirements.md) | 比赛交付及双端协作 |

当前已实现营地配装、出征校验和经济试算。主场景为空入口。调数值可打开[经济配表](game/economy/prototype.tres)，在 Godot Inspector 中查看中文备注。

首张 2D 等轴森林战场样片可在编辑器打开 [battle_preview.tscn](game/battle/battle_preview.tscn) 按 F6 运行（可随窗口扩展的像素世界层位于 [forest_battle_world.tscn](game/battle/forest_battle_world.tscn)）。按 `F1` 显示样片测试控件，支持切换战斗部署态、行动与敌方预告态、草地燃烧、石块二次碎裂、水晶采集器状态，按 `H` 可隐藏界面审阅纯像素战场，按 `R` 重置盘面。

## 开发记录

2026-11-24，作者提供角色、武器、纹章与出征规则。OpenAI Codex 根据这些规则编写营地模块、测试与工程配置，并运行 Godot 无窗口测试。
2026-11-25，Codex 按作者确认的经济规则编写配置和测试，整理工程目录并同步策划原稿。
2026-11-27，Antigravity 按作者确认的 2D 等轴像素方案搭建首张森林战场「寒林前哨」（640×360 SubViewport 实时法线打光 + 1280×720 顶层高清战术标记）。外围针叶松、覆雪松与树桩采用 pistachio 的 CC0 像素森林包，宝箱、林间小物件与队员基础小人采用 Kenney CC0 像素包，棋盘地形块、沙盘岩层台基、水晶采集器、掠夺地精及全套配对法线贴图由 AI 辅助脚本生成并保存为 [Pixelorama 分层原件](docs/art/battle/)。

2026-11-27，Codex 按作者确认方向制作森林地面连续延伸与边界迷雾样片。复用现有土壤、林木及单位素材，移除台基显示和地砖下侧沿，新增世界坐标迷雾 Shader，并按棋盘可见范围适配整数像素倍率。地图名称待定，人物为占位，本轮外观待作者审阅。
