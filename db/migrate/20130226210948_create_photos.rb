class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :title, :limit => Photo::MAX_TITLE_LEN
      t.string :caption
      t.string :facility_image
      t.references :treatment_facility

      t.timestamps
    end
  end
end
