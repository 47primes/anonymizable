class User < ActiveRecord::Base

  anonymizable do
    only_if :can_anonymize?

    attributes  :first_name, :last_name, :profile,
                email: Proc.new {|c| "anonymized.user.#{c.id}@anonymizable.io" }, 
                password: :random_password

    associations do
      anonymize :posts, :comments
      delete    :avatar
      destroy   :images
    end

    after :email_user, :email_admin

    public
  end

  belongs_to  :role
  has_many    :posts
  has_many    :comments
  has_one     :avatar, foreign_key: :profile_id
  has_many    :images
  has_many    :likes, through: :post
  has_many    :likes_given, class_name: "Like"

  def can_anonymize?
    !role.try(:admin?)
  end

  def random_password
    SecureRandom.hex.sub(/([a-z])/) {|s| s.upcase}
  end

  def email_user(original_attributes)
  end

  def email_admin(original_attributes)
  end

end