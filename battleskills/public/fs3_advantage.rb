module AresMUSH
  class FS3Advantage < Ohm::Model
    include ObjectModel
    include LearnableAbility
    
    reference :character, "AresMUSH::Character"
    attribute :name
    attribute :rating, :type => DataType::Integer, :default => 0
    
    index :name
    
    def print_rating
      rating_name
    end
    
    def rating_name
      case rating
      when 0
        return t('battleskills.everyman_rating')
      when 1
        return t('battleskills.fair_rating')
      when 2
        return t('battleskills.good_rating')
      when 3
        return t('battleskills.exceptional_rating')
      end
    end
  end
end