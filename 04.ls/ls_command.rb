# frozen_string_literal: true

def sorted_filenames
  filenames = Dir.foreach(Dir.getwd).to_a
  filenames.sort.reject { |i| i.start_with?('.') }
end

def calc_row(length, col)
  length.ceildiv(col)
end

def calc_width(names)
  return if names.empty?

  names.max_by(&:length).length + 5
end

def show_filenames(col)
  filenames = sorted_filenames
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
