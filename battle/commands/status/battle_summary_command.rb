module AresMUSH
  module Battle
    class CombatSummaryCommand
      include CommandHandler

      # disallow user actions except in combat
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

        # invoke a template to view on screen of combat actions so far
        template = CombatSummaryTemplate.new(combat)
        client.emit template.render
      end

    end
  end
end
