#!/usr/bin/env ruby
require "date"
require "optparse"

# 今日の日付を取得
today = Date.today
today_year = today.year
today_month = today.month

# コマンドラインで入力された内容を判定
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

# タイトル
puts "#{month}月 #{year}".center(20)

# 曜日一覧
day_of_week = ["日", "月", "火", "水", "木", "金", "土"]
puts day_of_week.join(" ")

# 1週目の空白を表示する
weekday_1st.times do
  print "   "
end

# 1週目の日付表示
wday_1st_week = 7 - weekday_1st
wday_1st_week.times do |n|
  printf("%2d", n + 1) 
  print " "
end
puts " "

# 2週目以降の日付表示
end_of_month.times do |n|
  break if n == end_of_month - wday_1st_week
  if n  == 0
    printf("%2d", n + 1 + wday_1st_week)
    print " "
  elsif n % 7 == 6
    printf("%2d", n + 1 + wday_1st_week)
    print " "
    puts " "
  else
    printf("%2d", n + 1 + wday_1st_week)
    print " "
  end
end
