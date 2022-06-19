class UserSerializer < ApplicationSerializer
  attributes :id, :full_name, :email, :mobile, :gender, :role, :status, :last_login_at
end
