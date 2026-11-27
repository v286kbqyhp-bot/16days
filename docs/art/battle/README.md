# 寒林前哨战场美术源层与来源记录（Section 1–4, 6, 14–15）

本目录保存《16days》首张 2D 等轴森林战场 **关卡 1「寒林前哨」** 的 **Pixelorama v1.2.4 可编辑分层原件（`.pxo`，v8 格式）** 与配对 **OpenGL 切线空间法线原件（`*_normal.pxo`）**。对应运行时贴图位于 `game/battle/art/`，世界场景为 `game/battle/forest_battle_world.tscn`，带高清 UI 与战术标记的预览入口为 `game/battle/battle_preview.tscn`。

## 2026-11-27 边界迷雾试样

作者确认基于本版继续修改。当前样片复用原有贴图，从普通地纹理中心取样铺设连续林地，隐藏台基和原背景画面，并在运行时裁去地砖下侧沿。原始 PNG 和 PXO 保留用于追溯。地图名暂定记录于历史文件名，界面已去掉临时名称；人物继续作为占位。

世界视口改为随窗口尺寸扩展，按完整棋盘、角色留白和顶栏可用区域计算整数像素倍率。多余的窗口边缘显示连续地面及迷雾。战术标记与鼠标拾取使用相同的世界到窗口变换。F1 显示测试工具栏，H 切换纯场景。

本轮迷雾试样从边界外 0.15 格开始，约 3 格内逐渐遮蔽，流速为 1.2 世界像素/秒。参数在世界场景脚本 Inspector 中可调，修改后重新运行预览。本轮视觉效果待作者审阅。

`fog-v1/` 保存本轮实渲染截图，下文为初版资产与构图记录。

## 1. 镜头规格与分层约定

- **等轴棋盘规格**：采用类似《陷阵之志》的 45° 旋转 **2:1 等轴正交盘面**。在 `640×360` 像素世界视口中，单格顶面菱形为 `48×24`（`TILE_HALF_W = 24`、`TILE_HALF_H = 12`），`A1`（西北顶点格）格心位于 `(320, 80)`；整张 8×8 棋盘水平跨度 `384 px`（`x = 128..512`）、垂直跨度 `192 px`（`y = 68..260`）。
- **像素世界层 + 高清 UI 层分离**（对齐《游戏美术》第 3 节）：
  - `ForestBattleWorld` 运行于 `640×360` `SubViewport`（`disable_3d = true`），通过 `CanvasTexture`（底色 + OpenGL 法线）+ `CanvasModulate` 冷月环境光 + `PointLight2D`（两侧守望火盆暖火光、三台采集器蓝青晶光、点燃草地火光）+ `battle_lit_pixel.gdshader`（4 阶明暗量化）+ `battle_pixelate.gdshader`（54 阶色彩收敛与寒林暗角聚光）渲染，并在 `1280×720` 设计窗口中按 `Nearest` 2× 整倍放大。
  - 棋盘悬停框、部署绿区、曼哈顿移动蓝区、地精珊瑚红攻击预告线、1 格推动箭头与中文字体面板置于 `1280×720` 顶层 `Control` 画布，避免文字和战术细线被低分辨率像素化模糊。
- **零遮挡原则**（对齐《美术需求清单》第 4 节）：外围针叶松、覆雪松、枯松、树桩与火盆严格布置于 8×8 菱形沙盘台基外侧，任何树冠与场边布景均不遮挡 64 个可交互棋盘格、单位轮廓或 `D1` 地精钻出预告。

## 2. 第三方 CC0 素材采用与二次加工记录

遵循参赛交付要求（`docs/requirements.md`），第三方美术仅选用**无附加限制的 CC0 1.0 Universal（公有领域）**像素素材，并统一色板与补绘配对法线：

