class Like < ActiveRecord::Base

  belongs_to :user
  belongs_to :post

  anonymizable :user_id

end