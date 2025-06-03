class AddStatusToRaces < ActiveRecord::Migration[7.1]
  def change
    add_column :races, :status, :string
  end
end
