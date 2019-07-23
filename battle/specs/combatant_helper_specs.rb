module AresMUSH
  module Battle
    describe Combatant do
      before do
        @combatant = double
        @char = double
        allow(@combatant).to receive(:log)
        allow(@combatant).to receive(:name) { "Trooper" }
        allow(@combatant).to receive(:character) { @char }
        stub_translate_for_testing
      end
        
      describe :roll_attack do
        before do
          allow(Battle).to receive(:weapon_stat).with("Knife", "skill") { "Knives" }
          allow(Battle).to receive(:weapon_stat).with("Knife", "accuracy") { 0 }
          allow(@combatant).to receive(:weapon) { "Knife" }
          @target = double
        end

        it "should roll the weapon attack stat" do
          expect(@combatant).to receive(:roll_ability).with("Knives", 0)
          Battle.roll_attack(@combatant, @target)
        end

        it "should account for stance modifiers" do
          allow(@combatant).to receive(:attack_stance_mod) { 1 }
          expect(@combatant).to receive(:roll_ability).with("Knives", 1)
          Battle.roll_attack(@combatant, @target)
        end
      end

      describe :roll_defense do
        before do
          allow(@combatant).to receive(:total_damage_mod) { 0 }
          allow(@combatant).to receive(:defense_stance_mod) { 0 }
          allow(@combatant).to receive(:defense_mod) { 0 }
          allow(@combatant).to receive(:armor) { "armor" }
          allow(Battle).to receive(:weapon_defense_skill) { "Reaction" }
          allow(Battle).to receive(:armor_stat) { 0 }
        end

        it "should roll the weapon defense stat" do
          expect(Battle).to receive(:weapon_defense_skill).with(@combatant, "Knife") { "Reaction" }
          expect(@combatant).to receive(:roll_ability).with("Reaction", 0)
          Battle.roll_defense(@combatant, "Knife")
        end

        it "should account for wound modifiers" do
          allow(@combatant).to receive(:total_damage_mod) { -1 }
          expect(@combatant).to receive(:roll_ability).with("Reaction", -1)
          Battle.roll_defense(@combatant, "Knife")
        end


        end
      end
    end
