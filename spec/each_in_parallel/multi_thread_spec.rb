require "spec_helper"
require "benchmark"

module EachInParallel
  RSpec.describe MultiThread do
    it "run in multithread" do
      r = []

      MultiThread.each(0..3, threads: 4) do |n|
        r[n] = Thread.current.object_id
        sleep 0.01
      end

      expect(r.compact.uniq.size).to eq 4
    end

    it "catch exception in any thread" do
      expect {
        ms = Benchmark.realtime do
          MultiThread.each(0..39, threads: 4) do |n|
            raise if n == 0

            sleep 0.01
          end
        end
        expect(ms).to be < 0.02
      }.to raise_error(RuntimeError)
    end

    it "accepts infinite enumerator" do
      expect {
        ms = Benchmark.realtime do
          MultiThread.each(0.., threads: 4) do |n|
            raise if n == 0

            sleep 0.01
          end
        end
        expect(ms).to be < 0.02
      }.to raise_error(RuntimeError)
    end
  end
end
