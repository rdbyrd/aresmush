module AresMUSH
  module Battle

    #check and make sure that the Battle plugin is enabled so it can be used
    #on the Mush Client
    def self.is_enabled?
      !Global.plugin_manager.is_enabled?("battle")
    end
  end
end
