When "I visit and print /$path" do |path|
  puts(@response_body = Net::HTTP.get(URI.parse("http://example.com/#{path}")))
end

When "I visit /$path" do |path|
  @response_body = Net::HTTP.get(URI.parse("http://example.com/#{path}"))
end

Then 'I should see "$something"' do |something|
  assert_match something, @response_body
end

