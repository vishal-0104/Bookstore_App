class UserMailer < ApplicationMailer
  default from: "kanojiavishal0401@gmail.com"

  def otp_email(user, otp)
    @user = user
    @otp = otp
    mail(to: @user.email, subject: "Your Password Reset OTP")
  end

  def password_reset_success_email(user)
    @user = user
    mail(to: @user.email, subject: "Password Reset Successful")
  end
end
