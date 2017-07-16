import babel from 'rollup-plugin-babel';

export default {
  entry: 'src/main.js',
  dest: 'app/assets/javascripts/copyray.js',
  format: 'iife',
  plugins: [babel()],
};
