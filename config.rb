require "lib/blog_content_helpers"

helpers BlogContentHelpers

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

activate :blog do |blog|
  blog.sources = "posts/{year}-{month}-{day}-{title}.html"
  blog.permalink = "{title}.html"
  blog.default_extension = ".md"

  # Pagination
  blog.paginate = false
end

activate :directory_indexes
activate :asset_hash

configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript
end

activate :syntax, line_numbers: true
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true, tables: true
