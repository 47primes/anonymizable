class Role < ActiveRecord::Base

  has_many :users

  def method_missing(method_name, *args, &block)
    if /[a-z]+\?/.match(method_name)
      return name == method_name.to_s.sub(/\?/,"")
    end
  end

end