module AresMUSH

  module BattleSkills
    class SkillScanCommand
      include CommandHandler

      attr_accessor :name

      def parse_args
        self.name = trim_arg(command.args)
      end

      def required_args
        [ self.name ]
      end

      def check_permission
        return nil if BattleSkills.can_view_sheets?(enactor)
        return nil if Global.read_config("battleskills", "public_sheets")
        return t('battleskills.no_permission_to_view_sheet')
      end
      
      def handle
        Global.logger.debug "Name: #{self.name}"
        type = self.name.titlecase
        types = [ 'Action', 'Background', 'Language', 'Bg' ]
        if (types.include?(type))
          if (type == 'Bg')
            type = 'Background'
          end
          template = SkillsCensusTemplate.new(type)
          client.emit template.render
        else
          skill_type = BattleSkills.get_ability_type(self.name)
          case skill_type
          when :attribute
            min_rating = 3
          when :action
            min_rating = 2
          else
            min_rating = 1
          end
          chars = Chargen.approved_chars
          .select { |c| BattleSkills.ability_rating(c, self.name) >= min_rating }
          .sort_by { |c| c.name }
          .map { |c| "%xn#{color(c)}#{c.name}#{room_marker(c)}%xn" }
          client.emit_ooc chars.join(", ")
        end
      end

      def color(char)
        char.room == enactor_room ? "%xh%xg" : ""
      end

      def room_marker(char)
        char.room == enactor_room ? "*" : ""
      end
    end
  end
end