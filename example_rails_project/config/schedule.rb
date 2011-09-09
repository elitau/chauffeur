# every 3.hours do
#   runner "MyModel.some_process"       
#   rake "my:rake:task"                 
#   command "/usr/bin/my_great_command"
# end
# 
every 1.day, :at => '6:30 am' do 
  runner "Subscription.rebill_subscriptions"
end
# 
# every :hour do # Many shortcuts available: :hour, :day, :month, :year, :reboot
#   runner "SomeModel.ladeeda"
# end
# 
# every :sunday, :at => '12pm' do # Use any day of the week or :weekend, :weekday 
#   runner "Task.do_something_great"
# end
# 
# every '0 0 27-31 * *' do
#   command "echo 'you can use raw cron syntax too'"
# end
