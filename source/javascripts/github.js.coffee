$ ->
  $.get 'https://api.github.com/users/dansowter/events/public', (data) ->
    displayPush public_event for public_event in data
    $('.github').fadeIn()


displayPush = (public_event) ->
  if public_event.type == "PushEvent"
    console.log public_event
    date = new Date(public_event.created_at)
    date_string = "#{date.getShortMonthName()} #{date.getDate()}"
    data =
      type: public_event.type
      date: date_string
      repo: public_event.repo.name
      commits: prettyCommits(public_event.payload.commits)

    html = HandlebarsTemplates['templates/push'](data)
    window.insertContentWithTimestamp(html, date)

prettyCommits = (commits) ->
  for commit in commits
    prettyCommit =
      message: commit.message
      sha: commit.sha.slice(0,6)
      url: webCommitUrl(commit.url)

webCommitUrl = (string) ->
  string.replace(/api.github.com\/repos/, "github.com").replace /commits/, "commit"
