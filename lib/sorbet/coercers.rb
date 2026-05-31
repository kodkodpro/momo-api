# typed: true
# frozen_string_literal: true

require_relative "coercers/boolean"
require_relative "coercers/json"

Typed::Coercion.register_coercer(Coercers::Boolean)
Typed::Coercion.register_coercer(Coercers::JSON)
