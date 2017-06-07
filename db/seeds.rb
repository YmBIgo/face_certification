# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.first_or_create(email: "hogehoge@hoge.com", password: "hogehoge", family_name: "sample", first_name: "taro")

# //image-boardd-development.s3.amazonaws.com/uploads/ad4626a9-0c88-414c-afae-6f8c9bf28fd2/clinton1.jpeg
# //image-boardd-development.s3.amazonaws.com/uploads/531fe7f9-07ba-4120-b97a-af310fa3b459/clinton2.jpeg
# //image-boardd-development.s3.amazonaws.com/uploads/38a2a926-f734-4741-b6b5-f9cabbfc7f18/clinton3.jpeg
# //image-boardd-development.s3.amazonaws.com/uploads/eaa9a4c5-c3e1-4ffe-bc87-a1a9ca27f575/clinton4.jpeg
# //image-boardd-development.s3.amazonaws.com/uploads/c9470c0a-b4b3-4420-a200-0abadad3b316/clinton5.jpeg

aws_array =
  ["//image-boardd-development.s3.amazonaws.com/uploads/05ca3036-dc3c-4c8a-9753-988317226744/kazuya_kurihara1.jpg",
  "//image-boardd-development.s3.amazonaws.com/uploads/844538a7-e07f-41b0-8a7c-f1876ddb2ad7/kazuya_kurihara3.png",
  "//image-boardd-development.s3.amazonaws.com/uploads/c463ac27-4d6e-4f70-9304-110d22edcde7/kazuya_kurihara8.jpg",
  "//image-boardd-development.s3.amazonaws.com/uploads/d2ebe44f-cd91-4a6c-b5cf-11cc65c71452/kazuya_kurihara4.JPG",
  "//image-boardd-development.s3.amazonaws.com/uploads/010bb4b4-7bf3-4b78-a081-7c019c309278/kazuya_kurihara9.jpg"]

aws_array.each do |a_url|
  unless UPhoto.where(user_id: user.id, aws_url: a_url).present?
    UPhoto.create(user_id: user.id, aws_url: a_url)
  end
end


