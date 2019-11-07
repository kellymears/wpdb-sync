# typed: true

require 'fileutils'
require 'json'

def help
  print "  \nWPDB Sync\n\n"

  print "  Configure:\n"
  print "    ./wpdb-sync new mysite.io /user/[username]/sites/mysite.io http://mysite.vagrant https://staging.mysite.io https://cdn.mysite.io\n"
  print "  Run:\n"
  print "    ./sync mysite.io development staging\n\n"

  print "  Arguments:\n"
  print "    - [site] site domain and tld\n"
  print "    - [from] wp-cli alias of data origin\n"
  print "    - [to]   wp-cli alias of data destination\n"

  exit true
end

def newSite site, siteRoot, development, staging, production
  configDir = "#{ ENV["HOME"] }/.config/wpdb-sync"
  configFile = "#{ configDir }/#{ site }"

  configContent = {
    :root        => siteRoot,
    :development => development,
    :staging     => staging,
    :production  => production,
  }

  if !Dir.exists?(configDir)
    FileUtils.mkdir_p(configDir)
  end

  if !File.exists?(configFile)
    FileUtils.touch(configFile)
  end

  File.open(configFile, "w") do |file|
    file.write configContent.to_json
  end

  exit true
end

def getSite site
  configDir = "#{ ENV["HOME"] }/.config/wpdb-sync"
  configFile = "#{ configDir }/#{ site }"

  return JSON.parse(File.read(configFile))
end
