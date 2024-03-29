require_relative "external_content"

module BlogContentHelpers
  def blog_content
    (blog.articles + external_content).sort_by(&:date).reverse
  end

  def external_content
    data.external_content.map { |attributes| ExternalContent.new(attributes) }
  end

  def external_content_note(article)
    if article.url.include? "robots.thoughtbot.com"
      "Written on Giant Robots"
    end
  end

  def external_content_icon(article)
    if article.url.include? "robots.thoughtbot.com"
      image_tag "robots.png"
    end
  end

  def featured_url(article)
    return unless article.respond_to? :featured_url

    article.featured_url
  end
end
