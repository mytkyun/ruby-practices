# frozen_string_literal: true

require 'optparse'

def fetch_options
  options = {}
  opts = OptionParser.new
  opts.on('-l') { options[:l] = true }
  opts.on('-w') { options[:w] = true }
  opts.on('-c') { options[:c] = true }
  opts.parse!(ARGV)
  { options:, filenames: ARGV }
end

def word_counts(filename)
  texts = []
  File.open(filename, 'r') do |text|
    texts = text.readlines
  end
  {
    l: texts.length,
    w: texts.sum { |line| line.split.length },
    c: texts.sum(&:length)
  }
end

def results(options, filenames)
  filenames.each do |filename|
    counts = word_counts(filename)
    if options.empty?
      print counts[:l].to_s.rjust(8)
      print counts[:w].to_s.rjust(8)
      print counts[:c].to_s.rjust(8)
    else
      print counts[:l].to_s.rjust(8) if options.key?(:l)
      print counts[:w].to_s.rjust(8) if options.key?(:w)
      print counts[:c].to_s.rjust(8) if options.key?(:c)
    end
    puts " #{filename}"
  end
end

option = fetch_options
results(option[:options], option[:filenames])
