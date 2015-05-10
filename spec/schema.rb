ActiveRecord::Schema.define(version: 0) do

  create_table :users, force: true do |t|
    t.string  :first_name
    t.string  :last_name
    t.string  :email,     null: false
    t.string  :password,  null: false
    t.integer :role_id,   null: false
    t.string  :profile
    t.timestamps
  end

  create_table :roles, force: true do |t|
    t.string :name, null: false
    t.timestamps
  end

  create_table :posts, force: true do |t|
    t.integer :user_id
    t.string  :title,   null: false
    t.string  :summary, null: false
    t.text    :content, null: false
    t.timestamps
  end

  create_table :comments, force: true do |t|
    t.integer :user_id
    t.integer :post_id, null: false
    t.text    :text, null: false
    t.timestamps
  end

  create_table :likes, force: true do |t|
    t.integer :user_id
    t.integer :post_id, null: false
    t.timestamps
  end

  create_table :images, force: true do |t|
    t.integer :image_id
    t.integer :user_id
    t.integer :profile_id
    t.integer :width
    t.integer :height
    t.binary  :data
    t.string  :caption
    t.timestamps
  end

end
