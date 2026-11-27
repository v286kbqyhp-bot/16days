# 守望者纹章：加宽与明度调整稿

2026-11-27，依据作者对 warden-v1 的修改意见：盾再宽一点、背景亮一点、盾再深一点。盾牌以中心 x=24 调整绘制坐标，横向放大约 18%，轮廓及亮面仍按一像素宽绘制；高度不变。背景从 #07080b 提亮到 #1b1d24，盾面整体压深，保留少量冷紫灰断面和左上亮面。

`crest_warden_color.pxo` 为 48×48 七层可编辑原件；`crest_warden_color.png` 为透明合成；`crest_warden_review.png` 为最近邻放大预览。全部图层检查图为 `layer-review.png`，技术核对记录为 `validation.json`。

AI 辅助制作：`author_warden.gd` 在 Pixelorama 1.2.4 源码环境运行，复用 `author_common.gd` 读取作者原圆盘、`author_pins.gd` 绘制并创建原生图层。执行时复制到临时源码目录的 author_sky.gd，使用已有 --sky-author 入口。正式游戏资源未替换，未制作法线，未提交或发布；本枚造型仍待作者人工审核。
