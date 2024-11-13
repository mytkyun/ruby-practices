filenames = []
Dir.foreach(Dir.getwd) do |filename|
  if filename =~ /^\./
  else
    filenames << filename
  end
end

if filenames.length.to_i % 3 == 0
  filenames_row = filenames.length/3.to_i
else 
  filenames_row = filenames.length/3.to_i + 1
end

filenames_row.times do |n|
  if filenames[filenames_row * 2 + n] == nil
    puts filenames[n].ljust(15) + filenames[filenames_row + n].ljust(15)
  else
    puts filenames[n].ljust(15) + filenames[filenames_row + n].ljust(15) + filenames[filenames_row * 2 + n].ljust(15) 
  end
end
