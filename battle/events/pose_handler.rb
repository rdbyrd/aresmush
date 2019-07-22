module AresMUSH
  module Battle
    class PoseEventHandler

      def on_event(event)
        enactor = Character[event.enactor_id]
        combatant = enactor.combatant
        room = Room[event.room_id]
        return if !combatant
        return if event.is_ooc

        combatant.update(posed: true)
        combat = combatant.combat

        #update scene so it is not a combat room when completed or if not a combat scene.
        set_scene = !combat.scene || combat.scene.completed
        if (set_scene && room.scene)
          combat.update(scene: room.scene)
        end

        #sclackers are labeled if character is not an NPC, have not posed, are not knockedout, and are not idle
        slackers = combat.active_combatants.select { |c| !c.is_npc? && !c.posed && !c.is_ko && !c.idle}
        if (slackers.empty? && !combat.everyone_posed)
          Battle.emit_to_organizer combat, t('battle.everyone_posed')
          combat.update(everyone_posed: true)
        end
      end
    end
  end
end
