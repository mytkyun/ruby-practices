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

options = fetch_options

def sorted_filenames(options)
  filenames = Dir.foreach(Dir.getwd).to_a.sort
  return if filenames.empty?

  filenames.reject! { |i| i.start_with?('.') } unless options[:a]
  filenames.reverse! if options[:r]
  filenames
end

def show_filenames
  options = fetch_options
  filenames = sorted_filenames(options)
  width = filenames.max_by(&:length).length + 5
  row = filenames.length.ceildiv(COLUMNS)
  row.times do |n|
    COLUMNS.times do |x|
      next if filenames[row * x + n].nil?

      print filenames[row * x + n].ljust(width)
    end
    puts
  end
end

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

def filestats(filenames)
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
    filestat['mtime'] = mtime.strftime(mtime.year == Date.today.year ? '%_b %_d %R' : '%_b %_d  %Y')
    blocks << stat.blocks
    filestats << filestat
  end
  { filestats:, blocks: }
end

result_filestats = filestats(filenames)
filestats = result_filestats[:filestats]
blocks = result_filestats[:blocks]

def calc_width_l_option(filestats)
  width_permission = 0
  width_nlink = 0
  width_uid = 0
  width_gid = 0
  width_filesize = 0
  filestats.each do |filestat|
    width_permission = [width_permission, filestat['permission'].length].max
    width_nlink = [width_nlink, filestat['nlink'].length].max
    width_uid = [width_uid, filestat['uid'].length].max
    width_gid = [width_gid, filestat['gid'].length].max
    width_filesize = [width_filesize, filestat['size'].length].max
  end
  { width_permission:, width_nlink:, width_uid:, width_gid:, width_filesize: }
end

l_option_width = calc_width_l_option(filestats)

def show_l_option_filenames(filestats, filenames, blocks, l_option_width)
  puts "total #{blocks.sum}"
  filestats.each do |filestat|
    print filestat['permission'], '  '
    print filestat['nlink'].rjust(l_option_width[:width_nlink]), ' '
    print filestat['uid'].ljust(l_option_width[:width_uid]), '  '
    print filestat['gid'].ljust(l_option_width[:width_gid]), '  '
    print filestat['size'].rjust(l_option_width[:width_filesize]), ' '
    print filestat['mtime'], ' '
    puts filenames[filestats.index(filestat)]
  end
end

COLUMNS = 3

if options[:l]
  show_l_option_filenames(filestats, filenames, blocks, l_option_width)
else
  show_filenames
end
