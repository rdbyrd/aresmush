module AresMUSH
  module Battle
    describe Battle do

      before do
        allow(Global).to receive(:read_config).with("battle", "recovery_skill") { "Body" }
        allow(Global).to receive(:read_config).with("battle", "treat_skill") { "First Aid" }
        stub_translate_for_testing
      end

      describe :print_damage do
        it "should print the right damage" do
          expect(Battle.print_damage(-0)).to eq "%xr%xn----"
          expect(Battle.print_damage(-0.25)).to eq "%xrX%xn---"
          expect(Battle.print_damage(-1.0)).to eq "%xrX%xn---"
          expect(Battle.print_damage(-1.25)).to eq "%xrXX%xn--"
          expect(Battle.print_damage(-2.25)).to eq "%xrXXX%xn-"
          expect(Battle.print_damage(-3.25)).to eq "%xrXXXX%xn"
          expect(Battle.print_damage(-5)).to eq "%xrXXXX%xn"
        end
      end

      describe :total_damage_mod do
        it "should count all wound levels" do
          damage1 = double
          damage2 = double
          allow(damage1).to receive(:wound_mod) { 1 }
          allow(damage2).to receive(:wound_mod) { 2 }
          wounds = [ damage1, damage2 ]
          char = double
          allow(char).to receive(:damage) { wounds }
          expect(Battle.total_damage_mod(char)).to eq -3
        end

        it "should count empty damage" do
          char = double
          allow(char).to receive(:damage) { [] }
          expect(Battle.total_damage_mod(char)).to eq 0
        end
      end

      describe :heal_wounds do
        before do
          @char = double
          allow(@char).to receive(:name) { "Bob" }
          @damage1 = double
          @damage2 = double
          allow(@damage1).to receive(:healing_points) { 2 }
          allow(@damage2).to receive(:healing_points) { 2 }
          @wounds =  [@damage1, @damage2]
          allow(Battle).to receive(:is_in_hospital?) { false }
          allow(@char).to receive(:doctors) { [] }
          allow(@char).to receive(:damage) { @wounds }
          allow(FS3Skills).to receive(:one_shot_roll) { { :successes => 0 } }
        end

        it "should apply a base of 1 healing point to each wound" do
          expect(Battle).to receive(:heal).with(@damage1, 1)
          expect(Battle).to receive(:heal).with(@damage2, 1)
          Battle.heal_wounds(@char)
        end

        it "should add a recovery roll to the healing points" do
          expect(FS3Skills).to receive(:one_shot_roll) do |char, roll_params|
            expect(char).to eq @char
            expect(roll_params.ability).to eq "Body"
            { :successes => 4 }
          end
          expect(Battle).to receive(:heal).with(@damage1, 2)
          expect(Battle).to receive(:heal).with(@damage2, 2)
          Battle.heal_wounds(@char)
        end

        it "should add 1 if in hospital" do
          allow(Battle).to receive(:is_in_hospital?) { true }
          expect(Battle).to receive(:heal).with(@damage1, 2)
          expect(Battle).to receive(:heal).with(@damage2, 2)
          Battle.heal_wounds(@char)
        end

        it "should add 1 if under doctor's care" do
          doctor = double
          allow(doctor).to receive(:name) { "Dr. Carter" }
          allow(@char).to receive(:doctors) { [doctor] }
          expect(Battle).to receive(:heal).with(@damage1, 2)
          expect(Battle).to receive(:heal).with(@damage2, 2)
          Battle.heal_wounds(@char)
        end

        it "should only add 1 if under both doctor and hospital" do
          doctor = double
          allow(doctor).to receive(:name) { "Dr. Carter" }
          allow(Battle).to receive(:is_in_hospital?) { true }
          allow(@char).to receive(:doctors) { [doctor] }
          allow(FS3Skills).to receive(:one_shot_roll) { { :successes => 3 } }
          expect(Battle).to receive(:heal).with(@damage1, 2)
          expect(Battle).to receive(:heal).with(@damage2, 2)
          Battle.heal_wounds(@char)
        end
      end


      describe :heal do
        before do
          allow(Global).to receive(:read_config).with("battle", "healing_points", "FLESH") { 5 }
          allow(Global).to receive(:read_config).with("battle", "healing_points", "HEAL") { 0 }
          @damage = double
          allow(@damage).to receive(:is_stun) { false }
          allow(@damage).to receive(:save)
        end

        it "should not touch a healed wound" do
          allow(@damage).to receive(:healing_points) { 0 }
          expect(@damage).to_not receive(:save)
          Battle.heal(@damage, 1)
        end

        it "should subtract healing points" do
          allow(@damage).to receive(:healing_points) { 5 }
          expect(@damage).to receive(:update).with(healing_points: 3)
          expect(@damage).to receive(:update).with(healed: true)
          Battle.heal(@damage, 2)
        end

        it "should heal stun wounds overnight" do
          allow(@damage).to receive(:healing_points) { 8 }
          allow(@damage).to receive(:is_stun) { true }
          expect(@damage).to receive(:update).with(healing_points: 0)
          expect(@damage).to receive(:update).with(healed: true)
          expect(@damage).to receive(:update).with(current_severity: "HEAL")
          Battle.heal(@damage, 2)
        end

        it "should lower severity and reset points when a wound gets enough healing points" do
          allow(@damage).to receive(:healing_points) { 2 }
          allow(@damage).to receive(:current_severity) { "IMPAIR" }
          expect(@damage).to receive(:update).with(healing_points: 5)
          expect(@damage).to receive(:update).with(healed: true)
          expect(@damage).to receive(:update).with(current_severity: "FLESH")
          Battle.heal(@damage, 2)
        end

        it "should reset healing points for a healed wound" do
          allow(@damage).to receive(:healing_points) { 2 }
          allow(@damage).to receive(:current_severity) { "FLESH" }
          expect(@damage).to receive(:update).with(healing_points: 0)
          expect(@damage).to receive(:update).with(healed: true)
          expect(@damage).to receive(:update).with(current_severity: "HEAL")
          Battle.heal(@damage, 3)
        end
      end

      describe :worst_treatable_wound do
        before do
          @char = double
          @damage1 = double
          @damage2 = double
          @damage3 = double

          allow(@damage1).to receive(:current_severity) { "FLESH" }
          allow(@damage2).to receive(:current_severity) { "INCAP" }
          allow(@damage3).to receive(:current_severity) { "IMPAIR" }

          allow(@damage1).to receive(:is_treatable?) { true }
          allow(@damage2).to receive(:is_treatable?) { true }
          allow(@damage3).to receive(:is_treatable?) { true }
        end

        it "should return the most serious wound if all treatable" do
          allow(@char).to receive(:damage) { [@damage1, @damage2, @damage3] }
          expect(Battle.worst_treatable_wound(@char)).to eq @damage2
        end

        it "should ignore treated wounds" do
          allow(@damage2).to receive(:is_treatable?) { false }
          allow(@char).to receive(:damage) { [@damage1, @damage2, @damage3] }
          expect(Battle.worst_treatable_wound(@char)).to eq @damage3
        end

        it "should return nil if no treatable wounds" do
          allow(@damage1).to receive(:is_treatable?) { false }
          allow(@damage2).to receive(:is_treatable?) { false }
          allow(@damage3).to receive(:is_treatable?) { false }
          allow(@char).to receive(:damage) { [@damage1, @damage2, @damage3] }
          expect(Battle.worst_treatable_wound(@char)).to be_nil
        end

      end

      describe :treat do
        before do
          @patient = double
          @doctor = double

          allow(@patient).to receive(:name) { "Bob" }
          allow(@doctor).to receive(:name) { "Doc" }
          allow(Battle).to receive(:combat)
          @damage = double
          allow(Battle).to receive(:worst_treatable_wound) { @damage }
        end

        it "should not do anything if no treatable wounds" do
          expect(Battle).to receive(:worst_treatable_wound).with(@patient) { nil }
          expect(Battle).to_not receive(:heal)
          expect(Battle.treat(@patient, @doctor)).to eq "battle.no_treatable_wounds"
        end

        it "should add a healing point if treat roll successful" do
          allow(Global).to receive(:read_config).with("battle", "treat_skill") { "Medicine" }
          expect(@doctor).to receive(:roll_ability).with("Medicine") { { successes: 2 }}

          expect(Battle).to receive(:heal).with(@damage, 1)
          expect(Battle.treat(@patient, @doctor)).to eq "battle.treat_success"
        end

        it "should not heal if treat roll unsuccessful" do
          allow(Global).to receive(:read_config).with("battle", "treat_skill") { "Medicine" }
          expect(@doctor).to receive(:roll_ability).with("Medicine") { { successes: 0 }}

          expect(Battle).to_not receive(:heal)
          expect(Battle.treat(@patient, @doctor)).to eq "battle.treat_failed"
        end
      end
    end
  end
end
