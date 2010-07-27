require File.join(File.dirname(__FILE__), '..', 'lib','pidfile')

describe PidFile do
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

  it "should secure pidfiles left behind and recycle them for itself" do
    @pidfile.release
    fakepid = 99999999 # absurd number
    open("/tmp/foo.pid", "w") {|f| f.puts fakepid }
    pf = PidFile.new(:pidfile => "foo.pid")
    PidFile.pid(pf.pidpath).should == Process.pid
    pf.should be_an_instance_of PidFile
    pf.pid.should_not == fakepid
    pf.pid.should be_a_kind_of Integer
    pf.release
  end

  it "should create a pid file upon instantiation" do
    File.exists?(@pidfile.pidpath).should be_true
  end

  it "should create a pidfile containing same PID as process" do
    @pidfile.pid.should == Process.pid
  end

  it "should know if pidfile exists or not" do
    @pidfile.pidfile_exists?.should be_true
    @pidfile.release
    @pidfile.pidfile_exists?.should be_false
  end

  it "should be able to tell if a process is running" do
    @pidfile.alive?.should be_true
  end

  it "should remove the pidfile when the calling application exits" do
    fork do
      exit
    end
    PidFile.pidfile_exists?.should be_false
  end

  it "should raise an error if a pidfile already exists" do
    lambda { PidFile.new(:pidfile => "rspec.pid") }.should raise_error
  end

  it "should know if a process exists or not - Class method" do
    PidFile.running?('/tmp/rspec.pid').should be_true
    PidFile.running?('/tmp/foo.pid').should be_false
  end

  it "should know if it is running - Class method" do
    pf = PidFile.new
    PidFile.running?.should be_true
    pf.release
    PidFile.running?.should be_false
  end

  it "should know if it's alive or not" do
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
