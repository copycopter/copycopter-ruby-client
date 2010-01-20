require File.dirname(__FILE__) + '/helper'

require File.dirname(__FILE__) + '/../lib/skywriter_tasks'
require 'fakeweb'

class SkywriterTasksTest < Test::Unit::TestCase
  def successful_response(body = "")
    response = Net::HTTPSuccess.new('1.2', '200', 'OK')
    response.stubs(:body).returns(body)
    return response
  end

  def unsuccessful_response(body = "")
    response = Net::HTTPClientError.new('1.2', '200', 'OK')
    response.stubs(:body).returns(body)
    return response
  end

  context "being quiet" do
    setup { SkywriterTasks.stubs(:puts) }

    context "in a configured project" do
      setup { SkywriterClient.configure { |config| config.api_key = "1234123412341234" } }

      context "on deploy({})" do
        setup { @output = SkywriterTasks.deploy({}) }

        before_should "complain about missing rails env" do
          SkywriterTasks.expects(:puts).with(regexp_matches(/rails environment/i))
        end

        should "return false" do
          assert !@output
        end
      end

      context "given valid options" do
        setup { @options = {:to => "staging", :from => 'development'} }

        context "on deploy(options)" do
          setup { @output = SkywriterTasks.deploy(@options) }

          before_should "post to http://skywriterapp.com/deploys" do
            URI.stubs(:parse).with('http://skywriterapp.com/deploys').returns(:uri)
            Net::HTTP.expects(:post_form).with(:uri, kind_of(Hash)).returns(successful_response)
          end

          before_should "use the project api key" do
            Net::HTTP.expects(:post_form).
              with(kind_of(URI), has_entries('api_key' => "1234123412341234")).
              returns(successful_response)
          end

          before_should "use the env params" do
            Net::HTTP.expects(:post_form).
              with(kind_of(URI), has_entries("deploy[to]" => "staging",
                                             "deploy[from]" => "development")).
              returns(successful_response)
          end

          before_should "use the :api_key param if it's passed in." do
            @options[:api_key] = "value"
            Net::HTTP.expects(:post_form).
              with(kind_of(URI), has_entries("api_key" => "value")).
              returns(successful_response)
          end

          before_should "puts the response body on success" do
            SkywriterTasks.expects(:puts).with("body")
            Net::HTTP.expects(:post_form).with(any_parameters).returns(successful_response('body'))
          end

          before_should "puts the response body on failure" do
            SkywriterTasks.expects(:puts).with("body")
            Net::HTTP.expects(:post_form).with(any_parameters).returns(unsuccessful_response('body'))
          end

          should "return false on failure", :before => lambda {
            Net::HTTP.expects(:post_form).with(any_parameters).returns(unsuccessful_response('body'))
          } do
            assert !@output
          end

          should "return true on success", :before => lambda {
            Net::HTTP.expects(:post_form).with(any_parameters).returns(successful_response('body'))
          } do
            assert @output
          end
        end
      end
    end

    context "in a configured project with custom host" do
      setup do
        SkywriterClient.configure do |config|
          config.api_key = "1234123412341234"
          config.host = "custom.host"
        end
      end

      context "on deploy(:to => 'staging', :from => 'development')" do
        setup { @output = SkywriterTasks.deploy(:to => "staging", :from => 'development') }

        before_should "post to the custom host" do
          URI.stubs(:parse).with('http://custom.host/deploys').returns(:uri)
          Net::HTTP.expects(:post_form).with(:uri, kind_of(Hash)).returns(successful_response)
        end
      end
    end

    context "when not configured" do
      setup { SkywriterClient.configure { |config| config.api_key = "" } }

      context "on deploy(:to => 'staging', :from => 'development')" do
        setup { @output = SkywriterTasks.deploy(:to => "staging", :from => 'development') }

        before_should "complain about missing api key" do
          SkywriterTasks.expects(:puts).with(regexp_matches(/api key/i))
        end

        should "return false" do
          assert !@output
        end
      end
    end
  end
end
