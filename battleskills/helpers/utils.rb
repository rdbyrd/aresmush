module AresMUSH
  module BattleSkills
    def self.can_manage_abilities?(actor)
      actor.has_permission?("manage_abilities")
    end
    
    def self.can_view_sheets?(actor)
      return true if Global.read_config("battleskills", "public_sheets")
      return false if !actor
      actor.has_permission?("view_sheets")
    end

    def self.attrs
      Global.read_config("battleskills", "attributes")
    end
    
    def self.action_skills
      Global.read_config("battleskills", "action_skills")
    end 
    
    def self.languages
      Global.read_config("battleskills", "languages")
    end
    
    def self.advantages
      return {} if !BattleSkills.use_advantages?
      Global.read_config("battleskills", "advantages")
    end
    
    def self.use_advantages?
      Global.read_config("battleskills", "use_advantages")
    end
    
    def self.background_skills
      Global.read_config("battleskills", "background_skills")
    end
    
    def self.get_ability_desc(metadata_list, name)
      entry = metadata_list.select { |m| m['name'].upcase == name.upcase }.first
      entry ? entry['desc'] : nil
    end
    
    def self.get_ability_specialties(metadata_list, name)
      entry = metadata_list.select { |m| m['name'].upcase == name.upcase }.first
      entry ? entry['specialties'] : nil
    end
    
    def self.attr_names
      attrs.map { |a| a['name'].titlecase }
    end
    
    def self.advantage_names
      advantages.map { |a| a['name'].titlecase }
    end
    
    def self.action_skill_names
      action_skills.map { |a| a['name'].titlecase }
    end
    
    def self.language_names
      languages.map { |l| l['name'].titlecase }
    end

    def self.action_skill_config(name)
      config = BattleSkills.action_skills.find { |s| s["name"].upcase == name.upcase }
      if (!config)
        raise "Error in skills configuration -- action skill #{name} not found."
      end
      config
    end
    
    def self.attr_blurb
      Global.read_config("battleskills", "attributes_blurb")
    end
    
    def self.action_blurb
      Global.read_config("battleskills", "action_skills_blurb")
    end
    
    def self.bg_blurb
      Global.read_config("battleskills", "bg_skills_blurb")
    end
    
    def self.language_blurb
      Global.read_config("battleskills", "language_blurb")
    end
    
    def self.advantages_blurb
      Global.read_config("battleskills", "advantages_blurb")
    end
    
    # Returns the type (attribute, action, etc) for a skill being rolled.
    def self.get_ability_type(ability)
      ability = ability.titlecase
      if (attr_names.include?(ability))
        return :attribute
      elsif (action_skill_names.include?(ability))
        return :action
      elsif (language_names.include?(ability))
        return :language
      elsif (advantage_names.include?(ability))
        return :advantage
      else
        return :background
      end        
    end
    
    private
    
    def self.add_to_hash(hash, char, skill)
      if (hash[skill.name])
        hash[skill.name] << "#{char.name}:#{skill.rating}"
      else
        hash[skill.name] = ["#{char.name}:#{skill.rating}"]
      end
    end  
  end
end