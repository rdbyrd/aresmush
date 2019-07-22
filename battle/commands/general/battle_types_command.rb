module AresMUSH
  module Battle
    class BattleTypesCommand
      include CommandHandler

      def handle
        template = CombatTypesTemplate.new(Battle.combatant_types)
        client.emit template.render
      end
    end
  end
end
