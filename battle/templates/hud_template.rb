module AresMUSH
  module Battle
    class CombatHudTemplate < ErbTemplateRenderer


      attr_accessor :combat

      def initialize(combat)
        @combat = combat
        super File.dirname(__FILE__) + "/hud.erb"
      end

      def organizer
        t('battle.combat_hud_organizer', :org => @combat.organizer.name)
      end

      def title
        scene = @combat.scene ? @combat.scene.id : t('global.none')
        t('battle.combat_hud_header', :num => @combat.id, :scene => scene)
      end

      def teams
        @combat.active_combatants.sort_by{|c| c.team}.group_by {|c| c.team}
      end


      def format_action(c)
        action = c.action ? c.action.print_action_short : "----"
        "#{action} #{format_stance(c)}"
      end

      def format_stance(c)
        case c.stance
        when "Normal"
          text = ""
        else
          text = "(#{c.stance[0,3].upcase})"
        end

      end

      def format_damage(c)
        return "%xh%xr#{t('battle.ko_status')}%xn" if c.is_ko
        Battle.print_damage(c.total_damage_mod)
      end

      def format_weapon(c)
        weapon = "#{c.weapon}"

        if (c.max_ammo > 0)
          notes = " (#{c.ammo})"
        else
          notes = ""
        end

        "#{weapon}#{notes}"
      end
    end
  end
end
