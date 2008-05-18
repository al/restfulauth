

class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    subject('Account Activation')
    body[:activate_url] = "http://localhost:3001/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    subject('Your Account has been Activated!')
    body[:login_url] = 'http://localhost:3001/'
  end
  
   def forgot_password(user)
     setup_email(user)
     subject('Reset your Password?')
     body[:reset_url] = "http://localhost:3001/reset_password/#{user.password_reset_code}"
   end
  
   def reset_password(user)
     setup_email(user)
     subject('Your Password has been Reset')
   end
  
  protected
  
  def setup_email(user)
    recipients(user.email)
    from('admin@domain.tld')
    sent_on(Time.now)
    body[:user] = user
  end
end