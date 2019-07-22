module AresMUSH
  module Battle

    #make the combat screen look pretty
    class BattleListCommand
      include CommandHandler

      #provide a template (box-ish type feature) to list combatants in
      def handle
        list = Battle.combats.map { |c| format_combat(c)}
        template = BorderedListTemplate.new list, t('battle.active_combats'), nil, t('battle.active_combats_titlebar')
        client.emit template.render

      end

      #list combatants left justified
      def format_combat(combat)
        combatants = combat.combatants.map { |c| c.name }.join(" ")
        num = combat.id.to_s
        "#{num.ljust(3)} #{combat.organizer.name.ljust(15)} #{combatants}"
      end
    end
  end
end
