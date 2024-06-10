# frozen_string_literal: true

require_relative "../spec_helper"

RSpec.describe 'PassiveColumns' do

  describe "#initialize" do
    context "when symbolized hash is passed" do
      subject { }

      it("assigns attributes") do
        user = User.new(email: 'jello@jello.com', id: 1, default_project_id: nil)
        project = Project.new(id: 1, user_id: 1, name: 'Project 1', description: 'asd', guidelines: 'GGuidelines')

        expect(user.id).to eq(project.user_id)
      end
    end
  end
end