def get_sorted_filenames
  filenames = []
  Dir.foreach(Dir.getwd) do |filename|
    next if filename =~ /^\./
    filenames << filename
  end
  filenames.sort!
end

def calc_row(length, col)
  length / col + (length % col == 0 ? 0 : 1)
end

def calc_width(names)
  names.sort_by {|name| name.length}.reverse[0].length + 5
end

def view_filename(col)
  filenames = get_sorted_filenames
  width = calc_width(filenames)
  row = calc_row(filenames.length, col)
  row.times do |n|
    col.times do |x|
      next if filenames[row * x + n] == nil
      print filenames[row * x + n].ljust(width) 
    end
    puts
  end
end

view_filename(3)
