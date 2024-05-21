#!/usr/bin/env ruby

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = []
shots.each_slice(2) do |s|
  frames << s
end

point = 0
frames.each.with_index do |frame, i|
  if i == 9 && frame.sum == 10
    point += frame.sum
  elsif frame[0] == 10 && shots[(i+1)*2] ==10 && i < 9 # ストライクの次もストライクの場合
    point += frame.sum + 10 + shots[(i+2)*2]
  elsif frame[0] == 10 && i < 9 # 上記以外のストライクの場合
    point += frame.sum + shots[(i+1)*2] + shots[(i+1)*2+1]
  elsif frame.sum == 10 && i < 9 # スペア
    point += frame.sum + shots[(i+1)*2]
  else
    point += frame.sum
  end
  puts "#{i}: #{point}"
end
puts point

