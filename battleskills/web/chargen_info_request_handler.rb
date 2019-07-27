module AresMUSH
  module BattleSkills
    class ChargenInfoRequestHandler
      def handle(request)
        
        {
          abilities: BattleSkills::AbilitiesRequestHandler.new.handle(request),
          skill_limits: Global.read_config('battleskills', 'max_skills_at_or_above'),
          attr_limits: Global.read_config('battleskills', 'max_attrs_at_or_above'),
          max_attrs: Global.read_config('battleskills', 'max_points_on_attrs'),
          max_action: Global.read_config('battleskills', 'max_points_on_action'),
          min_action_skill_rating: Global.read_config('battleskills', 'allow_unskilled_action_skills') ? 0 : 1,
          max_skill_rating: Global.read_config('battleskills', 'max_skill_rating'),
          max_attr_rating: Global.read_config('battleskills', 'max_attr_rating'),
          min_backgrounds: Global.read_config('battleskills', 'min_backgrounds'),
          free_languages:  Global.read_config('battleskills', 'free_languages'),
          free_backgrounds:  Global.read_config('battleskills', 'free_backgrounds'),
          advantages_cost: Global.read_config("battleskills", "advantages_cost"),
          max_ap: Global.read_config('battleskills', 'max_ap'),
          max_dots_action: BattleSkills.max_dots_in_action,
          max_dots_attrs: BattleSkills.max_dots_in_attrs,
          xp_costs: Global.read_config('battleskills', 'xp_costs'),
          allow_advantages_xp: Global.read_config('battleskills', 'allow_advantages_xp'),
          use_advantages: Global.read_config('battleskills', 'use_advantages')
        } 
      end
    end
  end
end


