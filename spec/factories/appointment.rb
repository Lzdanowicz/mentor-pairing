FactoryGirl.define do
  factory :appointment do
    association :mentee, factory: :mentee
    association :availability, factory: :availability
  end
end
