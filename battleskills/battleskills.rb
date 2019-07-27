$:.unshift File.dirname(__FILE__)

module AresMUSH
  module BattleSkills
    def self.plugin_dir
      File.dirname(__FILE__)
    end

    def self.shortcuts
      Global.read_config("battleskills", "shortcuts")
    end

    def self.get_command_handler(client, command, enactor)
      case command.root
      when "abilities"
        return AbilitiesCommand
      when "backup"
        return CharBackupCommand
      when "specialty"
        if (command.switch_is?("add"))
          return AddSpecialtyCommand
        elsif (command.switch_is?("remove"))
          return RemoveSpecialtyCommand
        end
      when "learn"
        return LearnAbilityCommand
      when "luck"
        case command.switch
        when "award"
          return LuckAwardCommand
        when "spend"
          return LuckSpendCommand
        end
      when "raise", "lower"
        return RaiseAbilityCommand
      when "reset"
        return ResetCommand
      when "roll"
        if (command.args =~ / vs /)
          return OpposedRollCommand
        else
          return RollCommand
        end
      when "sheet"
        return SheetCommand
      when "skill"
        case command.switch
        when "scan"
          return SkillScanCommand
        end
      when "ability"
        return SetAbilityCommand
      when "xp"
        case command.switch
        when "award"
          return XpAwardCommand
        when "undo"
          return XpUndoCommand
        else
          return XpCommand
        end
      end

      nil
    end

    def self.get_event_handler(event_name)
      case event_name
      when "CronEvent"
        return XpCronHandler
      end

      nil
    end

    def self.get_web_request_handler(request)
      case request.command
      when "abilities"
        return AbilitiesRequestHandler
      when "addSceneRoll"
        return AddSceneRollRequestHandler
      when "learnAbility"
        return LearnAbilityRequestHandler
      when"spendLuck"
        return SpendLuckRequestHandler
      end
      nil
    end
  end
end
