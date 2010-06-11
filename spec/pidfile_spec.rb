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
    @pidfile = PidFile.new(:pidfile => "rspec.pid")
  end

  after(:each) do
    @pidfile.release
  end

  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
  # Builder Tests
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#

  it "should set defaults upon instantiation" do
    @pidfile.pidfile.should == "rspec.pid"
    @pidfile.piddir.should == "/tmp"
    @pidfile.pidpath.should == "/tmp/rspec.pid"
  end

  it "should create a pid file upon instantiation" do
    File.exists?(@pidfile.pidpath).should be_true
  end

  it "should create a pidfile containing same PID as process" do
    @pidfile.pid.should == Process.pid
  end

  it "should determine if pidfile exists or not" do
    @pidfile.pidfile_exists?.should be_true
  end

  it "should be able to tell if a process is running" do
    @pidfile.alive?.should be_true
  end

#   it "should remove the pidfile when the calling application exits" do
#   end

  it "should raise an error if a pidfile already exists" do
    lambda { PidFile.new(:pidfile => "rspec.pid") }.should raise_error
  end

  it "should determine if a process exists or not" do
    PidFile.running?('/tmp/rspec.pid').should be_true
    PidFile.running?('/tmp/foo.pid').should be_false
  end

  it "running? should default to certain values" do
    pf = PidFile.new
    PidFile.running?.should be_true
    pf.release
    PidFile.running?.should be_false
  end

  it "should deterimine if it's alive or not" do
    @pidfile.alive?.should be_true
    @pidfile.release
    @pidfile.alive?.should be_false
  end

  it "should remove pidfile and set pid to nil when released" do
    @pidfile.release
    @pidfile.pidfile_exists?.should be_false
    @pidfile.pid.should be_nil
  end

  it "should give a DateTime value for locktime" do
    @pidfile.locktime.should be_an_instance_of Time
  end
end
