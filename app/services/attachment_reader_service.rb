class AttachmentReaderService
  require 'open-uri'

  class << self
    def read(url)
      new(url: url).to_s
    end
  end

  def initialize(url:)
    @url = url
  end

  def to_s
    return opened.string if opened.is_a?(StringIO)

    File.read(opened)
  end

  private

  def opened
    open(@url)
  end
end
