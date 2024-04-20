#!/usr/bin/env ruby
require "date"
require "optparse"

# 年月の設定
today = Date.today
params = ARGV.getopts("y:", "m:")

year = params["y"]&.to_i || today.year
month = params["m"]&.to_i || today.month

# 月の日数の取得、初日の曜日取得
days = Date.new(year, month, -1).day
weekday_1st = Date.new(year, month, 1).wday

# ヘッダー
puts "#{month}月 #{year}".center(20)
puts "日 月 火 水 木 金 土"

# 1週目の空白を表示する
print "   " * weekday_1st

# 日付を表示
(1..days).each do |n|
  printf("%2d ", n)
  puts "" if n % 7 == 6
end
puts ""
