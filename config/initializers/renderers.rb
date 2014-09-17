# Adds CSV Rendering Support
#
# Example:
#   respond_to do |format|
#     format.csv { render csv: @students_csv_string, :filename => 'students' }
#   end
#
ActionController::Renderers.add :csv do |obj, options|
  filename = options[:filename] || 'data'
  str = obj.respond_to?(:to_csv) ? obj.to_csv : obj.to_s
  send_data str, type: Mime::CSV, disposition: "attachment; filename=#{filename}.csv"
end
