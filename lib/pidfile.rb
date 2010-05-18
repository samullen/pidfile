class PidFile
  attr_accessor :pidfile, :piddir

  VERSION = '0.0.1'

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

    create_pidfile
  end

  # Returns the fullpath to the file containing the process ID (PID)
  def pidpath
    File.join(@piddir, @pidfile)
  end

  # Returns the PID of the currently running process
  def pid
    return @pid unless @pid.nil?

    begin
      @pid = open(self.pidpath, 'r').read.to_i
    rescue Errno::EACCES => e
      STDERR.puts "Error: unable to open file #{self.pidpath} for reading:\n\t"+
        "(#{e.class}) #{e.message}"
      exit!
    rescue => e
    end

    @pid
  end

#----- needs to be a class instance method too -----#
  def running?
  end

  def alive?
    begin
      Process.kill(0, self.pid)
      true
    rescue Errno::ESRCH, TypeError # "PID is NOT running or is zombied
      false
    rescue Errno::EPERM
      STDERR.puts "No permission to query #{pid}!";
    rescue => e
      STDERR.puts "(#{e.class}) #{e.message}:\n\t" <<
        "Unable to determine status for #{pid}."
    end
  end

  def exists?
    File.exists? pidpath
  end

  def release
  end

  def terminate
    unless self.pid
      STDERR.puts "pidfile #{self.pidpath} does not exist. Daemon not running?\n"
      return # not an error in a restart
    end

    begin
      while true do
        Process.kill("TERM", self.pid)
        sleep(0.1)
      end
    rescue Errno::ESRCH # gets here when there is no longer a process to kill
    rescue => e
      STDERR.puts "unable to terminate process: (#{e.class}) #{e.message}"
      exit!
    end
  end

  def locktime
    File.mtime(self.pidpath)
  end

# can I add an END block here?

private

  # Writes the process ID to the pidfile and defines @pid as such
  def create_pidfile
    begin
      open(self.pidpath, "w") do |f|
        @pid = Process.pid
        f.puts @pid
      end
    rescue => e
      STDERR.puts "Error: Unable to open #{self.pidpath} for writing:\n\t" +
        "(#{e.class}) #{e.message}"
      exit!
    end
  end

  # removes the pidfile. 
  def remove_pidfile
    begin
      File.unlink(self.pidpath)
    rescue => e
      STDERR.puts "ERROR: Unable to unlink #{self.pidpath}:\n\t" +
        "(#{e.class}) #{e.message}"
      exit
    end
  end

end
