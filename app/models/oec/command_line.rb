module Oec
  class CommandLine

    attr_reader :src_dir
    attr_reader :dest_dir
    attr_reader :departments
    attr_reader :is_debug_mode

    def initialize
      @src_dir = get_path_arg 'src'
      @dest_dir = get_path_arg 'dest'
      @is_debug_mode = ENV['debug'].to_s =~ /true/i
      split = ENV['departments'].to_s.strip.upcase.split(/\s*,\s*/).reject { |s| s.nil? || s.empty? }
      @departments = split.empty? ? [] : Oec::DepartmentRegistry.new(split).to_a
    end

    private

    def get_path_arg(arg_name)
      path = ENV[arg_name]
      return Rake.original_dir if path.blank?
      path.start_with?('/') ? path : File.expand_path(path, Rake.original_dir)
    end

  end
end
