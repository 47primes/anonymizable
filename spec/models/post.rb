class Post < ActiveRecord::Base

  belongs_to :user

  anonymizable :user_id

end