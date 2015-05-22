require 'yaml'
require 'anonymizable'

def user
  with_retries do
    @user ||= User.create! first_name: "Created", last_name: "User", email: "created.user@foobar.com", password: "foobar", role: role
  end
end

def role
  with_retries do
    @role ||= Role.create! name: "user"
  end
end

def with_retries(attempts=1, &block)
  retries = 1
  begin
    yield
  rescue NameError
    load_models
    retry unless retries > attempts
    retries += 1
  end
end

def load_models
  config = YAML::load(IO.read(File.join(Dir.pwd, "spec/database.yml")))
  ActiveRecord::Base.establish_connection(config['sqlite3'])
  load(File.join(Dir.pwd, "spec/schema.rb"))
  Dir.glob(File.join(Dir.pwd, "/spec/models/*.rb")) { |path| require path }
end