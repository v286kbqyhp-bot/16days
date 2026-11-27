# 天空纹章 · 长袍圣天使试稿

2026-11-27，作者否定 sky-v3 天使造型，要求参考中世纪宗教绘画的圣天使，并同意试画此前展示的安杰利科方向：金色圆光、象牙白长袍、修长身体和展开的浅色羽翼。作者看过本稿后评价“还凑合吧下一个纹章”，因此将 sky-v4 作为暂留版本，继续下一枚守望者纹章；该评价不代表提交、正式接入或发布授权。

参考：[Fra Angelico, Christ Glorified in the Court of Heaven，约 1423–1424，National Gallery](https://www.nationalgallery.org.uk/paintings/fra-angelico-christ-glorified-in-the-court-of-heaven)。原作媒介为木板蛋彩，并非油画。本稿借鉴两侧天使的圆光、长袍和人物比例，另按作者要求绘制展翼飞翔姿态；没有把博物馆照片裁剪或缩放为游戏贴图。[馆方图片使用说明](https://www.nationalgallery.org.uk/terms-of-use)已在参考展示阶段读取。

`crest_sky_color.pxo` 是 48×48、10 层 Pixelorama 原件；`crest_sky_color.png` 为透明合成；`crest_sky_review.png` 为最近邻放大预览；`layer-review.png` 为全部图层检查图。天空、圆盘明暗边、背后白云和下方白云四层与获认可 sky-v2 逐像素相同。

制作方式：AI 辅助编写 `author_sky.gd`，在 Pixelorama 1.2.4 源码环境运行原生绘制、图层创建与 PXO 保存接口；复用 sky-v3 的 `read_layers`（运行时复制为 `res://sky_previous.gd`）以及 pins-v2 的绘制辅助代码。不是逐点鼠标手绘。原件已在桌面 Pixelorama 打开并核对。

验证见 `validation.json`：10 层均有内容，PXO 合成与 PNG 相同，背景四层和圆盘透明轮廓保持，人物像素没有越过圆盘或覆盖边缘。上述只确认文件与分层完整；不代替作者视觉审核。本轮未制作法线、未替换正式游戏资源、未提交或发布。

2026-11-27 底边修正：作者指出底端颜色不一致。模板中 x20..27 / y46 的八个补齐像素未纳入阴影层；现以 Pixelorama 原生接口归入本枚下缘暗色，并清除该处叠在上方的装饰色。合成图仅八个像素变色，透明轮廓和其余像素不变。作者脚本同步修复；原有对照检查属于修正前记录，最新证据见 validation.json 的 bottom_edge_correction_20261127。
