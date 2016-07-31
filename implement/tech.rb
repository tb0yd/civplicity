
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

    def unlocks
      @tech[:unlocks].map { |t| get_tech(t.to_sym) }
    end

    def get_dependencies
      deps = []
      for_each_tech do |tech|
        if tech.unlocks.map(&:name).include?(name)
          deps += [tech]
        end
      end
      deps
    end

    def is_dependency_for?(tech)
      unlocks_techs = self.unlocks()

      while !unlocks_techs.empty?
        if unlocks_techs.map(&:name).include?(tech.name)
          return true
        end

        unlocks_techs = unlocks_techs.flat_map(&:unlocks)
      end

      false
    end
  end

end
