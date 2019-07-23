module AresMUSH
  module Battle
    class DamageTemplate < ErbTemplateRenderer


      attr_accessor :damage, :target

      def initialize(target)
        @target = target
        @damage = target.damage
        super File.dirname(__FILE__) + "/damage.erb"
      end

      def severity(d)
        initial_sev = d.initial_severity
        current_sev = Battle.display_severity(d.current_severity)
        "#{current_sev} (#{initial_sev[0..2]})"
      end

      def treatable(d)
        d.is_treatable? ? t('global.y') : '-'
      end

      def healing(d)
        total = Battle.healing_points(d.current_severity)
        healed = total - d.healing_points

        return "-----" if (total == 0)

        ProgressBarFormatter.format(healed, total, 5)
      end

      def healed_by
        return t('global.none') if @target.class != AresMUSH::Character
        docs = @target.doctors.map { |h| h.name }
        docs.count > 0 ? docs.join(", ") : t('global.none')
      end

      def wound_mod
        Battle.total_damage_mod(target)
      end
      
    end
  end
end
