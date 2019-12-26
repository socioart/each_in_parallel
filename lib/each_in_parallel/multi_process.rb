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

        exception_read, exception_write = IO.pipe

        cid = fork do
          exception_read.close
          begin
            block.call(item)
          rescue => e
            Marshal.dump(e, exception_write)
          ensure
            exception_write.close
          end
        end
        exception_write.close

        override_report_on_exception(false) do
          thwait.join_nowait(
            Thread.new {
              Thread.current.report_on_exception = false

              _, s = Process.waitpid2(cid)
              raise EachInParallel::Error, "Worker process exited with #{s.to_i >> 8}" unless s.success?

              e = exception_read.gets
              exception_read.close

              # rubocop:disable Security/MarshalLoad
              raise Marshal.load(e) unless e.nil?
              # rubocop:enable Security/MarshalLoad
            },
          )
        end
      end

      thwait.all_waits(&:join)
      enumerable
    end

    def override_report_on_exception(temp)
      original = Thread.report_on_exception
      Thread.report_on_exception = temp
      yield
    ensure
      Thread.report_on_exception = original
    end
  end
end
