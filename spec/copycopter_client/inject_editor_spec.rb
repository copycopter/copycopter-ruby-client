require 'spec_helper'

describe CopycopterClient::InjectEditor do
  let(:available_keys) { %w(one two) }
  let(:base_backend) { I18n::Backend::Simple.new }

  let(:app) do
    lambda do |env|
      I18n.t('one')
      I18n.t('two')

      [
        env['Response-Code'] || 200,
        { 'Content-Type' => env['Content-Type'] },
        [env['Response-Body']]
      ]
    end
  end

  let(:editor_code) do
    %{<script type="text/javascript" href="http://copycopter.test/javascripts/editor.js">} +
      %{</script>} +
      %{<script type="text/javascript">\n} +
      %{CopycopterEditor.editKeys(["one","two"])\n} +
      %{</script>}
  end

  before do
    available_keys.each do |key|
      base_backend.store_translations('en', key => 'value')
    end
    I18n.backend = base_backend
  end

  def call(env)
    config = { :host => "copycopter.test" }
    CopycopterClient::InjectEditor.new(app, config).call(env)
  end

  it "injects a translated key into html with a body tag" do
    response = call('Content-Type'  => 'text/html; charset=utf-8',
                    'Response-Code' => 200,
                    'Response-Body' => "<body>hello</body>")
    expected_body = "<body>hello#{editor_code}</body>"
    response.last.should == [expected_body]
    response[1]['Content-Length'].should == expected_body.size.to_s
  end

  it "doesn't inject a translated key into html without a body tag" do
    response = call('Content-Type'  => 'text/html; charset=utf-8',
                    'Response-Code' => 200,
                    'Response-Body' => "<div>hello</div>")
    response.last.should == ["<div>hello</div>"]
  end

  it "doesn't inject a translated key into non-html" do
    response = call('Content-Type'  => 'text/plain',
                    'Response-Code' => 200,
                    'Response-Body' => "hello")
    response.last.should == ["hello"]
  end

  it "doesn't inject a translated key into html with a non-200 response" do
    response = call('Content-Type'  => 'text/html; charset=utf-8',
                    'Response-Code' => 500,
                    'Response-Body' => "<body>hello</body>")
    response.last.should == ["<body>hello</body>"]
  end
end

