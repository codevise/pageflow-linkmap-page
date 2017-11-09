module Pageflow
  module LinkmapPage
    class CreateMaskedFileJob
      @queue = :resizing

      extend StateMachineJob

      def self.perform_with_result(masked_file, _options)
        tempfile = ::PaperclipTempfileFactory.new
        tempfile.for(masked_file.hover_image.attachment) do |hover_local_path|
          tempfile.for(masked_file.mask_image.attachment
                         .styles[:panorama_mask]) do |mask_local_path|
            masked_file.hover_local(hover_local_path)
            File.open(mask_local_path) do |mask_file|
              masked_file.attachment = mask_file
              masked_file.save!

              :ok
            end
          end
        end
      end
    end
  end
end
