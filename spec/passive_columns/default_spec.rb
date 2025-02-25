# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'PassiveColumns' do
  ActiveRecord::Base.logger = Logger.new($stdout) if defined?(ActiveRecord::Base)

  after(:each) do
    EmailItem.delete_all
    Email.delete_all
    Project.delete_all
    User.delete_all
  end

  let(:user) { User.create!(email: 'jello@jello.com', default_project_id: nil) }

  context 'active record relation' do
    it 'retrieves columns except passive ones' do
      Project.create!(user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g')
      expect(Project.take.attributes.keys).to match_array(%w[id name user_id])
    end

    it 'preloads the column on demand and caches it into the model' do
      project = Project.create!(user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g')
      expect(project.attributes.keys).to match_array(%w[id name user_id guidelines description settings])

      project.reload
      expect(project.attributes.keys).to match_array(%w[id name user_id])
      expect(project.description).to eq 'a description'
      expect(project.attributes.keys).to match_array(%w[id name user_id description])
    end

    it 'selects without changing the originally selected columns' do
      Project.create!(user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g')
      project = Project.select('id', 'name').take!
      expect(project.attributes.keys).to match_array(%w[id name])
      expect(project.guidelines).to eq 'g'

      expect(project.attributes.keys).to match_array(%w[id name guidelines])
    end

    it 'throws an exception when attempting to access a non-passive column' do
      Project.create!(user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g')
      project = Project.select('id').take!
      expect(project.attributes.keys).to match_array(%w[id])
      expect { project.name }.to raise_error(ActiveModel::MissingAttributeError)
      expect { project.description }.not_to raise_error
    end

    it 'retrieves columns other than passive ones declared in the child model' do
      ProjectWithPassiveDescription.create!(user_id: user.id, name: 'Project', description: 'd', guidelines: 'g')
      expect(ProjectWithPassiveDescription.take.attributes.keys).to \
      match_array(%w[id name user_id guidelines settings])
    end

    it 'includes the association and preloads its columns without passive ones' do
      ProjectWithPassiveDescription.create!(user_id: user.id, name: 'Project', description: 'd', guidelines: 'g')
      users = User.includes(:projects_with_passive_description).all
      projects = users[0].projects_with_passive_description
      expect(projects[0].attributes.keys).to match_array(%w[id name user_id settings guidelines])
    end
  end

  context 'finder methods that work via cached_find_by_statement mechanism' do
    it 'retrieves columns except passive ones by find_by' do
      Project.create!(id: 1, user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g')
      model = Project.find_by(id: 1)
      expect(model.attributes.keys).to match_array(%w[id name user_id])
    end

    it 'retrieves columns except passive ones by find' do
      Project.create!(id: 1, user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g')
      model = Project.find(1)
      expect(model.attributes.keys).to match_array(%w[id name user_id])
    end
  end

  context 'associations' do
    it 'retrieves columns except passive ones' do
      Project.create!(user_id: user.id, name: 'Project', description: 'a description', guidelines: 'Guidelines')
      expect(user.projects.to_a[0].attributes.keys).to match_array(%w[id name user_id])
    end

    it 'retrieves columns other than passive ones declared in the child model' do
      ProjectWithPassiveDescription.create!(user_id: user.id, name: 'Project', description: 'd', guidelines: 'g')

      expect(user.projects_with_passive_description.count).to eq 1
      expect(user.projects_with_passive_description.take.attributes.keys).to \
      match_array(%w[id name user_id settings guidelines])
    end
  end

  context 'load_column' do
    it 'loads the column if it is not loaded yet' do
      Project.create!(user_id: user.id, name: 'random', description: 'a description', guidelines: 'Guidelines')

      expect(Project.count).to eq 1
      project = Project.select('id').take!
      expect(project.attributes.keys).to match_array(%w[id])
      expect(project.load_column('name')).to eq 'random'
      expect(project.load_column('user_id')).to eq user.id
      expect(project.load_column('description')).to eq 'a description'
      expect(project.attributes.keys).to match_array(%w[id name user_id description])
    end
  end

  context 'to_sql' do
    it 'does not break uninvolved models' do
      expect(User.all.to_sql).to eq('SELECT "users".* FROM "users"')
    end

    it 'returns correct query' do
      sql = Project.all.to_sql
      expect(sql).to \
        eq('SELECT "projects"."id", "projects"."user_id", "projects"."name" FROM "projects"')
    end

    it 'returns correct query via association' do
      sql = user.projects.to_sql
      expect(sql).to \
        eq(
          format(
            'SELECT "projects"."id", "projects"."user_id", "projects"."name" FROM "projects" ' \
            'WHERE "projects"."user_id" = %<user_id>d',
            user_id: user.id
          )
        )
    end

    it 'returns correct query via association and with a condition' do
      sql = user.projects.where('id > ?', 0).to_sql
      expect(sql).to \
        eq(
          format(
            'SELECT "projects"."id", "projects"."user_id", "projects"."name" FROM "projects" ' \
            'WHERE "projects"."user_id" = %<user_id>d AND (id > 0)',
            user_id: user.id
          )
        )
    end

    it 'returns correct query via association with one condition and with selection' do
      sql = user.projects.select('id').where('id > ?', 0).to_sql
      expect(sql).to \
        eq(
          format(
            'SELECT "projects"."id" FROM "projects" WHERE "projects"."user_id" = %<user_id>d AND (id > 0)',
            user_id: user.id
          )
        )
    end

    it 'returns correct query if there is a condition' do
      sql = Project.where('id > ?', 0).to_sql
      expect(sql).to \
      eq('SELECT "projects"."id", "projects"."user_id", "projects"."name" FROM "projects" WHERE (id > 0)')
    end

    it 'returns correct query if there is the parent class with passive_columns and condition' do
      sql = ProjectWithPassiveDescription.where('id > ?', 0).to_sql
      expect(sql).to \
      eq(
        'SELECT "projects"."id", "projects"."user_id", ' \
        '"projects"."name", "projects"."guidelines", "projects"."settings" FROM "projects" WHERE (id > 0)'
      )
    end
  end

  context 'manipulations' do
    it 'skips the description attribute check because it is not modified' do
      Project.create!(user_id: user.id, name: 'random 1', description: 'a description', guidelines: 'Guidelines')
      Project.create!(user_id: user.id, name: 'random 2', description: 'a description', guidelines: 'Guidelines')
      Project.where('id > ?', 0).find_each do |project|
        expect(project.attributes.keys).to eq %w[id user_id name]
        project.update!(name: 'random 99')
        project.reload
        expect(project.attributes.keys).to eq %w[id user_id name]
        expect(project.name).to eq 'random 99'
      end
    end

    it 'validates the passive column if it has been changed' do
      Project.create!(user_id: user.id, name: 'random 1', description: 'a description', guidelines: 'Guidelines')
      Project.create!(user_id: user.id, name: 'random 2', description: 'a description', guidelines: 'Guidelines')
      Project.where('id > ?', 0).find_each do |project|
        expect(project.attributes.keys).to match_array %w[id name user_id]
        expect(project.description).to eq 'a description'

        project.update(name: 'new name')
        expect(project.errors.empty?).to eq true

        project.update(description: '')
        expect(project.errors[:description]).to eq ['can\'t be blank']
        project.update(description: '-')

        expect(project.attributes.keys).to match_array %w[id name user_id description]
        project.reload

        expect(project.attributes.keys).to match_array %w[id name user_id]
        expect(project.name).to eq 'new name'
        expect(project.description).to eq '-'
        expect(project.attributes.keys).to match_array %w[id name user_id description]
      end
    end

    it 'skips loading columns even through preloading' do
      project = Project.create! user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g'

      email = Email.create!(id: SecureRandom.uuid, from: 'hey@heyheyhey.test', mail: 'html mail')
      expect(email.attributes.keys).to match_array %w[id from mail subject to]
      EmailItem.create!(email_id: email.id, item_type: 'Project', item_id: project.id)

      email = Email.includes(email_items: [:item]).take
      expect(email.attributes.keys).to match_array %w[id from subject to]
      expect(email.email_items.first.item.attributes.keys).to match_array %w[id name user_id]
    end
  end

  context 'complex attribute' do
    it 'checks proper assignment for child attributes' do
      Project.create!(
        user_id: user.id, name: 'name', description: 'text', guidelines: 'Guidelines', settings: { color: 'white' }
      )

      project = Project.take
      expect(project.attributes.keys).to match_array %w[id name user_id]
      project.settings.assign_attributes({ color: 'red' })
      expect(project.settings.changes).to eq({ 'color' => %w[white red] })
      project.settings_will_change!
      expect(project.changes).not_to eq({})
      expect(project.changes['settings'].map(&:attributes)).to eq([{ color: 'white' }, { color: 'red' }])
    end

    it 'checks proper assignment for child attributes' do
      Project.create!(
        user_id: user.id, name: 'name', description: 'text', guidelines: 'Guidelines', settings: { color: 'white' }
      )

      project = Project.take
      expect(project.attributes.keys).to match_array %w[id name user_id]
      project.settings.assign_attributes({ color: 'white' })
      expect(project.settings.changes).to eq({})
      expect(project.changes).to eq({})
    end
  end

  context 'model with the accept_nested_attributes_for option configured' do
    it 'when non-passive-column model creates a passive-column-model via nested assignation' do
      User.create!(email: '', projects_attributes: [{ name: 'Project', description: 'a description' }])
    end

    it 'when a passive-column models creates a mon-passive-column model via nested assignation' do
      p = Project.create!(user_id: user.id, name: 'Project', description: 'a description', guidelines: 'g')

      email = Email.create!(
        id: SecureRandom.uuid,
        from: 'hey@heyheyhey.test',
        mail: 'html mail',
        email_items_attributes: [{ item_type: 'Project', item_id: p.id }]
      )

      expect(email.attributes.keys).to match_array %w[id from mail subject to]

      email = Email.take
      expect(email.attributes.keys).to match_array %w[id from subject to]
    end
  end
end
