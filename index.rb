# frozen_string_literal: true

require 'benchmark'
require 'yaml'

require 'pry'
require 'gruff'

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

formula = lambda { |amount|
  (7.486455732748022e-08 * amount * Math.log2(amount)) + (5.665389342181481e-07 * amount) - 5.5875711310657256e-05
}

times = AMOUNTS.map do |amount|
  Array.new(REPEATS) do
    array = Array.new(amount) { rand }
    Benchmark.measure { sort(array) }.real
  end.sum / REPEATS
end
calculated_times = AMOUNTS.map(&formula)

# Uncomment to calculate equastions arguments
# data = {
#   times: times,
#   n2logn2: AMOUNTS.sum { |amount| (amount**2) * (Math.log2(amount)**2) },
#   n2logn: AMOUNTS.sum { |amount| (amount**2) * Math.log2(amount) },
#   nlogn: AMOUNTS.sum { |amount| amount * Math.log2(amount) },
#   n2: AMOUNTS.sum { |amount| amount**2 },
#   n: AMOUNTS.sum { |amount| amount },
#   tnlogn: AMOUNTS.each_with_index.sum { |amount, index| amount * Math.log2(amount) * times[index] },
#   tn: AMOUNTS.each_with_index.sum { |amount, index| amount * times[index] },
#   t: times.sum
# }

# File.open(DATA, 'wb') { |file| file.write(data.to_yaml) }

chart.dataxy('Empirical', AMOUNTS, times)
chart.dataxy('Calculated', AMOUNTS, calculated_times)

chart.write(CHART)
