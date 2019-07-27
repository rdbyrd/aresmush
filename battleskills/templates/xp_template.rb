module AresMUSH
  module BattleSkills
    # Template for an exit.
    class XpTemplate < ErbTemplateRenderer
        
      attr_accessor :char
          
      def initialize(char)
        @char = char
        super File.dirname(__FILE__) + "/xp.erb"        
      end
              
      def display(a)
        "#{left(a.name, 20)} #{progress(a)} #{detail(a)} #{days_left(a)}"
      end
      
      def detail(a)
        can_raise = !BattleSkills.check_can_learn(@char, a.name, a.rating)
        status = can_raise ? "(#{a.xp}/#{a.xp_needed})" : "(---)"
        status.ljust(16)
      end
      
      def days_left(a)
        time_left = BattleSkills.days_to_next_learn(a)
        message = time_left == 0 ? t('battleskills.xp_days_now') : t('battleskills.xp_days', :days => time_left)
        center(message, 13)
      end
      
      def progress(a)
        can_raise = !BattleSkills.check_can_learn(@char, a.name, a.rating)
        return ".........." if !can_raise
        ProgressBarFormatter.format(a.xp, a.xp_needed)
      end
      
      def show_advantages
        Global.read_config("battleskills", "use_advantages")
      end
      
      def allow_advantages_xp
        Global.read_config("battleskills", "allow_advantages_xp")
      end
      
    end
  end
end
