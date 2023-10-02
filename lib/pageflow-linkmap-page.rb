require 'pageflow/linkmap_page/engine'
require 'pageflow/linkmap_page/version'

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
