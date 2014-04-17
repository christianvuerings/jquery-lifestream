desc 'Creates a non-digest version of all the digested public assets'
task fix_assets: :environment do
  regexp = /(-{1}[a-z0-9]{32}*\.{1}){1}/

  assets = File.join(Rails.root, 'public', 'assets', "**/*")
  Dir.glob(assets).each do |file|
    next if File.directory? file
    next unless file =~ regexp

    source = file.split '/'
    source[source.length-1] = source[source.length-1].gsub(regexp, '.')

    non_digested = File.join source
    File.delete non_digested if File.file? non_digested
    FileUtils.cp(file, non_digested)
  end
end
