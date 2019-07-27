module AresMUSH
  module BattleSkills
    class AbilitiesRequestHandler
      def handle(request)
        attrs = BattleSkills.attrs.map { |a| { name: a['name'].titleize, description: a['desc'] } }
        backgrounds = BattleSkills.background_skills.map { |name, desc| { name: name, description: desc } }
        action_skills = BattleSkills.action_skills.sort_by { |a| a['name'] }.map { |a| {
          name: a['name'].titleize,
          linked_attr: a['linked_attr'],
          description: a['desc'],
          specialties: a['specialties'] ? a['specialties'].join(', ') : nil,
        }}
        languages = BattleSkills.languages.sort_by { |a| a['name'] }.map { |a| { name: a['name'], description: a['desc'] } }
        advantages = BattleSkills.advantages.sort_by { |a| a['name'] }.map { |a| { name: a['name'], description: a['desc'] } }
        
        {
          attrs_blurb: Website.format_markdown_for_html(BattleSkills.attr_blurb),
          action_blurb: Website.format_markdown_for_html(BattleSkills.action_blurb),
          background_blurb: Website.format_markdown_for_html(BattleSkills.bg_blurb),
          language_blurb: Website.format_markdown_for_html(BattleSkills.language_blurb),
          advantages_blurb:  Website.format_markdown_for_html(BattleSkills.advantages_blurb),          
          
          attrs: attrs,
          action_skills: action_skills,
          backgrounds: backgrounds,
          languages: languages,
          advantages: advantages,
          use_advantages: BattleSkills.use_advantages?
        } 
      end
    end
  end
end


