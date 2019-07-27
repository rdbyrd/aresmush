module AresMUSH
  module BattleSkills
    def self.can_manage_xp?(actor)
      actor.has_permission?("manage_abilities")
    end
    
    def self.modify_xp(char, amount)
      max_xp = Global.read_config("battleskills", "max_xp_hoard")
      xp = char.xp + amount
      xp = [max_xp, xp].min
      char.update(fs3_xp: xp)
    end
    
    def self.days_between_learning
      Global.read_config("battleskills", "days_between_learning")
    end
    
    def self.xp_needed(ability_name, rating)
      ability_type = BattleSkills.get_ability_type(ability_name)
      costs = Global.read_config("battleskills", "xp_costs")
      costs = costs[ability_type.to_s]
      # Goofiness needed because XP keys could be either strings or integers.
      key = costs.keys.select { |r| r.to_s == rating.to_s }.first
      key ? costs[key] : nil
    end
    
    def self.days_to_next_learn(ability)
      (ability.time_to_next_learn / 86400).ceil
    end
    
    def self.check_can_learn(char, ability_name, rating)
      return t('battleskills.cant_raise_further_with_xp') if self.xp_needed(ability_name, rating) == nil

      ability_type = BattleSkills.get_ability_type(ability_name)
      
      if (ability_type == :attribute)
        # Attrs cost 2 points per dot
        dots_beyond_chargen = Global.read_config("battleskills", "attr_dots_beyond_chargen_max") || 2
        max = Global.read_config("battleskills", "max_points_on_attrs") + (dots_beyond_chargen * 2)
        points = AbilityPointCounter.points_on_attrs(char)
        new_total = points + 2
      elsif (ability_type == :action)
        dots_beyond_chargen = Global.read_config("battleskills", "action_dots_beyond_chargen_max") || 3
        max = Global.read_config("battleskills", "max_points_on_action") + dots_beyond_chargen
        points = AbilityPointCounter.points_on_action(char)
        new_total = points + 1
      else
        return nil
      end
      
      return max >= new_total ? nil : t('battleskills.max_ability_points_reached')
    end
    
    def self.learn_ability(char, name)
      return t('battleskills.not_enough_xp') if char.xp <= 0
      
      ability = BattleSkills.find_ability(char, name)
      
      ability_type = BattleSkills.get_ability_type(name)
      if (ability_type == :advantage && !Global.read_config("battleskills", "allow_advantages_xp"))
        return t('battleskills.cant_learn_advantages_xp')
      end
      
      if (!ability)
        BattleSkills.set_ability(char, name, 1)
      else
        
        error = BattleSkills.check_can_learn(char, name, ability.rating)
        if (error)
          return error
        end

        if (!ability.can_learn?)
          time_left = BattleSkills.days_to_next_learn(ability)
          return t('battleskills.cant_raise_yet', :days => time_left)
        end
        
        ability.learn
        if (ability.learning_complete)
          ability.update(xp: 0)
          BattleSkills.set_ability(char, name, ability.rating + 1)
          message = t('battleskills.xp_raised_job', :name => char.name, :ability => name, :rating => ability.rating + 1)
          category = Jobs.system_category
          Jobs.create_job(category, t('battleskills.xp_job_title', :name => char.name), message, Game.master.system_character)        
        end
        
      end 
      
      
      BattleSkills.modify_xp(char, -1)       
      return nil
    end
    
    def self.max_dots_in_action
      base = Global.read_config("battleskills", 'max_points_on_action') || 0
      extra = Global.read_config("battleskills", 'action_dots_beyond_chargen_max') || 0
      base + extra
    end
    
    def self.max_dots_in_attrs
      base = (Global.read_config("battleskills", 'max_points_on_attrs') || 0) / 2
      extra = Global.read_config("battleskills", 'attr_dots_beyond_chargen_max') || 0
      base + extra
    end
  end
end