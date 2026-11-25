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

## 开发记录

2026-11-24，作者提供角色、武器、纹章与出征规则。OpenAI Codex 根据这些规则编写营地模块、测试与工程配置，并运行 Godot 无窗口测试。
2026-11-25，Codex 按作者确认的经济规则编写配置和测试，整理工程目录并同步策划原稿。
