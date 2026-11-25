# 守望题材战棋开发仓库

游戏尚未命名。`16days` 是开发仓库的临时标识。项目使用 Godot 4.7.2 和 GDScript。当前原型实现营地配装和出征规则。主场景是空入口。

## 架构

- 营地持有角色与装备实例。每件武器和纹章都有实例 ID，同款装备可以分别归属不同角色。配装与出征校验集中在 `camp/expedition.gd`，可在场景树之外运行。
- 出征成功后，调用方通过 `party_snapshot()` 取得队伍与装备 ID 的独立副本。营地锁定配装，直到调用 `return_to_camp()`。后续战斗模块将持有本场位置、生命值与行动状态，再将战果交回营地结算。
- 场景层负责接收输入与显示状态。将来的预告和攻击结算应共用战斗规则，以便测试玩家看到的结果和实际结算是否一致。

## 运行

使用 Godot 编辑器导入根目录的 `project.godot`。在项目根目录执行以下命令可验证营地规则。

```sh
godot --headless --path . --script test/expedition_test.gd
```

## 开发记录

2026-11-24，作者提供角色、武器、纹章与出征规则。OpenAI Codex 根据这些规则编写营地模块、测试与工程配置，并运行 Godot 无窗口测试。当前提交尚待作者试玩和复核。

比赛提交需要 AtomGit 仓库、对应提交标识、Windows 可运行版本，以及官方模板的 AI 使用与素材声明。详见[大赛官网](https://2026gamejam.osgame.org/)。

[项目要求、比赛交付与双端分工](docs/requirements.md)

## 经济试算

在 Godot 中打开 `economy/prototype.tres` 调整采集、税、利息、价格与奖励预算。运行 `godot --headless --path . --script test/economy_test.gd` 检查公式边界。目前提供数值查询与验算，待营地交易和关卡结算调用。
