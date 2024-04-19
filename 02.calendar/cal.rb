#!/usr/bin/env ruby
require "date"
require "optparse"

# 今日の日付を取得
today = Date.today
today_year = today.year
today_month = today.month

# コマンドラインで入力された内容をもとに年月を指定
params = ARGV.getopts("y:", "m:")

if params["y"] == nil
  year = today_year
else 
  year = params["y"].to_i
end

if params["m"] == nil
  month = today_month
else 
  month = params["m"].to_i
end

# 月のはじまりと終わり
start_of_month = Date.new(year, month, 1).day
end_of_month = Date.new(year, month, -1).day
# 月の初日の曜日を取得する
weekday_1st = Date.new(year, month, 1).wday

# ヘッダー
puts "#{month}月 #{year}".center(20)
puts "日 月 火 水 木 金 土"

# 1週目の空白を表示する
weekday_1st.times do
  print "   "
end


# 2週目以降の日付表示
end_of_month.times do |n|
  break if n == end_of_month
  if n + 1  == 0
    printf("%2d ", n + 1)
  elsif (n + 1) % 7 == 6
    printf("%2d ", n + 1)
    puts ""
  else
    printf("%2d ", n + 1)
  end
end
