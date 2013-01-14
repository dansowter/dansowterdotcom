---
title: Mailman Guide
date: 2013-01-03 14:51 +10:00
tags:
---

# Mailman Guide

Mailman is an incoming mail processing microframework (with POP3 and Maildir support), that works with Rails “out of the box”. -&nbsp;Jonathan Rudenberg, author of Mailman.

I came across mailman a couple of weeks ago on [Railscasts](http://railscasts.com/episodes/313-receiving-email-with-mailman), and immediately began looking for a chance to implement it in my work at [NetEngine.com.au](http://netengine.com.au/). Things set off quickly, starting with Ryan Bates’ code and ideas and going from there, but I don’t have very much experience just yet in the ruby/rails world and I quickly ran into some problems that I couldn’t just fix with a quick trip to google and stack overflow. Realising of course, that everything I’ve learned about Rails is these last couple of months since I began has come from someone who’s taken the time to put together a tutorial, I thought I should boot-up DanSowter.com and start writing something that might help the 10 people with less experience than me.

```ruby
gem 'daemons'
gem 'mailman', require: false
gem 'maildir'
gem 'mail'
```

These are the gems you’ll need – Mail and Maildir are dependencies of Mailman, but I thought it was worth putting them here to be more aware of them, as I call them directly in tests etc.&nbsp;If we plan on approaching this process in a test-driven way (and I’ve been constantly assured we should), then we’ll need a way to load up the mailman server in test/development environments, and a way to daemonize it for staging/production environments. For that, I have ‘script/mailman_daemon’:

```ruby
#!/usr/bin/env ruby
 
require 'rubygems'
require "bundler/setup"
require 'daemons'
 
Daemons.run('script/mailman_server')
```

Not very much there to look at, but it does the trick, giving you start, stop, restart and run(non-daemonized) control.To see the syntax for calling these (obvious to most, I’m sure, but personally I struggled a little to see how to pass the RAILS_ENV variable to the script) have a look at the new mailman namespace in my capistrano deploy file:

```ruby
namespace :mailman do
  desc "Mailman::Start"
  task :start, :roles => [:app] do
    run "cd #{current_path};RAILS_ENV=#{rack_env} bundle exec script/mailman_daemon start"
  end
  
  desc "Mailman::Stop"
  task :stop, :roles => [:app] do
    run "cd #{current_path};RAILS_ENV=#{rack_env} bundle exec script/mailman_daemon stop"
  end
  
  desc "Mailman::Restart"
  task :restart, :roles => [:app] do
    mailman.stop
    mailman.start
  end
end
```

To start it up, call ‘RAILS\_ENV=’test’ bundle exec script/mailman\_daemon run’ from your application root. Simple. From the daemon, you can see it calls ‘script/mailman_server’:

```ruby
#!/usr/bin/env ruby
 
require "rubygems"
require "bundler/setup"
require "mailman"
 
ENV["RAILS_ENV"] ||= "test"
require File.dirname(__FILE__) + "/../config/environment"
 
Mailman.config.ignore_stdin = true
Mailman.config.logger = Logger.new File.expand_path("../../log/mailman_#{Rails.env}.log", __FILE__)
 
if Rails.env == 'test'
  Mailman.config.maildir = File.expand_path("../../tmp/test_maildir", __FILE__)
else
  Mailman.config.logger = Logger.new File.expand_path("../../log/mailman.log", __FILE__)
  Mailman.config.poll_interval = 15
  Mailman.config.pop3 = {
    server: 'pop.gmail.com', port: 995, ssl: true,
    username: MAILMAN_USER,
    password: MAILMAN_PASSWORD
  }
end
 
Mailman::Application.run do
  to('route_one_%interesting%@%domain%') do
    IncomingMail.new(message, params).process(:method_for_route_one)
  end
  to('someone_else@%domain%').subject('%interesting%') do
    IncomingMail.new(message, params).process(:method_for_route_two)
  end
  default do
    IncomingMail.new(message, params).process(:default)
  end
end
```

Which is where it gets interesting – we’re back in the core mailman functionality, instead of being lost in how to really tie it into our application. A couple of important things to note, in the boring part before the route definitions.

1.  We’re calling the rails environment BEFORE the mailman config. This lets us define the various POP3 usernames and passwords in our ‘config/initializers/constants.rb’ where they belong:

```ruby
if Rails.env == "production"
  MAILMAN_USER     = "something@production.com"
  MAILMAN_PASSWORD = "pasword123"
else
  MAILMAN_USER     = "something@staging.com"
  MAILMAN_PASSWORD = "password321"
end
```

2.  We’re expanding everything to absolute pathnames. Try not doing this, and watch daemons try to create logs and PIDs somewhere they don’t have permission. Not fun, and it doesn’t work.
3.  Note that we’re using gmail POP3 for all our production and development stuff at this point because of the painless way google apps lets you create and nominate a catch-all address for your domain. We’re using a maildir for testing, because it gives you easier access to the raw emails if you want to see what went wrong, and because it’s quick enough that you can automate your testing. This brings us to the rspec tests:

```ruby
require 'spec_helper'
require 'maildir'
 
def send_test_mail
  @mail = Mail.new(from: @from_address, to: @to_address, subject: @subject, body: @body)
  @sent = @maildir.add(@mail)
  sleep 2
end
 
describe ReceivedMail do
 
  before(:each) do
      @maildir = Maildir.new('tmp/test_maildir')
      @maildir.serializer = Maildir::Serializer::Mail.new
 
      @other_variable = Object.new
  end
 
  describe "Mail received by the mailman server" do
    before(:each) do
      @from_address = 'from@default.com'
      @to_address = 'to@default.com'
      @subject = 'default subject'
      @body = 'default body text'
    end
 
    it "should achieve something" do
      pending
    end
  end
end
```

It’s just a skeleton, given that I’ve stripped all of my application-specific testing from it, but I think you get the idea. Importantly, try testing the ActiveRecord changes without the ‘sleep 2′ line in your send\_test\_mail and you might pull out some hair.Now if we go back and look at the route-definitions in script/mailman_server, you can see I’ve kept them nice and clean, moving all the controller-logic into :

```ruby
class IncomingMail
  def initialize(message, params)
    @user = User.where(email: message.from).first rescue nil
    @message = message
    @params = params
  end
 
  def process(method)
    begin
      if spam_test #### this is a good place to filter unwanted mail.
        self.send method
      end
    rescue Exception => e
      Mailman.logger.error "Exception occurred while receiving message:\n#{@message}"
      Mailman.logger.error [e, *e.backtrace].join("\n")
    end
  end
 
  def spam_test
    if @user
      return true
    else
      Mailman.logger.error "Mail from #{@message.from.first} is unsolicited. Message ignored."
      return false
    end
  end
 
  def some_other_param_test(object)
    ### test
  end
 
  def default
    # create default action for emails from valid users.
    Mailman.logger.info 'Message matched the default route. Message ignored'
  end
 
  def method_for_route_one
    @interesting_param = @params[:interesting]
    if some_other_param_test(@interesting_param)
      if ## some Rails environment method
        Mailman.logger.info "#{@user.name} performed something useful."
      end
    else
      Mailman.logger.error "Something went wrong, here's useful debugging detail."
    end
  end
 
  def method_for_route_two
    @interesting_param = @params[:interesting]
    if some_other_param_test(@interesting_param)
      if ## some Rails environment method
        Mailman.logger.info "#{@user.name} performed something else."
      end
    else
      Mailman.logger.error "Something went wrong, here's another useful debugging detail."
    end
  end
end
```

And there it is. I hope this helps someone else. Thanks very much for reading.
