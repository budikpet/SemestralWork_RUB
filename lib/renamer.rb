# frozen_string_literal: true

require_relative 'renamer/cli_logic'
require 'bundler/setup'
Bundler.require(:default)

module Renamer
  # Thor CLI interface for Renamer CLI utility.
  class CLI < Thor
    desc '', 'Runs the Renamer CLI utility.'
    method_option :arabic, type: :string, aliases: '-a', required: false, desc: 'Input is either an arabic or a renamer value. Result is an arabic value. Returns an error if invalid input value is given.'
    method_option :renamer, type: :string, aliases: '-r', required: false, desc: 'Input is either an arabic or a renamer value. Result is a renamer value. Returns an error if invalid input value is given.'
    def renamer
      arabic_cmd = options[:arabic]
      renamer_cmd = options[:renamer]
      if arabic_cmd.nil? && renamer_cmd.nil?
        CLI.command_help(Thor::Base.shell.new, 'renamer')
        return
      end
      # cli_logic = CLI_Logic.new
      # puts cli_logic.renamer_method_logic(arabic_cmd, renamer_cmd)
    end

    default_task :renamer
  end
end
