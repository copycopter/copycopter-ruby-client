module.exports = {
  plugins: ['@sonicgarden'],
  extends: [
    'plugin:@sonicgarden/browser',
    'plugin:@sonicgarden/recommended',
    'plugin:@sonicgarden/typescript',
    'plugin:@sonicgarden/prettier',
  ],
  settings: {
    'import/internal-regex': '^@/',
  },
}
