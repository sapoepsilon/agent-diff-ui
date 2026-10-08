import * as esbuild from 'esbuild';
await esbuild.build({entryPoints:['bridge.js'],outfile:'../Sources/WhisperaDiffUI/Resources/diffs.js',bundle:true,minify:true,format:'iife',target:'safari17',legalComments:'linked',loader:{'.css':'text'}});
