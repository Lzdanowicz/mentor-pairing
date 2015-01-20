require 'factory_girl'

FactoryGirl.define do
  factory :availability do
    timezone "UTC"
    duration 30
    start_time  1.week.from_now
    association :mentor, factory: :mentor
    city 'Chicago'
    location 'DBC'
  end
end
