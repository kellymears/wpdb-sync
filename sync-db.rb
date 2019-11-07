#!/usr/bin/env ruby
# typed: true

require 'date'
require 'paint'
require 'fileutils'
require 'json'

require_relative "wpdb-sync/util"
require_relative "wpdb-sync/tasks"

if ARGV[0]=="help"
  help
end

if ARGV[0]=="new"
  site = ARGV[1]
  root = ARGV[2]
  development = ARGV[3]
  staging = ARGV[4]
  production = ARGV[5]

  newSite site, root, development, staging, production

  exit true
end

if !(ARGV[0] && ARGV[1] && ARGV[2])
  if !ARGV[0]
    "missing required argument: site"
  end

  if !ARGV[1]
    "missing required argument: origin"
  end

  if !ARGV[2]
    "missing required argument: destination"
  end

  exit false
end

site        = ARGV[0]
origin      = ARGV[1]
destination = ARGV[2]
config      = readConfig site

search = config["#{ origin }"]
  .gsub("[[bucket]]", site.gsub(".", "-"))

replace = config["#{ destination }"]
  .gsub("[[bucket]]", site.gsub(".", "-"))

tasks = Tasks.new config["root"], "@#{ origin }", "@#{ destination }", search, replace

tasks
  .start                 # setup class operations * REQUIRED
  .chDir                 # change dir to site root * REQUIRED
  .checkOriginAlias      # make sure origin cli alias is available
  .checkDestinationAlias # make sure destination cli alias is available
  .exportDB              # create backup of destination db
  .resetDB               # reset destination db
  .importDB              # import origin db to destination
  .replace               # do search & replace operation (pass @param bool true to log results)
  .cleanComments         # clean comments of spam
  .optimize              # optimize database
  .healthCheck           # make sure database is still accessible
  .flushRocketCache      # flush/preload page cache; regenerate wp-rocket-config/advanced-cache.php; * PLUGIN-SPECIFIC
  .flushObjectCache      # flush wordpress object cache
  .synopsis              # display synopsis of the state of both db tables for a quick sanity check

exit true
