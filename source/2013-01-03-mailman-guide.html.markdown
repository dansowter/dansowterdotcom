---
title: mailman-guide
date: 2013-01-03 14:51 +10:00
tags:
---

### Mailman Guide

Mailman is an incoming mail processing microframework (with POP3 and Maildir support), that works with Rails “out of the box”. -&nbsp;Jonathan Rudenberg, author of Mailman.

I came across mailman a couple of weeks ago on [Railscasts](http://railscasts.com/episodes/313-receiving-email-with-mailman), and immediately began looking for a chance to implement it in my work at [NetEngine.com.au](http://netengine.com.au/). Things set off quickly, starting with Ryan Bates’ code and ideas and going from there, but I don’t have very much experience just yet in the ruby/rails world and I quickly ran into some problems that I couldn’t just fix with a quick trip to google and stack overflow. Realising of course, that everything I’ve learned about Rails is these last couple of months since I began has come from someone who’s taken the time to put together a tutorial, I thought I should boot-up DanSowter.com and start writing something that might help the 10 people with less experience than me.

<script src="https://gist.github.com/1710103.js?file=Gemfile"></script>

These are the gems you’ll need – Mail and Maildir are dependencies of Mailman, but I thought it was worth putting them here to be more aware of them, as I call them directly in tests etc.&nbsp;If we plan on approaching this process in a test-driven way (and I’ve been constantly assured we should), then we’ll need a way to load up the mailman server in test/development environments, and a way to daemonize it for staging/production environments. For that, I have ‘script/mailman_daemon’:

<script src="https://gist.github.com/1710103.js?file=mailman_daemon.rb"></script>

Not very much there to look at, but it does the trick, giving you start, stop, restart and run(non-daemonized) control.To see the syntax for calling these (obvious to most, I’m sure, but personally I struggled a little to see how to pass the RAILS_ENV variable to the script) have a look at the new mailman namespace in my capistrano deploy file:

<script src="https://gist.github.com/1710103.js?file=deploy.rb"></script>

To start it up, call ‘RAILS\_ENV=’test’ bundle exec script/mailman\_daemon run’ from your application root. Simple. From the daemon, you can see it calls ‘script/mailman_server’:

<script src="https://gist.github.com/1710103.js?file=mailman_server.rb"></script>

Which is where it gets interesting – we’re back in the core mailman functionality, instead of being lost in how to really tie it into our application. A couple of important things to note, in the boring part before the route definitions.

1.  We’re calling the rails environment BEFORE the mailman config. This lets us define the various POP3 usernames and passwords in our ‘config/initializers/constants.rb’ where they belong:

<script src="https://gist.github.com/1710103.js?file=constants.rb"></script>

2.  We’re expanding everything to absolute pathnames. Try not doing this, and watch daemons try to create logs and PIDs somewhere they don’t have permission. Not fun, and it doesn’t work.
3.  Note that we’re using gmail POP3 for all our production and development stuff at this point because of the painless way google apps lets you create and nominate a catch-all address for your domain. We’re using a maildir for testing, because it gives you easier access to the raw emails if you want to see what went wrong, and because it’s quick enough that you can automate your testing. This brings us to the rspec tests:

<script src="https://gist.github.com/1710103.js?file=incoming_mail_spec.rb"></script>

It’s just a skeleton, given that I’ve stripped all of my application-specific testing from it, but I think you get the idea. Importantly, try testing the ActiveRecord changes without the ‘sleep 2′ line in your send\_test\_mail and you might pull out some hair.Now if we go back and look at the route-definitions in script/mailman_server, you can see I’ve kept them nice and clean, moving all the controller-logic into :

<script src="https://gist.github.com/1710103.js?file=incoming_mail.rb"></script>

And there it is. I hope this helps someone else. Thanks very much for reading.
