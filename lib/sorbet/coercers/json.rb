# typed: strict
# frozen_string_literal: true

module Coercers
  class JSON < Typed::Coercion::Coercer
    extend T::Generic

    Target = type_member { { fixed: TypedJSON } }

    sig { override.params(type: T::Types::Base).returns(T::Boolean) }
    def self.used_for_type?(type)
      type == T::Utils.coerce(TypedJSON)
    end

    sig { override.params(type: T::Types::Base, value: Typed::Value).returns(Typed::Result[Target, Typed::Coercion::CoercionError]) }
    def coerce(type:, value:)
      return Typed::Failure.new(Typed::Coercion::CoercionError.new("Type must be a TypedJSON.")) unless self.class.used_for_type?(type)
      return Typed::Success.new(value) if type.recursively_valid?(value)

      Typed::Success.new(TypedJSON.from_untyped(value))
    rescue ArgumentError
      Typed::Failure.new(Typed::Coercion::CoercionError.new("'#{value}' cannot be coerced into TypedJSON."))
    end
  end
end
