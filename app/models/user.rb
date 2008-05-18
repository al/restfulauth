

require 'digest/sha1'

class User < ActiveRecord::Base
  attr_accessor :password  
 
  validates_presence_of :login, :email
  validates_presence_of :password, :if => Proc.new{ |p| p.new_record? || !p.password.nil?  }
  validates_presence_of :password_confirmation, :if => Proc.new{ |p| p.new_record? || !p.password.nil? }
  validates_length_of :password, :within => 8..40, :if => Proc.new{ |p| p.new_record? || !p.password.nil? }
  validates_confirmation_of :password, :if => Proc.new{ |p| p.new_record? || !p.password.nil? }
  validates_length_of :login, :within => 3..40
  validates_length_of :email, :within => 6..100
  validates_uniqueness_of :login, :email, :case_sensitive => false
  validates_format_of :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i
 
  has_many :permissions
  has_many :roles, :through => :permissions
 
  before_save :encrypt_password
  before_create :make_activation_code
  
  attr_accessible :login, :email, :password, :password_confirmation
 
  class ActivationCodeNotFound < StandardError; end
    
  class AlreadyActivated < StandardError
    attr_reader :user, :message
    
    def initialize(user, message = nil)
      @message, @user = message, user
    end
  end
  
  def self.find_and_activate!(activation_code)
    raise ArgumentError if activation_code.nil?
    user = find_by_activation_code(activation_code)
    raise ActivationCodeNotFound if !user
    raise AlreadyActivated.new(user) if user.active?
    user.send(:activate!)
    user
  end
 
  def active?
    !activated_at.nil?
  end
 
  def pending?
    @activated
  end
 
  def self.authenticate(login, password)    
    u = find :first, :conditions => ['login = ?', login]
    u && u.authenticated?(password) ? u : nil
  end
 
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end
 
  def encrypt(password)
    self.class.encrypt(password, salt)
  end
 
  def authenticated?(password)
    crypted_password == encrypt(password)
  end
 
  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end
 
  def remember_me
    remember_me_for 2.weeks
  end
 
  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end
 
  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end
 
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token = nil
    save(false)
  end
  
  def forgot_password
    @forgotten_password = true
    self.password_reset_code = self.make_password_reset_code
    self.save
  end
 
  def reset_password
    @reset_password = true
    update_attribute(:password_reset_code, nil)
  end  
 
  def recently_forgot_password?
    @forgotten_password
  end
 
  def recently_reset_password?
    @reset_password
  end
  
  def self.find_for_forget(email)
    find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email]
  end
  
  def has_role?(rolename)
    self.roles.find_by_rolename(rolename) ? true : false
  end
 
  protected
  
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
      
  def password_required?
    crypted_password.blank? || !password.blank?
  end
    
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
  end
 
  def make_password_reset_code
    Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
  end
 
  private
  
  def activate!
    @activated = true
    self.update_attribute(:activated_at, Time.now.utc)
  end    
end