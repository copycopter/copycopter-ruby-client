require 'sinatra/base'
require 'json'

class FakeCopycopterApp < Sinatra::Base
  def self.add_project(api_key)
    Project.create(api_key)
  end

  def self.reset
    Project.delete_all
  end

  def self.project(api_key)
    Project.find(api_key)
  end

  def with_project(api_key)
    if api_key == 'raise_error'
      halt 500, { :error => "Blah ha" }.to_json
    elsif project = Project.find(api_key)
      yield(project)
    else
      halt 404, { :error => "No such project" }.to_json
    end
  end

  get "/api/v2/projects/:api_key/published_blurbs" do |api_key|
    with_project(api_key) { |project| project.published.to_json }
  end

  get "/api/v2/projects/:api_key/draft_blurbs" do |api_key|
    with_project(api_key) { |project| project.draft.to_json }
  end

  post "/api/v2/projects/:api_key/draft_blurbs" do |api_key|
    with_project(api_key) do |project|
      data = JSON.parse(request.body.read)
      project.update('draft' => data)
      201
    end
  end

  post "/api/v2/projects/:api_key/deploys" do |api_key|
    with_project(api_key) do |project|
      project.deploy
      201
    end
  end

  class Project
    attr_reader :draft, :published, :api_key

    def initialize(attrs)
      @api_key   = attrs['api_key']
      @draft     = attrs['draft']     || {}
      @published = attrs['published'] || {}
    end

    def to_hash
      { 'api_key'   => @api_key,
        'draft'     => @draft,
        'published' => @published }
    end

    def update(attrs)
      @draft.    update(attrs['draft'])     if attrs['draft']
      @published.update(attrs['published']) if attrs['published']
      self.class.save(self)
    end

    def reload
      self.class.find(api_key)
    end

    def deploy
      @published.update(@draft)
      self.class.save(self)
    end

    def self.create(api_key)
      project = Project.new('api_key' => api_key)
      save(project)
      project
    end

    def self.find(api_key)
      open_project_data do |data|
        if project_hash = data[api_key]
          Project.new(project_hash.dup)
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
      if File.exist?(project_file)
        data = JSON.parse(IO.read(project_file))
      else
        data = {}
      end

      result = yield(data)

      File.open(project_file, "w") { |file| file.write(data.to_json) }

      result
    end
  end
end

ShamRack.mount(FakeCopycopterApp.new, "copycopter.com")

