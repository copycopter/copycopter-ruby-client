Copycopter Client
=================

This is the Ruby on Rails client for
[Copycopter](https://github.com/copycopter/copycopter-server).

It uses I18n to access copy and translations from a Copycopter project.

Installation
------------

In your `Gemfile`:

    gem 'copycopter_client'

Run:

    bundle install

In your `config/initializers/copycopter.rb`:

    CopycopterClient.configure do |config|
      config.api_key = 'YOUR API KEY HERE'
      config.host = 'your-copycopter-server.herokuapp.com'
    end

The API key is on the project page. See `CopycopterClient::Configuration` for
all configuration options.

Usage
-----

Access blurbs by using `I18n.translate`. It is aliased as `translate` and `t`
inside Rails controllers and views.

    # controller
    def index
      flash[:success] = t('users.create.success', :default => 'User created')
    end

    # view
    <%= t '.welcome', :default => 'Why hello there' %>

    # model, rake task, etc.
    I18n.translate 'system.tasks_complete', :default => 'Tasks complete'

    # Interpolation
    I18n.translate 'mailer.welcome', :default => 'Welcome, %{name}!',
      :name => @user.name

Using a prefixed dot (ex: '.welcome') only works in views. Use the full key in
controllers and other places.

[I18n docs](http://rdoc.info/github/svenfuchs/i18n/master/file/README.textile).

Deploys
-------

Blurbs start out as draft copy and aren't displayed in production until
published. To publish all draft copy when deploying, use the rake task:

    rake copycopter:deploy

Exporting
---------

Blurbs are cached in-memory while your Rails application is running. To export
all cached blurbs to a yml file for offline access, use the rake task:

    rake copycopter:export

The exported yaml will be located at `config/locales/copycopter.yml`.

Contributing
------------

See the [style guide](https://github.com/copycopter/style-guide).

Credits
-------

![thoughtbot](http://thoughtbot.com/images/tm/logo.png)

Copycopter Client was created by [thoughtbot, inc](http://thoughtbot.com)

It is maintained by the fine folks at [Crowdtap](http://crowdtap.com) and
[Iora Health](http://iorahealth.com).

License
-------

Copycopter Client is free software, and may be redistributed under the terms
specified in the MIT-LICENSE file.
