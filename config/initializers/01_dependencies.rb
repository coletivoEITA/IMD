# coding: UTF-8

require 'mongo_caching'

require 'csv' if RUBY_VERSION >= "1.9"
CSV = FasterCSV unless RUBY_VERSION >= "1.9"
