begin
  puts 'Starting presentation.'
  Dreampresent.new(Screen, DcKosRb.new(DcKos)).start
rescue => ex
  # Note backtrace is only available when you pass -g to mrbc
  p ex.backtrace
  p ex.inspect
  raise ex
end
