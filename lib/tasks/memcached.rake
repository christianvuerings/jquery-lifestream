require 'calcentral_config'
require 'net/telnet'
require 'date'
require 'pp'

namespace :memcached do

  desc 'Fetch memcached stats from all cluster nodes'
  task :get_stats do
    hosts = ENV['hosts']
    if hosts.blank?
      config = CalcentralConfig.load_settings
      if config && config.cache && config.cache.servers
        hosts = config.cache.servers
      end
    else
      hosts = hosts.split ','
    end

    hosts.each do |host|
      host_tuple = host.split(':')
      hostname = host_tuple.first
      port = host_tuple[1] if host_tuple.size > 1
      port ||= 11211

      raw_stats = {}
      begin
        connected_host = Net::Telnet::new("Host" => "#{hostname}", "Port" => "#{port}", "Timeout" => 3)
        connected_host.cmd("String" => "stats", "Match" => /^END/) do |c|
          matches = c.gsub("STAT ", "").split(/\r?\n/)
          matches.slice!(-1)
          matches = matches.map { |match| match.strip.split ' ' }.flatten
          raw_stats = Hash[*matches]
        end
        connected_host.close
      rescue Exception => e
        p "ERROR: Unable to connect to #{hostname}:#{port} - #{e}"
      end
      if raw_stats

        stats = {
          :host => "#{hostname}:#{port}",
          up_since: DateTime.strptime(raw_stats["time"], "%s").advance(seconds: "-#{raw_stats["uptime"]}".to_i).iso8601,
          total_gets: raw_stats["cmd_get"],
          total_writes: raw_stats["cmd_set"],
          evictions: raw_stats["evictions"],
          get_hits: "#{raw_stats["get_hits"]}",
          get_hit_percentage:"0.00%",
          get_missess: "#{raw_stats["get_misses"]}",
          get_miss_percentage:"0.00%"
        }
        if raw_stats["cmd_get"].to_i > 0
          stats.merge!({
            get_hit_percentage:"#{"%0.2f" % (raw_stats["get_hits"].to_i * 100/raw_stats["cmd_get"].to_i)}%",
            get_miss_percentage:"#{"%0.2f" % (raw_stats["get_misses"].to_i * 100/raw_stats["cmd_get"].to_i)}%"
          })
        end
        pp stats
      end
    end

  end

  desc 'Reset memcached stats from all cluster nodes'
  task :clear_stats do
    hosts = ENV['hosts']
    if hosts.blank?
      config = CalcentralConfig.load_settings
      if config && config.cache && config.cache.servers
        hosts = config.cache.servers
      end
    else
      hosts = hosts.split ','
    end

    hosts.each do |host|
      host_tuple = host.split(':')
      hostname = host_tuple.first
      port = host_tuple[1] if host_tuple.size > 1
      port ||= 11211

      begin
        connected_host = Net::Telnet::new("Host" => "#{hostname}", "Port" => "#{port}", "Timeout" => 3)
        connected_host.cmd "String" => "stats reset", "Match" => /^RESET/
        p "Reset stats on #{hostname}:#{port}"
      rescue Exception => e
        p "ERROR: Unable to connect to #{hostname}:#{port} - #{e}"
      end
    end
  end

  desc 'Invalidate all memcached keys from all cluster nodes'
  task :empty do
    hosts = ENV['hosts']
    if hosts.blank?
      config = CalcentralConfig.load_settings
      if config && config.cache && config.cache.servers
        hosts = config.cache.servers
      end
    else
      hosts = hosts.split ','
    end

    hosts.each do |host|
      host_tuple = host.split(':')
      hostname = host_tuple.first
      port = host_tuple[1] if host_tuple.size > 1
      port ||= 11211

      begin
        connected_host = Net::Telnet::new("Host" => "#{hostname}", "Port" => "#{port}", "Timeout" => 3)
        connected_host.cmd "String" => "flush_all", "Match" => /^OK/
        p "Cache flushed on #{hostname}:#{port}"
      rescue Exception => e
        p "ERROR: Unable to connect to #{hostname}:#{port} - #{e}"
      end
    end
  end
end