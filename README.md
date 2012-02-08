Copycopter Client
=================

This is the client gem for integrating apps with [Copycopter](http://copycopter.com).

The client integrates with the I18n gem so that you can access copy and translations from a Copycopter project.

Installation
------------

Just install the gem:

    gem install copycopter_client

### Rails 3

Add the following line to your `Gemfile`:

    gem "copycopter_client"

Then run `bundle install`.

### Rails 2

Add the following line to your `config/environment.rb`:

    config.gem 'copycopter_client'

Then run `rake gems:install`. We also recommend vendoring the gem by running `rake gems:unpack:dependencies GEM=copycopter_client`.

### Configuration

Add the following to your application:

    CopycopterClient.configure do |config|
      config.api_key = "YOUR API KEY HERE"
    end

In a Rails application, this should be saved as `config/initializers/copycopter.rb`. You can find the API key on the project page on the Copycopter website. See the CopycopterClient::Configuration class for a full list of configuration options.

Usage
-----

You can access blurbs from Copycopter by using `I18n.translate`. This is also aliased as `translate` or just `t` inside Rails controllers and views.

    # In a controller
    def index
      flash[:success] = t("users.create.success", :default => "User created")
    end

    # In a view
    <%= t(".welcome", :default => "Why hello there") %>

    # Global scope (for example, in a Rake task)
    I18n.translate("system.tasks_complete", :default => "Tasks complete")

    # Interpolation
    I18n.translate("mailer.welcome", :default => "Welcome, %{name}!", :name => @user.name)

Note that using a preceding dot (such as ".welcome") will only work when calling t or translate from a view. The full key must be used from controllers and other places.

See the [I18n documentation](http://rdoc.info/github/svenfuchs/i18n/master/file/README.textile) documentation for more examples.

Deploys
-------

Blurbs start out as draft copy, and won't be displayed in production environments until they're published. If you want to publish all draft copy when deploying to production, you can use the `copycopter:deploy` rake task:

    rake copycopter:deploy

Exporting
---------

Blurbs are cached in-memory while your Rails application is running. If you want to export all cached blurbs to a yml file for offline access, you can use the `copycopter:export` rake task:

    rake copycopter:export

The exported `copycopter.yml` will be located in `config/locales/`.

Contributing
------------

Please see CONTRIBUTING.md for details.

Credits
-------

![thoughtbot](http://thoughtbot.com/images/tm/logo.png)

Copycopter Client is maintained and funded by [thoughtbot, inc](http://thoughtbot.com/community)

The names and logos for thoughtbot are trademarks of thoughtbot, inc.

License
-------

Copycopter Client is Copyright © 2010-2011 thoughtbot. It is free software, and may be redistributed under the terms specified in the MIT-LICENSE file.
