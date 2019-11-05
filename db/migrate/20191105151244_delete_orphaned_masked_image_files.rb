# Following the previous migration (20190724114801) this also deletes
# MaskedImageFiles which had either their source image file or their color map
# file deleted.
class DeleteOrphanedMaskedImageFiles < ActiveRecord::Migration[5.2]
  def up
    Pageflow::LinkmapPage::MaskedImageFile.find_each do |masked_image_file|
      next if masked_image_file.source_image_file.present? &&
              masked_image_file.color_map_file.present?

      page_config = Pageflow::Page
                    .where(template: 'linkmap_page')
                    .where('configuration like ?',
                           "%_image_id\":#{masked_image_file.id}%")

      masked_image_file.destroy unless page_config.exists?
    end
  end
end
