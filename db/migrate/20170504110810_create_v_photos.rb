class CreateVPhotos < ActiveRecord::Migration
  def self.up
    create_table :v_photos do |t|
      t.integer     :user_id, default: 0, null: false
      t.text        :azure_id
      t.text        :aws_url
      t.boolean     :identical_or_not, default: false, null: false
      t.timestamps null: false
    end
    add_column :users, :valid_user_or_not, :boolean, null: false, default: false
    add_column :users, :user_authenticate_user_or_not, :boolean, null: false, default: false
  end
  def self.down
    drop_table :v_photos
    remove_column :users, :valid_user_or_not, :boolean
    remove_column :users, :user_authenticate_user_or_not, :boolean
  end
end
