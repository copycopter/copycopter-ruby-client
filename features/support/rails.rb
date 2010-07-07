PROJECT_ROOT     = File.expand_path(File.join(File.dirname(__FILE__), '..', '..')).freeze
TEMP_ROOT        = File.join(PROJECT_ROOT, 'tmp').freeze
APP_NAME         = 'testapp'.freeze
CUC_RAILS_ROOT   = File.join(TEMP_ROOT, APP_NAME).freeze

Before do
  FileUtils.rm_rf(TEMP_ROOT)
  FileUtils.mkdir_p(TEMP_ROOT)
end

