module EachInParallel
  class MultiThread
    DEFAULT_NUM_OF_WORKERS = 2
    TERMINATER = Object.new

    class << self
      attr_accessor :disable

      %w(each each_with_index map map_with_index).each do |method|
        define_method method do |enumerable, options = {}, &block|
          new(enumerable).send(method, options, &block)
        end
      end
    end

    self.disable = false

    def initialize(enumerable)
      @enumerable = enumerable
    end

    def each_with_index(threads: DEFAULT_NUM_OF_WORKERS, map: false, &block)
      return @enumerable.each_with_index(&block) if disable?

      queue = SizedQueue.new(threads)
      result = []
      exception = nil
      workers = threads.times.map {
        Thread.new {
          loop do
            break if exception

            v, i = queue.shift
            break if v.equal?(TERMINATER)

            # rubocop:disable Lint/RescueException
            begin
              r = yield v, i
            rescue Exception
              exception = $!
              queue.shift # 最後から 2 番目の要素で例外が起こった場合に queue << でデッドロックを起こさないようにする
              break
            end
            # rubocop:enable Lint/RescueException

            result[i] = r if map
          end
        }
      }

      @enumerable.each_with_index {|v, i|
        raise exception if exception

        queue << [v, i]
      }
      threads.times { queue << [TERMINATER, nil] }

      workers.each(&:join)
      raise exception if exception # 最後の要素で例外が起こった場合、ここで raise

      map ? result : @enumerable
    end

    def each(**options, &block)
      return @enumerable.each(&block) if disable?

      each_with_index(**options) {|v, _| yield v }
    end

    def map_with_index(**options, &block)
      return @enumerable.each_with_index.map(&block) if disable?

      each_with_index(map: true, **options) {|v, i| yield v, i }
    end

    def map(**options, &block)
      return @enumerable.map(&block) if disable?

      map_with_index(**options) {|v| yield v }
    end

    def disable?
      self.class.disable
    end
  end
end
