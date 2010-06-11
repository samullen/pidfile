class PidFile
  attr_accessor :pidfile, :piddir

  VERSION = '0.1.0'

  DEFAULT_OPTIONS = {
    :pidfile => File.basename($0, File.extname($0)) + ".pid",
    :piddir => '/tmp',
  }

  def initialize(*args)
    opts = {}

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
    @fh         = nil

    create_pidfile

    at_exit { release }
  end

  # Returns the fullpath to the file containing the process ID (PID)
  def pidpath
    File.join(@piddir, @pidfile)
  end

  # Returns the PID, if any, of the currently running process
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

  def release
    unless @fh.nil?
      @fh.flock(File::LOCK_UN)
      remove_pidfile
    end
    @pid = nil
  end

  def locktime
    File.mtime(self.pidpath)
  end

  # class method for determining the existence of pidfile
  def self.pidfile_exists?(path=nil)
    path ||= File.join(DEFAULT_OPTIONS[:piddir], DEFAULT_OPTIONS[:pidfile])

    File.exists?(path)
  end

  # boolean stating whether the calling process is already running
  def self.running?(path=nil)
    path ||= File.join(DEFAULT_OPTIONS[:piddir], DEFAULT_OPTIONS[:pidfile])

    if pidfile_exists?(path)
      pid = open(path, 'r').read.to_i
    else
      pid = nil
    end

    return false unless pid && (pid != Process.pid)

    process_exists?(pid)
  end

private

  # Writes the process ID to the pidfile and defines @pid as such
  def create_pidfile
    @fh = open(self.pidpath, "w")
    @fh.flock(File::LOCK_EX | File::LOCK_NB) || raise
    @pid = Process.pid
    @fh.puts @pid
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
