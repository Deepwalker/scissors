require 'fiber'


module Iterate
  class StoppedIterator < FiberError; end

  def self.iter (seq)
    Fiber.new { seq.each {|e| Fiber.yield e}; raise StoppedIterator }
  end

  def self.next (f_iter)
    f_iter.resume
  end

  class FiberIter
    include Enumerable

    def initialize (arg)
      @f_iter = if Fiber === arg then arg else Iterate.iter(arg) end
    end

    def nxt (default=:no_default)
      @f_iter.resume
    rescue StoppedIterator
      if default != :no_default
        default
      else
        raise
      end
    end

    def each
      begin
        yield nxt
      rescue StoppedIterator
        break
      end while 1
    end

    class << self
      def tee (fiter, size=2)
        bufs = Array.new (size) {[]}
        Array.new (size) do |i|
          FiberIter.new Fiber.new {
            begin
              Fiber.yield(if bufs[i].empty?
                next_val = fiter.nxt
                (0...size).each do |j|
                  bufs[j] << next_val if j != i
                end
                next_val
              else
                bufs[i].slice!(0)
              end)
            rescue FiberError
              raise StoppedIterator
            end while 1
            raise StoppedIterator
          }
        end
      end

      def chain(*args)
        FiberIter.new Fiber.new {
          args.each { |arg| arg.each { |e| Fiber.yield e } }
          raise StoppedIterator
        }
      end

      def from_iterable(args)
        chain *args
      end
    end

  end
end


module Enumerable
  def iter
    Iterate::FiberIter.new self
  end
end
