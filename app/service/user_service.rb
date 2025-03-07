class UserService
  def self.signup(user_params)
    user = User.new(user_params)
    if user.save
      { success: true, message: "User created successfully", user: user }
    else
      { error: user.errors.full_messages }
    end
  end

  def self.login(login_params)
    user = User.find_by(email: login_params[:email])
    if user
      if user.authenticate(login_params[:password])
        token = JsonWebToken.encode(name: user.name, email: user.email)
        { success: true, message: "Login successful", token: token }
      else
        { success: false, error: "Wrong Password" }
      end
    else
      { success: false, error: "Email is not registered" }
    end
  end

  def self.forgetPassword(forget_params)
    user = User.find_by(email: forget_params[:email])
    return { success: false, error: "Email is not registered" } unless user

    @@otp = rand(100000..999999) # Generate 6-digit OTP
    @@otp_generated_at = Time.current

    begin
      UserMailer.otp_email(user, @@otp).deliver_later # Send OTP email asynchronously
      { success: true, message: "OTP has been sent to #{user.email}, check your inbox", user_id: user.id }
    rescue StandardError => e
      Rails.logger.error "Failed to send OTP: #{e.message}"
      { success: false, error: "Failed to send OTP, please try again" }
    end
  end

  def self.resetPassword(user_id, reset_params)
    user = User.find_by(id: user_id)
    return { success: false, error: "User not found" } unless user

    # Validate OTP
    if reset_params[:otp].to_i != @@otp || (Time.current - @@otp_generated_at > 2.minutes)
      return { success: false, error: "Invalid or expired OTP" }
    end

    if user.update(password: reset_params[:new_password])
      @@otp = nil
      @@otp_generated_at = nil
      UserMailer.password_reset_success_email(user).deliver_later # Notify user
      { success: true, message: "Password successfully reset" }
    else
      { success: false, error: user.errors.full_messages }
    end
  end

  private
  @@otp = nil
  @@otp_generated_at = nil
end

