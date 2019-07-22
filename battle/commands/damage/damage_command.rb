module AresMUSH
  module Battle
    class DamageCommand
      include CommandHandler

      #get the name of target object
      attr_accessor :name

      def parse_args
        self.name = cmd.args ? titlecase_arg(cmd.args) : enactor.name
      end

      def handle
        target = Battle.find_named_thing(self.name, enactor)

        if (target)
          template = DamageTemplate.new(target)
          client.emit template.render
        else
          client.emit_failure t('db.object_not_found')
        end
      end
    end
  end
end
