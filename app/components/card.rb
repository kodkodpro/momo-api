# typed: true
# frozen_string_literal: true

class Components::Card < Components::Base
  include Phlex::Sorbet

  class Props < T::Struct
    const :bordered, T::Boolean, default: false
    const :class_name, T.nilable(String)
  end

  def view_template
    div class: card_classes do
      div class: "p-4" do
        yield if block_given?
      end
    end
  end

  private

  def card_classes
    classes = T.let(["rounded-lg bg-card text-card-foreground shadow-sm"], T::Array[T.nilable(String)])
    classes << "border" if props.bordered
    classes << props.class_name
    classes.join(" ")
  end
end
