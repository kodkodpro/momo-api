# typed: strict
# frozen_string_literal: true

module TypedJSON
  extend T::Helpers

  sealed!
  abstract!

  sig { abstract.returns(T.untyped) }
  def to_untyped
  end

  sig { params(json: T.untyped).returns(TypedJSON) }
  def self.from_untyped(json)
    case json
    when nil then Null.instance
    when true, false then Boolean.new(val: json)
    when ::String then String.new(val: json)
    when ::Numeric then Number.new(val: json)
    when ::Array then Array.new(val: json.map { |json_item| from_untyped(json_item) })
    when ::Hash then Object.new(val: json.transform_values { |json_item| from_untyped(json_item) })
    else raise ArgumentError, "Malformed json"
    end
  end

  class Null
    include TypedJSON
    include Singleton

    sig { override.returns(NilClass) }
    def to_untyped = nil
  end

  class Boolean < T::Struct
    include TypedJSON

    prop :val, T::Boolean

    sig { override.returns(T::Boolean) }
    def to_untyped = val
  end

  class String < T::Struct
    include TypedJSON

    prop :val, ::String

    sig { override.returns(::String) }
    def to_untyped = val
  end

  class Number < T::Struct
    include TypedJSON

    prop :val, ::Numeric

    sig { override.returns(::Numeric) }
    def to_untyped = val
  end

  class Array < T::Struct
    include TypedJSON

    prop :val, T::Array[TypedJSON]

    sig { override.returns(T::Array[T.untyped]) }
    def to_untyped = val.map(&:to_untyped)
  end

  class Object < T::Struct
    include TypedJSON

    prop :val, T::Hash[::String, TypedJSON]

    sig { override.returns(T::Hash[::String, T.untyped]) }
    def to_untyped = val.transform_values(&:to_untyped)
  end
end
