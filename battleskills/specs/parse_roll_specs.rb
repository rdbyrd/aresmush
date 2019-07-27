module AresMUSH
  module BattleSkills
    describe BattleSkills do

      before do
        allow(Global).to receive(:read_config).with("battleskills", "max_luck") { 3 }
        stub_translate_for_testing
      end

      describe :parse_and_roll do
        before do
          @char = double
        end
  
        it "should emit failure and return nil if it can't parse the roll" do
          allow(BattleSkills).to receive(:parse_roll_params) { nil }
          expect(BattleSkills.parse_and_roll(@char, "x")).to be_nil
        end
  
        it "should return a die result for a plain number" do
          # Note - automatically factors in a default linked attr
          allow(BattleSkills).to receive(:roll_dice).with(4) { [1, 2, 3, 4, 5] }
          expect(BattleSkills.parse_and_roll(@char, "2")).to eq [1, 2, 3, 4, 5]
        end
  
        it "should parse results and roll the ability for any other string" do
          allow(BattleSkills).to receive(:parse_roll_params) { "x" }
          allow(BattleSkills).to receive(:roll_ability).with(@char, "x") { [1, 2, 3]}
          expect(BattleSkills.parse_and_roll(@char, "abc")).to eq [1, 2, 3]
        end
      end

      describe :can_parse_roll_params do
        before do
          allow(BattleSkills).to receive(:get_ability_type) { :action }
        end
        
        it "should handle attribute by itself" do
          allow(BattleSkills).to receive(:get_ability_type).with("A") { :attribute }
          params = BattleSkills.parse_roll_params("A")
          check_params(params, "A", 0, nil)
        end
        
        it "should handle abiliity and positive modifier" do
          params = BattleSkills.parse_roll_params("A+22")
          check_params(params, "A", 22, nil)
        end

        it "should handle abiliity and positive modifier" do
          params = BattleSkills.parse_roll_params("A+22")
          check_params(params, "A", 22, nil)
        end

        it "should handle abiliity and negative modifier" do
          params = BattleSkills.parse_roll_params("A-3")
          check_params(params, "A", -3, nil)
        end
        
        it "should handle ability with space" do
          params = BattleSkills.parse_roll_params("A B")
          check_params(params, "A B", 0, nil)
        end
        
        it "should handle ability with modifier and space" do
          params = BattleSkills.parse_roll_params("A B + 3")
          check_params(params, "A B", 3, nil)
        end

        it "should handle ability with modifier and linked attr and space" do
          params = BattleSkills.parse_roll_params("A B + C D + 3")
          check_params(params, "A B", 3, "C D")
        end
        
        it "should handle ability and linked attr" do
          params = BattleSkills.parse_roll_params("A+B")
          check_params(params, "A", 0, "B")
        end

        it "should handle ability and linked attr and modifier" do
          params = BattleSkills.parse_roll_params("A+B-2")
          check_params(params, "A", -2, "B")
        end
        
        it "should handle bad string with negative ruling attr" do
          params = BattleSkills.parse_roll_params("A-B+2")
          expect(params).to be_nil
        end
        
        it "should swap attr and ability if backwards" do
          allow(BattleSkills).to receive(:get_ability_type).with("Y") { :attribute }
          params = BattleSkills.parse_roll_params("Y+X")
          check_params(params, "X", 0, "Y")
        end

        it "should handle bad string with a non-digit modifier" do
          params = BattleSkills.parse_roll_params("A+B+C")
          expect(params).to be_nil
        end
        
        it "should handle bad string with too many params" do
          params = BattleSkills.parse_roll_params("A+B+2+D")
          expect(params).to be_nil
        end
      end
      
      describe :dice_to_roll_for_ability do
        before do
          @char = double
          allow(@char).to receive(:name) { "Nemo" }

          allow(BattleSkills).to receive(:get_ability_type).with("Firearms") { :action }
          allow(BattleSkills).to receive(:get_ability_type).with("Brawn") { :attribute }
          allow(BattleSkills).to receive(:get_ability_type).with("Reflexes") { :attribute }
          allow(BattleSkills).to receive(:get_ability_type).with("English") { :language }
          allow(BattleSkills).to receive(:get_ability_type).with("Basketweaving") { :background }
          allow(BattleSkills).to receive(:get_ability_type).with("Untrained") { :background }
          allow(BattleSkills).to receive(:get_ability_type).with(nil) { :background }
          
          allow(BattleSkills).to receive(:ability_rating).with(@char, "Untrained") { 0 }
          allow(BattleSkills).to receive(:ability_rating).with(@char, "Firearms") { 1 }
          allow(BattleSkills).to receive(:ability_rating).with(@char, "Basketweaving") { 2 }
          allow(BattleSkills).to receive(:ability_rating).with(@char, "English") { 3 }
          allow(BattleSkills).to receive(:ability_rating).with(@char, "Brawn") { 4 }
          allow(BattleSkills).to receive(:ability_rating).with(@char, "Reflexes") { 2 }
          
          allow(BattleSkills).to receive(:get_linked_attr).with("Untrained") { "Brawn" }
          allow(BattleSkills).to receive(:get_linked_attr).with("Firearms") { "Reflexes" }
          allow(BattleSkills).to receive(:get_linked_attr).with("Brawn") { nil }
          allow(BattleSkills).to receive(:get_linked_attr).with("Basketweaving") { "Reflexes" }
          allow(BattleSkills).to receive(:get_linked_attr).with("English") { "Reflexes" }
        end
      
        it "should roll ability alone" do
          roll_params = RollParams.new("Firearms")
          # Rolls Firearms + Reflexes 
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 3
        end
      
        it "should roll ability + a different ruling attr" do
          roll_params = RollParams.new("Firearms", 0, "Brawn")
          # Rolls Firearms + Brawn
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 5
        end
        
        it "should roll attr + ability" do
          roll_params = RollParams.new("Brawn", 0, "Firearms")
          # Rolls Brawn + Firearms
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 5
        end

        it "should roll attr + attr" do
          roll_params = RollParams.new("Brawn", 0, "Reflexes")
          # Rolls Brawn + Reflexes
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 6
        end
        
        it "should roll ability + ability" do
          roll_params = RollParams.new("Firearms", 0, "Firearms")
          # Rolls Firearms + Firearms
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 2
        end
        
        it "should roll twice a background skill" do 
          roll_params = RollParams.new("Basketweaving")
          # Rolls Basketweaving*2 + Reflexes
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 6
        end
        
        it "should roll twice a language skill" do 
          roll_params = RollParams.new("English")
          # Rolls English*2 + Reflexes
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 8
        end
        
        it "should roll ability + modifier" do
          roll_params = RollParams.new("Firearms", 1)
          # Rolls Firearms + Reflexes + 1
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 4
        end
      
        it "should roll ability - modifier" do
          roll_params = RollParams.new("Firearms", -1)
          # Rolls Firearms + Reflexes - 1 
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 2
        end
      
        it "should roll ability + ruling attr + modifier" do
          roll_params = RollParams.new("Firearms", 3, "Brawn")
          # Rolls Firearms + Brawn + 3 
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 8
        end
        
        it "should roll everyman for an attribute" do
          roll_params = RollParams.new("Brawn")
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 5
        end
        
        it "should roll everyman for nonexistant bg skill" do
          roll_params = RollParams.new("Untrained")
          # Rolls everyman (1) + Brawn
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 5
        end
        
        it "should roll zero for nonexistant lang skill" do
          allow(BattleSkills).to receive(:ability_rating).with(@char, "English") { 0 }
          roll_params = RollParams.new("English")
          # Rolls 0 + Reflexes
          expect(BattleSkills.dice_to_roll_for_ability(@char, roll_params)).to eq 2
        end
        
      end
      
      def check_params(params, ability, modifier, linked_attr)
        expect(params.ability).to eq ability
        expect(params.modifier).to eq modifier
        expect(params.linked_attr).to eq linked_attr
      end
      
      
    end
  end
end
