class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :v_photos
  has_many :u_photos

  def full_name
    return "#{self.family_name}#{self.first_name}"
  end

  def full_name?
    unless self.full_name == ""
      return true
    else
      return false
    end
  end

end
