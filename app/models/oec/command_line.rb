module Oec
  class CommandLine

    attr_reader :src_dir
    attr_reader :dest_dir
    attr_reader :departments
    attr_reader :is_limited_diff
    attr_reader :is_debug_mode

    def initialize
      @src_dir = get_path_arg 'src'
      @dest_dir = get_path_arg 'dest'
      options = split_csv_line ENV['options']
      @is_debug_mode = options.include? 'D'
      @is_limited_diff = options.include? 'Y'
      departments_split = split_csv_line ENV['departments']
      @departments = departments_split.empty? ? [] : Oec::DepartmentRegistry.new(departments_split).to_a
    end

    private

    def split_csv_line(comma_separated_args)
      comma_separated_args.to_s.strip.upcase.split(/\s*,\s*/).reject { |s| s.nil? || s.empty? }
    end

    def get_path_arg(arg_name)
      path = ENV[arg_name]
      return Rake.original_dir if path.blank?
      path.start_with?('/') ? path : File.expand_path(path, Rake.original_dir)
    end

  end
end
