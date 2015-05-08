class User < ActiveRecord::Base

  anonymizable do
    only_if :can_anonymize?

    attributes  :first_name, :last_name,
                email: Proc.new {|c| "john.doe.#{c.id}@foobaz.com" }, 
                password: :random_password

    associations do
      anonymize :posts, :comments
      delete    :avatar
      destroy   :images
    end

    after :email_customer, :email_admin

    public true
  end

  has_many :posts
  has_many :comments, through: :post
  has_one  :avatar

  def can_anonymize?
    
  end

  def random_password
    SecureRandom.hex.sub(/([a-z])/) {|s| s.upcase}
  end

  def email_admin(original_attributes)
  end

end