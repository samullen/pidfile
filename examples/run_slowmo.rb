#!/usr/bin/ruby

puts "start up a slow process. Starts and sleeps for ten"
system "./slowmo.rb &"

# give the first process time to create a lockfile
sleep 1

puts "Start up another slowmo.rb. This one should exit quickly"
system "./slowmo.rb"
puts 'exited'

