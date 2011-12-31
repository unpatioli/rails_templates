create_file ".rvmrc", "rvm gemset use #{app_name}"

gem "haml-rails"
#gem "sass"
gem "nifty-generators"
gem "simple_form"

gem "devise"
gem "cancan"

gem "rails3-generators", :group => [ :development ]
gem "rspec-rails", :group => [ :development, :test ]
gem "factory_girl_rails", :group => [ :development, :test ]
gem "capybara", :group => :test

run 'bundle install'

rake "db:create", :env => 'development'
rake "db:create", :env => 'test'

generate 'nifty:layout --haml'
remove_file 'app/views/layouts/application.html.erb'
generate 'simple_form:install'
generate 'nifty:config'

generate 'rspec:install'
inject_into_file 'spec/spec_helper.rb', "\nrequire 'factory_girl'", :after => "require 'rspec/rails'"
inject_into_file 'config/application.rb', :after => "config.filter_parameters += [:password]" do
	<<-ruby
		config.generators do |g|
			g.template_engine :haml
			g.test_framework :rspec, fixture: true, views: false
			g.fixture_replacement :factory_girl, dir: 'spec/factories'
		end
	ruby
end
run "echo '--format documentation' >> .rspec"

generate "devise:install"
generate "devise:install"
generate "devise User"
generate "devise:views"
run "db:migrate"
generate "cancan:ability"

remove_file 'public/index.html'
remove_file 'rm public/images/rails.png'
run 'cp config/database.yml config/database.example'
run "echo 'config/database.yml' >> .gitignore"

git :init
git :add => "."
git :commit => "-a -m 'initial commit'"
say <<-eos
  Your app is ready
eos

