require 'pageflow/linkmap_page/engine'
require 'paperclip_tempfile_factory'

module Pageflow
  module LinkmapPage
    def self.plugin
      LinkmapPage::Plugin.new
    end

    def self.page_type
      LinkmapPage::PageType.new
    end
  end
end
