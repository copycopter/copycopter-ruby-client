import babel from 'rollup-plugin-babel';
import resolve from 'rollup-plugin-node-resolve';
import commonjs from 'rollup-plugin-commonjs';

export default {
  input: 'src/main.js',
  output: {
    file: 'app/assets/javascripts/copyray.js',
    format: 'iife',
  },
  plugins: [
    resolve({ jsnext: true, main: true }),
    commonjs(),
    babel({ exclude: 'node_modules/**' }),
  ],
};
