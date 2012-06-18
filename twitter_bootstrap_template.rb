# ========
# = Gems =
# ========
gem "haml"
gem "simple_form"
gem "inherited_resources"

gem "devise"
gem "cancan"

gem "sanitize"

gem 'twitter-bootstrap-rails', git: 'git://github.com/seyhunak/twitter-bootstrap-rails.git', group: :assets
gem 'haml_coffee_assets', group: :assets

gem "haml-rails", group: :development

gem "pry", group: [:development, :test]

gem "rspec-rails", group: :test
gem "shoulda-matchers", group: :test
gem "factory_girl_rails", group: :test
gem "database_cleaner", group: :test
gem "capybara", group: :test

run 'bundle install'

# =================
# = Configuration =
# =================

# DB
rake "db:create", :env => 'development'
rake "db:create", :env => 'test'

run "db:migrate"

run 'cp config/database.yml config/database.example'
run "echo 'config/database.yml' >> .gitignore"

# generators
inject_into_file 'config/application.rb', :after => "config.filter_parameters += [:password]" do
	<<-RUBY
	
	
		config.generators do |g|
			g.template_engine :haml
			g.test_framework :rspec, fixture: true, views: false
			g.fixture_replacement :factory_girl, dir: 'spec/factories'
		end
	RUBY
end

# devise
model_name = 'User'
generate 'devise:install'
generate "devise", model_name
generate 'devise:views'

# cancan
generate 'cancan:ability'

# twitter bootstrap things
generate 'bootstrap:install'
generate 'bootstrap:layout application fixed'
remove_file 'app/views/layouts/application.html.erb'

# simple_form
generate 'simple_form:install --bootstrap'

# rspec
generate 'rspec:install'

create_file 'spec/support/devise.rb' do
  <<-RUBY
    RSpec.configure do |config|
      config.include Devise::TestHelpers, type: :controller
    end
  RUBY
end

create_file 'spec/support/factory_girl.rb' do
  <<-RUBY
    RSpec.configure do |config|
      config.include Factory::Syntax::Methods
    end
  RUBY
end

create_file 'spec/support/capybara.rb' do
  <<-RUBY
    require "capybara/rspec"
    require "capybara/rails"
  RUBY
end

# ActionMailer
gsub_file 'config/environments/development.rb', /# Don't care if the mailer can't send/, '# ActionMailer Config'
gsub_file 'config/environments/development.rb', /config.action_mailer.raise_delivery_errors = false/ do
  <<-RUBY
    config.action_mailer.default_url_options = { host: 'localhost:3000' }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = false
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.default charset: 'utf-8'
  RUBY
end

gsub_file 'config/environments/production.rb', /config.active_support.deprecation = :notify/ do
  <<-RUBY
    config.active_support.deprecation = :notify
    
    config.action_mailer.default_url_options = { host: 'yourhost.com' }
    
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = false
    config.action_mailer.default charset: 'utf-8'
  RUBY
end

remove_file 'public/index.html'
remove_file 'rm public/images/rails.png'

generate :controller, 'home index'
gsub_file 'config/routes.rb', /get \"home\/index\"/, 'root to: "home#index"'

# ==============
# = Git commit =
# ==============
git :init
git add: "."
git commit: "-a -m 'initial commit'"

# =========
# = Final =
# =========
say <<-EOS
  Your app is ready
EOS
