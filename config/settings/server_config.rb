require 'lib/calcentral_config'

module ServerConfig
  extend self

  def get_settings(source_file)

    if File.exists?(source_file)
      source = YAML.load(ERB.new(IO.read(source_file.to_s)).result)
    end
    source ||= false

    settings = CalcentralConfig.deep_open_struct(source)
    settings
  end
end
