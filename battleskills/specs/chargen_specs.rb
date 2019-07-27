module AresMUSH
  module BattleSkills
    describe BattleSkills do

      before do
        allow(Global).to receive(:read_config).with("battleskills", "max_skill_rating") { 7 }
        allow(Global).to receive(:read_config).with("battleskills", "max_attr_rating") { 4 }
        allow(BattleSkills).to receive(:attr_names) { [ "Brawn", "Mind" ] }
        allow(BattleSkills).to receive(:action_skill_names) { [ "Firearms", "Demolitions" ] }
        allow(BattleSkills).to receive(:advantage_names) { [ "Rank" ] }
        allow(BattleSkills).to receive(:language_names) { [ "English", "Spanish" ] }
        allow(Global).to receive(:read_config).with("battleskills", "allow_unskilled_action_skills") { false }
        stub_translate_for_testing
      end
      
      describe :check_ability_name do
        it "should not allow funky chars" do
          # Because it will mess up the +/- modifier parsing
          expect(BattleSkills.check_ability_name("X+Y")).to eq "battleskills.no_special_characters"
          expect(BattleSkills.check_ability_name("X-Y")).to eq "battleskills.no_special_characters"
          expect(BattleSkills.check_ability_name("X=Y")).to eq "battleskills.no_special_characters"
          expect(BattleSkills.check_ability_name("X,Y")).to eq "battleskills.no_special_characters"
          
          # For aesthetic reasons
          expect(BattleSkills.check_ability_name("X:.[]|Y")).to eq "battleskills.no_special_characters"
          
          # Because folks on older clients can't see them properly.
          expect(BattleSkills.check_ability_name("XñY")).to eq "battleskills.no_special_characters"
        end
        
        it "should allow spaces and underlines" do
          expect(BattleSkills.check_ability_name("X Y")).to be_nil
          expect(BattleSkills.check_ability_name("X_Y")).to be_nil
        end
      end
      
      describe :check_rating do
        it "should error if below min ratings" do
          expect(BattleSkills.check_rating("Brawn", 0)).to eq "battleskills.min_rating_is"
          expect(BattleSkills.check_rating("Firearms", -1)).to eq "battleskills.min_rating_is"
          expect(BattleSkills.check_rating("English", -1)).to eq "battleskills.min_rating_is"
          expect(BattleSkills.check_rating("Basketweaving", -1)).to eq "battleskills.min_rating_is"
        end
        
        it "should allow unskilled for min rating if configured" do
          allow(Global).to receive(:read_config).with("battleskills", "allow_unskilled_action_skills") { true }
          expect(BattleSkills.check_rating("Brawn", 0)).to eq "battleskills.min_rating_is"
        end
        
        it "should allow min ratings" do
          expect(BattleSkills.check_rating("Brawn", 1)).to be_nil
          expect(BattleSkills.check_rating("Firearms", 1)).to be_nil
          expect(BattleSkills.check_rating("English", 0)).to be_nil
          expect(BattleSkills.check_rating("Basketweaving", 0)).to be_nil
        end

        it "should allow max ratings" do
          expect(BattleSkills.check_rating("Brawn", 4)).to be_nil
          expect(BattleSkills.check_rating("Firearms", 7)).to be_nil
          expect(BattleSkills.check_rating("English", 3)).to be_nil
          expect(BattleSkills.check_rating("Basketweaving", 3)).to be_nil
        end
        
        it "should error if above max ratings" do
          expect(BattleSkills.check_rating("Brawn", 5)).to eq "battleskills.max_rating_is"
          expect(BattleSkills.check_rating("Firearms", 8)).to eq "battleskills.max_rating_is"
          expect(BattleSkills.check_rating("English", 4)).to eq "battleskills.max_rating_is"
          expect(BattleSkills.check_rating("Basketweaving", 4)).to eq "battleskills.max_rating_is"
        end
        
        it "should allow max action skill rating to be configurable" do
          allow(Global).to receive(:read_config).with("battleskills", "max_skill_rating") { 5 }
          expect(BattleSkills.check_rating("Firearms", 5)).to be_nil
          expect(BattleSkills.check_rating("Firearms", 6)).to eq "battleskills.max_rating_is"
        end
      end
      
      describe :set_ability do 
        before do
          allow(BattleSkills).to receive(:check_rating) { nil }
          allow(BattleSkills).to receive(:check_ability_name) { nil }
          
          @char = double
        end
          
        it "should error if abiliy name invalid" do 
          allow(BattleSkills).to receive(:check_ability_name) { "an error" }
          error = BattleSkills.set_ability(@char, "Firearms", 4)
          expect(error).to eq("an error")
        end
        
        context "success" do
          before do
            @ability = double
            allow(@char).to receive(:id) { 1 }
            allow(BattleSkills).to receive(:find_ability).with(@char, "Firearms") { @ability }
            allow(@ability).to receive(:update)
            allow(@char).to receive(:name) { "Bob" }
            allow(@ability).to receive(:rating_name) { "X" }
          end
        
          it "should update an existing ability" do
            expect(@ability).to receive(:update).with(rating: 4)
            error = BattleSkills.set_ability(@char, "Firearms", 4)
            expect(error).to be_nil
          end

          it "should create a new ability" do
            allow(BattleSkills).to receive(:find_ability).with(@char, "Firearms") { nil }
            expect(FS3ActionSkill).to receive(:create).with(character: @char, name: "Firearms", rating: 4) { @ability }
            error = BattleSkills.set_ability(@char, "Firearms", 4)
            expect(error).to be_nil
          end
        end
      end
    end
  end
end
        
