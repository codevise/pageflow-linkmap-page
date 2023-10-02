require 'pageflow-external-links'
require 'paperclip'

require 'pageflow/linkmap_page/paperclip_processors/colors'
require 'pageflow/linkmap_page/paperclip_processors/color_mask'
require 'pageflow/linkmap_page/paperclip_processors/invoke_callback'
require 'pageflow/linkmap_page/paperclip_processors/image_dimensions'

module Pageflow
  module LinkmapPage
    class Engine < Rails::Engine
      isolate_namespace Pageflow::LinkmapPage

      config.i18n.load_path += Dir[config.root.join('config', 'locales', '**', '*.yml').to_s]

      if Rails.respond_to?(:autoloaders)
        lib = root.join('lib')

        config.autoload_paths << lib
        config.eager_load_paths << lib

        initializer 'pageflow_linkmap_page.autoloading' do
          Rails.autoloaders.main.ignore(
            lib.join('generators'),
            lib.join('pageflow-linkmap-page.rb'),
            lib.join('pageflow/linkmap_page/paperclip_processors'),
            lib.join('pageflow/linkmap_page/version.rb')
          )
        end
      else
        config.autoload_paths << File.join(config.root, 'lib')
      end

      initializer 'pageflow_linkmap_page.paperclip' do
        Paperclip.configure do |config|
          config.register_processor(:pageflow_linkmap_page_image_colors,
                                    Pageflow::LinkmapPage::PaperclipProcessors::Colors)

          config.register_processor(:pageflow_linkmap_page_color_mask,
                                    Pageflow::LinkmapPage::PaperclipProcessors::ColorMask)

          config.register_processor(:pageflow_linkmap_page_invoke_callback,
                                    Pageflow::LinkmapPage::PaperclipProcessors::InvokeCallback)

          config.register_processor(:pageflow_linkmap_page_image_dimensions,
                                    Pageflow::LinkmapPage::PaperclipProcessors::ImageDimensions)
        end
      end

      config.generators do |g|
        g.test_framework :rspec,:fixture => false
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
        g.assets false
        g.helper false
      end

      initializer 'pageflow_linkmap_page.paperclip' do
        Paperclip::DataUriAdapter.register
      end
    end
  end
end
