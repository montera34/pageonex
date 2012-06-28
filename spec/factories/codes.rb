# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :code do
    code_text "MyString"
    threadx_id 1
  end
end
