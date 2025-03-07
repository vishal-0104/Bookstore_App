require 'rails_helper'

RSpec.describe UserService do
  let(:user_params) { { name: "John", email: "john@gmail.com", password: "Password123!", mobile_number: "9876543210" } }
  let(:login_params) { { email: "john@gmail.com", password: "Password123!" } }
  let(:forget_params) { { email: "john@gmail.com" } }
  let(:reset_params) { { otp: "123456", new_password: "Newpass123!" } }
  let(:user) { create(:user, email: "john@gmail.com", password: "Password123!") }

  describe ".signup" do
    context "when user creation is successful" do
      it "returns success response" do
        result = described_class.signup(user_params)
        expect(result[:success]).to eq(true)
        expect(result[:message]).to eq("User created successfully")
        expect(result[:user]).to be_a(User)
      end
    end

    context "when user creation fails" do
      it "returns error response" do
        allow_any_instance_of(User).to receive(:save).and_return(false)
        allow_any_instance_of(User).to receive(:errors).and_return(double(full_messages: ["Email is invalid"]))
        result = described_class.signup(user_params)
        expect(result[:success]).to be_nil
        expect(result[:error]).to eq(["Email is invalid"])
      end
    end
  end

  describe ".login" do
    context "when credentials are valid" do
      before { user }

      it "returns success response with token" do
        result = described_class.login(login_params)
        expect(result[:success]).to eq(true)
        expect(result[:message]).to eq("Login successful")
        expect(result[:token]).to be_present
      end
    end

    context "when password is incorrect" do
      before { user }
      let(:invalid_login_params) { { email: "john@gmail.com", password: "wrongpass123!" } }

      it "returns error response" do
        result = described_class.login(invalid_login_params)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Wrong Password")
      end
    end

    context "when email is not registered" do
      it "returns error response" do
        result = described_class.login(email: "unknown@gmail.com", password: "Password123!")
        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Email is not registered")
      end
    end
  end

  describe ".forgetPassword" do
    context "when email is registered" do
      before { user }

      it "sends OTP and returns success response" do
        allow(UserMailer).to receive(:otp_email).and_return(double(deliver_later: true))
        result = described_class.forgetPassword(forget_params)
        expect(result[:success]).to eq(true)
        expect(result[:message]).to eq("OTP has been sent to john@gmail.com, check your inbox")
        expect(result[:user_id]).to eq(user.id)
      end
    end

    context "when email is not registered" do
      it "returns error response" do
        result = described_class.forgetPassword(email: "unknown@gmail.com")
        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Email is not registered")
      end
    end

    context "when email delivery fails" do
      before { user }

      it "returns error response" do
        allow(UserMailer).to receive(:otp_email).and_raise(StandardError.new("SMTP error"))
        result = described_class.forgetPassword(forget_params)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Failed to send OTP, please try again")
      end
    end
  end

  describe ".resetPassword" do
    let(:user_id) { user.id }

    before do
      user
      described_class.class_variable_set(:@@otp, 123456)
      described_class.class_variable_set(:@@otp_generated_at, Time.current)
    end

    context "when OTP is valid and password reset succeeds" do
      it "resets password and returns success response" do
        allow(UserMailer).to receive(:password_reset_success_email).and_return(double(deliver_later: true))
        result = described_class.resetPassword(user_id, reset_params)
        expect(result[:success]).to eq(true)
        expect(result[:message]).to eq("Password successfully reset")
        expect(user.reload.authenticate("Newpass123!")).to be_truthy
      end
    end

    context "when OTP is invalid" do
      it "returns error response" do
        result = described_class.resetPassword(user_id, otp: "999999", new_password: "Newpass123!")
        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Invalid or expired OTP")
      end
    end

    context "when OTP is expired" do
      before { described_class.class_variable_set(:@@otp_generated_at, 3.minutes.ago) }

      it "returns error response" do
        result = described_class.resetPassword(user_id, reset_params)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("Invalid or expired OTP")
      end
    end

    context "when user is not found" do
      it "returns error response" do
        result = described_class.resetPassword(999, reset_params)
        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("User not found")
      end
    end
  end
end