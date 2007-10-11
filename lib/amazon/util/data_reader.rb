# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'yaml'
require 'csv'
require 'amazon/util/hash_nesting'

module Amazon
module Util

# DataReader is a class for loading in data files.  It is used to support bulk file-based operations.
# DataReader supports a number of different formats:
# * YAML
# * Tabular
# * CSV
# * Java Properties
# By default, DataReader assumes Tabular, but load and save both support your choice of format
class DataReader

  attr_accessor :data

  def initialize(data=[])
    @data = data
  end
  
  def [](index)
    return @data[index]
  end
  
  def []=(index)
    return @data[index]
  end
  
  def load( filename, format=:Tabular )
    return {} unless File.exists? filename
    raw_data = File.read( filename )
    case format
    when :Tabular
      @data = parse_csv( raw_data, "\t" )
    when :YAML
      @data = YAML.load( raw_data ) || {}
    when :CSV
      @data = parse_csv( raw_data )
    when :Properties
      @data = parse_properties( raw_data )
    else
      raise "invalid format.  options are :Tabular, :YAML, :CSV, :Properties"
    end
  end
  
  def save( filename, format=:Tabular, force_headers=false )
    return if @data.nil? or @data.empty?
    existing = File.exists?( filename ) && File.size( filename ) > 0
    File.open( filename, 'a+' ) {|f| 
      f << case format
      when :Tabular
        generate_csv( @data, force_headers || !existing, "\t" )
      when :YAML
        YAML.dump( @data )
      when :CSV
        generate_csv( @data, force_headers || !existing )
      when :Properties
        generate_properties( @data )
      end
      f << "\n" # adding a newline on the end, so appending is happy
    }
  end

  def self.load( filename, format=:Tabular )
    reader = DataReader.new()
    reader.load( filename, format )
  end
  
  def self.save( filename, data, format=:Tabular, force_headers=false )
    reader = DataReader.new( data )
    reader.save( filename, format, force_headers )
  end
  
  private
  
  def parse_csv( raw_data, delim=nil )
    processed = []
    rows = CSV.parse( raw_data, delim )
    return parse_rows( rows )
  end

  def parse_rows( rows )
    processed = []
    headers = rows.shift
    for row in rows
      item = {}
      headers.each_index do |i|
        item[headers[i].to_sym] = correct_type(row[i]) unless row[i].nil? or row[i].empty?
      end
      item.extend HashNesting
      processed << item.unnest
    end
    return processed
  end
  
  def split_data( data )
    data = data.collect {|d| d.extend(HashNesting).nest }
    headers = data[0].keys.sort
    rows = data.collect { |item|
      row = []
      item.keys.each {|k|
        headers << k unless headers.include? k
        index = headers.index k
        row[index] = item[k].to_s
      }
      row
    }
    return headers, rows
  end
  
  def generate_csv( data, dump_header, delim=nil )
    return "" if data.nil? or data.empty?
    headers, rows = split_data( data )
    return generate_rows( headers, rows, dump_header, delim )
  end
  
  def generate_rows( headers, rows, dump_header, record_seperator=nil )
    rows.unshift headers if dump_header
    buff = rows.collect { |row|
      CSV.generate_line( row, record_seperator )
    }
    return buff.join("\n")
  end

  def parse_properties( raw_data )
    processed = {}
    for line in raw_data.split(/\n\r?/)
      next if line =~ /^\W*(#.*)?$/ # ignore lines beginning w/ comments
      if md = /^([^:=]+)[=:](.*)/.match(line)
        processed[md[1].strip] = correct_type(md[2].strip)
      end
    end
    processed.extend HashNesting
    return processed.unnest
  end
  
  def generate_properties( raw_data )
    raw_data.extend HashNesting
    (raw_data.nest.collect {|k,v| "#{k}:#{v}" }).join("\n")
  end
  
  # convert to integer if possible
  def correct_type( str )
    return str.to_f if str =~ /^\d+\.\d+$/ unless str =~ /^0\d/
    return str.to_i if str =~ /^\d+$/ unless str =~ /^0\d/
    return str
  end
  
end # DataReader

end # Amazon::Util
end # Amazon
