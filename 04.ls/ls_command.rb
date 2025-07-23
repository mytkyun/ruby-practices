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

def permission(stat_mode)
  user_permission = FILEMODES[stat_mode.slice(3)]
  user_permission[2] = user_permission[2] == 'x' ? 't' : 'T' if FILEMODES[stat_mode[3]] == '1'
  group_permission = FILEMODES[stat_mode.slice(4)]
  group_permission[2] = group_permission[2] == 'x' ? 's' : 'S' if FILEMODES[stat_mode[3]] == '2'
  other_permission = FILEMODES[stat_mode.slice(5)]
  other_permission[2] = other_permission[2] == 'x' ? 's' : 'S' if FILEMODES[stat_mode[3]] == '4'
  "#{user_permission}#{group_permission}#{other_permission}"
end

filenames = sorted_filenames(options)
filestats = []
blocks = []

filenames.each do |filename|
  filestat = {}
  stat = File.stat(filename)
  stat_mode = stat.mode.to_s(8).rjust(6, '0')
  filetype = FILETYPES[stat_mode.slice(0..1)]
  permission = "#{filetype}#{permission(stat_mode)}"
  filestat['permission'] = permission
  filestat['nlink'] = stat.nlink.to_s
  filestat['uid'] = Etc.getpwuid(stat.uid).name
  filestat['gid'] = Etc.getgrgid(stat.gid).name
  filestat['size'] = stat.size.to_s
  mtime = stat.mtime
  year = Date.today.year
  filestat['mtime'] = mtime.strftime(mtime.year == year ? '%_b %_d %R' : '%_b %_d  %Y')
  blocks << stat.blocks
  filestats << filestat
end

width_permission = 0
width_nlink = 0
width_uid = 0
width_gid = 0
width_filesize = 0

filestats.each do |x|
  width_permission = x['permission'].length if x['permission'].length > width_permission
  width_nlink = x['nlink'].length if x['nlink'].length > width_nlink
  width_uid = x['uid'].length if x['uid'].length > width_uid
  width_gid = x['gid'].length if x['gid'].length > width_gid
  width_filesize = x['size'].length if x['size'].length > width_filesize
end

puts "total #{blocks.sum}"
filestats.each do |n|
  print n['permission'], '  '
  print n['nlink'].rjust(width_nlink), ' '
  print n['uid'].ljust(width_uid), '  '
  print n['gid'].ljust(width_gid), '  '
  print n['size'].rjust(width_filesize), ' '
  print n['mtime'], ' '
  puts filenames[filestats.index(n)]
end
