module AresMUSH
  module Battle
    describe Battle do
      describe :join_combat do
        before do
          @combat = double
          @enactor = double
          @client = double

          allow(Battle).to receive(:emit_to_combat) {}
          allow(Battle).to receive(:is_in_combat?) { false }
          allow(ClassTargetFinder).to receive(:find) { FindResult.new(nil, "error") }
          allow(Battle).to receive(:combatant_type_stat) { nil }
          allow(Battle).to receive(:set_default_gear)
          allow(Battle).to receive(:handle_combat_join_achievement) {}
          stub_translate_for_testing
        end

        it "should fail if already in combat" do
          expect(Battle).to receive(:is_in_combat?).with("Bob") { true }
          expect(@client).to receive(:emit_failure).with("battle.already_in_combat")
          Battle.join_combat(@combat, "Bob", "soldier", @enactor, @client)
        end

        it "should create a NPC if char not found" do
          expect(ClassTargetFinder).to receive(:find).with("Bob", Character, @enactor) { FindResult.new(nil, "error") }
          npc = double
          expect(Npc).to receive(:create).with(name: "Bob", combat: @combat, level: "Boss") { npc }
          expect(Battle).to receive(:default_npc_type) { "Boss" }
          expect(Combatant).to receive(:create) do |params|
            expect(params[:combatant_type]).to eq "soldier"
            expect(params[:team]).to eq 9
            expect(params[:npc]).to eq npc
            expect(params[:combat]).to eq @combat
          end
          Battle.join_combat(@combat, "Bob", "soldier", @enactor, @client)
        end

        it "should create a combatant for a character if found" do
          char = double
          expect(ClassTargetFinder).to receive(:find).with("Bob", Character, @enactor) { FindResult.new(char) }
          expect(Combatant).to receive(:create) do |params|
            expect(params[:combatant_type]).to eq "soldier"
            expect(params[:team]).to eq 1
            expect(params[:character]).to eq char
            expect(params[:combat]).to eq @combat
          end
          Battle.join_combat(@combat, "Bob", "soldier", @enactor, @client)
        end

        it "should emit join message to combat" do
          combatant = double
          allow(Npc).to receive(:create)
          allow(Combatant).to receive(:create) { combatant }
          expect(Battle).to receive(:emit_to_combat).with(@combat, "battle.has_joined")
          Battle.join_combat(@combat, "Bob", "soldier", @enactor, @client)
        end

        it "should set default gear" do
          combatant = double
          allow(Npc).to receive(:create)
          allow(Combatant).to receive(:create) { combatant }
          expect(Battle).to receive(:set_default_gear).with(@enactor, combatant, "soldier")
          Battle.join_combat(@combat, "Bob", "soldier", @enactor, @client)
        end
      end
    end
  end
end
