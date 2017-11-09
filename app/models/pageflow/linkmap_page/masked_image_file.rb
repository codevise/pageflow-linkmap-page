module Pageflow
  module LinkmapPage
    class MaskedImageFile < ActiveRecord::Base
      include ::Pageflow::UploadedFile
      belongs_to :hover_image, class_name: '::Pageflow::ImageFile'
      belongs_to :mask_image, class_name: '::Pageflow::ImageFile'
      attr_reader :hover_local_path

      state_machine initial: 'not_processed' do
        extend StateMachineJob::Macro

        state 'not_processed'
        state 'processing'
        state 'processed'

        event :process do
          transition 'not_processed' => 'processing'
          transition 'processing_failed' => 'processing'
        end

        job CreateMaskedFileJob do
          on_enter 'processing'
          result ok: 'processed'
          result error: 'processing_failed'
        end
      end

      def url
        attachment.url if attachment.present?
      end

      def original_url
        url
      end

      def palette_colors
        %i(F65B57 4B0905 902E28 F4C8C3 893E2C 472114
           FF7E4B 775241 B4805C EEBE9A 9B6419 DBA85B 0C0904 BF8103
           F1AB1F AA9B71 F6D96F F2DD91 FBF6DA 6A5D09 FFE739 9BA351
           222512 555941 D5EB8D D4F586 436B32 9BFF8C 4DC943 167814
           003B0C 69A77B A8E9BF 88F7E9 515454 33ECF9 B6F7FE C1EAFF
           4CB0F1 3083EC 1C56D1 292F79 545AA6 8984D2 050317 1E123C
           E3D7FA 8732AD CD5DFA E8B6FB A598A8 521151 A43099 7A3571
           EE6ED1 7B536D FFBFE0 302A2D AF8191 F3DAE1 FEA0A5 D87778)
      end

      def palette_color_strings
        palette_colors.map(&:to_s)
      end

      STYLES ||= lambda do |attachment|
        panorama_format =
          File.extname(attachment.original_filename) == '.png' ? :PNG : :JPG
        hover_width = attachment.instance.hover_image.width
        hover_height = attachment.instance.hover_image.height
        geometry = hover_width.to_s + 'x' + hover_height.to_s + '^'
        standard_style = { geometry: geometry, format: panorama_format }
        palette_colors = attachment.instance.palette_colors
        styles = {}

        palette_colors.each do |color|
          styles[color] = standard_style.merge(
            convert_options: lambda do |_instance|
              imagemagick_color = '#' + color.to_s.downcase
              hover_local_path = attachment.instance.hover_local_path

              "-fill black +opaque '#{imagemagick_color}' "\
            "-fill white -opaque '#{imagemagick_color}' -size '#{geometry}' "\
            "tile:'#{hover_local_path}' -compose Multiply -composite -transparent black"
            end
          )
        end

        styles
      end

      has_attached_file(:attachment,
                        Pageflow.config.paperclip_s3_default_options
                          .merge(default_url: ':pageflow_placeholder',
                                 styles: STYLES))

      do_not_validate_attachment_file_type(:attachment)

      def unprocessed_attachment
        mask_image.attachment
      end

      def retry!
        process!
      end

      def publish!
        process!
      end

      def retryable?
        processing_failed?
      end

      def ready?
        processed?
      end

      def basename
        'unused'
      end

      def hover_local(path)
        @hover_local_path = path
      end
    end
  end
end
