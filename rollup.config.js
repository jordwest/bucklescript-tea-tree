import resolve from 'rollup-plugin-node-resolve';
import uglify from 'rollup-plugin-uglify';

export default {
  entry: 'lib/es6/src/main.js',
  moduleName: 'bucklescript-tea-tree',
  format: 'iife',
  plugins: [ resolve(), uglify() ],
  dest: 'dist/main.bundle.js'
};
