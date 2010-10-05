require 'spec_helper'
require 'copycopter_tasks'

describe CopycopterTasks do
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

  describe "being quiet" do
    before { CopycopterTasks.stubs(:puts) }

    describe "in a configured project" do
      before { CopycopterClient.configure(false) { |config| config.api_key = "1234123412341234" } }

      describe "on deploy({})" do
        before do
          CopycopterTasks.stubs(:puts)
          @output = CopycopterTasks.deploy({})
        end

        it "complains about missing rails env" do
          CopycopterTasks.should have_received(:puts).
            with(regexp_matches(/rails environment/i))
        end

        it "should return false" do
          (@output).should_not be
        end
      end

      describe "given valid options" do
        before do
          @options = {:to => "staging", :from => 'development'}
          @http = mock()
          Net::HTTP.expects(:new).with(any_parameters).returns(@http)
	end

        describe "on deploy(options)" do
          def deploy
            @output = CopycopterTasks.deploy(@options)
          end

          it "posts to http://copycopter.com/deploys" do
            @http.expects(:post).with('/api/v1/deploys', kind_of(String), kind_of(Hash)).returns([successful_response, nil])
            deploy
          end

          it "uses the project api key" do
            @http.expects(:post).with('/api/v1/deploys', kind_of(String), has_entries('X-API-KEY' => '1234123412341234')).returns([successful_response, nil])
            deploy
          end

          it "uses the env params" do
            @http.expects(:post).with('/api/v1/deploys', 'deploy[to]=staging&deploy[from]=development', kind_of(Hash)).returns([successful_response, nil])
            deploy
          end

          it "uses the :api_key param if it's passed in." do
            @options[:api_key] = "value"
            @http.expects(:post).with('/api/v1/deploys', kind_of(String), has_entries('X-API-KEY' => 'value')).returns([successful_response, nil])
            deploy
          end

          it "puts the response body on success" do
            CopycopterTasks.expects(:puts).with("body")
            @http.expects(:post).with(any_parameters).returns([successful_response('body'), nil])
            deploy
          end

          it "puts the response body on failure" do
            CopycopterTasks.expects(:puts).with("body")
            @http.expects(:post).with(any_parameters).returns([unsuccessful_response('body'), nil])
            deploy
          end

          it "should return false on failure" do
            @http.expects(:post).with(any_parameters).returns([unsuccessful_response('body'), nil])
            deploy
            @output.should_not be
          end

          it "should return true on success" do
            @http.expects(:post).with(any_parameters).returns([successful_response('body'), nil])
            deploy
            @output.should be
          end
        end
      end
    end

    describe "in a configured project with custom host" do
      before do
        CopycopterClient.configure(false) do |config|
          config.api_key = "1234123412341234"
          config.host = "custom.host"
        end
        @http = mock()
      end

      describe "on deploy(:to => 'staging', :from => 'development')" do
        before do
          Net::HTTP.stubs(:new => @http)
          @http.stubs(:post).returns([successful_response, nil])
          @output = CopycopterTasks.deploy(:to => "staging", :from => 'development')
        end

        it "posts to the custom host" do
          Net::HTTP.should have_received(:new).
            with('custom.host')
          @http.should have_received(:post).
            with('/api/v1/deploys',
                 kind_of(String),
                 kind_of(Hash))
        end
      end
    end

    describe "when not configured" do
      before { CopycopterClient.configure(false) { |config| config.api_key = "" } }

      describe "on deploy(:to => 'staging', :from => 'development')" do
        before do
          CopycopterTasks.stubs(:puts)
          @output = CopycopterTasks.deploy(:to => "staging", :from => 'development')
        end

        it "complains about missing api key" do
          CopycopterTasks.should have_received(:puts).with(regexp_matches(/api key/i))
        end

        it "should return false" do
          @output.should_not be
        end
      end
    end
  end
end
