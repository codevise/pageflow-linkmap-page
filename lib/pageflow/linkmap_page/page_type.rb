module Pageflow
  module LinkmapPage
    class PageType < Pageflow::PageType
      name 'linkmap_page'

      def file_types
        [LinkmapPage.masked_image_file_type]
      end

      def view_helpers
        [AreasHelper]
      end

      def thumbnail_candidates
        [
          {attribute: 'thumbnail_image_id', file_collection: 'image_files'},
          {attribute: 'panorama_image_id', file_collection: 'image_files'},
          {attribute: 'panorama_video_id', file_collection: 'video_files'}
        ]
      end
    end

    def self.masked_image_file_type
      FileType.new(model: MaskedImageFile,
                   custom_attributes: [:hover_image_id, :mask_image_id])
    end
  end
end
