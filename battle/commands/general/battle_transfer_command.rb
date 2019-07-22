module AresMUSH
  module Battle
    class BattleTransferCommand
      include CommandHandler
      include NotAllowedWhileTurnInProgress

      attr_accessor :name

      def parse_args
        self.name = titlecase_arg(cmd.args)
      end

      #prevent unnecessary actions from the user if not in combat
      def handle
        if (!enactor.is_in_combat?)
          client.emit_failure t('battle.you_are_not_in_combat')
          return
        end

        combat = enactor.combat

        # output method to report failure of a unit acts outside of combat
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          if (!model.combatant || model.combat != combat)
            client.emit_failure t('battle.must_transfer_to_combatant', :name => self.name)
            return
          end

          #update the server to recognize combat
          combat.update(organizer: model)
          Battle.emit_to_combat combat, t('battle.combat_transferred', :name => self.name)
        end

      end
    end
  end
end
