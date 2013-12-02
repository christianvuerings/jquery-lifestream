require 'java'

module ProcessControl
  extend self

  def process_map
    java_import 'sun.jvmstat.monitor.MonitoredHost'
    java_import 'sun.jvmstat.monitor.VmIdentifier'
    java_import 'sun.jvmstat.monitor.MonitoredVmUtil'
    mhost = MonitoredHost.getMonitoredHost('localhost')
    pids = mhost.activeVms()
    pids.each_with_object({}) do |pid, pid_map|
      vm = mhost.getMonitoredVm(VmIdentifier.new("//#{pid}"))
      pid_map[pid] = "#{MonitoredVmUtil.commandLine(vm)} #{MonitoredVmUtil.jvmArgs(vm)} #{MonitoredVmUtil.mainArgs(vm)}"
    end
  end

  def grep_pid(pattern)
    process_map.inject([]) do |results, key_value|
      results << key_value[0] if key_value[1] =~ pattern
      results
    end
  end

  def grep_kill(pattern, signal="TERM")
    grep_pid(pattern).each do |pid|
      # Yes, we have no logger.
      puts "Sending #{signal} to process #{pid}"
      Process.kill(signal, pid)
    end
  end

end
