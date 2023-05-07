class UserSerializer < ApplicationSerializer
  attributes :id, :full_name, :email, :mobile, :gender, :role, :status

  attribute :last_login_at do |user, _params|
    user.last_login_at.present? ? user.last_login_at.in_time_zone("Asia/Riyadh") : nil
  end
end
