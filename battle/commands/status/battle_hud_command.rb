module AresMUSH
  module Battle
    class CombatHudCommand
      include CommandHandler

      def handle
        combat = Battle.combat(enactor.name)

        #report error to user if not in combat
        if (!combat)
          client.emit_failure t('battle.you_are_not_in_combat')
          return
        end

        #emit a new template for combat
        template = CombatHudTemplate.new(combat)
        client.emit template.render
      end
    end
  end
end
