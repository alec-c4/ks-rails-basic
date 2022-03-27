require "rails/all"
require "fileutils"
require "shellwords"

RAILS_REQUIREMENT = ">= 7.0.0"
REPO_LINK = "https://github.com/alec-c4/ks-rails-blank.git"

def apply_template!
  assert_minimum_rails_version
  add_template_repository_to_source_path

  # setup vscode
  copy_file ".editorconfig", force: true
  directory ".vscode", force: true

  # setup .gitignore 
  copy_file ".gitignore", force: true

  # setup Makefile
  copy_file "Makefile", force: true

  # setup Gemfile
  template "Gemfile.tt", force: true

  # setup lefthook
  copy_file "lefthook.yml", force: true

  after_bundle do
    apply_app_changes
    show_post_install_message
  end
end

def apply_app_changes
  # setup generators
  copy_file "config/initializers/generators.rb", force: true
  copy_file "config/initializers/semantic_logger.rb", force: true

  # setup main configuration

  copy_file "config/settings.yml", force: true

  inject_into_file "config/application.rb", after: /config\.generators\.system_tests = nil\n/ do
    <<-'RUBY'
  # use config file
  config.settings = config_for(:settings)

     # disable remote forms generation
     config.action_view.form_with_generates_remote_forms = false
    RUBY
  end

  inject_into_file "config/environments/development.rb",
                   after: /config\.action_cable\.disable_request_forgery_protection = true\n/ do
    <<-'RUBY'
    # Mail
    config.action_mailer.delivery_method = :letter_opener_web
    config.action_mailer.default_url_options = {
      host: URI.parse(Rails.configuration.settings.base_url).host,
      port: URI.parse(Rails.configuration.settings.base_url).port,
      protocol: URI.parse(Rails.configuration.settings.base_url).scheme
    }
    config.action_mailer.perform_deliveries = true

    config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"

    # Bullet
    config.after_initialize do
      Bullet.enable = true
      Bullet.alert = true
      Bullet.bullet_logger = true
      Bullet.console = true
      # Bullet.growl         = true
      Bullet.rails_logger = true
      Bullet.add_footer = true
    end
    RUBY
  end

  inject_into_file "config/environments/test.rb",
                   after: /config\.action_view\.annotate_rendered_view_with_filenames = true\n/ do
    <<-'RUBY'
    # Bullet
    config.after_initialize do
      Bullet.enable = true
      Bullet.bullet_logger = true
      Bullet.raise = true # raise an error if n+1 query occurs
    end

    # Mailer
    config.action_mailer.default_url_options = {
      host: URI.parse(Rails.configuration.settings.base_url).host,
      port: URI.parse(Rails.configuration.settings.base_url).port,
      protocol: URI.parse(Rails.configuration.settings.base_url).scheme
    }
    RUBY
  end

  inject_into_file "config/environments/production.rb",
                   after: /config\.active_record\.dump_schema_after_migration = false\n/ do
    <<-'RUBY'
    # Mail
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = {
      api_token: Rails.application.credentials.postmark[:api_key]
    }
    config.action_mailer.default_url_options = {
      host: URI.parse(Rails.configuration.settings.base_url).host,
      protocol: URI.parse(Rails.configuration.settings.base_url).scheme
    }
    config.action_mailer.perform_deliveries = true
    RUBY
  end

  gsub_file "config/environments/production.rb", /STDOUT/, "$stdout"

  run "cp config/environments/production.rb config/environments/staging.rb"

  # setup migrations

  generate "migration EnableUuidPsqlExtension"
  uuid_migration_file = (Dir["db/migrate/*_enable_uuid_psql_extension.rb"]).first
  copy_file "migrations/uuid.rb", uuid_migration_file, force: true


  # setup i18n
  copy_file "config/initializers/i18n.rb", force: true
  directory "config/locales", force: true
  copy_file "config/i18n-tasks.yml", force: true

  # setup application logic

  directory "app/components", force: true
  directory "app/helpers", force: true
  directory "app/interactions", force: true
  directory "app/mailers", force: true
  directory "app/models", force: true
  copy_file "config/puma.rb", force: true
  copy_file "config/initializers/active_interaction.rb", force: true
  copy_file ".erb-lint.yml", force: true

  # setup specs
  generate "rspec:install"
  directory "spec", force: true
  copy_file ".rspec", force: true

  # setup db related gems
  generate "hypershield:install"
  generate "annotate:install"
  generate "strong_migrations:install"

  copy_file "public/robots.txt", force: true

  # run linters
  run "i18n-tasks normalize"
  run "bundle exec erblint --lint-all -a"
  run "standardrb --fix"
end

def show_post_install_message
  say "\n
  #########################################################################################

  App successfully created!\n

  Next steps:
  1 - add credentials as described in README.md
  2 - configure database connections
  3 - configure application options in config/settings.yml
  4 - run following command \n
  git init && git add . &&  git commit -am 'Initial import' && lefthook install \n
  
  #########################################################################################\n", :green
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

def add_template_repository_to_source_path
  if __FILE__.match?(%r{\Ahttps?://})
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("kickstart-tmp"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      REPO_LINK,
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{kickstart/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def gemfile_requirement(name)
  @original_gemfile ||= IO.read("Gemfile")
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(,[><~= \t\d.\w'"]*)?.*$/, 1]
  req && req.tr("'", %(")).strip.sub(/^,\s*"/, ', "')
end

run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"
apply_template!
