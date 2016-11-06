require "jigit/core/jigitfile"

describe Jigit::Jigitfile do
  describe ".initialize" do
    context "when there is no jigitfile at the given path" do
      it "raises an exception" do
        expect { Jigit::Jigitfile.new("./jigitfile.yml") }.to raise_error("Couldn't find Jigitfile file at './jigitfile.yml'")
      end
    end

    context "when the file does not have a legit YAML syntax" do
      it "raises an exception" do
        expect { Jigit::Jigitfile.new("spec/fixtures/jigitfile_invalid.yaml") }.to raise_error("File at 'spec/fixtures/jigitfile_invalid.yaml' doesn't have a legit YAML syntax")
      end
    end

    context "when file exista and sytax is valid" do
      let(:subject) { Jigit::Jigitfile.new("spec/fixtures/jigitfile_valid.yaml") }

      it "assigns in_progress_status" do
        expect(subject.in_progress_status).to be == "In Progress"
      end

      it "assigns other_statuses" do
        expect(subject.other_statuses).to be == ["To Do", "In Review"]
      end
    end
  end
end
