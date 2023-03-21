# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'
require 'chunky_png'

describe TableauApi::Resources::Workbooks, vcr: { cassette_name: 'workbooks' } do
  include_context 'tableau client'

  def find_or_publish_workbook(name)
    project = client.projects.list.find { |p| p['name'] == 'test' }
    workbook = client.workbooks.list.find { |w| w['name'] == name }

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
  describe '#publish' do
    it 'can publish a twbx workbook in project in a site' do
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
        'tags' => nil,
        'views' => workbook['views'],
        'size' => '1',
        'createdAt' => workbook['createdAt'],
        'updatedAt' => workbook['updatedAt'],
        'webpageUrl' => workbook['webpageUrl']
      )
    end

    it 'raises an exception', vcr: { cassette_name: 'workbooks', match_requests_on: %i[path query] } do
      ex = expect do
        client.workbooks.publish(
          name: 'tableau_api test',
          project_id: 'foo',
          file: 'spec/fixtures/workbooks/test.twbx',
          overwrite: true
        )
      end

      ex.to raise_error(TableauApi::TableauError) do |e|
        expect(e.message).to eq "404005: Resource Not Found; Project 'foo' could not be found."
        expect(e.http_response_code).to eq '404'
        expect(e.error_code).to eq '404005'
        expect(e.summary).to eq 'Resource Not Found'
        expect(e.detail).to eq "Project 'foo' could not be found."
      end
    end
  end

  describe '#add_permissions' do
    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Add_Workbook_Permissions%3FTocPath%3DAPI%2520Reference%7C_____9
    it 'can add user permissions to a workbook' do
      workbook = find_or_publish_workbook('testpublish')
      expect(client.workbooks.add_permissions(
               workbook_id: workbook['id'],
               user_id: admin_user['id'],
               capabilities: { Read: true, ChangePermissions: false }
             )).to be true
    end

    # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Add_Workbook_Permissions%3FTocPath%3DAPI%2520Reference%7C_____9
    it 'can add group permissions to a workbook' do
      workbook = find_or_publish_workbook('testpublish')
      expect(client.workbooks.add_permissions(
               workbook_id: workbook['id'],
               group_id: test_group['id'],
               capabilities: { Read: true, ChangePermissions: false }
             )).to be true
    end

    it 'requires a user or a group id' do
      expect do
        client.workbooks.add_permissions(
          workbook_id: '1',
          capabilities: { Read: true }
        )
      end.to raise_error(/must specify user_id or group_id/)
    end

    it 'does not accept both a user and a group id' do
      expect do
        client.workbooks.add_permissions(
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
      workbook = find_or_publish_workbook('testpublish')
      client.workbooks.add_permissions(
        workbook_id: workbook['id'],
        user_id: admin_user['id'],
        capabilities: { Read: true }
      )
      expect(client.workbooks.delete_permissions(
               workbook_id: workbook['id'],
               user_id: admin_user['id'],
               capability: 'Read',
               capability_mode: 'ALLOW'
             )).to be true
    end

    it 'can delete a group permission' do
      workbook = find_or_publish_workbook('testpublish')
      expect(client.workbooks.delete_permissions(
               workbook_id: workbook['id'],
               group_id: test_group['id'],
               capability: 'Read',
               capability_mode: 'ALLOW'
             )).to be true
    end

    it 'accepts a symbol as a permission' do
      workbook = find_or_publish_workbook('testpublish')
      client.workbooks.add_permissions(
        workbook_id: workbook['id'],
        group_id: all_users_group['id'],
        capabilities: { ExportImage: true }
      )
      expect(client.workbooks.delete_permissions(
               workbook_id: workbook['id'],
               group_id: all_users_group['id'],
               capability: :ExportImage,
               capability_mode: :ALLOW
             )).to be true
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

  describe '#permissions' do
    it 'can retrieve multiple permissions for a workbook' do
      workbook = find_or_publish_workbook('testpublish')
      expected = [{
        grantee_type: 'group',
        grantee_id: all_users_group['id'],
        capabilities: {
          Read: true,
          ShareView: true,
          ViewUnderlyingData: true,
          Filter: true,
          Write: true
        }
      }, {
        grantee_type: 'group',
        grantee_id: test_group['id'],
        capabilities: {
          ChangePermissions: false
        }
      }, {
        grantee_type: 'user',
        grantee_id: admin_user['id'],
        capabilities: {
          ChangePermissions: false
        }
      }]
      actual = client.workbooks.permissions(workbook_id: workbook['id'])
      expect(actual).to eq expected
    end

    it 'returns an array for even a single permission' do
      workbook = find_or_publish_workbook('testpublish')

      # use up the VCR recording from the previous spec
      client.workbooks.permissions(workbook_id: workbook['id'])

      # remove most of the remaining permissions
      %w[ExportData ViewComments AddComment].each do |p|
        client.workbooks.delete_permissions(
          workbook_id: workbook['id'],
          group_id: all_users_group['id'],
          capability: p,
          capability_mode: 'ALLOW'
        )
      end
      client.workbooks.delete_permissions(
        workbook_id: workbook['id'],
        group_id: test_group['id'],
        capability: :ChangePermissions,
        capability_mode: 'DENY'
      )
      client.workbooks.delete_permissions(
        workbook_id: workbook['id'],
        user_id: admin_user['id'],
        capability: 'ChangePermissions',
        capability_mode: 'DENY'
      )
      client.workbooks.delete_permissions(
        workbook_id: workbook['id'],
        group_id: test_group['id'],
        capability: 'ExportImage',
        capability_mode: 'ALLOW'
      )

      expected = [{
        grantee_type: 'group',
        grantee_id: all_users_group['id'],
        capabilities: {
          Read: true,
          Filter: true,
          ShareView: true,
          ViewUnderlyingData: true,
          Write: true
        }
      }]
      expect(client.workbooks.permissions(workbook_id: workbook['id'])).to eq expected
    end
  end

  describe '#list' do
    it 'can list workbooks' do
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
        'tags' => nil,
        'size' => '1',
        'updatedAt' => workbook['updatedAt'],
        'createdAt' => workbook['createdAt'],
        'webpageUrl' => workbook['webpageUrl']
      )

      same_workbook = client.workbooks.list.find do |w|
        w['name'] == workbook['name']
      end

      expect(found_workbook).to eq same_workbook
    end

    it 'can paginate workbooks' do
      find_or_publish_workbook('test pagination1')
      find_or_publish_workbook('test pagination2')
      find_or_publish_workbook('test pagination3')
      workbooks = client.workbooks.list

      url = "sites/#{client.auth.site_id}/users/#{client.auth.user_id}/workbooks"
      expect(client.connection.api_get_collection(url, 'workbooks.workbook', page_size: 2).count).to eq workbooks.count
    end
  end

  # http://onlinehelp.tableau.com/v9.0/api/rest_api/en-us/help.htm#REST/rest_api_ref.htm#Update_Workbook%3FTocPath%3DAPI%2520Reference%7C_____59
  describe '#update' do
    it 'can update the workbook' do
      workbook = find_or_publish_workbook('testpublish')
      expect(client.workbooks.update(
               workbook_id: workbook['id'],
               owner_user_id: admin_user['id']
             )).to be true
    end
  end

  describe '#views' do
    it 'can get the list of views for a workbook' do
      workbook = find_or_publish_workbook('testpublish')
      views = client.workbooks.views(workbook['id']).to_a
      expect(views).to eq([workbook['views']['view']])
    end
  end

  describe '#find' do
    it 'can find a workbook by workbook_id' do
      workbook = find_or_publish_workbook('testpublish')
      found_workbook = client.workbooks.find(workbook['id'])

      expect(workbook).to eq found_workbook
    end
  end

  describe '#preview_image' do
    it 'can download a preview image' do
      workbook = find_or_publish_workbook('testpublish')
      res = client.workbooks.preview_image(workbook_id: workbook['id'])
      f = Tempfile.new('png')
      f.write(res)
      f.close
      # will raise an error if PNG parsing fails
      ChunkyPNG::Image.from_file(f)
    end
  end

  describe '#refresh' do
    it 'can refresh a workbook' do
      workbook = find_or_publish_workbook('testpublish')
      expect(
        client.workbooks.refresh(workbook_id: workbook['id'])
      ).to be true
    end
  end

  describe '#version' do
    it 'can get the version of a twbx file' do
      expect(client.workbooks.version('spec/fixtures/workbooks/test.twbx')).to eq '10.5'
    end

    it 'returns nil if file not found' do
      expect(client.workbooks.version('spec/fixtures/workbooks/foo.twbx')).to be_nil
    end

    it 'returns nil if file not twbx' do
      expect(client.workbooks.version('spec/fixtures/workbooks/foo.bar')).to be_nil
    end
  end

  def test_group
    @test_group ||= client.groups.list.find { |g| g['name'] == 'testgroup' }
  end

  def all_users_group
    @all_users_group ||= client.groups.list.find { |g| g['name'] == 'All Users' }
  end

  def admin_user
    @admin_user ||= client.users.list.find { |g| g['name'] == ENV['TABLEAU_ADMIN_USERNAME'] }
  end
end
