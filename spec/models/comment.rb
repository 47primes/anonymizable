class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user

  anonymizable :user_id
end
