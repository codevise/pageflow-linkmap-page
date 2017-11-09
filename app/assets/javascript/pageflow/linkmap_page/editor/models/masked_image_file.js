pageflow.linkmapPage.MaskedImageFile = pageflow.UploadedFile.extend({
  stages: [
    {
      name: 'processing',
      activeStates: ['processing'],
      finishedStates: ['processed'],
      failedStates: ['processing_failed']
    }
  ],

  readyState: 'processed',

  toJSON: function() {
    return _.extend(_.pick(this.attributes,
                           'rights',
                           'parent_file_id',
                           'parent_file_model_type',
                           'hover_image_id',
                           'mask_image_id'), {
                             configuration: this.configuration.toJSON()
                           });
  }
});
