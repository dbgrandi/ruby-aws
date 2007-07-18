# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'optparse'
require 'highline'
require 'ruby-aws'
require 'amazon/util/user_data_store'

module Amazon
module WebServices
module Util

class CommandLine

  SDKS = ['Mechanical Turk']

  MISSING_AUTH = "You are missing authentication information required to utilize Amazon Web Services.  You will now be prompted for your <%= color('Access Key ID',BOLD) %> and your <%= color('Secret Access Key',BOLD) %>.  If you do not have this information, please log into http://www.amazonaws.com/  \n\n"
  RESUME_AUTH = "Authentication information has been initialized.  Continuing... \n\n"

  MAIN_HELP = <<EOF

This is the <%= color('RubyAWS', RED, BOLD) %> Command Line Application's Interactive mode.
You got here by typing:

  <%= color('$ ruby-aws',GREEN) %>

This application currently supports the following functionality:

<%= list( ['Amazon Web Services Authentication Configuration'] ) %>
You can also invoke this tool with commandline parameters.  For more information:

  <%= color('$ ruby-aws --help',GREEN) %>

Thanks for using Amazon Web Services!

EOF

  def initialize( interactive = true )
    @interactive = interactive
    @h = HighLine.new
    @h.wrap_at = :auto
    @store = Amazon::Util::UserDataStore.new :AWS
    HighLine.use_color = useColor?
    HighLine.track_eof = false # disabling because it misbehaves
  end

  def checkAuthConfig
    if @store.get(:Auth,:AccessKeyId).nil? or @store.get(:Auth,:SecretAccessKey).nil?
      @h.say MISSING_AUTH
      getAuthConfig
      @h.say RESUME_AUTH
    end
  end

  def getAuthConfig( default={} )
    id = @h.ask( 'What is your Access Key ID?' ) {|q| q.validate = /^[A-Z0-9]{20}$/ ; q.default = authId.to_s ; q.first_answer = default[:ID] }
    key = @h.ask( 'What is your Secret Access Key?' ) {|q| q.validate = /^[\w\/+]{40}$/ ; q.default = authKey.to_s ; q.first_answer = default[:Key] }

    @store.set(:Auth,:AccessKeyId,id)
    @store.set(:Auth,:SecretAccessKey,key)
    @store.save
  rescue
    raise "Unable to retrieve authentication information from the Console"
  end

  def authKey
    @store.get(:Auth,:SecretAccessKey)
  end
  def authId
    @store.get(:Auth,:AccessKeyId)
  end

  def useColor?
    if @store.get(:Misc,:ColorTerminal).nil?
      if @interactive and @h.agree( "Should the console application use color? (y/n)" )
        @store.set(:Misc,:ColorTerminal,true)
      else
        @store.set(:Misc,:ColorTerminal,false)
      end
      @store.save
    end
    return @store.get(:Misc,:ColorTerminal)
  end

  def toggleColor
    value = !useColor?
    @store.set(:Misc,:ColorTerminal,value)
    HighLine.use_color = value
  end

  def default_menu
    loop do
      @h.choose do |menu|
        menu.header = "\n" + @h.color('RubyAWS',HighLine::BOLD,HighLine::RED) + " " + @h.color('Command Line Application',HighLine::BOLD) + " " + @h.color('[Interactive Mode]',HighLine::GREEN,HighLine::BOLD)
        menu.select_by = :index
        menu.choice( 'Configure Amazon Web Services Authentication' ) do
          if @h.agree( "\nCurrent ID: #{@h.color(authId,HighLine::BOLD)}\nCurrent Key: #{@h.color(authKey,HighLine::BOLD)}\nDo you want to change?" )
            getAuthConfig
          end
        end
        menu.choice( 'Toggle Color' ) { toggleColor }
        menu.choice( :help ) do
          @h.say MAIN_HELP
        end
        menu.choice( 'Save and Quit' ) { @store.save ; exit }
        menu.prompt = "\nWhat would you like to do? "
      end
    end
  end

  def parseOptions
    res = {}
    opts = OptionParser.new

    opts.on( '-i', '--interactive', 'Load Interactive Mode' ) { res[:Interactive] = true }
    opts.on( '-a', '--authenticate', 'Configure Authentication Options' ) { res[:Auth] = true }
    opts.on( '--id=ID', 'Set Access Key ID (requires "-a")' ) { |id| res[:ID] = id }
    opts.on( '--key=KEY', 'Set Secret Access Key (requires "-a")' ) { |key| res[:Key] = key }

    begin
      opts.parse(ARGV)
      raise "-i and -a are exclusive options.  Please pick one." if res[:Interactive] and res[:Auth]
      raise "--id requires -a" if res[:ID] and !res[:Auth]
      raise "--key requires -a" if res[:Key] and !res[:Auth]
      res[:Mode] = res[:Auth] ? :Auth : :Interactive
    rescue => e
      p e.message
    end
    res
  end

  def run

    opts = parseOptions

    case opts[:Mode]
    when :Interactive

      @h.say "\n<%= color('Welcome to',BOLD) %> <%= color('RubyAWS #{RubyAWS::VERSION}',BOLD,RED) %>"
      @h.say "This version includes SDK extensions for: <%= list (#{SDKS.inspect}.collect {|a| color(a,BOLD)}), :inline, ' and ' %>\n\n"

      checkAuthConfig

      default_menu
    when :Auth

      getAuthConfig( :Key => opts[:Key], :ID => opts[:ID] )

    end
  end

end

end # Amazon::WebServices::Util
end # Amazon::WebServices
end # Amazon::WebServices
