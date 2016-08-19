Dir.glob(File.join(File.dirname(__FILE__), '../boot.rb')).each { |f| require f }

include Implement
