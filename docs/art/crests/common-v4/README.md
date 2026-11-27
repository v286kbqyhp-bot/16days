# 普通纹章：石英形与静态明暗修订

2026-11-27，按作者要求参考 Minecraft 石英形状，并修正圆盘上沿高光、下沿阴影。本版仅为普通纹章审阅草稿，保留全部先前版本，未接入游戏。

形状参考：[Mojang 官方 Bedrock samples 石英物品贴图](https://github.com/Mojang/bedrock-samples/blob/main/resource_pack/textures/items/quartz.png)。已下载到临时目录并放大目视：一根较长主晶体与两侧较短晶体组成不对称簇状。此处重新绘制轮廓，没有将 Minecraft 的原图作为工程资产使用。Minecraft 参考图版权仍归其权利人。

明暗参考：此前 REA 从本机 Balatro 游戏包提取的 `1x/BlindChips.png`，放大第一帧第 4、5、9 行核对。上沿浅色、下沿深色、中央基本平色的边缘关系已纳入；静态明暗与动画扫光是不同事项。本版未制作动画和法线。

`crest_common.pxo` 包含「灰青平色底盘」「上沿高光_下沿阴影」「石英晶簇」三层；48 × 48 透明 PNG 与源件逐像素合成一致。`普通纹章_石英形对比.png` 为上一版与当前版的放大及原尺寸对比，已目视检查。

AI 辅助绘制脚本 `author_common.gd` 在 Pixelorama 1.2.4 原生 Project / PixelLayer / PixelCel 环境执行，依赖上一批 `pins-v2/author_pins.gd` 的辅助方法；不是鼠标逐点手绘。Pillow 只用于对比图排版。此次未额外打开 GUI。
