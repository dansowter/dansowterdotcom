## Mailman Guide

Mailman is an incoming mail processing microframework (with POP3 and Maildir support), that works with Rails “out of the box”. -&nbsp;Jonathan Rudenberg, author of Mailman.

I came across mailman a couple of weeks ago on [Railscasts][11], and immediately began looking for a chance to implement it in my work at [NetEngine.com.au][12]. Things set off quickly, starting with Ryan Bates’ code and ideas and going from there, but I don’t have very much experience just yet in the ruby/rails world and I quickly ran into some problems that I couldn’t just fix with a quick trip to google and stack overflow. Realising of course, that everything I’ve learned about Rails is these last couple of months since I began has come from someone who’s taken the time to put together a tutorial, I thought I should boot-up DanSowter.com and start writing something that might help the 10 people with less experience than me.

``

These are the gems you’ll need – Mail and Maildir are dependencies of Mailman, but I thought it was worth putting them here to be more aware of them, as I call them directly in tests etc.&nbsp;If we plan on approaching this process in a test-driven way (and I’ve been constantly assured we should), then we’ll need a way to load up the mailman server in test/development environments, and a way to daemonize it for staging/production environments. For that, I have ‘script/mailman_daemon’:

``

Not very much there to look at, but it does the trick, giving you start, stop, restart and run(non-daemonized) control.To see the syntax for calling these (obvious to most, I’m sure, but personally I struggled a little to see how to pass the RAILS_ENV variable to the script) have a look at the new mailman namespace in my capistrano deploy file:

``

To start it up, call ‘RAILS\_ENV=’test’ bundle exec script/mailman\_daemon run’ from your application root. Simple. From the daemon, you can see it calls ‘script/mailman_server’:

``

Which is where it gets interesting – we’re back in the core mailman functionality, instead of being lost in how to really tie it into our application. A couple of important things to note, in the boring part before the route definitions.

1.  We’re calling the rails environment BEFORE the mailman config. This lets us define the various POP3 usernames and passwords in our ‘config/initializers/constants.rb’ where they belong:
``

2.  We’re expanding everything to absolute pathnames. Try not doing this, and watch daemons try to create logs and PIDs somewhere they don’t have permission. Not fun, and it doesn’t work.
3.  Note that we’re using gmail POP3 for all our production and development stuff at this point because of the painless way google apps lets you create and nominate a catch-all address for your domain. We’re using a maildir for testing, because it gives you easier access to the raw emails if you want to see what went wrong, and because it’s quick enough that you can automate your testing. This brings us to the rspec tests:

``

It’s just a skeleton, given that I’ve stripped all of my application-specific testing from it, but I think you get the idea. Importantly, try testing the ActiveRecord changes without the ‘sleep 2′ line in your send\_test\_mail and you might pull out some hair.Now if we go back and look at the route-definitions in script/mailman_server, you can see I’ve kept them nice and clean, moving all the controller-logic into :

``

And there it is. I hope this helps someone else. Thanks very much for reading.

© 2012 [**DanSowter.com**][51] All Rights Reserved.

