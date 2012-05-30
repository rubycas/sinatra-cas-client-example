require 'bundler/setup'

$:.unshift "#{File.dirname(__FILE__)}/lib"

require 'cas_example'

use Rack::Lint

run CasExample
