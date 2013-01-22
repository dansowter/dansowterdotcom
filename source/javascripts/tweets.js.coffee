$ ->
  user = "dansowter"
  $.getJSON "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=" + user + "&include_rts=1&callback=?", (data) ->
    displayTweet tweet for tweet in data

displayTweet = (tweet) ->
  data =
    text: replaceMentions(addLinks(tweet.text))
    date: formatDate(tweet.created_at)
    tags: grabTags(tweet.text)

  html = HandlebarsTemplates['templates/tweet'](data)
  $("#tweets").append(html)

formatDate = (timestamp) ->
  date = new Date(timestamp)
  "#{date.getShortMonthName()} #{date.getDate()}"

addLinks = (text) ->
  text.replace /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig, (url) ->
    "<a target=\"_blank\" href=\"#{url}\">#{url}</a>"

replaceMentions = (text) ->
  text.replace /@([_a-z0-9]+)/ig, (mention) ->
    "<a href=\"http://twitter.com/" + mention.substring(1) + "\">" + mention + "</a>"

grabTags = (text) ->
  text.match(/#([_a-z0-9]+)/ig)
