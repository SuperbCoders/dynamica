# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :permission do
    user
    project
  end
end
