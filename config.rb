Time.zone = "Australia/Brisbane"

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :livereload
activate :directory_indexes
activate :syntax

activate :blog do |blog|
  blog.permalink = ":title/index.html"
  blog.taglink = "tags/:tag.html"
  blog.default_extension = ".markdown"
  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"
  blog.paginate = true
  blog.per_page = 5
  blog.page_link = "page/:num"
  blog.layout = "article_layout"
end

activate :sync do |sync|
  sync.fog_provider = 'AWS'
  sync.fog_directory = 'dansowter.com'
  sync.fog_region = 'ap-southeast-2'
  sync.aws_access_key_id = ENV['AWS_ACCESS_KEY_DANSOWTER']
  sync.aws_secret_access_key = ENV['AWS_SECRET_KEY_DANSOWTER']
  sync.existing_remote_files = 'delete' # What to do with your existing remote files? ( keep or delete )
  # sync.after_build = false # Disable sync to run after Middleman build ( defaults to true )
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
end
