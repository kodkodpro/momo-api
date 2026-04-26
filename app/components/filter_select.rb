# typed: true
# frozen_string_literal: true

class Components::FilterSelect < Components::Base
  include Phlex::Sorbet

  class Props < T::Struct
    const :name, String
    const :label, String
    const :options, T::Array[[String, String]]
    const :selected, String
  end

  def view_template
    label class: "flex flex-col text-sm gap-1" do
      span { props.label }

      Select class: "w-56" do
        SelectInput id:, name: props.name, value: props.selected

        SelectTrigger do
          SelectValue id: do
            selected_label
          end
        end

        SelectContent outlet_id: id do
          SelectGroup do
            props.options.each do |value, text|
              SelectItem value: do
                text
              end
            end
          end
        end
      end
    end
  end

  private

  memoize def id
    "#{props.name.to_param}-#{SecureRandom.hex(4)}"
  end

  def selected_label
    match = props.options.find { |value, _text| value == props.selected }
    match ? match.last : props.selected
  end
end
