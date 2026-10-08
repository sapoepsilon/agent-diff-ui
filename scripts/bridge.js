import {FileDiff, parsePatchFiles} from '@pierre/diffs';
let instances=[];
window.showPatch = async function(patch, dark, split, wrap) {
  for(const instance of instances) instance.cleanUp();
  instances=[];
  document.documentElement.style.colorScheme=dark?'dark':'light';
  document.body.style.background=dark?'#111318':'#ffffff';
  document.body.style.color=dark?'#dce0e8':'#252832';
  const root=document.getElementById('diffs'); root.replaceChildren();
  try {
    const patches=parsePatchFiles(patch, undefined, true);
    const files=patches.flatMap(p=>p.files);
    if(!files.length) throw new Error('No complete diff was found');
    for(const file of files) {
      const host=document.createElement('div');root.append(host);
      const diff=new FileDiff({theme:{dark:'github-dark',light:'github-light'},themeType:dark?'dark':'light',
        diffStyle:split?'split':'unified',overflow:wrap?'wrap':'scroll',diffIndicators:'bars',
        lineDiffType:'word-alt',hunkSeparators:'line-info',stickyHeader:true});
      diff.render({fileDiff:file,containerWrapper:host});instances.push(diff);
    }
    window.webkit?.messageHandlers?.diffState?.postMessage({ready:true,files:files.length});
  } catch(error) {
    const pre=document.createElement('pre');pre.textContent=patch;root.append(pre);
    window.webkit?.messageHandlers?.diffState?.postMessage({ready:false,error:'Showing the original patch. This diff is incomplete or unsupported.'});
  }
};
