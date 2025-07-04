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

FILETYPES = { '01' => 'p',  '02' => 'c', '04' => 'd', '06' => 'b', '10' => '-', '12' => 'l', '14' => 's' }.freeze
FILEMODES = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }.freeze

def user_permission(stat_mode, filemodes = FILEMODES)
  user_permission = filemodes[stat_mode.slice(3)]
  if user_permission.slice(2) == 'x' && filemodes[stat_mode.slice(3)] == '1'
    user_permission[2] = 't'
  elsif user_permission.slice(2) == '-' && filemodes[stat_mode.slice(3)] == '1'
    user_permission[2] = 'T'
  end
  user_permission
end

def group_permission(stat_mode, filemodes = FILEMODES)
  group_permission = filemodes[stat_mode.slice(4)]
  if group_permission.slice(2) == 'x' && filemodes[stat_mode.slice(3)] == '2'
    group_permission[2] = 's'
  elsif group_permission.slice(2) == '-' && filemodes[stat_mode.slice(3)] == '2'
    group_permission[2] = 'S'
  end
  group_permission
end

def other_permission(stat_mode, filemodes = FILEMODES)
  other_permission = filemodes[stat_mode.slice(5)]
  if other_permission.slice(2) == 'x' && filemodes[stat_mode.slice(3)] == '4'
    other_permission[2] = 's'
  elsif other_permission.slice(2) == '-' && filemodes[stat_mode.slice(3)] == '4'
    other_permission[2] = 'S'
  end
  other_permission
end

filenames = sorted_filenames(options)
filestats = []
blocks = []

filenames.each do |filename|
  filestat = []
  stat = File.stat(filename)
  stat_mode = stat.mode.to_s(8).rjust(6, '0')
  filetype = FILETYPES[stat_mode.slice(0..1)]
  user_perm = user_permission(FILEMODES, stat_mode)
  group_perm = group_permission(FILEMODES, stat_mode)
  other_perm = other_permission(FILEMODES, stat_mode)
  permission = "#{filetype}#{user_perm}#{group_perm}#{other_perm}"
  filestat << permission
  filestat << stat.nlink.to_s
  filestat << Etc.getpwuid(stat.uid).name
  filestat << Etc.getgrgid(stat.gid).name
  filestat << stat.size.to_s
  mtime = stat.mtime
  year = Date.today.year
  filestat << if mtime.year == year
                mtime.strftime('%_b %_d %R')
              else
                mtime.strftime('%_b %_d  %Y')
              end
  blocks << stat.blocks
  filestats << filestat
end

width_permission = 0
width_nlink = 0
width_uid = 0
width_gid = 0
width_filesize = 0

filestats.each do |x|
  width_permission = x[0].length if x[0].length > width_permission
  width_nlink = x[1].length if x[1].length > width_nlink
  width_uid = x[2].length if x[2].length > width_uid
  width_gid = x[3].length if x[3].length > width_gid
  width_filesize = x[4].length if x[4].length > width_filesize
end

puts "total #{blocks.sum}"
filestats.each do |n|
  print n[0], '  '
  print n[1].rjust(width_nlink), ' '
  print n[2].ljust(width_uid), '  '
  print n[3].ljust(width_gid), '  '
  print n[4].rjust(width_filesize), ' '
  print n[5], ' '
  puts filenames[filestats.index(n)]
end
