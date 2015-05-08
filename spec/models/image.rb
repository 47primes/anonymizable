class Image < ActiveRecord::Base

  belongs_to :user
  has_many :thumbnails, class_name: "Image"

end