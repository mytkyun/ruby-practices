# 1-20を表示する
numbers = 1 .. 20
numbers.each do |number|
  # 3と5の倍数のときFizzBuzz
  if number % 15 == 0 
    puts "FizzBuzz"
  # 3の倍数のときFizz
  elsif number % 3 == 0
    puts "Fizz"
    # 5の倍数のときBuzz
  elsif number % 5 == 0
    puts "Buzz"
  # それ以外のもの
  else
    puts number
  end
end

