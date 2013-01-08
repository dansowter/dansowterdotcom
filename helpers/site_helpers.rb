module SiteHelpers

  def page_title
    title = "dansowter.com"
    if data.page.title
      title << " | " + data.page.title
    end
    title
  end

  def page_description
    if data.page.description
      description = data.page.description
    else
      description = "who would read this?"
    end
    description
  end

end
