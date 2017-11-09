class PaperclipTempfileFactory
  def for(attachment, &block)
    tempfile = Paperclip.io_adapters.for(attachment)
    begin
      yield(tempfile.path)
    ensure
      tempfile.close
      tempfile.unlink
    end
  end
end
