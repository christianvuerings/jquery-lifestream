# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  # Rails Assets Pipeline
  watch(%r{app/assets/\w+/(.+\.(css|js|html)).*})  { |m| "/assets/#{m[2]}" }
end
