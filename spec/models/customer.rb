class Customer < ActiveRecord::Base

  anonymizable do
    only_if :can_anonymize?

    nullify :first_name, :last_name

    anonymize :email, Proc.new {|c| "john.doe.#{c.id}@foobaz.com" }
    anonymize :password, :random_password

    associations :addresses, :credit_cards, :shopping_cart

    after :email_admin

    public true
  end

  has_many :addresses
  has_many :credit_cards
  has_one :shopping_cart
  has_many :items, through: :shopping_cart

  def can_anonymize?
    email.split("@").last != "thewidgetstore.com"
  end

  def random_password
    SecureRandom.hex.sub(/([a-z])/) {|s| s.upcase}
  end

  def email_admin(original_attributes)
  end

  def email_admin_without_argument
  end

end