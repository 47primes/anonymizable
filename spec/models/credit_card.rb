class CreditCard < ActiveRecord::Base

  belongs_to :payment_method
  belongs_to :customer, through: :payment_method

end