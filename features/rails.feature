Feature: Using copycopter in a rails app

  Background:
    Given I have a copycopter project with an api key of "abc123"
    When I generate a rails application
    And I configure the copycopter client with api key "abc123"

  Scenario: copycopter in the controller
    Given the "abc123" project has the following blurbs:
      | key                            | published content |
      | en.users.index.controller-test | This is a test    |
    When I write to "app/controllers/users_controller.rb" with:
    """
    class UsersController < ActionController::Base
      def index
        @text = t("users.index.controller-test", :default => "default")
      end
    end
    """
    When I write to "config/routes.rb" with:
    """
    ActionController::Routing::Routes.draw do |map|
      map.resources :users
    end
    """
    When I write to "app/views/users/index.html.erb" with:
    """
    <%= @text %>
    """
    When I visit /users/
    Then the output should contain "This is a test"

  Scenario: copycopter in the view
    Given the "abc123" project has the following blurbs:
      | key                      | published content |
      | en.users.index.view-test | This is a test    |
    When I write to "app/controllers/users_controller.rb" with:
    """
    class UsersController < ActionController::Base
      def index
        render
      end
    end
    """
    When I write to "config/routes.rb" with:
    """
    ActionController::Routing::Routes.draw do |map|
      map.resources :users
    end
    """
    When I write to "app/views/users/index.html.erb" with:
    """
    <%= t(".view-test", :default => "default") %>
    """
    When I visit /users/
    Then the output should contain "This is a test"

  Scenario: missing key
    When I write to "app/controllers/users_controller.rb" with:
    """
    class UsersController < ActionController::Base
      def index
        render :action => "index"
      end
    end
    """
    When I write to "config/routes.rb" with:
    """
    ActionController::Routing::Routes.draw do |map|
      map.resources :users
    end
    """
    When I write to "app/views/users/index.html.erb" with:
    """
    <%= t(".404", :default => "default") %>
    """
    When I visit /users/
    Then the output should contain "default"

