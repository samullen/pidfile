#!/usr/bin/ruby

require File.join(File.dirname(__FILE__), '..', 'lib','pidfile')

p = PidFile.new unless PidFile.running?

puts p.pidfile
puts p.piddir
puts p.pid
puts p.pidpath

gets
