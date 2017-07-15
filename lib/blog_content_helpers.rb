require_relative "external_content"

module BlogContentHelpers
  def blog_content
    (blog.articles + external_content).sort_by(&:date).reverse
  end

  def external_content
    data.external_content.map { |attributes| ExternalContent.new(attributes) }
  end
end
