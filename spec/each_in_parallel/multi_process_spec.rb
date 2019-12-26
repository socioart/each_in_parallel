require "spec_helper"
require "benchmark"
require "tempfile"

module EachInParallel
  RSpec.describe MultiProcess do
    it "run in multiProcess" do
      f = Tempfile.new

      MultiProcess.each(0..3, processes: 4) do |n|
        f << Process.pid.to_s + "\n"
        sleep 0.01
      end

      f.rewind
      pids = f.read.lines.map(&:to_i).uniq
      expect(pids.size).to eq 4
    end

    it "catch exception in any process" do
      expect {
        ms = Benchmark.realtime do
          MultiProcess.each(0..39, processes: 4) do |n|
            raise if n == 0

            sleep 0.01
          end
        end
        expect(ms).to be < 0.02
      }.to raise_error(EachInParallel::Error)
    end

    it "accepts infinite enumerator" do
      expect {
        ms = Benchmark.realtime do
          MultiProcess.each(0.., processes: 4) do |n|
            raise if n == 0

            sleep 0.01
          end
        end
        expect(ms).to be < 0.02
      }.to raise_error(EachInParallel::Error)
    end
  end
end
