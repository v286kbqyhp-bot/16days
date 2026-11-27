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
