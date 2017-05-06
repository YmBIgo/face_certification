class CreateUPhotos < ActiveRecord::Migration
  def self.up
    create_table :u_photos do |t|
      t.integer     :user_id, default: 0, null: false
      t.text        :azure_id
      t.text        :aws_url
      t.timestamps null: false
    end
    add_column :users, :azure_id, :text
  end
  def self.down
    drop_table :u_photos
    remove_column :users, :azure_id, :text
  end
end
