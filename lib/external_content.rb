class ExternalContent
  attr_reader :title, :date, :url, :featured_url, :featured_text

  def initialize(attributes)
    @title = attributes.fetch(:title)
    @date = attributes.fetch(:date)
    @url = attributes.fetch(:url)
    @featured_url = attributes[:featured_url]
    @featured_text = attributes[:featured_text]
  end
end
