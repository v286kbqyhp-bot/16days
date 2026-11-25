# 仓库目的

本仓库用于开发和验证一款以守望为主题的单人 Game Jam 回合制战棋。使用 Godot 4.7.2 标准版和 GDScript。开发前先读 [README](README.md) 与[主策划](docs/design/游戏设计文档.md)，按本次任务查阅对应系统和附件。

## 文件归属

- `game/` 是 Godot 资源根。场景、运行时脚本、配表和已确认的游戏资产都放在这里。`res://` 从本目录起算。
- `tests/` 放测试脚本、测试场景和测试专用数据。测试加载正式工程资源，正式场景和脚本只依赖游戏目录内的资源。
- `docs/design/` 保存作者 Obsidian 原稿的仓库快照。同步时保留文件名、空白设计稿和附件引用，核对内容。先确认最新版本，避免异端旧副本覆盖作者的新改动。参考手册用于研究《陷阵之志》；本作规则以作者策划为准。
- `docs/requirements.md` 记录参赛要求和双端分工。Godot 缓存及本机导出成品留在版本库外。

## 实现与协作

- 按已确认规则实现，用中文解释可调字段的用途、单位和倍率。策划中的试算值保留试算标识。新增玩法、文案或美术方案先与作者讨论。
- 营地持有角色和装备实例；出征成功后向战斗提供队伍快照。场景负责输入与展示，数值计算使用 `game/economy/` 中的规则和配表，测试直接调用同一实现。
- 修改前核对当前分支与工作树。Mac 与 Windows 的协作使用提交号报告已测版本，涉及共享工程配置时同步变更。提交 AI 生成内容时更新相应开发记录，方便赛后整理声明。

## 从仓库根目录验证

以下命令假设 Godot 4.7.2 标准版在终端中的命令名为 godot。也可用本机 Godot 可执行文件的路径替换它。

```sh
godot --headless --editor --path game --import
godot --headless --path game --quit
godot --headless --path game --script ../tests/expedition_test.gd
godot --headless --path game --script ../tests/economy_test.gd
```

出征与经济测试分别输出失败数，预期均为 0，进程退出码为 0。新增用例放进 tests/，并在此补上运行入口。导出运行与跨平台验收另记平台、Godot 版本和提交号。
