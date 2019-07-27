module AresMUSH

  module BattleSkills
    class AbilitiesCommand
      include CommandHandler
      
      def handle
        
        num_pages = BattleSkills.use_advantages? ? 5 : 4
        
        case command.page
        when 1
          template = AbilityPageTemplate.new("/attributes.erb", 
              { attrs: BattleSkills.attrs, num_pages: num_pages, page: command.page })
        when 2
          template = AbilityPageTemplate.new("/action_skills.erb", 
              { skills: BattleSkills.action_skills.sort_by { |a| a['name'] }, num_pages: num_pages, page: command.page })
        when 3
          template = AbilityPageTemplate.new("/background_skills.erb", 
              { skills: BattleSkills.background_skills, num_pages: num_pages, page: command.page } )
        when 4
          template = AbilityPageTemplate.new("/languages.erb", 
              { skills: BattleSkills.languages.sort_by { |a| a['name'] }, num_pages: num_pages, page: command.page })
        when 5 
          if (BattleSkills.use_advantages?)
            template = AbilityPageTemplate.new("/advantages.erb",
               { advantages: BattleSkills.advantages.sort_by { |a| a['name'] }, num_pages: num_pages, page: command.page })
           else
             client.emit_failure t('pages.not_that_many_pages')
             return
           end
        else
          client.emit_failure t('pages.not_that_many_pages')
          return
        end
      
        client.emit template.render
      end
    end
  end
end
