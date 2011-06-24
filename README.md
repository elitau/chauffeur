chauffeur - Jenkins jobs in ruby

### Introduction
chauffeur is a whenever like tool to describe your reoccuring jobs in ruby and run them via the Jenkins/Hudson CI server. It's aimed to be compatible with the whenever syntax to describe your jobs. Inspired by <http://fourkitchens.com/blog/2010/05/09/drop-cron-use-hudson-instead> and <http://github.com/javan/whenever>

### Installation
  
    $ gem install chauffeur

Or with Bundler in your Gemfile.

    gem 'chauffeur', :require => false
 
### Getting started

    $ cd /my/rails/app
    $ rake chauffeur:bootstrap

This will create an initial "config/schedule.rb" file you.


### Example schedule.rb file
  
    every 3.hours do
      runner "MyModel.some_process"       
      rake "my:rake:task"                 
      command "/usr/bin/my_great_command"
    end

    every 1.day, :at => '4:30 am' do 
      runner "MyModel.task_to_run_at_four_thirty_in_the_morning"
    end

    every :hour do # Many shortcuts available: :hour, :day, :month, :year, :reboot
      runner "SomeModel.ladeeda"
    end

    every :sunday, :at => '12pm' do # Use any day of the week or :weekend, :weekday 
      runner "Task.do_something_great"
    end

    every '0 0 27-31 * *' do
      command "echo 'you can use raw cron sytax too'"
    end

More examples on the wiki: <http://wiki.github.com/elitau/chauffeur/instructions-and-examples>


### How it works
 - write your config/schedule.rb
 - on deployment with capistrano the jobs will be pushed (async) to jenkins over its API
 
### TODOs
 - read schedule.rb
 - convert schedule.rb task to jenkins config files
 - push jenkins config files to a jenkins server
 - setup a Vagrant VM with jenkins to test pushes
 - 

### License

Copyright (c) 2011 Eduard Litau

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

