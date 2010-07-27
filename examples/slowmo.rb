#!/usr/bin/ruby

require File.join(File.dirname(__FILE__), '..', 'lib','pidfile')

p = PidFile.new
sleep 10
