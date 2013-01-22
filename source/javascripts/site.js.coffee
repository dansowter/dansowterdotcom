#= require handlebars
#= require date
#= require tweets
#= require_tree ./templates

$ ->
  $("#nav-toggle").click ->
    $("nav").slideToggle()

#   $.get 'https://api.github.com/users/dansowter/events/public', (data) ->
#     PlotEvent public_event for public_event in data

# PlotEvent = (public_event) ->
#   date = new Date(public_event.created_at)
#   date_string = "#{date.getShortMonthName()} #{date.getDate()}"
  
#   data =
#     type: public_event.type
#     date: date_string

#   html = HandlebarsTemplates['templates/event'](data)
#   $("#github").append(html)
