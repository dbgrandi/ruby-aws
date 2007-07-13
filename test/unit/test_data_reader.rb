# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'tempfile'
require 'test/unit/testcase'
require 'amazon/util/data_reader'

class TestDataReader < Test::Unit::TestCase
  include Amazon::Util

SAMPLE_LIST_DATA = [ { :a => 1, :b => { :c => 2, :d => 3 }, :e => [ {:f => 4, :g => 5}, {:f => "anew\nline", :g => 7} ] }, 
                     { :a => 2, :b => { :c => 4, :d => "for	fun" }, :e => [ {:f => 2, :g => 4}, {:f => 8, :g => 7} ] }, 
                     { :a => 3, :b => { :c => "apples, oranges", :d => 1 }, :e => [ {:f => 2, :g => 3}, {:f => 9, :g => 6} ] }, ] 

YAML_LIST_DATA = <<EOF
---
- :b:
    :c: 2
    :d: 3
  :a: 1
  :e:
  - :f: 4
    :g: 5
  - :f: "anew\\nline"
    :g: 7
- :b:
    :c: 4
    :d: for	fun
  :a: 2
  :e:
  - :f: 2
    :g: 4
  - :f: 8
    :g: 7
- :b:
    :c: apples, oranges
    :d: 1
  :a: 3
  :e:
  - :f: 2
    :g: 3
  - :f: 9
    :g: 6
EOF

TABULAR_LIST_DATA = <<EOF
a	b.c	b.d	e.1.f	e.1.g	e.2.f	e.2.g
1	2	3	4	5	"anew
line"	7
2	4	"for	fun"	2	4	8	7
3	apples, oranges	1	2	3	9	6
EOF

CSV_LIST_DATA = <<EOF
a,b.c,b.d,e.1.f,e.1.g,e.2.f,e.2.g
1,2,3,4,5,"anew
line",7
2,4,for	fun,2,4,8,7
3,"apples, oranges",1,2,3,9,6
EOF

SAMPLE_PROPERTIES_DATA = { :a => 1, :b => { :c => 2, :d => 3 }, :e => 4, :f => "Such a complex, yet whimsical fancy" }

YAML_PROPERTIES_DATA = <<EOF
---
:b:
  :c: 2
  :d: 3
:a: 1
:e: 4
:f: Such a complex, yet whimsical fancy
EOF

PROP_PROPERTIES_DATA = <<EOF
b.c=2
b.d=3
a=1
e=4
f=Such a complex, yet whimsical fancy
EOF

  include Amazon::Util

  def saveAndLoad( raw, format, sample )
    @tmp = Tempfile.new( 'ruby-aws-test')
    @tmp << raw
    @tmp.close
    data = DataReader.load( @tmp.path, format )
    assert_equal sample, data
  end

  def reloadCheck( format, data )
    @tmp = Tempfile.new( 'ruby-aws-test')
    @tmp.close
    DataReader.save( @tmp.path, data, format )
    restore = DataReader.load( @tmp.path, format )
    assert_equal data, restore
  end

  def testReadYAML
    saveAndLoad( YAML_LIST_DATA, :YAML, SAMPLE_LIST_DATA )
    saveAndLoad( YAML_PROPERTIES_DATA, :YAML, SAMPLE_PROPERTIES_DATA )
  end

  def testReadProp
    saveAndLoad( PROP_PROPERTIES_DATA, :Properties, SAMPLE_PROPERTIES_DATA )
  end

  def testReadTabular
    saveAndLoad( TABULAR_LIST_DATA, :Tabular, SAMPLE_LIST_DATA )
  end

  def testReadCSV
    saveAndLoad( CSV_LIST_DATA, :CSV, SAMPLE_LIST_DATA )
  end

  def testRestoreYAML
    reloadCheck( :YAML, SAMPLE_LIST_DATA )
    reloadCheck( :YAML, SAMPLE_PROPERTIES_DATA )
  end

  def testRestoreProp
    reloadCheck( :Properties, SAMPLE_PROPERTIES_DATA )
  end

  def testRestoreTabular
    reloadCheck( :Tabular, SAMPLE_LIST_DATA )
  end

  def testRestoreCSV
    reloadCheck( :CSV, SAMPLE_LIST_DATA )
  end


end # TestDataReader
