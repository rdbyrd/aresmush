module AresMUSH
  module Battle
    class HealingTemplate < ErbTemplateRenderer


      attr_accessor :char

      def initialize(char)
        @char = char
        super File.dirname(__FILE__) + "/healing.erb"
      end

      def max_patients
        Battle.max_patients(@char)
      end

      def damage_mod(patient)
        Battle.total_damage_mod(patient)
      end
    end
  end
end
