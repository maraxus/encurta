class ShortUrl
  def initialize(raw_url)
    @url       = raw_url
    @short_url = nil
  end
  attr_reader :url, :short_url
end
