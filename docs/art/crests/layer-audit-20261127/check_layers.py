from pathlib import Path
import json, zipfile, re, hashlib
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[1]
ITEMS=[('clear-eye-v1','clear_eye'),('sky-v4','sky'),('warden-v4','warden'),('up-v3','up'),('vanguard-v1','vanguard')]
rows=[]
for folder,key in ITEMS:
 d=ROOT/folder;p=d/('crest_'+key+'_color.pxo')
 with zipfile.ZipFile(p) as z:
  data=json.loads(z.read('data.json')); layers=[];names=[l['name'] for l in data['layers']]
  for i,c in enumerate(data['frames'][0]['cels']):
   sz=tuple(map(int,re.findall(r'-?\d+',c['image_size'])[-2:]));off=tuple(map(int,re.findall(r'-?\d+',c['offset'])[-2:]));im=Image.new('RGBA',(48,48));im.paste(Image.frombytes('RGBA',sz,z.read('image_data/frames/1/layer_'+str(i+1))),off);layers.append(im)
 rim=next(i for i,n in enumerate(names) if '阴影' in n or '明暗边' in n)
 flat=Image.new('RGBA',(48,48));base=layers[0]
 for i,im in enumerate(layers):
  assert im.getbbox(),(folder,names[i],'empty')
  assert all(not im.getpixel((x,y))[3] or base.getpixel((x,y))[3] for y in range(48) for x in range(48)),(folder,names[i],'outside')
  if i not in [0,rim]:
   assert all(not(im.getpixel((x,y))[3] and layers[rim].getpixel((x,y))[3]) for y in range(48) for x in range(48)),(folder,names[i],'rim overlap')
  flat=Image.alpha_composite(flat,im)
 assert flat.tobytes()==Image.open(d/('crest_'+key+'_color.png')).convert('RGBA').tobytes()
 assert all(layers[rim].getpixel((x,46))==layers[rim].getpixel((23,45)) for x in range(20,28))
 sheet=Image.new('RGB',(624,((len(layers)+2)//3)*228),'#242c32');dr=ImageDraw.Draw(sheet)
 for i,im in enumerate(layers):
  ox=i%3*208+8;oy=i//3*228+24
  for y in range(0,192,16):
   for x in range(0,192,16):dr.rectangle((ox+x,oy+y,ox+x+15,oy+y+15),fill=('#424b55' if (x//16+y//16)%2 else '#343c46'))
  big=im.resize((192,192),Image.Resampling.NEAREST);sheet.paste(big,(ox,oy),big);dr.text((ox,oy-18),'L'+str(i+1),fill='white')
 sheet.save(d/'layer-review.png')
 record={'crest':key,'layers':names,'rim_layer':names[rim],'rim_index':rim,'all_nonempty':True,'outside_pixels':0,'decoration_rim_overlap':0,'bottom_owned_by_rim':True,'pxo_png_match':True,'pxo_sha256':hashlib.sha256(p.read_bytes()).hexdigest()};rows.append(record)
 vpath=d/'validation.json';v=json.loads(vpath.read_text()) if vpath.exists() else {'visual_status':'awaiting author review'}
 v['layer_ownership_audit']=record;v['pxo_sha256']=record['pxo_sha256']
 if 'bottom_edge_correction_20261127' in v: v['bottom_edge_correction_20261127']['pxo_sha256']=record['pxo_sha256']
 vpath.write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n')
(ROOT/'layer-audit-20261127/results.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2)+'\n')
print('PASS',len(rows),'crests,',sum(len(r['layers']) for r in rows),'layers; rim ownership, bounds and PNG verified')
