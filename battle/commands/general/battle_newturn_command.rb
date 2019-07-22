module AresMUSH
  module Battle
    class CombatNewTurnCmd
      include CommandHandler
      include NotAllowedWhileTurnInProgress

      #handle combat conditions and report a status to the user
      def handle
        if (!enactor.is_in_combat?)
          client.emit_failure t('battle.you_are_not_in_combat')
          return
        end

        combat = enactor.combat

        if (combat.organizer != enactor)
          client.emit_failure t('battle.only_organizer_can_do')
          return
        end

        combat.log "****** NEW COMBAT TURN ******"

        #first turn command, accounts initially for NPCs.
        if (combat.first_turn)
          combat.active_combatants.select { |c| c.is_npc? && !c.action }.each_with_index do |c, i|
            Battle.ai_action(combat, client, c)
          end
          Battle.emit_to_combat combat, t('battle.new_turn', :name => enactor_name)
          combat.update(first_turn: false)
          return
        end

        Battle.emit_to_combat combat, t('battle.starting_turn_resolution', :name => enactor_name)
        combat.update(turn_in_progress: true)
        combat.update(everyone_posed: false)

        Global.dispatcher.spawn("Combat Turn", client) do
            begin
              initiative_order = Battle.get_initiative_order(combat)

              initiative_order.each do |id|
                c = Combatant[id]
                next if !c.action
                next if c.is_noncombatant?

                combat.log "Action #{c.name} #{c.action ? c.action.print_action_short : "-"} #{c.is_noncombatant}"

                messages = c.action.resolve
                messages.each do |m|
                  Battle.emit_to_combat combat, m, nil, true
                end

              end

              combat.log "---- Resolutions ----"
              combat = enactor.combat
              combat.active_combatants.each { |c| Battle.reset_for_new_turn(c)}

              #this will reset an action if everyone is knocked out
              combat.active_combatants.each { |c| c.action }

              Battle.emit_to_combat combat, t('battle.new_turn', :name => enactor_name)
            ensure
              combat.update(turn_in_progress: false)
            end
          end
        end
      end
    end
  end
