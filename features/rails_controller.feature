Feature: Using skywriter in a rails controller

  Scenario: Skywriter in some flash messages
    Given I generate a new rails application
    And I save the following as "app/controllers/users_controller.rb"
    """
    class UsersController < ActionController::Base
      def index
        flash[:success] = s(".skywriter", :default => "default")
      end
    end
    """
    And I save the following as "config/routes.rb"
    """
    ActionController::Routing::Routes.draw do |map|
      map.resources :users
    end
    """
    And I save the following as "config/initializers/skywriter.rb"
    """
    SkywriterClient.configure do |c|
      c.host = "skywriter.local"
    end
    """
    And I save the following as "app/views/users/index.html.erb"
    """
    <%= flash[:success] %>
    """
    And this plugin is available
    And skywriter is available
    And the rails app is running
    When I visit /users/
    Then I should see "e:development b:users.index.skywriter"
