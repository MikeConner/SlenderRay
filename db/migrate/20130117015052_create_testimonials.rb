class CreateTestimonials < ActiveRecord::Migration
  def change
    create_table :testimonials do |t|
      t.text :comment, :null => false
      t.date :date_entered
      t.boolean :displayable, :default => true
      
      t.references :patient
      
      t.timestamps
    end
  end
end
