class RemoveDefaultOnUsername < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:users, :username, nil)
    change_column_default(:users, :email, nil)

    remove_index :users, :username
    add_index :users, :uid, unique: true
  end
end
