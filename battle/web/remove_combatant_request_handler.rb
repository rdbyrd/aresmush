module AresMUSH
  module Battle

    #exit combat in either webportal or MUSH client using this class
    class RemoveCombatantRequestHandler
      def handle(request)
        id = request.args[:id]
        enactor = request.enactor

        error = Website.check_login(request)
        return error if error

        combatant = Combatant[id]
        if (!combatant)
          return { error: t('webportal.not_found') }
        end

        combat = combatant.combat
        can_manage = (enactor == combat.organizer) || enactor.is_admin? || (enactor.name == combatant.name)

        if (!can_manage)
          return { error: t('dispatcher.not_allowed') }
        end

        Battle.leave_combat(combat, combatant)
        {
        }
      end
    end
  end
end
