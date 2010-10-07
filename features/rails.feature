Feature: Using copycopter in a rails app

  Background:
    Given I have a copycopter project with an api key of "abc123"
    When I generate a rails application
    And I configure the copycopter client with api key "abc123"

  Scenario: copycopter in the controller
    Given the "abc123" project has the following blurbs:
      | key                            | draft content  |
      | en.users.index.controller-test | This is a test |
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
    When I start the application
    And I wait for changes to be synchronized
    Then the copycopter client version and environment should have been logged
    Then the log should contain "Downloaded translations"
    When I visit /users/
    Then the output should contain "This is a test"
    And the output should contain a link to edit "en.users.index.controller-test" from "abc123"

  Scenario: copycopter in the view
    Given the "abc123" project has the following blurbs:
      | key                      | draft content  |
      | en.users.index.view-test | This is a test |
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
    When I start the application
    And I wait for changes to be synchronized
    And I visit /users/
    Then the output should contain "This is a test"

  Scenario: copycopter detects updates to copy
    Given the "abc123" project has the following blurbs:
      | key                            | draft content |
      | en.users.index.controller-test | Old content   |
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
    When I start the application
    And I wait for changes to be synchronized
    And I visit /users/
    Then the output should contain "Old content"
    When the the following blurbs are updated in the "abc123" project:
      | key                            | draft content |
      | en.users.index.controller-test | New content   |
    And I wait for changes to be synchronized
    And I visit /users/
    Then the output should contain "New content"

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
    <%= t(".404", :default => "not found") %>
    """
    When I start the application
    And I visit /users/
    Then the output should contain "not found"
    When I wait for changes to be synchronized
    Then the "abc123" project should have the following blurbs:
      | key                | draft content |
      | en.users.index.404 | not found     |
    And the log should contain "Uploaded missing translations"

  Scenario: copycopter in production
    Given the "abc123" project has the following blurbs:
      | key                            | published content | draft content |
      | en.users.index.controller-test | This is a test    | Extra extra   |
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
    When I configure the copycopter client to used published data
    And I start the application
    And I wait for changes to be synchronized
    And I visit /users/
    Then the output should contain "This is a test"
    And the output should not contain an edit link

  Scenario: backwards compatibility
    Given the "abc123" project has the following blurbs:
      | key                            | draft content    |
      | en.users.index.controller-test | Controller blurb |
      | en.users.index.view-test       | View blurb       |
    When I write to "app/controllers/users_controller.rb" with:
    """
    class UsersController < ActionController::Base
      def index
        @text = s('.controller-test')
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
    <%= @text %>
    <%= s(".view-test", "default") %>
    """
    When I start the application
    And I wait for changes to be synchronized
    And I visit /users/
    Then the output should contain "Controller blurb"
    And the output should contain "View blurb"

