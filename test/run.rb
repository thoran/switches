#!/usr/bin/env ruby

# 20100222

# Changes: 
# 1. Added #perform and #perform method...  

require File.expand_path(File.dirname(__FILE__) + '/../lib/Switches')
require 'pp'

"-a --bless me -r --goes bang --go --an_action".split.each{|a| ARGV << a}

def an_action
  pp 'an action'
end

switches = Switches.new do |s|
  s.banner = 'Here is a banner.'
  s.set(:z, :zip, :zippy) # Switch summaries are optional.  
  s.set(:f, :file, :filename){'Optionally provide the name of a file to be read in.'}
  s.set!(:h, :host, :hostname){'The hostname switch is optional, but has a mandatory argument if used.'}
  s.required(:a, :app, :application){'Necessarily provide an application name, but an argument is optional.'}
  s.required!(:bless, :blessing){'Blessings are always necessary, yet they will always cause an argument!'}
  s.set(:s?, :sec?, :secure?){'Optionally use a secure connection.'}
  s.required(:r?, :req?, :required?){'Required?'}
  s.optional(:d?, :del?, :delete?){'Optionally delete after action?'}
  s.optional!(:p, :port, :port_number, :cast => Integer){'Otherwise use the default port and cast ye spell and turn it into an integer.'}
  s.optional!(:t, :temp, :temperature, :type => Float){'Temperature will have the type Float.'}
  s.integer(:i, :int, :default => 31){'Cast me as an int with a default value of 31.'}
  s.boolean(:yes_or_no){'This seems like a step backwards by comparison with ?-methods...'}
  s.perform(:go){pp 'go'} # This non-bang method does not require a switch value.  
  s.perform!(:goes){|value| pp value.upcase} # Bang methods do require a switch value, and if not provided the block parameter will be nil and the action will likely fail.  
  s.perform(:an_action){an_action}
end
print switches.application == nil ? '.' : 'x'
print switches.blessing == 'me' ? '.' : 'x'
print switches.required? == true ? '.' : 'x'
puts
