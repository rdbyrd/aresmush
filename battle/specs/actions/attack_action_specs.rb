module AresMUSH
  module Battle
    describe AttackAction do
      before do
        @combatant = double
        @target = double
        @combat = double

        allow(@combat).to receive(:find_combatant) { @target }
        allow(@combatant).to receive(:combat) { @combat }
        allow(@combatant).to receive(:name) { "A" }
        allow(@target).to receive(:name) { "Target" }
        allow(@target).to receive(:is_noncombatant?) { false }
        stub_translate_for_testing
      end

      describe :prepare do
        it "should parse simple taget" do
          @action = AttackAction.new(@combatant, " target ")
          expect(@action.prepare).to be_nil
        end

        it "should fail if multiple targets" do
          @action = AttackAction.new(@combatant, "target1 target2")
          expect(@action.prepare).to eq "battle.only_one_target"
        end

        it "should succeed" do
          @action = AttackAction.new(@combatant, "target")
          expect(@action.prepare).to be_nil
          expect(@action.targets).to eq [ @target ]
        end
      end
      end
    end
  end
