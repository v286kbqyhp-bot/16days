shader_type canvas_item;
render_mode unshaded, blend_mix;
uniform vec4 laser_color : source_color = vec4(1.0,0.24,0.62,1.0);
uniform float strength = 0.85;
uniform bool ground_glow = false;
uniform float edge_length = 214.66;
uniform float wall_height = 22.0;
// 负值为实时播放；非负值用于可重复的截图和动画验收。
uniform float preview_time = -1.0;
float hash(float p){return fract(sin(p*127.1+17.7)*43758.5453);}
void fragment(){
 float t=preview_time < 0. ? TIME : preview_time;
 float s=floor(UV.x*edge_length);
 float alpha=0.;
 vec3 color=laser_color.rgb;
 if(ground_glow){
  float d=abs(UV.y-.5)*2.;
  float halo=pow(max(0.,1.-d),2.)*.13;
  float core=(1.-smoothstep(.03,.16,d))*.72;
  float pulse=.92+.08*sin(UV.x*25.-t*1.2);
  alpha=(halo+core)*strength*pulse;
  color=mix(laser_color.rgb,vec3(1.,.73,.85),core*.35);
 }else{
  float h=1.-clamp(UV.y,0.,1.);
  float row=floor(h*wall_height);
  float column=floor(s/3.);
  float seed=hash(column);
  // 各束长度不同，没有一根刚性的顶部栏杆。
  float cap=.57+seed*.34+.035*sin(t*.8+seed*12.);
  float dissolve=1.-smoothstep(cap-.24,cap,h);
  float root=pow(1.-h,2.);
  float body=(.075+.12*root)*dissolve;
  float filament=step(.66,hash(s))*(.12+.20*seed);
  float rise=fract(row/13.-t*(.16+seed*.07)+seed);
  float moving=pow(max(0.,1.-abs(rise-.5)*9.),3.);
  float threads=filament*(.42+.58*moving)*dissolve;
  float glints=step(.88,hash(column+41.))*moving*.25*dissolve;
  float foot=(1.-smoothstep(0.,.07,h))*.33;
  alpha=(body+threads+glints+foot)*strength;
  color=mix(vec3(.77,.22,.64),laser_color.rgb,root);
  color=mix(color,vec3(1.,.72,.90),clamp(moving*filament*2.+foot*.25,0.,.6));
 }
 COLOR=vec4(color,clamp(alpha,0.,.83));
}
