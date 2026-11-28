森林棋盘光幕审阅样片 v12

运行：
godot --editor --path game --import --quit
godot --path game res://battle/boundary_cc0_trial/preview.tscn
验证静态截图：godot --path game --script ../tests/capture_boundary_cc0.gd
验证24帧：godot --path game --script ../tests/capture_boundary_cc0.gd -- --animate
截图输出 docs/art/battle/boundary-cc0/laser-v12/。

当前行为：
独立纯地景，无角色、水晶、岩石物件、树木或草实例。8×8棋盘格心范围0..7，真实外沿-0.5..7.5。保持3倍整数缩放（1280×720），不同窗口自适应整数倍率。
地面为草/土/残砖片区，无道路中心线；花仅在棋盘外，每株3–8原生像素，透明PNG单独节点。格内草花留给以后关卡状态。
激光幕：四边统一22原生像素高、幕面强度0.82。地面白色高光芯、亮粉色Gaussian衰减光晕与淡粉色透明幕面独立。光束按24px分区错开，每区5.5–9.5秒周期，约45%周期触发一次0.95秒紫色上射；每次位置变化，无固定竖条。没有不透明顶栏或整体频闪。无碰撞逻辑，移动范围仍应由玩法规则负责。
设置在 landscape.gd 顶部导出变量。Shader 的 preview_time=-1 为实时，非负数为可复现截图时间。

实现与参考：
laser_boundary.gdshader 是本次编写的2D canvas shader，未复制参考代码。参考“透明场体与发光轮廓分开控制”“沿轴向流动”的思路：
https://godotshaders.com/shader/simple-energy-shield/ （作者说明参考 Guilty Gear Xrd 的 Faultless Defense）
https://godotshaders.com/shader/ray-force-field/
本次没有确认《沉星之序》对应光幕的精确材质或动态，不声称复刻其实现。

资源来源：
flowers-v7 是本次逐像素制作的原创小样，参考资料为 https://stardewvalleywiki.com/Blue_Jazz 和 https://stardewvalleywiki.com/Tulip ，没有复制其图片。
source_ground_trial 中四张地面/遮罩PNG是《沉星之序》Build 26825502纹理的解码、缩小和调色试验，见该目录PROVENANCE.json；不属于CC0，不声明原创或已获游戏发行授权。文件夹 boundary_cc0_trial 为此前试验遗留名称，不代表整个场景CC0。
仅本轮运行所需代码、派生缩略纹理、小花和截图纳入提交；没有原游戏包、GLB下载、历史大批截图、Ink checkout或Godot缓存。

验证：Windows / Godot 4.7.2 Compatibility / NVIDIA RTX 3050 Ti。24帧导出退出0，检查两侧层结构、四边参数一致、草层为空；帧0/12像素存在差异。视觉为待审阅小样，未标最终定稿。
