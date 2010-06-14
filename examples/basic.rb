#!/usr/bin/ruby

require File.join(File.dirname(__FILE__), '..', 'lib','pidfile')

PidFile.new unless PidFile.running?
PidFile.new

puts p.pidfile
puts p.piddir
puts p.pid
puts p.pidpath

gets
