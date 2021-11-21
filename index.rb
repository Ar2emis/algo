# frozen_string_literal: true

require 'benchmark'

require 'gruff'
require 'numpy'

REPEATS = 10
AMOUNTS = (100..10_000).step(100).to_a
CHART = 'chart.png'
DATA = 'data.yml'
TITLE = 'Ruby QuickSort'

def sort(arr)
  (p = arr.delete_at(arr.size.pred / 2)) ? [*sort(arr.select { |e| p > e }), p, *sort(arr.select { |e| p <= e })] : []
end

chart = Gruff::Line.new(4000)
chart.title = TITLE
chart.labels = AMOUNTS.select { |e| (e % 10_000).zero? }.to_h { |amount| [amount, amount] }

times = AMOUNTS.map do |amount|
  Array.new(REPEATS) do
    array = Array.new(amount) { rand }
    Benchmark.measure { sort(array) }.real
  end.sum / REPEATS
end

data = {
  n2logn2: AMOUNTS.sum { |amount| (amount**2) * (Math.log2(amount)**2) },
  n2logn: AMOUNTS.sum { |amount| (amount**2) * Math.log2(amount) },
  nlogn: AMOUNTS.sum { |amount| amount * Math.log2(amount) },
  n2: AMOUNTS.sum { |amount| amount**2 },
  n: AMOUNTS.sum { |amount| amount },
  tnlogn: AMOUNTS.each_with_index.sum { |amount, index| amount * Math.log2(amount) * times[index] },
  tn: AMOUNTS.each_with_index.sum { |amount, index| amount * times[index] },
  t: times.sum
}
left_part = Numpy.asarray(
  [
    [data[:n2logn2], data[:n2logn], data[:nlogn]],
    [data[:n2logn], data[:n2], data[:n]],
    [data[:nlogn], data[:n], 100]
  ]
)
right_part = Numpy.asarray([data[:tnlogn], data[:tn], data[:t]])
a, b, c = Numpy.linalg.solve(left_part, right_part).to_a

calculated_times = AMOUNTS.map { |amount| (a * amount * Math.log2(amount)) + (b * amount) + c }
errors = times.map.with_index do |time, index|
  ((time - calculated_times[index]).abs.to_f / calculated_times[index]) * 100
end

puts "Average Relative Error: #{(errors.sum / errors.length).round(2)}%"

chart.dataxy('Empirical', AMOUNTS, times)
chart.dataxy('Calculated', AMOUNTS, calculated_times)

chart.write(CHART)
