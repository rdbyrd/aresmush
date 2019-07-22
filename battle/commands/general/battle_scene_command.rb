module AresMUSH
  module Battle

    #BattleSceneCommand should allow for combat within a specific scene, tying it to a battle log
    class BattleSceneCommand
      include CommandHandler

      #get scene id
      attr_accessor :scene id

      #parse argument to ensure only the scene's number passes through
      def parse_args
        self.scene_id = integer_arg(cmd.args)
      end

      #prevent user from taking action when not in combat
      def handle
        if(!enactor.is_in_combat?)
          client.emit_failure t('battle.you_are_not_in_combat')
          return
        end

        combat = enactor.combat
        scene = Scene[self.scene_id]

        #prevent a user from initiating combat when not in a scene
        if(!scene)
          client.emit_failure t('battle.invalid_scene')
          return
        end

        # database updates for combat within a scene
        combat.update(scene: scene)
        client.emit_success t('battle.scene_set', :scene => scene.id)

      end
    end
  end
end
