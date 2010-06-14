#!/usr/bin/ruby

require File.join(File.dirname(__FILE__), '..', 'lib','pidfile')

if PidFile.running?
  exit
end

p = PidFile.new

puts p.pidfile
puts p.piddir
puts p.pid
puts p.pidpath
