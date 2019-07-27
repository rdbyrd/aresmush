module AresMUSH
  class FS3ActionSkill < Ohm::Model
    include ObjectModel
    include LearnableAbility
    
    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :rating, :type => DataType::Integer, :default => 0
    attribute :specialties, :type => DataType::Array, :default => []
    index :name
    
    def print_rating
      case rating
      when 0
        return ""
      when 1
        return "%xg@%xn"
      when 2
        return "%xg@@%xn"
      when 3
        return "%xg@@%xy@%xn"
      when 4
        return "%xg@@%xy@@%xn"
      when 5
        return "%xg@@%xy@@%xr@%xn"
      when 6
        return "%xg@@%xy@@%xr@@%xn"
      when 7
        return "%xg@@%xy@@%xr@@%xb@%xn"
      when 8
        return "%xg@@%xy@@%xr@@%xb@@%xn"
      end
    end
    
    def rating_name
      case rating
      when 0
        return t('battleskills.unskilled_rating')
      when 1
        return t('battleskills.everyman_rating')
      when 2
        return t('battleskills.fair_rating')
      when 3
        return t('battleskills.competent_rating')
      when 4
        return t('battleskills.good_rating')
      when 5
        return t('battleskills.great_rating')
      when 6
        return t('battleskills.exceptional_rating')
      when 7
        return t('battleskills.amazing_rating')
      when 8
        return t('battleskills.legendary_rating')
      end
    end
  end
end