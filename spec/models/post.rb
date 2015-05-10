class Post < ActiveRecord::Base

  belongs_to :user
  has_many :comments
  has_many :images
  has_many :likes

  anonymizable :user_id

end