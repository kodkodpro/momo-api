# typed: true
# frozen_string_literal: true

class T::Struct
  class << self
    sig do
      params(
        serializer_type: Symbol,
        source: T.untyped,
        options: T::Hash[Symbol, T.untyped],
      ).returns(T.attached_class)
    end
    def deserialize_from!(serializer_type, source, options: {})
      result = deserialize_from(serializer_type, source, options:)
      raise result.error if result.failure?

      result.payload
    end

    sig do
      params(
        source: T.untyped,
        options: T::Hash[Symbol, T.untyped],
      ).returns(T.attached_class)
    end
    def from_hash!(source, options: {})
      deserialize_from!(:hash, source, options:)
    end
  end

  sig do
    params(
      serializer_type: Symbol,
      options: T::Hash[Symbol, T.untyped],
    ).returns(T.untyped)
  end
  def serialize_to!(serializer_type, options: {})
    result = serialize_to(serializer_type, options:)
    raise result.error if result.failure?

    result.payload
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def to_h
    serialize_to!(:hash, options: { should_serialize_values: true })
  end
end
