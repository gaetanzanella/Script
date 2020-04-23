
# usage ruby deploy_prod.rb -v=X.X.X

VERSION_REGEX = /(\d+\.\d+\.\d+)/

def spec_file
      Dir.glob('*.podspec')[0]
    end

def version_from_file
  raise NotfoundSpecFileError if Dir.glob('*.podspec').empty?
  File.read(spec_file())[VERSION_REGEX]
end

def spec_file
  Dir.glob('*.podspec')[0]
end

def replace(old, new)
  content = File.read(spec_file())
  File.open(spec_file(), "w"){|f| f.write(content.sub(old, new)) }
end

def system_cmd(command)
  puts command
  system command
end

def commit(version)
  return unless File.directory?(".git")
  system_cmd("git add --update #{spec_file()} && git commit -m 'Bump to #{version}'")
  system_cmd("git tag #{version}")
end

def push(version)
    system_cmd("git push origin HEAD:master")
    system_cmd("git push origin #{version}")
end

def publish()
    system_cmd("pod trunk push #{spec_file()} --allow-warnings")
end

args = Hash[ ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
version = args["v"]

if (version.nil?)
    puts "Specify pod version"
    return
end

if (`git rev-parse --abbrev-ref HEAD`.strip! != "master")
    puts "Checkout master"
    return
end

puts "Bumping #{version_from_file()} to #{version}…"
replace(version_from_file(), version)
commit(version)
print "Should push? (y/n)"
if (STDIN.gets.strip != "y")
    return
end
puts "Pushing tag #{version} & master…"
push(version)
print "Should publish? (y/n)"
if (STDIN.gets.strip != "y")
    return
end
puts "Publishing #{version}…"
publish()
