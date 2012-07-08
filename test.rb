$:.unshift '.'

require 'iter'


s = [1,2,3,4,5]
p s

fi = Iterate::iter s

s.each {
    p Iterate::next(fi)
}

s.iter.each {|e| p e }


puts 'Test tee'
a, b = Iterate::FiberIter::tee(s.iter)
p b.nxt
p a.to_a.zip b
