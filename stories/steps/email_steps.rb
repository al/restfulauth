

steps_for(:email) do
  Given 'a working email system' do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  
  Then '$object should be emailed' do |object|
    response.should send_email
  end
end