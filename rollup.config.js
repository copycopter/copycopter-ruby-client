import babel from 'rollup-plugin-babel';
import resolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';

export default {
  entry: 'src/main.js',
  dest: 'app/assets/javascripts/copyray.js',
  format: 'iife',
  plugins: [
    resolve({ jsnext: true, main: true }),
    commonjs(),
    babel({ exclude: 'node_modules/**' }),
  ],
};
