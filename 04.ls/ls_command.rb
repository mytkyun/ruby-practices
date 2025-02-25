# frozen_string_literal: true

require 'optparse'

def fetch_options
  options = {}
  opts = OptionParser.new
  opts.on('-a') { options[:a] = true }
  opts.on('-r') { options[:r] = true }
  opts.parse(ARGV)
  options
end

def sorted_filenames(options)
  filenames = Dir.foreach(Dir.getwd).to_a.sort
  filenames.reject! { |i| i.start_with?('.') } unless options[:a]
  filenames.reverse! if options[:r]
  filenames
end

def calc_row(length, col)
  length.ceildiv(col)
end

def calc_width(names)
  return if names.empty?

  names.max_by(&:length).length + 5
end

def show_filenames(col)
  options = fetch_options
  filenames = sorted_filenames(options)
  width = calc_width(filenames)
  row = calc_row(filenames.length, col)
  row.times do |n|
    col.times do |x|
      next if filenames[row * x + n].nil?

      print filenames[row * x + n].ljust(width)
    end
    puts
  end
end

COLUMNS = 3
show_filenames(COLUMNS)
