# Kickstart rails app template (basic/plain version)

## Usage

1. Install 
- PostgreSQL database
- Redis key-value server
- ruby using rbenv
- ruby on rails using `gem install rails`

2. Create app using template

```bash
rails new APP_NAME -T -d postgresql -m https://raw.githubusercontent.com/alec-c4/ks-rails-basic/master/template.rb
```

3. Create all required accounts:

- [Digital Ocean](https://m.do.co/c/cfc852e7f0e6) or [Linode](https://www.linode.com/?r=163287613c0644b17ccd5aad43f40bdf9b0b0e2f)
- [Appsignal](https://appsignal.com/r/53a0242a45)
- [Postmark](https://postmarkapp.com)

4. Configure Appsignal with `bundle exec appsignal install APPSIGNAL_KEY`

5. Setup hypershield gem for [PostgreSQL](https://github.com/ankane/hypershield#postgres)

6. Configure application secrets with following template

```yaml
active_record_encryption:
  primary_key: ''
  deterministic_key: ''
  key_derivation_salt: ''
secret_key_base: ''
postmark:
  api_key: ''
```

You can generate active record encryption keys with following command

```bash
bin/rails db:encryption:init
```

7. Configure application in  `config/settings.yml`

## What's inside

- ruby on rails application template 
- .gitignore file
- [VSCode](https://code.visualstudio.com/) configuration files
- postgresql database connector
- [online_migrations](https://github.com/fatkodima/online_migrations)
- pre-configured generators
- I18n tools - [rails-i18n](http://github.com/svenfuchs/rails-i18n) and [i18n-tasks](https://github.com/glebm/i18n-tasks)
- rspec for testing
- [better_html](https://github.com/Shopify/better-html) and [erb-lint](https://github.com/Shopify/erb-lint) for erb linting
- [standard.rb](https://github.com/testdouble/standard) for code style validations
- [bullet](https://github.com/flyerhzm/bullet) to prevent N+1 problems
- [brakeman](https://github.com/presidentbeef/brakeman) and [bundler-audit](https://github.com/postmodern/bundler-audit) as security scanners
- [pry-rails](https://github.com/rweng/pry-rails) and [amazing_print](https://github.com/amazing-print/amazing_print) for better rails console
- [view_component](https://viewcomponent.org/) as a replacement for partials
- [annotate](https://github.com/ctran/annotate_models) for annotations
- [lefthook](https://github.com/evilmartians/lefthook) with pre-commit run of rspec, brakeman, standardjs, standardrb and erblint
- [semantic_logger](https://github.com/reidmorrison/semantic_logger) as a highly configurable logging system
- [simplecov](https://github.com/simplecov-ruby/simplecov) for test coverage research
- [hypershield](https://github.com/ankane/hypershield)

## TODO

- add documentation (howto's, best practices, curated list of libraries)
