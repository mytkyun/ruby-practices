# frozen_string_literal: true

require 'optparse'

def fetch_options
  options = {}
  opts = OptionParser.new
  opts.on('-l') { |opt| options[:l] = opt }
  opts.on('-w') { |opt| options[:w] = opt }
  opts.on('-c') { |opt| options[:c] = opt }
  opts.parse!(ARGV)
  { options:, ARGV: }
end

options = fetch_options
p options

def open_files
  texts = []
  File.open(ARGV[0], 'r') do |text|
    texts = text.readlines
  end
  texts
end

p open_files

def word_counts
  wc = {
    l: open_files.length,
    w: open_files.sum { |line| line.split.length },
    c: open_files.sum(&:length)
  }
end

def results
  print word_counts[:l].to_s.rjust(8)
  print word_counts[:w].to_s.rjust(8)
  print word_counts[:c].to_s.rjust(8), ' '
  puts ARGV
end

results
