class CreateMaskedImageFiles < ActiveRecord::Migration
  def change
    create_table :pageflow_linkmap_page_masked_image_files do |t|
      t.belongs_to(:entry, index: true)
      t.string(:state)
      t.string(:rights)
      t.string(:attachment_file_name)
      t.string(:attachment_content_type)
      t.integer(:attachment_file_size, limit: 8)
      t.datetime(:attachment_updated_at)
      t.belongs_to :hover_image
      t.belongs_to :mask_image
      t.column :parent_file_id, :integer
      t.column :parent_file_model_type, :string
      t.index [:parent_file_id, :parent_file_model_type],
              name: 'index_masked_image_files_on_parent_id_and_parent_model_type'
    end
  end
end
