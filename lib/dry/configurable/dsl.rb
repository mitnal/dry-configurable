# frozen_string_literal: true

require 'dry/configurable/constants'
require 'dry/configurable/setting'
require 'dry/configurable/settings'
require 'dry/configurable/compiler'

module Dry
  module Configurable
    # Setting DSL used by the class API
    #
    # @api private
    class DSL
      VALID_NAME = /\A[a-z_]\w*\z/i.freeze

      # @api private
      attr_reader :compiler

      # @api private
      attr_reader :ast

      # @api private
      def initialize(&block)
        @compiler = Compiler.new
        @ast = []
        instance_exec(&block) if block
      end

      # Register a new setting node and compile it into a setting object
      #
      # @see ClassMethods.setting
      # @api public
      # @return Setting
      def setting(name, **options, &block)
        unless VALID_NAME.match?(name.to_s)
          raise ArgumentError, "#{name} is not a valid setting name"
        end

        ensure_valid_options options

        node = [:setting, [name.to_sym, options]]

        if block
          ast << [:nested, [node, DSL.new(&block).ast]]
        else
          ast << node
        end

        compiler.visit(ast.last)
      end

      private

      # @api private
      def ensure_valid_options(options)
        return if options.none?

        keys = options.keys - Setting::OPTIONS
        raise ArgumentError, "Invalid options: #{keys.inspect}" unless keys.empty?
      end
    end
  end
end
