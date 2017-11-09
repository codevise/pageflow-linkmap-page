(function() {
  pageflow.linkmapPage.pageConfigurationMixin = {
    initialize: function(options) {
      this.listenTo(this,
                    'change:hover_image_id',
                    function(model, imageFileId) {
                      this.triggerGenerateMaskedFile(model, imageFileId);
                    });
      this.listenTo(this,
                    'change:linkmap_color_map_image_id',
                    function(model, imageFileId) {
                      this.triggerGenerateMaskedFile(model, imageFileId);
                    });
    },

    triggerGenerateMaskedFile: function(model, imageFileId) {
      if (model.get('hover_image_id') && model.get('linkmap_color_map_image_id')) {
        generateMaskedFileWhenReady(this,
                                    model.get('hover_image_id'),
                                    model.get('linkmap_color_map_image_id'),
                                    imageFileId);
      }
      else {
        resetMaskSprite(this);
      }
    },

    linkmapPageLinks: function() {
      this._linkmapPageLinks = this._linkmapPageLinks || new pageflow.linkmapPage.PageLinksCollection({
        areas: this.linkmapAreas()
      });

      return this._linkmapPageLinks;
    },

    linkmapAreas: function() {
      var configuration = this;

      this._linkmapAreas = this._linkmapAreas || create();
      return this._linkmapAreas;

      function create() {
        var collection = new pageflow.linkmapPage.AreasCollection(
          configuration.get('linkmap_areas'),
          {
            page: configuration.page
          }
        );

        configuration.listenTo(collection, 'add remove change', function() {
          configuration.set('linkmap_areas', collection.map(function(area) {
            return _.omit(area.attributes, 'highlighted', 'editing', 'selected');
          }));
        });

        return collection;
      }
    },

    getLinkmapAreaMask: function(masks, permaId) {
      if (this.get('background_type') !== 'hover_video') {
        return masks.findByPermaId(permaId);
      }
    }
  };

  function generateMaskedFileWhenReady(configuration, hoverFileId, maskFileId, unreadyFileId) {
    var unreadyFile = pageflow.imageFiles.get(unreadyFileId);
    if (!!unreadyFile) {
      unreadyFile.stopListening(unreadyFile, 'change:state');
    }
    if (!!unreadyFile && unreadyFile.isReady()) {
      generateMaskedFile(configuration, hoverFileId, maskFileId);
    }
    else {
      if (!!unreadyFile) {
        unreadyFile.once('change:state', function() {
          generateMaskedFileWhenReady(configuration, hoverFileId, maskFileId, unreadyFileId);
        });
      }
      else {
        pageflow.imageFiles.once('change', function() {
          generateMaskedFileWhenReady(configuration, hoverFileId, maskFileId, unreadyFileId);
        });
      }
    }
  }

  function generateMaskedFile(configuration, hoverFileId, maskFileId) {
    var fileType = pageflow.editor.fileTypes
        .findByCollectionName('pageflow_linkmap_page_masked_image_files');
    var file = new fileType.model({
      state: 'processing',
      file_name: 'unused',
      parent_file_id: null,
      parent_file_model_type: null,
      hover_image_id: hoverFileId,
      mask_image_id: maskFileId
    }, {
      fileType: fileType
    });

    pageflow.entry.getFileCollection(fileType).add(file);
    file.save();
  }

  function resetMaskSprite(configuration) {
    configuration.unset('linkmap_masks');
  }
}());
