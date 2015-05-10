class Avatar < ActiveRecord::Base
  self.table_name = :images

  belongs_to :user, foreign_key: :profile_id

end