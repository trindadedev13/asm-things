require "fileutils"

def run(cmd)
  puts cmd
  system(cmd) or abort("Failed #{cmd}")
end

if ARGV.length < 1
  puts "Please pass name of project."
  exit 1
end

project_name = ARGV[0];

args = [
  "-nostartfiles",
  "-nostdlib",
  "-nodefaultlibs",
  "-fPIC"
]

FileUtils.mkdir_p("build")

files = Dir.glob("#{project_name}/*")

out = "build/#{project_name}"
run("gcc #{args.join(' ')} #{files.join(' ')} -o #{out}")

home = ENV["HOME"]
home_out = "#{home}/temp/gas/#{project_name}"

FileUtils.mkdir_p(home_out)
FileUtils.cp(out, home_out)

Dir.chdir("#{home}/temp/gas/#{project_name}") do
  run("chmod +x #{project_name}")
  run("./#{project_name}")
end