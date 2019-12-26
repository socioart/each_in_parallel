require "thwait"
# require "ohai"

module EachInParallel
  module MultiProcess
    # DEFAULT_NUM_OF_WORKERS = ::Ohai::System.new.all_plugins("cpu")["cpu"]["cores"]

    class << self
      attr_accessor :disable
    end

    module_function
    def each(enumerable, processes: 1, &block)
      return enumerable.each(&block) if MultiProcess.disable

      thwait = ThreadsWait.new

      enumerable.each do |item|
        thwait.next_wait.join if thwait.threads.size >= processes

        cid = fork do
          block.call(item)
        end

        thwait.join_nowait(
          Thread.new {
            _, s = Process.waitpid2(cid)
            raise EachInParallel::Error, "Worker process exited with #{s.to_i >> 8}" unless s.success?
          },
        )
      end

      thwait.all_waits(&:join)
      enumerable
    end
  end
end
