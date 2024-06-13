class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :start
      t.datetime :end
      t.integer :event_type
      t.text :notes
      t.references :property, foreign_key: true
      t.references :user, foreign_key: true


      t.timestamps
    end
  end
end
