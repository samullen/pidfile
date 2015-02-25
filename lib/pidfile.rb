class PidFile
  attr_reader :pidfile, :piddir, :pidpath

  class DuplicateProcessError < RuntimeError; end

  VERSION = '0.3.0'

  DEFAULT_OPTIONS = {
    :pidfile => File.basename($0, File.extname($0)) + ".pid",
    :piddir => '/var/run',
  }

  def initialize(*args)
    opts = {}

    #----- set options -----#
    case
    when args.length == 0 then
    when args.length == 1 && args[0].class == Hash then
      arg = args.shift

      if arg.class == Hash
        opts = arg
      end
    else
      raise ArgumentError, "new() expects hash or hashref as argument"
    end

    opts = DEFAULT_OPTIONS.merge opts

    @piddir     = opts[:piddir]
    @pidfile    = opts[:pidfile]
    @pidpath    = File.join(@piddir, @pidfile)
    @fh         = nil

    #----- Does the pidfile or pid exist? -----#
    if self.pidfile_exists?
      if self.class.running?(@pidpath)
        raise DuplicateProcessError, "Process (#{$0} - #{self.class.pid(@pidpath)}) is already running."
        
        exit! # exit without removing the existing pidfile
      end

      self.release
    end

    #----- create the pidfile -----#
    create_pidfile

    at_exit { release }
  end

  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
  # Instance Methods
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#

  # Returns the PID, if any, of the instantiating process
  def pid
    return @pid unless @pid.nil?

    if self.pidfile_exists?
      @pid = open(self.pidpath, 'r').read.to_i
    else
      @pid = nil
    end
  end

  # Boolean stating whether this process is alive and running
  def alive?
    return false unless self.pid && (self.pid == Process.pid)

    self.class.process_exists?(self.pid)
  end

  # does the pidfile exist?
  def pidfile_exists?
    self.class.pidfile_exists?(pidpath)
  end

  # unlock and remove the pidfile. Sets pid to nil
  def release
    unless @fh.nil?
      @fh.flock(File::LOCK_UN)
      remove_pidfile
    end
    @pid = nil
  end

  # returns the modification time of the pidfile
  def locktime
    File.mtime(self.pidpath)
  end

  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#
  # Class Methods
  #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=#

  # Return the default pidfile path
  def self.default_pidfile
    File.join(DEFAULT_OPTIONS[:piddir], DEFAULT_OPTIONS[:pidfile])
  end

  # Returns the PID, if any, of the instantiating process
  def self.pid(path=nil)
    path ||= default_pidfile
    if pidfile_exists?(path)
      open(path, 'r').read.to_i
    end
  end

  # class method for determining the existence of pidfile
  def self.pidfile_exists?(path=nil)
    path ||= default_pidfile

    File.exists?(path)
  end

  # boolean stating whether the calling program is already running
  def self.running?(path=nil)
    calling_pid = nil
    path ||= default_pidfile

    if pidfile_exists?(path)
      calling_pid = pid(path)
    end

    process_exists?(calling_pid)
  end

private

  # Writes the process ID to the pidfile and defines @pid as such
  def create_pidfile
    # Once the filehandle is created, we don't release until the process dies.
    @fh = open(self.pidpath, "w")
    @fh.flock(File::LOCK_EX | File::LOCK_NB) || raise
    @pid = Process.pid
    @fh.puts @pid
    @fh.flush
    @fh.rewind
  end

  # removes the pidfile.
  def remove_pidfile
    File.unlink(self.pidpath) if self.pidfile_exists?
  end

  def self.process_exists?(process_id)
    begin
      Process.kill(0, process_id)
      true
    rescue Errno::ESRCH, TypeError # "PID is NOT running or is zombied
      false
    end
  end
end
