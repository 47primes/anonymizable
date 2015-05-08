ActiveRecord::Schema.define(version: 0) do

  create_table :users, force: true do |t|
    t.string  :first_name, null: false
    t.string  :last_name,  null: false
    t.string  :email,      null: false
    t.string  :encrypted_password
    t.timestamps
  end

  create_table :posts, force: true do |t|
    t.integer :user_id
    t.string  :subject
    t.text    :content
    t.timestamps
  end

  create_table :comments, force: true do |t|
    t.integer :user_id
    t.integer :post_id, null: false
    t.text    :text
    t.timestamps
  end

  create_table :images, force: true do |t|
    t.integer :image_id
    t.integer :user_id
    t.integer :width
    t.integer :height
    t.binary  :data
    t.string  :caption
    t.timestamps
  end

end
