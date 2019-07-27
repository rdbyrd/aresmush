module AresMUSH
  module BattleSkills    
    class XpCronHandler
      def on_event(event)
        config = Global.read_config("battleskills", "xp_cron")
        return if !Cron.is_cron_match?(config, event.time)
        
        Global.logger.debug "XP awards."
        
        periodic_xp = Global.read_config("battleskills", "periodic_xp")
        max_xp = Global.read_config("battleskills", "max_xp_hoard")
        
        approved = Chargen.approved_chars
        approved.each do |a|
          BattleSkills.modify_xp(a, periodic_xp)
        end
      end
    end    
  end
end