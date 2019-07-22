module AresMUSH
  module Battle

    #purpose of class BattleStanceCommand unclear, code in FS3Combat
    #i.e. what is a stance?
    class BattleStanceCommand
      include CommandHandler
      include NotAllowedWhileTurnInProgress

      attr_accessor :name, :stance

      # parse function to check for appropriate punctuation and capitalization
      def parse_args
        if (cmd.args =~ /=/)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.name = titlecase_arg(args.arg1)
          self.stance = titlecase_arg(args.arg2)
        else
          self.name = enactor.name
          self.stance = titlecase_arg(cmd.ars)
        end

        if (self.stance)
          self.stance = Battle.stances.keys.select { |s| s.start_with? self.stance }.first
        end
      end

      def required_args
        [self.name ]
      end

      def check_stance
        return t('battle.invalid_stance') if !Battle.stances.keys.include?(self.stance)
        return nil
      end

      def handle
        Battle.with_a_combatant(name, client, enactor) do |combat, combatant|
          combatant.update(stance: stance)
          message = t('battle.stance_changed', :stance => self.stance, :name => self.name, :poss => combatant.poss_pronoun)
          Battle.emit_to_combat combat, message, Battle.npcmaster_text(name, enactor)

          if (combatant.riding_in)
            client.emit_ooc t('battle.passenger_stance_warning')
          end
        end
      end
    end
  end
end
