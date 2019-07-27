module AresMUSH

  module BattleSkills
    class SheetCommand
      include CommandHandler
      
      attr_accessor :target
      
      def parse_args
        self.target = !command.args ? enactor_name : titlecase_arg(command.args)
      end
      
      def check_permission
        return nil if self.target == enactor_name
        return nil if BattleSkills.can_view_sheets?(enactor)
        return nil if Global.read_config("battleskills", "public_sheets")
        return t('battleskills.no_permission_to_view_sheet')
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.target, client, enactor) do |model|
          template = SheetTemplate.new(model, client)
          client.emit template.render
        end
      end
    end
  end
end
