# frozen_string_literal: true

require 'optparse'
require 'etc'

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

def l_option
  options = fetch_options
  return unless options[:l]

  filenames = sorted_filenames(options)
  filetype = { '01' => 'p',  '02' => 'c', '04' => 'd', '06' => 'b', '10' => '-', '12' => 'l', '14' => 's' }
  filemode = { '0' => '---', '1' => '--x', '2' => '-w-', '3' => '-wx', '4' => 'r--', '5' => 'r-x', '6' => 'rw-', '7' => 'rwx' }
  permissions = []
  nlinks = []
  user_ids = []
  group_ids = []
  sizes = []
  mtimes = []
  blocks = []

  filenames.each do |n|
    stat = File.stat(n)
    stat_mode = stat.mode.to_s(8)
    stat_mode = '0' + stat_mode if stat_mode.size == 5
    user_permissions = filemode[stat_mode.slice(3)]
    if user_permissions.slice(2) == 'x' && filemode[stat_mode.slice(3)] == '1'
      user_permissions[2] = 't'
    elsif user_permissions.slice(2) == '-' && filemode[stat_mode.slice(3)] == '1'
      user_permissions[2] = 'T'
    else
    end

    group_permissions = filemode[stat_mode.slice(4)]
    if group_permissions.slice(2) == 'x' && filemode[stat_mode.slice(3)] == '2'
      group_permissions[2] = 's'
    elsif group_permissions.slice(2) == '-' && filemode[stat_mode.slice(3)] == '2'
      group_permissions[2] = 'S'
    else
    end

    other_permissions = filemode[stat_mode.slice(5)]
    if other_permissions.slice(2) == 'x' && filemode[stat_mode.slice(3)] == '4'
      other_permissions[2] = 's'
    elsif other_permissions.slice(2) == '-' && filemode[stat_mode.slice(3)] == '4'
      other_permissions[2] = 'S'
    else
    end

    perimission = filetype[stat_mode.slice(0..1)] + user_permissions + group_permissions + other_permissions
    permissions << perimission

    nlinks << stat.nlink

    user_ids << Etc.getpwuid(stat.uid).name

    group_ids << Etc.getgrgid(stat.gid).name

    sizes << stat.size

    mtime = stat.mtime
    mtimes << mtime.strftime('%_m %_d %R')

    blocks << stat.blocks
  end

  puts 'total ' + blocks.sum.to_s

  nlinks_to_i = nlinks.map(&:to_s)

  nlinks_blank = nlinks_to_i.max_by(&:length).length + 1
  user_ids_blank = user_ids.max_by(&:length).length + 1
  group_ids_blank = group_ids.max_by(&:length).length + 1

  sizes_to_i = sizes.map(&:to_s)

  sizes_blank = sizes_to_i.max_by(&:length).length + 1

  filenames.each_index.select do |x|
    print permissions[x], ' '
    print nlinks[x].to_s.rjust(nlinks_blank), ' '
    print user_ids[x].ljust(user_ids_blank)
    print group_ids[x].ljust(group_ids_blank)
    print sizes[x].to_s.rjust(sizes_blank), ' '
    print mtimes[x], ' '
    print filenames[x]
    puts
  end
end

l_option
