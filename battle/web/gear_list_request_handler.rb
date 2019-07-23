module AresMUSH
  module Battle

    #function with hash for reporting weapon/armor names and descriptions
    class GearListRequestHandler
      def handle(request)
        {
          weapons: build_list(Battle.weapons),
          armor: build_list(Battle.armors),
        }
      end

      def build_list(hash)
        hash.sort.map { |name, data| {
          key: name,
          name: name.titleize,
          description: data['description']
          }
        }
      end
    end
  end
end
