$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'models')))

require 'anonymizable'
require 'logger'
require 'rspec'
require 'database_cleaner'
require 'factory_girl'
require 'yaml'

def load_schema
  config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
  ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
  ActiveRecord::Base.establish_connection(config['sqlite3'])
  load(File.dirname(__FILE__) + "/schema.rb")
end

def load_models
  Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), 'models/*.rb'))).each {|f| require f}
  Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), 'factories/*.rb'))).each {|f| require f}
end

load_schema
load_models

RSpec.configure do |config|
  config.color      = true
  config.formatter  = :documentation
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:each) do |example|
    DatabaseCleaner.clean
  end
end
