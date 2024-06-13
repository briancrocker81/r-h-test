class UserMailer < ApplicationMailer

  def temp_password(id, password)
    @user = User.find_by(id: id)
    @password = password
    mail(to: @user.email, subject: "Login access credentials!")
  end

end
