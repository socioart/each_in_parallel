require "each_in_parallel/version"

module EachInParallel
  class Error < StandardError; end

  require "each_in_parallel/multi_process"
  require "each_in_parallel/multi_thread"

  module_function
  def each_in_threads(*args, **options, &block)
    MultiThread.each(*args, **options, &block)
  end

  def each_in_processes(*args, **options, &block)
    MultiProcess.each(*args, **options, &block)
  end
end
