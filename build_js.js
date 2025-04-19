const esbuild = require('esbuild');

esbuild.build({
  entryPoints: ['assets/js/coins_bundle.js'],
  bundle: true,
  minify: true,
  outfile: 'assets/js/bundle.min.js',
  format: 'iife',
  target: ['es2020'],
}).catch(() => process.exit(1));
