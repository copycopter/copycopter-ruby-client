CopyTuner Client
=================

[![Build Status](https://travis-ci.org/SonicGarden/copy-tuner-ruby-client.svg?branch=master)](https://travis-ci.org/SonicGarden/copy-tuner-ruby-client)

Development
=================

## Spec

### default spec

    $ bundle exec rake

### Appraisal for Multi Version Rails spec

    $ bundle exec appraisal install
    $ bundle exec rake appraisal

## release gem

    $ bundle exec rake build      # build gem to pkg/ dir
    $ bundle exec rake install    # install to local gem
    $ bundle exec rake release    # release gem to rubygems.org
