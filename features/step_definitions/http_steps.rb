When "I visit $path" do |path|
  @response_body = open("http://example.com#{path}").read
end

Then 'I should see "$something"' do |something|
  assert_match something, @response_body
end

