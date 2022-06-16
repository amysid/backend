class User < ApplicationRecord
  has_secure_password
  enum gender: ["Male", "Female"]
  enum role: ["Admin", "Approver", "operator"]
  enum status: ["Invited", "Active", "Blocked"]
  has_many :books,dependent: :destroy
  has_and_belongs_to_many :booths
  scope :active, -> { where(status: "Active")}

  after_create :send_invitation

  def accessible_features
    if self.role == "operator"
      feature = ["homes-index", "books-index", "books-show", "books-create","books-update",
                "books-setting", "books-edit", "books-destroy", "booths-index", "booths-create",
               "booths-show", "booths-edit", "booths-destroy", "booths-setting", "booths-update"]
      return feature
    elsif self.role == "Approver"
      return ["homes-index","books-index", "books-edit", "books-show", "books-update","books-setting", "books-change-status"]
    else
      return []
    end
  end

  private
  def send_invitation
    generate_verificatin_link
    UserMailer.send_invitation_link(self).deliver_now
  end

  def generate_verificatin_link
    self.reload
    token = SecureRandom.urlsafe_base64(64).gsub(/[\-_]/, "")
    self.update(verificatin_link: token)
  end

end
