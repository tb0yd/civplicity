class Array
  alias sample_without_log sample

  def sample
    res = sample_without_log()
    puts "sample: #{res}"
    res
  end
end
