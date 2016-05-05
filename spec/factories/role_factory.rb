FactoryGirl.define do
  factory :role, class: Role do
    name "user"
  end

  factory :admin_role, class: Role do
    name "admin"
  end
end
