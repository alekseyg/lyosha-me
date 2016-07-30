source 'https://rubygems.org'

require 'json'
require 'open-uri'
versions = JSON.parse(open('https://pages.github.com/versions.json').read)

gem 'github-pages', versions['github-pages']

gem 'jekyll', '~> 3.1.6'
gem 'jekyll-sitemap'
gem 'jekyll-redirect-from', '~> 0.11.0'
gem 'jekyll-coffeescript'
