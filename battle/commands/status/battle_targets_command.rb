module AresMUSH
  module Battle
    class BattleTargetsCommand
      include CommandHandler

      #allow actions only if user in combat
      def handle
        combat = Battle.combat(enactor.name)
        if (!combat)
          client.emit_failure t('battle.you_are_not_in_combat')
          return
        end


        if (combat.organizer != enactor)
          client.emit_failure t('battle.only_organizer_can_do')
          return
        end

        #create BattleTargetsTemplate later, find original CombatTargetsTemplate class
        template = BattleTargetsTemplate.new(combat)
        client.emit template.render
      end

    end
  end
end
