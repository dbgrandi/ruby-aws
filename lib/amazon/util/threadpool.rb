# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'thread'
require 'set'

module Amazon
module Util

# ThreadPool is a generic threadpooling class that enables
# easier multithreaded workflows.  Initialize with a thread count,
# then addWork to queue up tasks.  You can +sync+ to ensure the current
# workload is complete, or +finish+ to flush the threads when you're done.
class ThreadPool

  # First arg is the thread count.  Threads will be created once and wait
  # for work ( no performance penalty, since they're waiting on a Queue.
  # Second arg (optional) is a proc to be used as an exception handler. If
  # this argument is passed in and the thread encounters an uncaught
  # exception, the proc will be called with the exception as the only argument.
  def initialize( num_threads, exception_handler=nil )
    @work = Queue.new
    @threads = ThreadGroup.new
    num_threads.times do
      worker_thread = Thread.new { workerProcess(exception_handler) }
      @threads.add worker_thread
    end
  end

  # add work to the queue
  # pass any number of arguments, they will be passed on to the block.
  def addWork( *args, &block )
    item = WorkItem.new( args, &block )
    @work.push( item )
    item
  end

  # how many worker threads are there?
  def threadcount
    @threads.list.length
  end

  # request thread completion
  # No more work will be performed
  def noMoreWork
    threadcount.times { @work << :Finish }
  end

  # request thread completion and wait for them to finish
  def finish
    noMoreWork
    @threads.list.each do |t|
      t.join
    end
  end

  # wait for the currently queued work to finish
  # (This freezes up the entire pool, temporarily)
  def sync
    t = threadcount

    if t < 2
      item = addWork { :sync }
      return item.getResult
    end

    q = Queue.new
    items = []

    items << addWork do
      q.pop
    end

    (t-2).times do |t|
      items << addWork(t) do |i|
        items[i].getResult
      end
    end

    addWork do
      q.push :sync
    end

    items.last.getResult
  end

  private

  def workerProcess( exception_handler=nil )
    while true
      workitem = @work.pop
      return if workitem == :Finish
      begin
        workitem.run
      rescue Exception => e
        if exception_handler.nil?
          print "Worker thread has thrown an exception: "+e.to_s+"\n"
        else
          exception_handler.call(workitem)
        end
      end
    end
  end

  class WorkItem
    attr_reader :args, :block
    def initialize( args, &block )
      @args = args
      @block = block
      @result = Queue.new
    end
    def run
      res = @block.call( *@args)
      @result.push res
    rescue Exception => e
      @result.push e
      raise e
    end
    def getResult
      value = @result.pop
      @result = [value]
      value
    end
  end

end # ThreadPool

end # Amazon::Util
end # Amazon
