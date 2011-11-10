@disable-bundler
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
    When I route the "users" resource
    And I write to "app/views/users/index.html.erb" with:
    """
    <%= @text %>
    """
    When I start the application
    And I wait for changes to be synchronized
    Then the copycopter client version and environment should have been logged
    Then the log should contain "Downloaded translations"
    When I visit /users/
    Then the response should contain "This is a test"
    And the log should not contain "DEPRECATION WARNING"

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
    When I route the "users" resource
    And I write to "app/views/users/index.html.erb" with:
    """
    <%= t(".view-test", :default => "default") %>
    """
    When I start the application
    And I wait for changes to be synchronized
    And I visit /users/
    Then the response should contain "This is a test"

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
    When I route the "users" resource
    And I write to "app/views/users/index.html.erb" with:
    """
    <%= @text %>
    """
    When I start the application
    And I visit /users/
    Then the response should contain "Old content"
    When the the following blurbs are updated in the "abc123" project:
      | key                            | draft content |
      | en.users.index.controller-test | New content   |
    And I visit /users/
    Then the response should contain "New content"

  Scenario: missing key
    When I write to "app/controllers/users_controller.rb" with:
    """
    class UsersController < ActionController::Base
      def index
        render :action => "index"
      end
    end
    """
    When I route the "users" resource
    And I write to "app/views/users/index.html.erb" with:
    """
    <%= t(".404", :default => "not found") %>
    """
    When I start the application
    And I visit /users/
    Then the response should contain "not found"
    And the "abc123" project should have the following blurbs:
      | key                | draft content |
      | en.users.index.404 | not found     |
    And the log should contain "Uploaded missing translations"

  Scenario: copycopter in production
    Given the "abc123" project has the following blurbs:
      | key                             | published content | draft content |
      | en.users.index.controller-test  | This is a test    | Extra extra   |
      | en.users.index.unpublished-test |                   | Extra extra   |
    When I write to "app/controllers/users_controller.rb" with:
    """
    class UsersController < ActionController::Base
      def index
        @text = t("users.index.controller-test", :default => "default")
        @unpublished = t("users.index.unpublished-test", :default => "Unpublished")
        t("users.index.unknown-test", :default => "Unknown")
      end
    end
    """
    When I route the "users" resource
    And I write to "app/views/users/index.html.erb" with:
    """
    <%= @text %>
    <%= @unpublished %>
    """
    When I start the application in the "production" environment
    And I wait for changes to be synchronized
    And I visit /users/
    Then the response should contain "This is a test"
    And the response should contain "Unpublished"
    And I wait for changes to be synchronized
    And the "abc123" project should have the following blurbs:
      | key                         | draft content |
      | en.users.index.unknown-test | Unknown       |

  Scenario: configure a bad api key
    When I configure the copycopter client with api key "bogus"
    And I start the application
    And I wait for changes to be synchronized
    Then the log should contain "Invalid API key: bogus"

  Scenario: deploy
    Given the "abc123" project has the following blurbs:
      | key      | draft content | published content |
      | test.one | expected one  | unexpected one    |
      | test.two | expected two  | unexpected two    |
    When I successfully rake "copycopter:deploy"
    And the output should contain "Successfully marked all blurbs as published"
    Then the "abc123" project should have the following blurbs:
      | key      | draft content | published content |
      | test.one | expected one  | expected one      |
      | test.two | expected two  | expected two      |

  Scenario: fallback on the simple I18n backend
    When I write to "config/locales/en.yml" with:
    """
    en:
      test:
        key: Hello, %{name}
    """
    When I write to "app/controllers/users_controller.rb" with:
    """
    class UsersController < ActionController::Base
      def index
      render :text => t("test.key", :name => 'Joe')
      end
    end
    """
    When I route the "users" resource
    And I start the application
    And I visit /users/
    Then the response should contain "Hello, Joe"
    When I wait for changes to be synchronized
    Then the "abc123" project should have the following blurbs:
      | key         | draft content  |
      | en.test.key | Hello, %{name} |

  Scenario: preserve localization keys
    When I write to "app/controllers/users_controller.rb" with:
    """
    class UsersController < ActionController::Base
      def index
        render
      end
    end
    """
    When I route the "users" resource
    And I write to "app/views/users/index.html.erb" with:
    """
    <%= number_to_currency(2.5) %>
    """
    When I start the application
    And I visit /users/
    Then the response should contain "$2.50"
    When I wait for changes to be synchronized
    Then the "abc123" project should not have the "en.number.format" blurb

  Scenario: view validation errors
    When I write to "app/models/user.rb" with:
    """
    class User < ActiveRecord::Base
      validates_presence_of :name
    end
    """
    When I write to "db/migrate/1_create_users.rb" with:
      """
      class CreateUsers < ActiveRecord::Migration
        def self.up
          create_table :users do |t|
            t.string :name
          end
        end
      end
      """
    When I write to "app/controllers/users_controller.rb" with:
    """
    class UsersController < ActionController::Base
      def index
        @user = User.new
        @user.valid?
        render
      end
    end
    """
    When I route the "users" resource
    And I write to "app/views/users/index.html.erb" with:
    """
    <%= @user.errors.full_messages.first %>
    """
    When I successfully rake "db:migrate"
    And I configure the copycopter client to use published data
    And I start the application
    And I visit /users/
    Then the response should contain "Name can't be blank"
    When I wait for changes to be synchronized
    Then the "abc123" project should have the following error blurbs:
      | key                        | draft content  |
      | user.attributes.name.blank | can't be blank |

  Scenario: ensure keys are synced with short lived processes
    When I configure the copycopter client to have a polling delay of 86400 seconds
    And I start the application
    And I run a short lived process that sets the key "threaded.key" to "all your base"
    Then the "abc123" project should have the following blurbs:
      | key             | draft content |
      | en.threaded.key | all your base |

  Scenario: support pluralization
    Given I write to "app/controllers/users_controller.rb" with:
    """
    class UsersController < ActionController::Base
      def index
        render
      end
    end
    """
    And I route the "users" resource
    And I write to "app/views/users/index.html.erb" with:
    """
    <%= time_ago_in_words(1.hour.ago) %> ago
    <%= time_ago_in_words(2.hours.ago) %> ago
    """
    When I start the application
    And I visit /users/
    Then the response should contain "1 hour ago"
    And the response should contain "2 hours ago"
    When I wait for changes to be synchronized
    Then the "abc123" project should have the following blurbs:
      | key                                               | draft content        |
      | en.datetime.distance_in_words.about_x_hours.one   | about 1 hour         |
      | en.datetime.distance_in_words.about_x_hours.other | about %{count} hours |

