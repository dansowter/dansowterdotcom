#= require handlebars
#= require date
#= require tweets
#= require_tree ./templates

@insertContentWithTimestamp = (content, timestamp) ->
  $(".item").filter ->
    elementTimestamp = new Date($(this).data("timestamp"))
    elementTimestamp < new Date(timestamp)
  .first().before(content)
