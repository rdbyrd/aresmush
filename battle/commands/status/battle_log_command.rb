module AresMUSH
  module Battle

    class BattleLogCommand
      include CommandHandler

      # access page attribute so that multiple messages can be sorted through by user
      attr_accessor :page

      def parse_args
        if (!cmd.args)
          self.page = cmd.page
        else
          self.page = cmd.args ? cmd.args.to_i : 1
        end
      end

      def handle
        # ensure user is in combat before they try to invoke the log
        combat = Battle.combat(enactor.name)
        if(!combat)
          client.emit_failure t('battle.you_are_not_in_combat')
          return
        end

        # sort combat log messages chronologically
        if (combat.debug_log)
          list = combat.debug_log.combat_log_messages.sort_by(:timestamp).map {|1| "#{1.created_at} #{1.message}"}.reverse
        else
          list = []
        end

        # make it look pretty
        template = BorderedPagedListTemplate.new list, self.page, 25, t('battle.log_title')
        client.emit template.render
      end
    end
  end
end
