class VPhoto < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :aws_url
end
