module AresMUSH
  module Battle
    class GearDetailRequestHandler
      def handle(request)
        type = request.args[:type]
        name = request.args[:name]

        if (name.blank?)
          return { error: t('battle.invalid_gear_type') }
        end

        case (type || "").downcase
        when "weapon"
          data = Battle.weapon(name)
        when "armor"
          data = Battle.armor(name)
        else
          return { error: t('battle.invalid_gear_type') }
        end

        if (!data)
          return { error: t('battle.invalid_gear_type') }
        end

        values = data.map { |key, value|  {
          title: key.titleize,
          detail: Website.format_markdown_for_html(Battle.gear_detail(value).to_s)
          }
        }

        {
          type: type.titleize,
          name: name.titleize,
          values: values
        }
      end
    end
  end
end