| 素材包名称 | 原作者 | 来源链接 | 许可证 | 采用资产与本项目加工说明 |
| --- | --- | --- | --- | --- |
| **Pixel Pine Tree Assets (10 Pack)** | pistachio | <https://opengameart.org/content/pixel-pine-tree-assets-10-pack> | **CC0 1.0 Universal** | 裁切提取针叶松、覆雪寒松、苔藓枯松与大小树桩共 9 件（`tree_pine_*`, `tree_dead_*`, `prop_stump_*`）；按保色阶最近邻缩至 640×360 沙盘比例，统一冷青松林色调，新增林地接地暗影层与 OpenGL 法线贴图 |
| **Tiny Dungeon** | Kenney Vleugels | <https://kenney.nl/assets/tiny-dungeon> | **CC0 1.0 Universal** | 采用宝箱开闭（`tile_0089`, `tile_0091`）及骑士/游侠/法师基础小人（`tile_0097`, `tile_0112`, `tile_0084`）与长剑/法杖局部（`tile_0106`, `tile_0130`）；重绘等轴石座、守望小队深青披风、1px 外描边、占格环及法线贴图 |
| **Tiny Town** | Kenney Vleugels | <https://kenney.nl/assets/tiny-town> | **CC0 1.0 Universal** | 采用灌木、红伞蘑菇、原木堆、营地木栅与猎弓局部（`tile_0005`, `tile_0029`, `tile_0106`, `tile_0045`, `tile_0118`）；统一寒林暗部色调并补绘接地阴影与法线贴图 |

## 3. 原创手绘/脚本分层像素资产清单（CC BY 4.0）

| 资产名 | Pixelorama 源件 | 尺寸 | 图层结构与用途 |
| --- | --- | --- | --- |
| 北境寒林背景 | `bg_cold_forest.pxo` (+ `_normal.pxo`) | `640×360` | 北境寒雾与林地环光层 / 远景层叠松岭剪影层 / 林间苔藓与碎石肌理层 |
| 8×8 沙盘岩层台基 | `board_cliff_base.pxo` (+ `_normal.pxo`) | `416×244` | 沙盘深渊投影层 / 玄武岩层与垂苔剖面层 / 盘面石质外沿层 |
| 普通地（`.`） | `tile_plain.pxo` (+ `_normal.pxo`) | `48×32` | 等轴块体与侧沿层 / 格界明暗线层 / 冻土碎砾层（3–4 色阶） |
| 草地（`"`）与燃烧态 | `tile_grass.pxo`, `tile_grass_burning.pxo` (+ `_normal.pxo`) | `48×32` | 深松绿地表与亮绿像素草簇；点燃后切换焦黑余烬地表并叠加 `fx_tile_fire_f1..f2.pxo`（`32×28` 双帧火苗） |
| 水地（`~`） | `tile_water.pxo` (+ `_normal.pxo`) | `48×32` | 内凹冰溪水面 + 1px 亮青水岸线与横向像素波纹 |
| 石地（`#` 完好 / 裂纹） | `tile_rock_intact.pxo`, `tile_rock_cracked.pxo` (+ `_normal.pxo`) | `48×44` | 高出盘面的冷灰花岗巨石；1 次碰撞显示深色裂纹与碎屑，2 次碰撞在局内碎裂转为 `tile_plain` |
| 扩展地形预备（`:` 沙地 / `O` 地洞） | `tile_sand.pxo`, `tile_pit.pxo` (+ `_normal.pxo`) | `48×32` | 暖黄沙垄纹与内凹锯齿深黑地洞（形状与颜色严格区分于橙红钻出裂隙） |
| 水晶采集器（`C` 三态） | `collector_{working,complete,destroyed}.pxo` (+ `_normal.pxo`) | `40×46` | 整晶簇核心 + 锻铁木抓架（工作中蓝青微光 / 完成态金冠 / 被毁碎晶残骸） |
| 掠夺地精与钻出预告 | `unit_goblin_raider.pxo` (+ `_normal.pxo`), `marker_goblin_emerge.pxo` | `32×34`, `48×28` | 绿皮尖耳佝偻掠夺地精（配红圈与砍刀）；`D1` 地底橙红裂隙与上涌箭头预告 |
| 守望火盆 | `prop_watch_brazier.pxo` (+ `_normal.pxo`) | `28×36` | 锻铁三脚火盆与篝火烈焰，配合 `PointLight2D` 提供冷林暖火光影对比 |
