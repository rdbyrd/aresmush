module AresMUSH
  class FS3Attribute < Ohm::Model
    include ObjectModel
    include LearnableAbility
    
    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :rating, :type => DataType::Integer, :default => 0
    
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
      end
    end
    
    def rating_name
      case rating
      when 0 
        return ""
      when 1
        return t('battleskills.poor_rating')
      when 2
        return t('battleskills.average_rating')
      when 3
        return t('battleskills.good_rating')
      when 4
        return t('battleskills.exceptional_rating')
      end
    end
  end
end