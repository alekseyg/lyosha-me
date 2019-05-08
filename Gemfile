source 'https://rubygems.org'

require 'json'
require 'open-uri'
versions = JSON.parse(open('https://pages.github.com/versions.json').read)

gem 'github-pages', versions['github-pages']

gem 'jekyll', '~> 3.8.5'
gem 'jekyll-sitemap'
gem 'jekyll-redirect-from', '~> 0.14.0'
