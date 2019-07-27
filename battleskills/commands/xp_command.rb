module AresMUSH

  module BattleSkills
    class XpCommand
      include CommandHandler

      attr_accessor :target

      def parse_args
        self.target = !command.args ? enactor_name : trim_arg(command.args)
      end

      def handle
        ClassTargetFinder.with_a_character(self.target, client, enactor) do |model|
          if (!can_view_xp(model))
            client.emit_failure t('dispatcher.not_allowed')
            return
          end

          template = XpTemplate.new(model)
          client.emit template.render
        end
      end

      def can_view_xp(char)
        return true if self.target == enactor_name
        return true if enactor.has_permission?("view_sheets")
        AresCentral.is_alt?(enactor, char)
      end
    end
  end
end
