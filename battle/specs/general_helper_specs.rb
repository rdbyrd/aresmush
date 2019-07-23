module AresMUSH
  module Battle
    describe Battle do
      include GlobalTestHelper

      describe :find_combat_by_number do
        before do
          @combat1 = double
          @combat2 = double
          @client = double
          allow(Combat).to receive(:[]).with(1) { @combat1 }
          allow(Combat).to receive(:[]).with(2) { @combat2 }
          allow(Combat).to receive(:[]).with(3) { nil }
          stub_translate_for_testing
        end

        it "should fail if not a number" do
          expect(@client).to receive(:emit_failure).with("battle.invalid_combat_number")
          expect(Battle.find_combat_by_number(@client, "A")).to be_nil
        end

        it "should fail if not a valid number" do
          expect(@client).to receive(:emit_failure).with("battle.invalid_combat_number")
          expect(Battle.find_combat_by_number(@client, 3)).to be_nil
        end

        it "should succeed if valid number string specified" do
          expect(Battle.find_combat_by_number(@client, "1")).to eq @combat1
          expect(Battle.find_combat_by_number(@client, "2")).to eq @combat2
        end

        it "should succeed if valid number specified" do
          expect(Battle.find_combat_by_number(@client, 1)).to eq @combat1
          expect(Battle.find_combat_by_number(@client, 2)).to eq @combat2
        end

      end
    end

    describe :get_initiative_order do
      it "should return combatants in order of initiative roll" do
        @combat = double
        allow(@combat).to receive(:log)
        @combatant1 = double
        @combatant2 = double
        @combatant3 = double

        allow(@combatant1).to receive(:name) { "A" }
        allow(@combatant2).to receive(:name) { "B" }
        allow(@combatant3).to receive(:name) { "C" }

        allow(@combatant1).to receive(:id) { 1 }
        allow(@combatant2).to receive(:id) { 2 }
        allow(@combatant3).to receive(:id) { 3 }

        allow(@combat).to receive(:active_combatants) { [ @combatant1, @combatant2, @combatant3 ]}

        allow(Global).to receive(:read_config).with("battle", "initiative_skill") { "init" }

        expect(Battle).to receive(:roll_initiative).with(@combatant1, "init") { 3 }
        expect(Battle).to receive(:roll_initiative).with(@combatant2, "init") { 5 }
        expect(Battle).to receive(:roll_initiative).with(@combatant3, "init") { 1 }

        expect(Battle.get_initiative_order(@combat)).to eq [ 2, 1, 3 ]
      end
    end


  end
end
