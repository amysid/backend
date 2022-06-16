class UserMailer < ApplicationMailer
  def send_invitation_link user
    @user = user
    mail(:to=> @user.email,:subject=> t("invitation_link"))
  end
end
