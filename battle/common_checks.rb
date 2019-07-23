module AresMUSH
  module Battle

    #module designed for many classes in this plugin to disable noncombatants from taking actions
    #and it will check a user to stop them from spamming actions when it is not their turn
    module NotAllowedWhileTurnInProgress
      def check_turn_in_progress
        combat = enactor.combat
        return nil if !combat
        return t('battle.turn_in_progress') if combat.turn_in_progress
        return nil
      end
    end
  end
end
