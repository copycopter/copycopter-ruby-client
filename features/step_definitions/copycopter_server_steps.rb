require File.join(PROJECT_ROOT, "spec", "support", "fake_copycopter_app")

Given /^I have a copycopter project with an api key of "([^"]*)"$/ do |api_key|
  FakeCopycopterApp.add_project api_key
end

Given /^the "([^"]*)" project has the following blurbs:$/ do |api_key, table|
  project = FakeCopycopterApp.project(api_key)
  table.hashes.each do |blurb_hash|
    key = blurb_hash['key']
    data = { 'draft'     => { key => blurb_hash['draft content'] },
             'published' => { key => blurb_hash['published content'] } }
    project.update(data)
  end
end

When /^the the following blurbs are updated in the "([^"]*)" project:$/ do |api_key, table|
  Given %{the "#{api_key}" project has the following blurbs:}, table
end

Then /^the "([^"]*)" project should have the following blurbs:$/ do |api_key, table|
  project = FakeCopycopterApp.project(api_key)
  table.hashes.each do |blurb_hash|
    key = blurb_hash['key']

    if blurb_hash['draft content']
      project.draft[key].should == blurb_hash['draft content']
    end

    if blurb_hash['published content']
      project.published[key].should == blurb_hash['published content']
    end
  end
end

Then /^the "([^"]*)" project should not have the "([^"]*)" blurb$/ do |api_key, blurb_key|
  project = FakeCopycopterApp.project(api_key)
  project.draft[blurb_key].should be_nil
end

When /^I wait for changes to be synchronized$/ do
  sleep(3)
end

After do
  FakeCopycopterApp.reset
end

