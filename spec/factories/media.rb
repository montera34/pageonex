# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :medium, :class => 'Media' do
    name "MyString"
    country "MyString"
    city "MyString"
    url "MyString"
  end
end
