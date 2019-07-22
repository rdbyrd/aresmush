module AresMUSH
  module Battle

    #purpose of stances remains unclear, passed to Battle plugin for completion
    #for the time being
    class BattleStancesCommand
      include CommandHandler

      def handle
        template = StancesTemplate.new(Battle.stances)
        client.emit template.render
      end
    end
  end
end
