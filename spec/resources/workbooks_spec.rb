require 'spec_helper'

describe TableauApi::Resources::Workbooks do
  include_context 'tableau client'

  def find_or_publish_workbook(name)
    project = { 'id' => '57058e8e-3363-4de9-a03b-5e7401933073' }

    workbook = client.workbooks.list.find do |w|
      w['name'] == name
    end

    if workbook
      workbook = client.workbooks.find(workbook['id'])
      return workbook
    end

    client.workbooks.publish(
      name: name,
      project_id: project['id'],
      file: 'spec/fixtures/workbooks/test.twbx',
      overwrite: true
    )
  end

  # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Publish_Workbook%3FTocPath%3DAPI%2520Reference%7C_____31
  # Workbooks created in a later version of Tableau Desktop cannot be published to earlier versions of Tableau Server.
  #  - http://kb.tableau.com/articles/knowledgebase/desktop-and-server-compatibility
  describe '.publish' do
    it 'can publish a twbx workbook in project in a site' do
      VCR.use_cassette('workbooks') do
        workbook_name = 'testpublish'
        workbook = find_or_publish_workbook(workbook_name)

        expect(workbook['id']).to be_a_tableau_id
        expect(workbook['owner']['id']).to be_a_tableau_id

        expect(workbook).to eq(
          'id' => workbook['id'],
          'name' => workbook_name,
          'contentUrl' => workbook_name,
          'showTabs' => 'false',
          'project' => workbook['project'],
          'owner' => workbook['owner'],
          'tags' => "\n    ",
          'views' => workbook['views']
        )
      end
    end

    it 'raises an exception' do
      VCR.use_cassette('workbooks') do
        ex = expect do
          client.workbooks.publish(
            name: 'tableau_api test',
            project_id: 'foo',
            file: 'spec/fixtures/workbooks/test.twbx',
            overwrite: true
          )
        end

        ex.to raise_error do |e|
          expect(e).to be_a TableauApi::TableauError
          expect(e.message).to eq 'Resource Not Found'
          expect(e.http_response_code).to eq '404'
          expect(e.error_code).to eq '404005'
          expect(e.summary).to eq 'Resource Not Found'
          expect(e.detail).to eq "Project 'foo' could not be found."
        end
      end
    end
  end

  describe '#permissions' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Add_Workbook_Permissions%3FTocPath%3DAPI%2520Reference%7C_____9
    it 'can add user permissions to a workbook' do
      VCR.use_cassette('workbooks') do
        workbook = find_or_publish_workbook('testpublish')
        expect(client.workbooks.permissions(
                 workbook_id: workbook['id'],
                 user_id: 'e408f778-3708-4685-b7f9-100b584a02aa',
                 capabilities: { Read: true, ChangePermissions: false }
        )).to be true
      end
    end

    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Add_Workbook_Permissions%3FTocPath%3DAPI%2520Reference%7C_____9
    it 'can add group permissions to a workbook' do
      VCR.use_cassette('workbooks') do
        workbook = find_or_publish_workbook('testpublish')
        expect(client.workbooks.permissions(
                 workbook_id: workbook['id'],
                 group_id: 'f3bb9eb0-581c-428e-a744-5735ffd5bf50',
                 capabilities: { Read: true, ChangePermissions: false }
        )).to be true
      end
    end

    it 'requires a user or a group id' do
      expect do
        client.workbooks.permissions(
          workbook_id: '1',
          capabilities: { Read: true }
        )
      end.to raise_error(/must specify user_id or group_id/)
    end

    it 'does not accept both a user and a group id' do
      expect do
        client.workbooks.permissions(
          workbook_id: '1',
          user_id: '1',
          group_id: '2',
          capabilities: { Read: true }
        )
      end.to raise_error(/cannot specify user_id and group_id simultaneously/)
    end
  end

  describe '#delete_permissions' do
    it 'can delete a user permission' do
      VCR.use_cassette('workbooks') do
        workbook = find_or_publish_workbook('testpublish')
        expect(client.workbooks.permissions(
                 workbook_id: workbook['id'],
                 user_id: 'e408f778-3708-4685-b7f9-100b584a02aa',
                 capabilities: { Read: true }
        )).to be true
        expect(client.workbooks.delete_permissions(
                 workbook_id: workbook['id'],
                 user_id: 'e408f778-3708-4685-b7f9-100b584a02aa',
                 capability: 'Read',
                 capability_mode: 'ALLOW'
        )).to be true
      end
    end

    it 'can delete a group permission' do
      VCR.use_cassette('workbooks') do
        workbook = find_or_publish_workbook('testpublish')
        expect(client.workbooks.permissions(
                 workbook_id: workbook['id'],
                 user_id: 'e408f778-3708-4685-b7f9-100b584a02aa',
                 capabilities: { Read: true }
        )).to be true
        expect(client.workbooks.delete_permissions(
                 workbook_id: workbook['id'],
                 user_id: 'e408f778-3708-4685-b7f9-100b584a02aa',
                 capability: 'Read',
                 capability_mode: 'ALLOW'
        )).to be true
      end
    end

    it 'requires a user or a group id' do
      expect do
        client.workbooks.delete_permissions(
          workbook_id: '1',
          capability: 'READ',
          capability_mode: 'ALLOW'
        )
      end.to raise_error(/must specify user_id or group_id/)
    end

    it 'does not accept both a user and a group id' do
      expect do
        client.workbooks.delete_permissions(
          workbook_id: '1',
          user_id: '1',
          group_id: '2',
          capability: 'READ',
          capability_mode: 'ALLOW'
        )
      end.to raise_error(/cannot specify user_id and group_id simultaneously/)
    end
  end

  # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Update_Workbook%3FTocPath%3DAPI%2520Reference%7C_____59
  it 'can update the workbook' do
    VCR.use_cassette('workbooks') do
      workbook = find_or_publish_workbook('testpublish')
      expect(client.workbooks.update(
               workbook_id: workbook['id'],
               owner_user_id: 'e408f778-3708-4685-b7f9-100b584a02aa'
      )).to be true
    end
  end

  describe '.list' do
    it 'can list workbooks' do
      VCR.use_cassette('workbooks') do
        workbook = find_or_publish_workbook('testpublish')

        found_workbook = client.workbooks.list.find do |w|
          w['contentUrl'] == workbook['contentUrl']
        end

        expect(found_workbook['id']).to be_a_tableau_id
        expect(found_workbook).to eq(
          'id' => workbook['id'],
          'name' => workbook['name'],
          'contentUrl' => workbook['contentUrl'],
          'showTabs' => 'false',
          'project' => workbook['project'],
          'owner' => workbook['owner'],
          'tags' => "\n      "
        )

        same_workbook = client.workbooks.list.find do |w|
          w['name'] == workbook['name']
        end

        expect(found_workbook).to eq same_workbook
      end
    end

    it 'can paginate workbooks' do
      VCR.use_cassette('workbooks') do
        find_or_publish_workbook('test pagination1')
        find_or_publish_workbook('test pagination2')
        find_or_publish_workbook('test pagination3')
        workbooks = client.workbooks.list

        url = "sites/#{client.auth.site_id}/users/#{client.auth.user_id}/workbooks"
        expect(client.connection.api_get_collection(url, 'workbooks.workbook', page_size: 2).count).to eq workbooks.count
      end
    end
  end

  describe '.views' do
    it 'can get the list of views for a workbook' do
      VCR.use_cassette('workbooks') do
        workbook = find_or_publish_workbook('testpublish')
        views = client.workbooks.views(workbook['id']).to_a
        expect(views).to eq([workbook['views']['view']])
      end
    end
  end

  describe '.find' do
    it 'can find a workbook by workbook_id' do
      VCR.use_cassette('workbooks') do
        workbook = find_or_publish_workbook('testpublish')
        found_workbook = client.workbooks.find(workbook['id'])

        expect(workbook).to eq found_workbook
      end
    end
  end

  describe '.version' do
    it 'can get the version of a twbx file' do
      expect(client.workbooks.version('spec/fixtures/workbooks/test.twbx')).to eq '9.0'
    end

    it 'returns nil if file not found' do
      expect(client.workbooks.version('spec/fixtures/workbooks/foo.twbx')).to be_nil
    end

    it 'returns nil if file not twbx' do
      expect(client.workbooks.version('spec/fixtures/workbooks/foo.bar')).to be_nil
    end
  end
end
