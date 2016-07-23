
module Implement
  class Tech
    attr_accessor :tech, :name

    def initialize(t, n)
      @tech = t
      @name = n
    end

    def research
      @tech[:research]
    end
  end

end
