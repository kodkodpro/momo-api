# typed: true
# frozen_string_literal: true

require "sorbet-runtime"
require "sorbet-schema"

class Module
  include T::Sig
end

require_relative "types/typed_json"
require_relative "coercers"
require_relative "t_enum"
require_relative "t_struct"
