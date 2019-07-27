module AresMUSH
  module BattleSkills
    class CharAbilitiesRequestHandler
      def handle(request)
        char = Character.find_one_by_name request.args[:id]
        enactor = request.enactor

        if (!char)
          return []
        end

        error = Website.check_login(request, true)
        return error if error


        can_view = BattleSkills.can_view_sheets?(enactor) || (enactor && enactor.id == char.id)
        if (!can_view)
          return { error: t('dispatcher.not_alllowed') }
        end

        abilities = []

        [ char.battle_attributes, char.battle_action_skills, char.battle_background_skills, char.battle_languages, char.battle_advantages ].each do |list|
          list.each do |a|
            abilities << a.name
          end
        end

        return abilities
      end
    end
  end
end
