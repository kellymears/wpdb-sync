# typed: true

require 'date'
require 'paint'

class Tasks
  def initialize dir, origin, destination, search, replace
    @dir         = dir
    @origin      = origin
    @destination = destination
    @search      = search
    @replace     = replace

    self
  end

  def start
    label "\nRunning DB sync"
    puts "#{ @origin } ➡️  #{ @destination }\n"

    self
  end

  def chDir
    label "Check if working directory is accessible"

    !File.exist? @dir do
      fail "Directory either doesn't exist or can't be traversed."
    end

    success "Directory is accessible."
    Dir.chdir(@dir)

    self
  end

  def checkOriginAlias
    label "Checking #{ @origin } cli alias"

    if !system "wp #{ @origin } option get home &>/dev/null"
      fail "wp-cli #{ @origin } alias not found."
    end

    success "#{ @origin } alias found."
    self
  end

  def checkDestinationAlias
    label "Checking #{ @destination } cli alias"

    if !system "wp #{ @destination } option get home &>/dev/null"
      fail "#{ @destination } alias not found."
    end

    success "#{ @destination } alias found."
    self
  end

  def exportDB
    label "Exporting #{ @destination } database"

    if !system "wp #{ @destination } db export &>/dev/null"
      fail "Error exporting #{ @destination } database."
    end

    success "#{ @destination } database exported"

    self
  end

  def resetDB
    label "Resetting #{ @destination } database"

    if !system "wp #{ @destination } db reset --yes &>/dev/null"
      fail "Error resetting development database."
    end

    success "#{ @destination } database reset."

    self
  end

  def importDB
    label "Importing #{ @origin } database"

    if system "wp #{ @origin } db export - | wp #{ @destination } db import - &>/dev/null"
      success "#{ @origin } database imported to #{ @destination }."
    else
      fail "Error importing #{ @origin } database to #{ @destination }."
    end

    self
  end

  def replace log = false
    label "Replacing '#{ @search }' with '#{ @replace }' on #{ @destination }"

    if log
      logFile = DateTime.now.strftime "db-search-replace-%y-%m-%Y-%H-%M.log"
      log = "--log=#{ logFile }"
    else
      log = ""
    end

    if system "wp #{ @destination } search-replace '#{ @search }' '#{ @replace }' --recurse-objects --all-tables --report-changed-only #{ log }"
      success "Search-replace operation complete. 🕵️‍"
    else
      fail "Error replacing #{ @search } with #{ @replace } strings."
    end

    if logFile
      success "Log written to #{ @dir }/#{ @logFile } 📃"
    end


    self
  end

  def flushRocketCache
    label "Checking if wp-rocket is active on #{ @destination }"
    if system "wp #{ @destination } plugin is-active wp-rocket &>/dev/null"
      success "WP Rocket cache detected"

      label "Regenerating wp-rocket configuration"
      if system "wp #{ @destination } rocket regenerate --file=config &>/dev/null"
        success "#{ @destination } wp-rocket configuration regenerated successfully"
      else
        error "Error regenerating wp-rocket configuration."
      end

      label "Regenerating advanced-cache"
      if system "wp #{ @destination } rocket regenerate --file=advanced-cache &>/dev/null"
        success "#{ @destination } advanced-cache regenerated successfully"
      else
        error "Error regenerating wp-rocket configuration."
      end

      label "Flushing #{ @destination } wp-rocket cache."
      if system "wp #{ @destination } rocket clean --confirm &>/dev/null"
        success "#{ @destination } wp-rocket cache cleared."
      else
        error "There was an error clearing the wp-rocket cache on #{ @destination }"
      end

      label "Preloading wp-rocket cache on #{ @destination }"
      if system "wp #{ @destination } rocket preload &>/dev/null"
        success "#{ @destination } wp-rocket preload initiated."
      else
        error "There was an error preloading the wp-rocket cache on #{ @destination }"
      end
    else
      info "WP Rocket plugin not activated. Skipping WP Rocket tasks."
    end

    self
  end

  def flushObjectCache
    label "Flushing #{ @destination } object cache"
    if system "wp #{ @destination } cache flush &>/dev/null"
      success "#{ @destination } object cache cleared."
    end

    self
  end

  def healthCheck
    label "Checking #{ @destination } database health"
    if system "wp #{ @destination } db check &>/dev/null"
      success "#{ @destination } database is responding normally."
    else
      fail "#{ @destination } database is inaccessible."
    end

    self
  end

  def cleanComments
    label "Cleaning #{ @destination } comments table of spam 🧹"

    if system "wp #{ @destination } comment list --format=ids --status=spam | xargs -I{} wp #{ @destination } comment delete {} --quiet &>/dev/null"
      success "#{ @destination } comments cleanup complete. ✨"
    else
      success "#{ @destination } has no spam comments to delete. ✨"
    end

    self
  end

  def optimize
    label "Optimizing #{ @destination } database tables"

    if system "wp #{ @destination } db optimize --quiet &>/dev/null"
      success "#{ @destination } database tables optimized"
    else
      fail "#{ @destination } database could not be optimized."
    end

    self
  end

  def synopsis
    puts Paint["\n\nTasks complete! 💜\n", :green]

    puts "Origin\n"
    system "wp #{ @origin } db size --all-tables"
    system "wp #{ @origin } db tables --all-tables"

    puts "\nDestination\n"
    system "wp #{ @destination } db size --all-tables"
    system "wp #{ @destination } db tables --all-tables"

    self
  end

  def info message
    puts Paint["\n     #{ message }\n", :white]
  end

  def label message
    puts "\n#{ Paint[message, :cyan] }\n"
  end

  def success message
    puts Paint["\n     ✅ #{ message }\n", :green]
  end

  def fail message
    abort Paint["\n     ❗#{ message }\n", :red]
  end
end
