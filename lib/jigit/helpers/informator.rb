require "cork"

module Jigit
  # This class is heavily based on the Interviewer class from the Danger gem
  # The original link is https://github.com/danger/danger/blob/master/lib/danger/commands/init_helpers/interviewer.rb
  class Informator
    attr_accessor :no_waiting, :ui, :no_delay

    def initialize(cork_board)
      @ui = cork_board
    end

    def show_prompt
      ui.print("> ".bold.green)
    end

    def say(message)
      ui.puts(message)
    end

    def inform(message)
      ui.puts(message.green)
    end

    def link(url)
      say " -> " + url.underline + "\n"
    end

    def pause(time)
      sleep(time) unless @no_waiting
    end

    def header(title)
      say title.yellow
      say ""
      pause 0.6
    end

    def important(message)
      i = message.length + 8
      inform("-" * i)
      inform("--- " + message + " ---")
      inform("-" * i)
    end

    def warn(message)
      ui.puts(message.yellow)
    end

    def error(message)
      ui.puts(message.red)
    end

    def wait_for_return
      STDOUT.flush
      STDIN.gets unless @no_delay
      ui.puts
    end

    def ask(question)
      STDIN.reopen(File.open("/dev/tty", "r"))

      answer = ""
      loop do
        ui.puts "\n#{question}?"

        show_prompt
        answer = STDIN.gets.chomp

        break unless answer.empty?

        ui.print "\nYou need to provide an answer."
      end
      answer
    end

    def ask_with_answers(question, possible_answers, is_numerated = false)
      STDIN.reopen(File.open("/dev/tty", "r"))

      ui.print("\n#{question}? [")
      possible_answers_to_print = is_numerated ? possible_answers.map.with_index { |answer, index| "#{index}. #{answer}" } : possible_answers
      print_possible_answers(possible_answers_to_print)
      answer = ""
      loop do
        show_prompt
        answer = read_answer(possible_answers)

        if is_numerated
          numerated_answer = Integer(answer) rescue break
          break if numerated_answer < 0 && possible_answers.count <= numerated_answer
          answer = possible_answers[numerated_answer]
        end

        break if possible_answers.include? answer

        ui.print "\nPossible answers are ["
        print_possible_answers(possible_answers)
      end
      answer
    end

    private

    def read_answer(possible_answers)
      answer = @no_waiting ? possible_answers[0] : STDIN.gets
      answer = answer.chomp unless answer.nil?
      answer = "yes" if answer == "y"
      answer = "no" if answer == "n"

      # default to first answer
      if answer == ""
        answer = possible_answers[0]
        ui.puts "Using: " + answer.yellow
      end
      answer
    end

    def print_possible_answers(possible_answers)
      possible_answers.each_with_index do |answer, i|
        the_answer = i.zero? ? answer.underline : answer
        ui.print " " + the_answer
        ui.print(" /") if i != possible_answers.length - 1
      end
      ui.print " ]\n"
    end
  end
end
