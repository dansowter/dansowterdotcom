---
title: Adding recent tweets to my static site with coffeescript
date: 2013-01-22 21:39 +10:00
tags: coffeescript, middleman, handlebars
---

I recently began redesigning my blog, and settled on [middleman](http://middlemanapp.com/). Things have been going swimmingly, and I'm now happily deploying with a simple "middleman sync" to S3.

Today I decided a list of my most recent tweets would help bring things to life a little, and I took it as an opportunity to get playing with [Handlebars](http://handlebarsjs.com/). We'll be using the excellent [handlebars_assets](https://github.com/leshill/handlebars_assets) gem.

The source for this blog is available [here](https://github.com/dansowter/dansowterdotcom), if I've missed something, or this all seems a bit out of context.

```ruby
## In Gemfile
gem 'handlebars_assets'

## In config.rb
env = Sprockets::Environment.new

require 'handlebars_assets'
env.append_path HandlebarsAssets.path
```

And a little date manipulation JS from a nice chap on [stackoverflow](http://stackoverflow.com/questions/1643320/get-month-name-from-date-using-javascript). Thanks [Jesper](http://stackoverflow.com/users/135589/jesper).

```javascript
Date.prototype.monthNames = [
    "January", "February", "March",
    "April", "May", "June",
    "July", "August", "September",
    "October", "November", "December"
];

Date.prototype.getMonthName = function() {
    return this.monthNames[this.getMonth()];
};
Date.prototype.getShortMonthName = function () {
    return this.getMonthName().substr(0, 3);
};
```

Then, somewhere in the sprockets manifest.. (mine is site.js.coffee)

```coffeescript
#= require handlebars
#= require date
#= require tweets
#= require_tree ./templates
```

A new 'tweets.hbs' handlebars template (mine live in javascript/templates)

```html
<div class="item">
  <div class="info">
    <div class="date">
      <h2>
        {{date}}
      </h2>
    </div>
    <div class="tags">
      {{#each tags}}
        {{this}}
      {{/each}}
    </div>
  </div>
  <div class="content">
    <h2>
      <a href="http://twitter.com/dansowter">@dansowter</a> tweeted
    </h2>
    <p>
      {{{text}}}
    </p>
  </div>
</div>
<hr/>
```
And finally, the coffeescript to hook it all up. Thanks very much to [shoogledesigns](https://github.com/shoogledesigns/embed-tweets-static-website) for the inspiration.

```coffeescript
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
```

Et voila. As always, I hope this is useful to someone with a similar challenge. I intend to do the same shortly for my public github activity, then to add a function that puts all tweets, github events and blog articles into appropriate order. To be continued...
