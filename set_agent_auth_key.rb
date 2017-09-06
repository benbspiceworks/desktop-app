# encoding: utf-8
#!/usr/bin/env ruby
# Copyright © 2017 Spiceworks, Inc.  All Rights Reserved.  http://www.spiceworks.com
AGENT_KEY = ARGV[0]
$version = "1"
def eputs(m); puts "Error: #{m}"; exit 1; end  # print error and exit
def dbg(m); puts "Debug: #{m}" if $verbose; end  # print optional debug message

# make sure that we have GEM_HOME set properly
unless ENV['GEM_HOME']
  p = File.expand_path('../pkg')
  p = '/Program Files/Spiceworks/pkg' unless File.directory?(p)
  p = '/Program Files (x86)/Spiceworks/pkg' unless File.directory?(p)
  if File.directory?(p)
    ENV['GEM_HOME'] = p
    dbg "Set GEM_HOME to '#{ENV['GEM_HOME']}'"
  else
    eputs "You must set GEM_HOME to proceed - normally this is your Spiceworks intallation directory / pkg"
  end
end

require 'fileutils'
require 'active_record'
require 'logger'

def eputs(m); puts "Error: #{m}"; exit! 1; end  # print error and exit

# Make a timestamp for filenames
$timestamp = Time.now.strftime("%d%b%Y_%H_%M_%S")

#Logging section, comment out if not needed (along with all $log calls)    
$log = Logger.new("../log/sqlchange#{$timestamp}.log") 
$log.info "all tasks should have stopped"

Dir.chdir '../db' 

#Open DB
ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => 'spiceworks_prod.db'
)
#Method to make Changes
def insert_configuration_changes(value, configvalue)
  present = ActiveRecord::Base.connection.execute("SELECT * FROM 'configuration' WHERE name = '#{configvalue}'")
  $log.info "before changes"
  $log.info present
    if present.empty?
      $log.info "record does not exist, creating"
      ActiveRecord::Base.connection.execute("INSERT INTO 'configuration' ('name', 'value', 'updated_at') VALUES('#{configvalue}', '#{value}', '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}')")
        present2 = ActiveRecord::Base.connection.execute("SELECT * FROM 'configuration' WHERE name = '#{configvalue}'")
      $log.info present2
      else
      $log.info "changing existing record"
      ActiveRecord::Base.connection.execute("UPDATE 'configuration' SET value = '#{value}', updated_at = '#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}' WHERE id = '#{present[0]['id']}'")
      present3 = ActiveRecord::Base.connection.execute("SELECT * FROM 'configuration' WHERE name = '#{configvalue}'")
      $log.info present3
    end 
end

#Changes to be made
$log.info "Adding/updating remote agent key"
insert_configuration_changes(AGENT_KEY, "remote_agent_key")
$log.info "Done updating remote agent key"

$log.info "All Finished!"

# End modification section
ActiveRecord::Base.connection.disconnect!
puts "Changes have been completed"
