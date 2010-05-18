require File.join(File.dirname(__FILE__), '..', 'lib','pidfile')

describe PidFile do
  before(:all) do
#     basedir        = File.dirname(__FILE__)
#     @example_files = Hash.new
# 
#     @example_files[:halloween] = File.join(basedir, "files/halloween2009.puz")
#     @example_files[:crnet]     = File.join(basedir, "files/crnet100306.puz")
#     @example_files[:tmcal]     = File.join(basedir, "files/tmcal100306.puz")
#     @example_files[:xp]        = File.join(basedir, "files/xp100306.puz")
#     @example_files[:ydx]       = File.join(basedir, "files/ydx100515.puz")
  end

  before(:each) do
    @pidfile = PidFile.new
  end

#   after(:each) do
#   end

  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
  # Builder Tests
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#

  it "should set defaults upon instantiation" do
    @pidfile.pidfile.should == "spec.pid"
    @pidfile.piddir.should == "/tmp"
    @pidfile.pidpath.should == "/tmp/spec.pid"
  end

  it "should create a pid file upon instantiation" do
    File.exists?(@pidfile.pidpath).should be_true
  end

  it "should create a pidfile containing same PID as process" do
    @pidfile.pid.should == Process.pid
  end

  it "should determine if pidfile exists or not" do
    @pidfile.exists?.should be_true
  end

  it "should be able to tell if a process is running" do
    @pidfile.alive?.should be_true
  end
end
