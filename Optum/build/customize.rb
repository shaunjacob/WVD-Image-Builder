require 'json'

ARGV.each do |file|
  unless File.readable?(file)
    puts 'usage: customize.rb <json_file> <customization script>'
    exit(1)
  end
end

tpl = File.read(ARGV[0])
json_tpl = JSON.parse(tpl)
customization_script = File.read(ARGV[1])

customize_task = {
  type: 'PowerShell',
  name: 'OptumServeCustomizations',
  runElevated: true,
  inline: customization_script.split("\n")
}

# Add script as inline customize task to JSON template
json_tpl['resources'][0]['properties']['customize'] << customize_task

File.write(ARGV[0], JSON.pretty_generate(json_tpl))
