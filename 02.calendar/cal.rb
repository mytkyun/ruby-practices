#!/usr/bin/env ruby
require "date"
require "optparse"

# 今日の日付を取得(デフォルト値の設定)
today = Date.today
year = today.year
month = today.month

# コマンドラインで指定があった場合の分岐
params = ARGV.getopts("y:", "m:")

if params["y"] != nil 
  year = params["y"].to_i
end

if params["m"] != nil
  month = params["m"].to_i
end

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
  if n == 0
    printf("%2d ", n)
  elsif n % 7 == 6
    printf("%2d ", n)
    puts ""
  else
    printf("%2d ", n)
  end
end
