require 'sinatra/base'
require 'json'
require 'thin'

class FakeCopycopterApp < Sinatra::Base
  disable :show_exceptions

  def self.start
    Thread.new do
      if ENV['DEBUG']
        Thin::Logging.debug = true
      else
        Thin::Logging.silent = true
      end

      Rack::Handler::Thin.run self, :Port => port
    end
  end

  def self.port
    (ENV['COPYCOPTER_PORT'] || 3002).to_i
  end

  def self.add_project(api_key)
    Project.create api_key
  end

  def self.reset
    Project.delete_all
  end

  def self.project(api_key)
    Project.find api_key
  end

  def with_project(api_key)
    if api_key == 'raise_error'
      halt 500, { :error => 'Blah ha' }.to_json
    elsif project = Project.find(api_key)
      yield project
    else
      halt 404, { :error => 'No such project' }.to_json
    end
  end

  get '/api/v2/projects/:api_key/published_blurbs' do |api_key|
    with_project(api_key) do |project|
      etag project.etag
      project.published.to_json
    end
  end

  get '/api/v2/projects/:api_key/draft_blurbs' do |api_key|
    with_project(api_key) do |project|
      etag project.etag
      project.draft.to_json
    end
  end

  post '/api/v2/projects/:api_key/draft_blurbs' do |api_key|
    with_project(api_key) do |project|
      with_json_data do |data|
        project.update 'draft' => data
        201
      end
    end
  end

  def with_json_data
    if request.content_type == 'application/json'
      yield JSON.parse(request.body.read)
    else
      406
    end
  end

  post '/api/v2/projects/:api_key/deploys' do |api_key|
    with_project(api_key) do |project|
      project.deploy
      201
    end
  end

  class Project
    attr_reader :draft, :published, :api_key

    def initialize(attrs)
      @api_key = attrs['api_key']
      @draft = attrs['draft']  || {}
      @etag = attrs['etag'] || 1
      @published = attrs['published'] || {}
    end

    def to_hash
      {
        'api_key' => @api_key,
        'etag' => @etag,
        'draft' => @draft,
        'published' => @published
      }
    end

    def update(attrs)
      if attrs['draft']
        @draft.update attrs['draft']
      end

      if attrs['published']
        @published.update attrs['published']
      end

      @etag += 1
      self.class.save self
    end

    def reload
      self.class.find api_key
    end

    def deploy
      @published.update @draft
      self.class.save self
    end

    def etag
      @etag.to_s
    end

    def self.create(api_key)
      project = Project.new('api_key' => api_key)
      save project
      project
    end

    def self.find(api_key)
      open_project_data do |data|
        if project_hash = data[api_key]
          Project.new project_hash.dup
        else
          nil
        end
      end
    end

    def self.delete_all
      open_project_data do |data|
        data.clear
      end
    end

    def self.save(project)
      open_project_data do |data|
        data[project.api_key] = project.to_hash
      end
    end

    def self.open_project_data
      project_file = File.expand_path('/../../../tmp/projects.json', __FILE__)

      if File.exist? project_file
        data = JSON.parse(IO.read(project_file))
      else
        data = {}
      end

      result = yield(data)

      File.open(project_file, 'w') do |file|
        file.write data.to_json
      end

      result
    end
  end
end
