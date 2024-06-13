class CreateJoinTableForPropertiesAndEvents < ActiveRecord::Migration[5.2]
  def change
  	create_join_table :events, :properties do |t|
      t.index [:event_id, :property_id]
    end
  end
end
