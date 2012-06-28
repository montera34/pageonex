# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :threadx do
    thread_name "MyString"
    thread_display_name "MyString"
    start_date "2012-06-27"
    end_date "2012-06-27"
    description "MyText"
    category "MyString"
    status "MyString"
  end
end
