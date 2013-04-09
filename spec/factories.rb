
FactoryGirl.define do
  factory :membership do |m|
    m.user { |u| u.association(:user)}
    m.group { |g| g.association(:group)}
  end

  factory :user do
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    password 'password'
    after(:build) do |user|
      user.generate_username
    end
  end

  factory :admin_user, class: User do
    sequence(:email) { Faker::Internet.email }
    sequence(:name) { Faker::Name.name }
    password 'password'
    is_admin {true}
    after(:build) do |user|
      user.generate_username
    end
  end

  factory :group do
    sequence(:name) { Faker::Name.name }
    description 'A description for this group'
    viewable_by :everyone
  end

  factory :discussion do
    association :author, :factory => :user
    group
    title Faker::Lorem.sentence(2)
    description 'A description for this discussion'
    after(:build) do |discussion|
      discussion.group.parent.add_member!(discussion.author) if discussion.group.parent
      discussion.group.add_member!(discussion.author)
    end
    after(:create) do |discussion|
      discussion.group.save
    end
  end

  factory :comment do
    user
    association :commentable, factory: :discussion
    title Faker::Lorem.sentence(2)
    body 'body of the comment'

    after(:build) do |comment|
      comment.discussion.group.parent.add_member!(comment.user) if comment.discussion.group.parent
      comment.discussion.group.add_member!(comment.user)
    end
    after(:create) do |comment|
      comment.discussion.group.save
    end
  end

  factory :motion do
    sequence(:name) { Faker::Name.name }
    association :author, :factory => :user
    phase 'voting'
    description 'Fake description'
    discussion
    after(:build) do |motion|
      motion.group.parent.add_member!(motion.author) if motion.group.parent
      motion.group.add_member!(motion.author)
    end
    after(:create) do |motion|
      motion.group.save
    end
  end

  factory :motion_read_log do
    user
    motion
  end

  factory :vote do
    user
    motion
    position Vote::POSITIONS.sample
    after(:build) do |vote|
      vote.motion.group.add_member!(vote.user)
    end
    after(:create) do |vote|
      vote.motion.group.save
    end
  end

  factory :group_request do
    sequence(:admin_name) { Faker::Name.name }
    admin_email Faker::Internet.email
    country_name "nz"
    sectors ["community"]
    name Faker::Name.name
    description "MyText"
    expected_size 50
    cannot_contribute false
  end

  factory :invitation do
    recipient_email { Faker::Internet.email }
    association :inviter, factory: :user
  end
end
