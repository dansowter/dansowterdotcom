Time.zone = "Australia/Brisbane"

set :markdown, :layout_engine => :erb,
               :tables => true,
               :autolink => true,
               :smartypants => true

activate :livereload
activate :directory_indexes

activate :blog do |blog|
  blog.permalink = ":title/index.html"
  blog.taglink = "tags/:tag.html"
  blog.layout = "layout"
  blog.default_extension = ".markdown"
  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"
  blog.paginate = true
  blog.per_page = 5
  blog.page_link = "page/:num"
end

page "/feed.xml", :layout => false

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :cache_buster
  activate :relative_assets
end
