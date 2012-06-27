# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image do
    type ""
    publication_date "2012-06-27"
    size 1
    media_id 1
  end
end