Theme by [**Theme Trust**][52]

 []: http://dansowter.com
 [2]: http://dansowter.com/contact/
 [3]: http://dansowter.com/about/
 [4]: http://dansowter.com/mailman-guide/
 [5]: http://dansowter.com/author/dansowter/ "Posts by dansowter"
 [6]: http://dansowter.com/category/code/ "View all posts in Code"
 [7]: http://dansowter.com/mailman-guide/#comments
 []: http://500px.com/photo/2248151
 [9]: http://500px.com/photo/2248151
 [10]: http://500px.com/jarod
 [11]: http://railscasts.com/episodes/313-receiving-email-with-mailman
 [12]: http://netengine.com.au/
 [13]: http://1.gravatar.com/avatar/ddf827b5f3033b004007e318bbbc1aa7?s=60&amp;d=http%3A%2F%2Fdansowter.com%2Fwp-content%2Fthemes%2Freveal%2Fimages%2Fdefault_avatar.png%3Fs%3D60&amp;r=G
 [14]: http://www.ncvmxvxc.com
 [15]: /mailman-guide/?replytocom=86#respond
 [16]: http://1.gravatar.com/avatar/b34f3958a543a75bb76e1d23f0f3a8b2?s=60&amp;d=http%3A%2F%2Fdansowter.com%2Fwp-content%2Fthemes%2Freveal%2Fimages%2Fdefault_avatar.png%3Fs%3D60&amp;r=G
 [17]: http://www.FLANKERSYSTEMS.COM
 [18]: /mailman-guide/?replytocom=87#respond
 [19]: http://dansowter.com/first-comment/
 [20]: /mailman-guide/?replytocom=88#respond
 [21]: http://0.gravatar.com/avatar/a4032c9ed91a94eb8d489e720e42f7f5?s=60&amp;d=http%3A%2F%2Fdansowter.com%2Fwp-content%2Fthemes%2Freveal%2Fimages%2Fdefault_avatar.png%3Fs%3D60&amp;r=G
 [22]: http://www.qoyutte.net
 [23]: /mailman-guide/?replytocom=89#respond
 [24]: http://0.gravatar.com/avatar/83b0b64cd1608d674918559582bdf75c?s=60&amp;d=http%3A%2F%2Fdansowter.com%2Fwp-content%2Fthemes%2Freveal%2Fimages%2Fdefault_avatar.png%3Fs%3D60&amp;r=G
 [25]: http://www.88news.net/forum/index.php?action=profile;u=986547
 [26]: /mailman-guide/?replytocom=98#respond
 [27]: http://1.gravatar.com/avatar/fd5c5330a82f255dddea98f070959648?s=60&amp;d=http%3A%2F%2Fdansowter.com%2Fwp-content%2Fthemes%2Freveal%2Fimages%2Fdefault_avatar.png%3Fs%3D60&amp;r=G
 [28]: http://dansowter.com/wp-includes/images/smilies/icon_smile.gif
 [29]: /mailman-guide/?replytocom=99#respond
 [30]: http://1.gravatar.com/avatar/d050bbd08194ff869406a02b84367412?s=60&amp;d=http%3A%2F%2Fdansowter.com%2Fwp-content%2Fthemes%2Freveal%2Fimages%2Fdefault_avatar.png%3Fs%3D60&amp;r=G
 [31]: /mailman-guide/?replytocom=1659#respond
 [32]: http://1.gravatar.com/avatar/debe85c12a29eab1436d74c9ca884690?s=60&amp;d=http%3A%2F%2Fdansowter.com%2Fwp-content%2Fthemes%2Freveal%2Fimages%2Fdefault_avatar.png%3Fs%3D60&amp;r=G
 [33]: /mailman-guide/?replytocom=1724#respond
 [34]: http://0.gravatar.com/avatar/86dce44d0f028a7d02954caa169d1f9d?s=60&amp;d=http%3A%2F%2Fdansowter.com%2Fwp-content%2Fthemes%2Freveal%2Fimages%2Fdefault_avatar.png%3Fs%3D60&amp;r=G
 [35]: /mailman-guide/?replytocom=1793#respond
 [36]: /mailman-guide/?replytocom=1794#respond
 []: http://dansowter.com/kony2012/
 [38]: http://dansowter.com/kony2012/ "Kony 2012"
 []: http://dansowter.com/first-comment/
 [40]: http://dansowter.com/first-comment/ "How I almost won a Diablo 3 Beta Key"
 []: http://dansowter.com/tools/
 [42]: http://dansowter.com/tools/ "The Tools"
 []: http://dansowter.com/mailman-guide/
 [44]: http://dansowter.com/mailman-guide/ "Mailman Guide"
 [45]: http://twitter.com/@dansowter
 [46]: http://dansowter.com/mailman-guide/#comment-1794
 [47]: http://dansowter.com/mailman-guide/#comment-1793
 [48]: http://dansowter.com/mailman-guide/#comment-1724
 [49]: http://dansowter.com/mailman-guide/#comment-1659
 [50]: http://dansowter.com/mailman-guide/#comment-99
 [51]: http://dansowter.com
 [52]: http://themetrust.com "Theme Trust"  