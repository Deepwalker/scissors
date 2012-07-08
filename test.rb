$:.unshift '.'

require 'iter'


s = [1,2,3,4,5]
p s

fi = Iterate::iter s

s.each {
    p Iterate::next(fi)
}

puts 'Test Enumerable interface'
s.iter.each {|e| p e }


puts 'Test tee'
a, b = Iterate::FiberIter::tee(s.iter)
b.nxt # Consume first element from iterator
p a.to_a.zip b

puts 'Test chain'
p Iterate::FiberIter::chain(s, s).select {|i| i < 3}

p Iterate::FiberIter::from_iterable([s, s]).select {|i| i > 3}
