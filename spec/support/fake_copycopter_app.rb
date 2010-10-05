require 'sinatra/base'

class FakeCopycopterApp < Sinatra::Base
  class << self
    attr_accessor :projects
  end

  self.projects = {}

  def self.add_project(api_key)
    self.projects[api_key] = Project.new(api_key)
  end

  def self.reset
    self.projects.clear
  end

  def projects
    self.class.projects
  end

  get "/api/v2/projects/:api_key/published_blurbs" do |api_key|
    if projects[api_key]
      projects[api_key].published.to_json
    else
      halt 404, "No such project"
    end
  end

  get "/api/v2/projects/:api_key/draft_blurbs" do |api_key|
    if projects[api_key]
      projects[api_key].draft.to_json
    else
      halt 404, "No such project"
    end
  end

  put "/api/v2/projects/:api_key/defaults" do |api_key|
    if projects[api_key]
      raise NotImplementedError
    else
      halt 404, "No such project"
    end
  end

  not_found do
    "Unknown resource"
  end

  class Project
    attr_reader :draft, :published, :api_key

    def initialize(api_key)
      @api_key   = api_key
      @draft     = {}
      @published = {}
    end
  end
end

ShamRack.mount(FakeCopycopterApp.new, "copycopter.com")

