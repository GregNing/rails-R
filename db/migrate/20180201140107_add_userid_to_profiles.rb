class AddUseridToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :user_id, :integer, :index => true
  end
end
