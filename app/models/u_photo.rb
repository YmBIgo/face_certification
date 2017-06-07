class UPhoto < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :aws_url
end
