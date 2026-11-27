# 普通纹章与可复用圆盘模板

48 × 48 像素，透明背景，使用最近邻过滤。彩图来自作者在 Pixelorama 最终手改的原件，包括底部补回的八个像素。

| 文件 | 用途 |
| --- | --- |
| `crest_common_color.png` | 保留手绘明暗的最终彩图 |
| `crest_common_normal.png` | 独立 OpenGL 法线：圆盘弧面、边缘倒角、石英切面 |
| `crest_common_highlight_mask.png` | 扫光反射强弱；这是自定义 shader 的强度遮罩，不是 Godot 的高光锐度图 |
| `template_disc_color.png` | 作者确认的圆盘底色、高光与阴影，供后续纹章复用 |
| `template_disc_normal.png` | 与模板逐像素对齐的公共圆盘法线 |
| `template_disc_highlight_mask.png` | 公共圆盘的反光强弱 |
| `crest_common_glint.tres` | 斜向双光带的程序化扫光材质 |
| `crest_common_canvas_texture.tres` | 需要 Godot 原生 Light2D 时使用的彩图＋法线绑定 |

## 程序化扫光

Sprite2D 或 TextureRect 的纹理设为 `crest_common_color.png`，材质使用 `crest_common_glint.tres`。shader 自己计算附加高光，不需要 Light2D，也不重新计算原图漫反射。`highlight_strength=0` 时与原图一致。材质不改变 alpha。

`sweep_phase=-1` 自动循环，设为 0..1 可由动画或脚本控制进度；`period_seconds` 是循环秒数，默认 3 秒；`band_half_width` 是相对图宽的光带半宽，默认 0.065；`highlight_strength` 是高光混合强度，默认 0.85。三个亮度档位、主光带及较细的伴随光带模拟 Balatro 盲注的扫光观感；法线轻微改变光带在切面上的位置和反射强弱。

此 shader 是本项目实现。已研究的 Balatro 版本中盲注扫光来自 PNG 序列帧，因此这里不宣称是其原始 shader 的移植。暂未替换商店旧纹章或修改正式主场景。

## 法线约定

X 正向右、Y 正向上、Z 正向观察者，RGB 编码 `N * 0.5 + 0.5`。法线和遮罩是数据贴图，不使用 sRGB 转换；shader 采用最近邻取样。源 PNG 无有损压缩、无 mipmap。不要直接根据彩图亮度生成高度，否则手绘颜色会错误地变成凸凹。

两种受光方案分开使用：自定义扫光保留手绘明暗；`CanvasTexture` 是可选的原生灯光入口，接入 Light2D 后会影响整体受光，尚未接入正式界面。

可编辑原件、制作记录与审阅图见 `docs/art/crests/source/`。测试及交互预览入口见仓库 `AGENTS.md`。
# 悬停展示组件

`crest_hover_view.gd` 是可复用的 Control，设置 `size` 决定纹章尺寸，内部使用独立材质和阴影。当前按作者试玩反馈：上层进入时向固定右上方浮起并放大回弹；随后鼠标只控制绕固定中心的透视，指针所在边压下、对侧翘起；阴影只同步缩放，中心和朝向固定。移出落回原位。拿起热区仍是原位置的小圆，半径为宽度的 38%。拿起后改为完整彩图的实际显示轮廓：对当前透视做逆变换，再按彩图 alpha 判定，包含放大、浮起、旋转和所有边缘像素；透明四角不计入。屏幕半像素采样范围用于处理 GPU/CPU 边界舍入。此前 0.05 单位的圆形缓冲不再用于当前放下判定，这是作者明确要求的轮廓适配，不能说成原作的热区实现。

缩放弹动沿 REA 提取的 `Card:hover → Card:juice_up → Moveable` 调用链：实际缩放振幅 0.02、旋转振幅 ±0.012 弧度、0.4 秒衰减，角频率 50.8 / 40.8，缩放速度递推使用 `exp(-60*dt)`。本项目固定以 60 Hz 执行。来源和参数见 `docs/art/crests/source/rea-card-hover-findings.json`。

局部透视方向项倍率 12、默认进入时右上偏移各 4%，是本项目适配参数，不是原版实测值。原式平方距离中的方向项单独用于局部投影，中心不随指针平移。之前错误添加的 12% 跟手位移已删除。指针从 Godot 鼠标事件的 viewport 坐标转换，避免全局轮询位置与输入事件不一致。底图、法线与扫光内容不变。

试玩：`godot --path game res://../tests/crest_glint_live.tscn`。指向右侧纹章内部的不同方向；空格暂停，R 重播。仅接入独立预览，没有替换商店。
