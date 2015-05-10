FactoryGirl.define do
  factory :user do
    email { "user.#{id}@anonymizable.io" }
    password { random_password }
    role
  end

  factory :admin, class: User do
    email { "admin.user.#{id}@anonymizable.io" }
    password { random_password }
    role { FactoryGirl.create(:admin_role) }
  end
end