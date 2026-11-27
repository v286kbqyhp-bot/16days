# 仓库目的

本仓库用于开发和验证一款以守望为主题的单人 Game Jam 回合制战棋。使用 Godot 4.7.2 标准版和 GDScript。开发前先读 [README](README.md) 与[主策划](docs/design/游戏设计文档.md)，按本次任务查阅对应系统和附件。

## 文件归属

- `game/` 是 Godot 资源根。场景、运行时脚本、配表和已确认的游戏资产都放在这里。`res://` 从本目录起算。
- `tests/` 放测试脚本、测试场景和测试专用数据。测试加载正式工程资源，正式场景和脚本只依赖游戏目录内的资源。
- `docs/design/` 保存作者 Obsidian 原稿的仓库快照。同步时保留文件名、空白设计稿和附件引用，核对内容。先确认最新版本，避免异端旧副本覆盖作者的新改动。参考手册用于研究《陷阵之志》；本作规则以作者策划为准。
- `docs/requirements.md` 记录参赛要求和双端分工。Godot 缓存及本机导出成品留在版本库外。

## 实现与协作

### 纹章逐枚人工审核（作者 2026-11-27 明确要求）

- **图层归属必须逐层检查（作者 2026-11-27 补充）**：不能以合成图颜色正确代替分层正确。圆盘底色、背景纹样、圆盘高光阴影、主体与主体明暗分别归层；底端补齐像素的暗色属于圆盘阴影层，不能混入放射纹、云、风或人物层。不同纹章的层序不相同，脚本必须按图层名称或明确语义定位，禁止用固定层号猜测。保存后回读 PXO 的全部图层，检查轮廓外杂点、背景纹样与边框交叠、底边暗色归属，以及合成结果与 PNG 一致；同时目视检查全图层联系表。缺一项不得声称图层检查完成。

- 已通过的是 Pixelorama 制作、法线／扫光及悬停交互流程，不代表后续纹章的造型、配色或视觉效果自动通过。
- 每枚纹章先提供可编辑样稿，由作者人工审核具体外观与效果；根据作者明确给出的造型、颜色和修改意见逐项调整，再交回审阅。不能以一键生成、技术测试通过或上一枚通过代替本枚视觉确认。
- 复用已确认圆盘时应区分结构与配色：结构可以沿用，不能据此把普通纹章的配色当作其他纹章已确认的配色。配色由作者指定／确认后修改。
- 未经本枚纹章的明确视觉确认，不自行定稿、替换正式资源、接入正式界面或发版。视觉确认与提交／发布授权分别核对，不从流程通过推导发布授权。
- 天空纹章的高饱和蔚蓝天空与洁白云朵背景已获作者认可（sky-v2），后续保留这四个背景层。作者否定 sky-v3 的飞翔天使造型，要求参考中世纪宗教绘画的圣天使，并授权尝试安杰利科方向的金色圆光、白色长袍与浅色展开羽翼；看过 `docs/art/crests/sky-v4/` 后评价“还凑合吧下一个纹章”，本版暂留，继续下一枚守望者纹章。此评价不等于提交、正式接入或发布授权；下一枚的具体造型与配色仍由作者指定／确认。

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
godot --headless --path game --script ../tests/crest_maps_test.gd
godot --path game --script ../tests/crest_render_preview.gd
godot --path game --script ../tests/crest_hover_test.gd
godot --headless --path game --script ../tests/battle_scene_test.gd
godot --path game --script ../tests/battle_viewport_test.gd
```

出征与经济测试分别输出失败数，预期均为 0，进程退出码为 0。新增用例放进 tests/，并在此补上运行入口。导出运行与跨平台验收另记平台、Godot 版本和提交号。

纹章贴图测试预期 `failures=0`。`crest_render_preview.gd` 需真实图形渲染，不能加 `--headless`；可通过 `CREST_CAPTURE_DIR` 指定帧输出目录。交互审阅运行 `godot --path game res://../tests/crest_glint_live.tscn`，空格暂停／继续，R 重播。

战场视口测试需要真实图形渲染，覆盖六种尺寸、棋盘坐标和 GUI 点选，通过 `BATTLE_CAPTURE_DIR` 指定截图目录。
