shader_type canvas_item;
render_mode unshaded;
uniform sampler2D dirt_tex : source_color, filter_nearest, repeat_enable;
uniform sampler2D grass_tex : source_color, filter_nearest, repeat_enable;
uniform sampler2D stone_tex : source_color, filter_nearest, repeat_enable;
uniform sampler2D blend_breakup : filter_nearest, repeat_enable;
uniform sampler2D stone_regions : filter_nearest, repeat_disable;
varying vec2 world_pos;
void vertex(){world_pos=(MODEL_MATRIX*vec4(VERTEX,0.,1.)).xy;}
float patch(vec2 p,vec2 center,vec2 size){return length((p-center)/size);}
void fragment(){
 vec2 delta=floor(world_pos)+.5-vec2(320.,80.);
 vec2 cell=vec2(delta.x/24.+delta.y/12.,-delta.x/24.+delta.y/12.)*.5;
 vec2 uv=(cell+.5)/4.;
 float breakup=texture(blend_breakup,uv*.69+vec2(.17,.31)).r;
 float fine=texture(blend_breakup,uv*1.91+vec2(.47,.09)).r;
 vec2 warped=cell+vec2(breakup-.5,fine-.5)*.72;
 // 面状泥土斑块，独立分布，没有道路中心线或贯穿条带。
 float soil_shape=min(patch(warped,vec2(1.1,1.4),vec2(2.6,2.0)),
                     patch(warped,vec2(5.8,5.3),vec2(2.5,1.9)));
 soil_shape=min(soil_shape,patch(warped,vec2(1.7,6.4),vec2(1.45,1.2)));
 soil_shape=min(soil_shape,patch(warped,vec2(6.9,.1),vec2(1.65,1.45)));
 soil_shape=min(soil_shape,patch(warped,vec2(2.7,.4),vec2(1.4,1.25)));
 soil_shape=min(soil_shape,patch(warped,vec2(4.5,6.7),vec2(1.55,1.25)));
 float soil_weight=1.-smoothstep(.88,1.12,soil_shape+(fine-.5)*.36);
 vec3 dirt=texture(dirt_tex,uv).rgb;
 vec3 grass=texture(grass_tex,uv).rgb;
 // 草地内部有相连的深浅色块，不增加高草丛或物件。
 float tone=texture(blend_breakup,uv*.31+vec2(.53,.7)).r;
 grass*=mix(vec3(.91,.95,.87),vec3(1.06,1.035,1.0),tone);
 vec3 terrain=mix(grass,dirt,soil_weight);
 // 稀疏铺砖片区由布局图控制；接缝对齐逻辑格，残边被土草覆盖。
 float slab=texture(stone_regions,(floor(cell+.5)+vec2(2.5))/12.).r;
 vec2 local=fract(cell+.5);
 float rim=min(min(local.x,1.-local.x),min(local.y,1.-local.y));
 float erosion=.012+(1.-slab)*.15+max(0.,fine-.40)*.17;
 float stone_weight=step(.1,slab)*smoothstep(erosion,erosion+.035,rim);
 float corner_cut=min(local.x+local.y,2.-local.x-local.y);
 stone_weight*=smoothstep(.10+breakup*.13,.16+breakup*.13,corner_cut);
 stone_weight*=1.-smoothstep(.79,.94,breakup+fine*.12);
 vec3 stone=mix(vec3(.59,.575,.49),texture(stone_tex,uv).rgb,.28);
 COLOR=vec4(mix(terrain,stone,stone_weight),1.);
}
