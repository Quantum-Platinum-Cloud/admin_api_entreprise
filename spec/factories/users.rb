FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.org" }
    context 'VERY_DEVELOPMENT'

    # Do not send devise confirmation email on factory creation
    after(:build) do |u|
      u.skip_confirmation_notification!
    end

    after(:create) do |u|
      create(:token, user: u)
    end

    factory :user_provider do
      after(:build) do |u|
        build(:contact, contact_type: 'tech', user: u)
        build(:contact, contact_type: 'admin', user: u)
      end
    end

    factory :user_with_contacts do
      after(:create) do |u|
        create(:contact, contact_type: 'tech', user: u)
        create(:contact, contact_type: 'admin', user: u)
        create(:contact, contact_type: 'other', user: u)
      end
    end
  end
end
