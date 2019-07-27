module AresMUSH
  module BattleSkills
    class LearnAbilityRequestHandler
      def handle(request)
        ability = request.args[:ability]
        enactor = request.enactor
        
        error = Website.check_login(request)
        return error if error

        error = BattleSkills.learn_ability(enactor, ability)
        if (error)
          return { error: error }
        end
        
        {
        }
      end
    end
  end
end