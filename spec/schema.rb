ActiveRecord::Schema.define(:version => 0) do

  create_table :customers, :force => true do |t|
    t.string :first_name
    t.string :last_name
    t.string :email
    t.string :encrypted_password
    t.timestamps
  end

  create_table :addresses, :force => true do |t|
    t.integer :number
    t.string :street
    t.string :city
    t.string :state
    t.string :zip_code
  end

  create_table :payment_methods, :force => true do |t|
    t.string :name
    t.timestamps
  end

  create_table :credit_cards, :force => true do |t|
    t.integer :payment_method_id
    t.integer :last_four
    t.string :name
    t.string :card_type
    t.timestamps
  end

  create_table :shopping_cart, :force => true do |t|
    t.integer :customer_id
    t.integer :items
    t.integer :total
    t.timestamps
  end

end
