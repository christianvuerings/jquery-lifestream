class ToolsController < ApplicationController

  def get_styles
    # Extract global color vars into an API endpoint for
    # consumption by the live style guide.

    colorvars = []
    style_dir = Dir.glob(Rails.root.join('app', 'assets', 'stylesheets', '*'))

    style_dir.each do |filename|
      begin
        f = File.open(filename, 'r')
        f.each_line do |line|
          if line.start_with?('$cc-color-') && line.include?('#')
            # Strip from right of semicolon in case someone adds a comment after a color
            line = line.gsub(/;.*$/,'')
            # Trim cruft and split on semicolons
            temparr = line.rstrip().delete(' ').delete('$').delete(';').split(':')
            color = {
              name: temparr[0],
              hex: temparr[1]
            }
            colorvars.push(color)
          end
        end
      rescue
        Rails.logger.warn "Exception thrown in ToolsController::get_styles: #{$!}"
      end
    end

    styles = {"colors" => colorvars}
    render :json => styles.to_json

  end
end
