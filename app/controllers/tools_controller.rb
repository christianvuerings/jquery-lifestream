class ToolsController < ApplicationController

  def get_file_as_string(filename)
    data = ''
    f = File.open(filename, "r")
    f.each_line do |line|
      data += line
    end
    return data
  end

  def get_styles
    colorvars = []
    data = get_file_as_string(Rails.root.join('app', 'assets', 'stylesheets', 'calcentral.scss'))

    # Convert string data into a single row; remove everything before and after markers
    data = data.gsub(/\n/,'')
    data = data.sub(/^.*START SASS COLOR VARS/, '')
    data = data.sub(/END SASS COLOR VARS.*$/, '')

    # Remove last line and Split on semicolons
    temparr = data.split(';')
    temparr = temparr[0..-2]

    # Push each k/v par onto an array
    temparr.each do |color|
      kv = color.delete(' ').delete('$').split(":")
      color = {"name" => kv[0], "hex" => kv[1]}
      colorvars.push(color)
    end
    styles = {"colors" => colorvars}

    render :json => styles.to_json
  end
end
