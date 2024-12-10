def filenames
  filenames = []
  Dir.foreach(Dir.getwd) do |filename|
    if filename =~ /^\./
    else
      filenames << filename
    end
  end
  filenames.sort!
end

def filenames_row
  if filenames.length.to_i % 3 == 0
    filenames.length/3.to_i
  else 
    filenames.length/3.to_i + 1
  end
end

def view_filenames
  width = filenames.sort_by {|array| array.length}.reverse[0].length + 5
  filenames_row.times do |n|
    if filenames[filenames_row * 2 + n] == nil
      puts filenames[n].ljust(width) + filenames[filenames_row + n].ljust(width)
    else
      puts filenames[n].ljust(width) + filenames[filenames_row + n].ljust(width) + filenames[filenames_row * 2 + n].ljust(width) 
    end
  end
end

view_filenames
