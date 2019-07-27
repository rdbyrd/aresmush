module AresMUSH

  module BattleSkills
    class CharBackupCommand
      include CommandHandler
      
      attr_accessor :target
      
      def parse_args
        self.target = !command.args ? enactor.name : titlecase_arg(command.args)
      end
      
      def check_permission
        return nil if self.target == enactor.name
        return nil if BattleSkills.can_view_sheets?(enactor)
        return t('battleskills.no_permission_to_backup')
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.target, client, enactor) do |model|
          
          ["sheet", "bg", "profile", "damage", "relationships"].each_with_index do |command, seconds|
            Global.dispatcher.queue_timer(seconds, "Character backup #{model.name}", client) do
              Global.dispatcher.queue_command(client, Command.new("#{command} #{model.name}"))
            end
          end
          
          template = Describe.desc_template(model, enactor)
          client.emit template.render
        end
        
        
      end
    end
  end
end
