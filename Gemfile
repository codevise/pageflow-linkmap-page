source 'https://rubygems.org'

# Specify your gem's dependencies in chart.gemspec
gemspec

gem 'spring-commands-rspec', group: :development
gem 'spring-commands-teaspoon', group: :development

if ENV['PAGEFLOW_DEPENDENCIES'] == 'experimental'
  git 'https://github.com/codevise/pageflow', branch: 'edge', glob: '**/*.gemspec' do
    gem 'pageflow'
    gem 'pageflow-support'
  end

  gem 'pageflow-external-links', git: 'https://github.com/codevise/pageflow-external-links'
else
  gem 'rails', '5.2.6'
end
