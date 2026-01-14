#!/usr/bin/env ruby
# frozen_string_literal: true

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
  point += frame.sum
  next if frame.sum != 10 || i >= 9

  point += shots[(i + 1) * 2]
  point += shots[(i + 2) * 2] if frame[0] == 10 && shots[(i + 1) * 2] == 10 # ストライクの次がストライクの場合
  point += shots[(i + 1) * 2 + 1] if frame[0] == 10 # 上記以外のストライクの場合
end
puts point
