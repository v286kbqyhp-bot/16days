shader_type canvas_item;
render_mode unshaded, blend_mix;
uniform vec4 laser_color : source_color = vec4(1.0,0.30,0.70,1.0);
uniform float strength = 0.82;
uniform bool ground_glow = false;
uniform float edge_length = 214.66;
uniform float wall_height = 22.0;
uniform float edge_seed = 0.0;
uniform float preview_time = -1.0;
float hash(float p){return fract(sin(p*127.1+17.7)*43758.5453);}
float noise(vec2 p){
 vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);
 float n=i.x+i.y*57.;
 return mix(mix(hash(n),hash(n+1.),f.x),mix(hash(n+57.),hash(n+58.),f.x),f.y);
}
void fragment(){
 float t=preview_time < 0. ? TIME : preview_time;
 float s=UV.x*edge_length;
 float alpha=0.;
 vec3 color=laser_color.rgb;
 if(ground_glow){
  // 8px宽光带：白芯 + 亮粉Gaussian衰减光晕，不依赖后处理。
  float d=abs(UV.y-.5)*8.;
  float core=exp(-pow(d/.72,2.));
  float halo=exp(-pow(d/2.1,2.));
  color=mix(vec3(1.,.22,.66),vec3(1.,.98,1.),smoothstep(.12,.75,core));
  alpha=clamp(core*.99+halo*.40,0.,.98);
 }else{
  float h=1.-clamp(UV.y,0.,1.);
  float cloud=noise(vec2(s/38.+edge_seed*4.,h*2.-t*.055));
  float cap=.84+noise(vec2(s/57.,t*.035+edge_seed))*.12;
  float dissolve=1.-smoothstep(cap-.24,cap,h);
  float body=(.14+.10*cloud)*dissolve;
  // 每24px一候选区，独立4.5–8秒周期；约48%的周期发射。
  float slot=floor(s/24.);
  float base=slot+edge_seed*31.;
  float period=4.5+hash(base+4.)*3.5;
  float clock=t+hash(base+9.)*period;
  float cycle=floor(clock/period);
  float age=mod(clock,period);
  float seed=hash(base+cycle*43.);
  float center=(slot+.18+hash(base+cycle*17.+7.)*.64)*24.;
  float event_on=step(.52,seed)*(1.-step(.82,age));
  float progress=age/.68;
  float crossbeam=exp(-pow((s-center)/.85,2.));
  float beamglow=exp(-pow((s-center)/2.0,2.));
  float tail=smoothstep(progress-.5,progress-.12,h)*(1.-smoothstep(progress,progress+.07,h));
  float head=exp(-pow((h-progress)/.065,2.));
  float beam=(crossbeam*(tail*.65+head*.7)+beamglow*tail*.18)*event_on;
  beam*=1.-smoothstep(.80,1.,h);
  float foot=exp(-h*wall_height/1.3)*.19;
  alpha=clamp((body+foot+beam)*strength,0.,.78);
  color=mix(vec3(.94,.34,.73),vec3(.72,.32,1.),clamp(beam*1.6,0.,1.));
  color=mix(color,vec3(.96,.82,1.),clamp(head*crossbeam*event_on*.65,0.,.6));
 }
 COLOR=vec4(color,alpha);
}
