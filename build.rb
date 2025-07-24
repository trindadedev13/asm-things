require "fileutils"

def run(cmd)
  puts cmd
  system(cmd) or abort("Failed #{cmd}")
end

if ARGV.length < 1
  puts "Please pass name of project."
  exit 1
end

project_name = ARGV[0]
project_path = "#{project_name}"
build_dir = "build/#{project_name}"
output_exe = "#{build_dir}/#{project_name}"

# create build dir
FileUtils.mkdir_p(build_dir)

# list all .S
asm_files = Dir.glob("#{project_path}/*.S")

# compile .S to .o
obj_files = asm_files.map do |f|
  obj = "#{build_dir}/" + File.basename(f, ".S") + ".o"
  run("as #{f} -o #{obj}")
  obj
end

# link
run("ld #{obj_files.join(" ")} -o #{output_exe}")

# copy to home
home = ENV["HOME"]
home_out = "#{home}/temp/gas/#{project_name}"

FileUtils.mkdir_p(home_out)
FileUtils.cp(output_exe, home_out)

# run at home
Dir.chdir(home_out) do
  run("chmod +x #{project_name}")
  run("./#{project_name}")
end