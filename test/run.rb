#!/usr/bin/env ruby

# 20100222

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
end
pp switches.filename
pp switches.hostname
pp switches.application
pp switches.blessing
pp switches.secure?
pp switches.required?
pp switches.delete?
pp switches.port
pp switches.degrees
pp switches.temperature
pp switches.int
pp switches.yes_or_no?
puts
puts switches.help
puts
