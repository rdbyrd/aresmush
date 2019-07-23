module AresMUSH
  module Battle

    #Get data about combatants and post required information for fighting
    class SaveCombatSetupRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor

        error = Website.check_login(request)
        return error if error

        combat = Combat[id]
        if (!combat)
          return { error: t('battle.invalid_combat_number') }
        end

        can_manage = enactor && (enactor == combat.organizer || enactor.is_admin?)
        if (!can_manage)
          return { error: t('dispatcher.not_allowed') }
        end

        combatants = request.args[:combatants]
        combatants.each do |key, combatant_data|

          combatant = Combatant[combatant_data[:id]]

          if (!combatant)
            return { error: t('battle.not_in_combat', :name => combatant_data[:name])}
          end

          team = combatant_data[:team].to_i
          stance = combatant_data[:stance]
          weapon = combatant_data[:weapon]
          selected_weapon_specials = (combatant_data[:weapon_specials] || [])
             .select { |k, w| (w[:selected] || "").to_bool }
              .map { |k, w| w[:name] }
          armor = combatant_data[:armor]
          selected_armor_specials = (combatant_data[:armor_specials] || [])
            .select { |k, a| (a[:selected] || "").to_bool }
            .map { |k, a| a[:name] }
          npc_level = combatant_data[:npc_skill]

          error = Battle.update_combatant(combat, combatant, enactor, team, stance, weapon, selected_weapon_specials, armor, selected_armor_specials, npc_level)

          if (error)
            return { error: error }
          end
        end

        {
        }
      end
    end
  end
end
