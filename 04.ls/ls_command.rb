# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

def fetch_options
  options = {}
  opts = OptionParser.new
  opts.on('-a') { options[:a] = true }
  opts.on('-r') { options[:r] = true }
  opts.on('-l') { options[:l] = true }
  opts.parse(ARGV)
  options
end

def sorted_filenames(options)
  filenames = Dir.foreach(Dir.getwd).to_a.sort
  filenames.reject! { |i| i.start_with?('.') } unless options[:a]
  filenames.reverse! if options[:r]
  filenames
end

options = fetch_options
return unless options[:l]

filetypes = { '01' => 'p',  '02' => 'c', '04' => 'd', '06' => 'b', '10' => '-', '12' => 'l', '14' => 's' }
filemodes = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }

def user_permission(filemodes, stat_mode)
  user_permission = filemodes[stat_mode.slice(3)]
  if user_permission.slice(2) == 'x' && filemodes[stat_mode.slice(3)] == '1'
    user_permission[2] = 't'
  elsif user_permission.slice(2) == '-' && filemodes[stat_mode.slice(3)] == '1'
    user_permission[2] = 'T'
  end
  user_permission
end

def group_permission(filemodes, stat_mode)
  group_permission = filemodes[stat_mode.slice(4)]
  if group_permission.slice(2) == 'x' && filemodes[stat_mode.slice(3)] == '2'
    group_permission[2] = 's'
  elsif group_permission.slice(2) == '-' && filemodes[stat_mode.slice(3)] == '2'
    group_permission[2] = 'S'
  end
  group_permission
end

def other_permission(filemodes, stat_mode)
  other_permission = filemodes[stat_mode.slice(5)]
  if other_permission.slice(2) == 'x' && filemodes[stat_mode.slice(3)] == '4'
    other_permission[2] = 's'
  elsif other_permission.slice(2) == '-' && filemodes[stat_mode.slice(3)] == '4'
    other_permission[2] = 'S'
  end
  other_permission
end

def fetch_year
  today = Date.today
  year = today.year
end

filenames = sorted_filenames(options)
filestats = []
blocks = []

filenames.each do |filename|
  filestat = []
  stat = File.stat(filename)
  stat_mode = stat.mode.to_s(8)
  stat_mode = "0#{stat_mode}" if stat_mode.size == 5
  filetype = filetypes[stat_mode.slice(0..1)]
  user_perm = user_permission(filemodes, stat_mode)
  group_perm = group_permission(filemodes, stat_mode)
  other_perm = other_permission(filemodes, stat_mode)
  permission = "#{filetype}#{user_perm}#{group_perm}#{other_perm}"
  filestat << permission
  filestat << stat.nlink.to_s
  filestat << Etc.getpwuid(stat.uid).name
  filestat << Etc.getgrgid(stat.gid).name
  filestat << stat.size.to_s
  mtime = stat.mtime
  year = fetch_year
  filestat << if mtime.year == year
                mtime.strftime('%_m %_d %R')
              else
                mtime.strftime('%_m %_d  %Y')
              end
  blocks << stat.blocks
  filestats << filestat
end

blank_permission = 0
blank_nlink = 0
blank_uid = 0
blank_gid = 0
blank_filesize = 0

filestats.each do |x|
  blank_permission = x[0].length if x[0].length > blank_permission
  blank_nlink = x[1].length if x[1].length > blank_nlink
  blank_uid = x[2].length if x[2].length > blank_uid
  blank_gid = x[3].length if x[3].length > blank_gid
  blank_filesize = x[4].length if x[4].length > blank_filesize
end

puts "total #{blocks.sum}"
filestats.each do |n|
  print n[0], '  '
  print n[1].rjust(blank_nlink), ' '
  print n[2].ljust(blank_uid), '  '
  print n[3].ljust(blank_gid), '  '
  print n[4].rjust(blank_filesize), ' '
  print n[5], ' '
  puts filenames[filestats.index(n)]
end
