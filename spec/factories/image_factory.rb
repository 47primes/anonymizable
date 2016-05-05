FactoryGirl.define do
  factory :image do
    user
  end

  factory :avatar do
    user
  end

  factory :thumbnail, class: Image do
    image
  end
end
