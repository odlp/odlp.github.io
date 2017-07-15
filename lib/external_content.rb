class ExternalContent
  attr_reader :title, :date, :url

  def initialize(attributes)
    @title = attributes.fetch(:title)
    @date = attributes.fetch(:date)
    @url = attributes.fetch(:url)
  end
end
