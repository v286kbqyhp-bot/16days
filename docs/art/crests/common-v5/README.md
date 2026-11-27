# 普通纹章：下界石英轮廓纠正

2026-11-27。作者指出上一版晶体像叶片、与 Minecraft 下界石英不符，并询问底部阴影像素是否不足。本次只修订普通纹章，保存独立版本供审阅。

参考为 Mojang 官方 Bedrock samples 的 `resource_pack/textures/items/quartz.png`：https://github.com/Mojang/bedrock-samples/blob/main/resource_pack/textures/items/quartz.png 。另核对 Java 1.21.4 物品贴图，观察到相同的簇状形态。根据参考重新绘制长主晶体、错落的短晶体、平切端部和重叠关系；对比图左侧展示参考原图，版权归原权利人，未将其用作运行时资产。

原版普通纹章底部中央暗边为一行。本次在 y=46、x=18..29 添加 12 个暗色像素，中央增加为两行。逐像素核对边缘明暗层仅这 12 个像素变化，其余圆盘及上沿高光保留。此为本作 48 × 48 草稿的调整，不声称 Balatro 的 34 × 34 原图同样缺少像素。

输出：`crest_common.pxo`、透明 PNG 与 `普通纹章_石英轮廓修正.png`。Pixelorama 原生三层合成与 PNG 逐像素一致，对比图已目视检查。AI 辅助源脚本在 Pixelorama 1.2.4 中执行，复用 `pins-v2/author_pins.gd` 的绘制与保存方法；Pillow 用于验证和对比排版。仍为待作者审阅稿，未接入游戏，本次未额外打开 GUI。
