require "jigit/version"
require "jigit/helpers/informator"
require "claide"
require "cork"

module Jigit
  class Runner < CLAide::Command
    self.abstract_command = true
    self.summary = "Jira + Git = onelove"
    self.version = Jigit::VERSION
    self.command = "jigit"

    def initialize(argv)
      super
      @cork = Cork::Board.new(silent: argv.option("silent", false), verbose: argv.option("verbose", false))
    end

    def ui
      @ui ||= Informator.new(@cork)
    end
  end
end
