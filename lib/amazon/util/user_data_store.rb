# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'amazon/util/data_reader'

module Amazon
module Util

# The UserDataStore is a platform-independent class intended to store application configuration information in a human-readable per-user location.
class UserDataStore

  def initialize(app_name)
    @app = sanitizeKey(app_name)
    @base = findBaseStore(@app)
    @dirty = []
    @data = Hash.new {|h,a| h[a] = {} }
    loadConfig
  end

  def get(namespace,property)
    ns = sanitizeKey(namespace)
    @data[ns][property]
  end

  def set(namespace,property,value)
    ns = sanitizeKey(namespace)
    @dirty << ns unless @dirty.member? ns
    @data[ns][property] = value
  end

  def clear(namespace,property = nil)
    ns = sanitizeKey(namespace)
    @dirty << ns unless @dirty.member? ns
    if property.nil?
      @data[ns] = {}
    else
      @data[ns].delete_if {|k,v| k == property }
    end
  end

  def save
    @dirty.delete_if do |name|
      saveNamespace( name )
    end
  end

  private

  def loadConfig
    Dir.open(@base).each do |filename|
      next if filename =~ /^\./
      loadNamespace( filename )
    end
  end
 
  def sanitizeKey(ns)
    ns.to_s.downcase
  end

  def loadNamespace(name)
    @data[name] = DataReader.load( File.join( @base, name ), :Properties )
  end

  def saveNamespace(name)
    filename = File.join( @base, name )
    # kill old config before saving
    File.delete filename if File.exists? filename
    # now save out the data
    DataReader.save( filename, @data[name], :Properties ) unless @data[name].keys.empty?
  end

  def findBaseStore(app_name)
    home = findHomeDir
    folder = findAppFolderName(app_name)
    base = File.join( home, folder )
    Dir.open( home ) do |d|
      unless d.member? folder
        Dir.mkdir base
      end
    end
    base
  end

  def findHomeDir
    return ENV['TEST_HOME_OVERRIDE'] unless ENV['TEST_HOME_OVERRIDE'].nil?
    return Gem::user_home if defined? Gem
    return ENV['HOME'] unless ENV['HOME'].nil?
    return ENV['USERPROFILE'] unless ENV['USERPROFILE'].nil?
    return ENV['HOMEDRIVE'] + ENV['HOMEPATH'] if PLATFORM =~ /win32/
    return '.'
  end

  def findAppFolderName(app_name)
    "." + app_name
  end

end # UserDataStore

end # Amazon::Util
end # Amazon
