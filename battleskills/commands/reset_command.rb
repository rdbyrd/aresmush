module AresMUSH

  module BattleSkills
    class ResetCommand
      include CommandHandler

      def check_chargen_locked
        Chargen.check_chargen_locked(enactor)
      end

      def handle
        BattleSkills.reset_char(enactor)
        client.emit_success t('battleskills.reset_complete')
      end
    end
  end
end
