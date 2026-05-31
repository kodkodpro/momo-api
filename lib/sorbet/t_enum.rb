# typed: true
# frozen_string_literal: true

class T::Enum
  sig { returns(String) }
  def const_name
    instance_variable_get(:@const_name).to_s
  end

  class << self
    sig { returns(T::Array[String]) }
    def serialized_values
      T.bind(self, T.class_of(T::Enum))
      values.map(&:serialize)
    end
  end
end
