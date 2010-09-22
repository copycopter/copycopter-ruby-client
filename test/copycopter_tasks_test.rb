require File.dirname(__FILE__) + '/helper'

require File.dirname(__FILE__) + '/../lib/copycopter_tasks'
require 'fakeweb'

class CopycopterTasksTest < Test::Unit::TestCase
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
    setup { CopycopterTasks.stubs(:puts) }

    context "in a configured project" do
      setup { CopycopterClient.configure { |config| config.api_key = "1234123412341234" } }

      context "on deploy({})" do
        setup { @output = CopycopterTasks.deploy({}) }

        before_should "complain about missing rails env" do
          CopycopterTasks.expects(:puts).with(regexp_matches(/rails environment/i))
        end

        should "return false" do
          assert !@output
        end
      end

      context "given valid options" do
        setup do
          @options = {:to => "staging", :from => 'development'}
          @http = mock()
          Net::HTTP.expects(:new).with(any_parameters).returns(@http)
	end

        context "on deploy(options)" do
          setup { @output = CopycopterTasks.deploy(@options) }

          before_should "post to http://copycopter.com/deploys" do
            @http.expects(:post).with('/api/v1/deploys', kind_of(String), kind_of(Hash)).returns([successful_response, nil])
          end

          before_should "use the project api key" do
            @http.expects(:post).with('/api/v1/deploys', kind_of(String), has_entries('X-API-KEY' => '1234123412341234')).returns([successful_response, nil])
          end

          before_should "use the env params" do
            @http.expects(:post).with('/api/v1/deploys', 'deploy[to]=staging&deploy[from]=development', kind_of(Hash)).returns([successful_response, nil])
          end

          before_should "use the :api_key param if it's passed in." do
            @options[:api_key] = "value"
            @http.expects(:post).with('/api/v1/deploys', kind_of(String), has_entries('X-API-KEY' => 'value')).returns([successful_response, nil])
          end

          before_should "puts the response body on success" do
            CopycopterTasks.expects(:puts).with("body")
            @http.expects(:post).with(any_parameters).returns([successful_response('body'), nil])
          end

          before_should "puts the response body on failure" do
            CopycopterTasks.expects(:puts).with("body")
            @http.expects(:post).with(any_parameters).returns([unsuccessful_response('body'), nil])
          end

          should "return false on failure", :before => lambda {
            @http.expects(:post).with(any_parameters).returns([unsuccessful_response('body'), nil])
          } do
            assert !@output
          end

          should "return true on success", :before => lambda {
            @http.expects(:post).with(any_parameters).returns([successful_response('body'), nil])
          } do
            assert @output
          end
        end
      end
    end

    context "in a configured project with custom host" do
      setup do
        CopycopterClient.configure do |config|
          config.api_key = "1234123412341234"
          config.host = "custom.host"
        end
        @http = mock()
      end

      context "on deploy(:to => 'staging', :from => 'development')" do
        setup { @output = CopycopterTasks.deploy(:to => "staging", :from => 'development') }

        before_should "post to the custom host" do
          Net::HTTP.expects(:new).with('custom.host').returns(@http)
	  @http.expects(:post).with('/api/v1/deploys', kind_of(String), kind_of(Hash)).returns([successful_response, nil])
        end
      end
    end

    context "when not configured" do
      setup { CopycopterClient.configure { |config| config.api_key = "" } }

      context "on deploy(:to => 'staging', :from => 'development')" do
        setup { @output = CopycopterTasks.deploy(:to => "staging", :from => 'development') }

        before_should "complain about missing api key" do
          CopycopterTasks.expects(:puts).with(regexp_matches(/api key/i))
        end

        should "return false" do
          assert !@output
        end
      end
    end
  end
end
