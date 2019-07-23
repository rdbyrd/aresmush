module AresMUSH
  module Battle

    #allow combatants to join the battle
    class AddCombatantRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor
        combatant_type = request.args[:combatant_type] || Battle.default_combatant_type
        name = request.args[:name]

        #ensure user is logged in
        error = Website.check_login(request)
        return error if error

        combat = Combat[id]
        if (!combat)
          return { error: t('battle.invalid_combat_number') }
        end

        if (Battle.is_in_combat?(name))
          return { error: t('battle.already_in_combat', :name => name) }
        end

        Battle.join_combat(combat, name, combatant_type, enactor, nil)
        {
        }
      end
    end
  end
end
