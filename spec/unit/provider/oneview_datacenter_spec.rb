################################################################################
# (C) Copyright 2016-2017 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

require 'spec_helper'

provider_class = Puppet::Type.type(:oneview_datacenter).provider(:c7000)
api_version = login[:api_version] || 200
resource_type = OneviewSDK.resource_named(:Datacenter, api_version, :C7000)

describe provider_class, unit: true do
  include_context 'shared context'

  let(:provider) { resource.provider }

  let(:instance) { provider.class.instances.first }

  let(:test) { resource_type.new(@client, resource['data']) }

  before(:each) do
    allow_any_instance_of(resource_type).to receive(:retrieve!).and_return(true)
    provider.exists?
  end

  context 'given the create parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_datacenter).new(
        name: 'Datacenter',
        ensure: 'present',
        data:
            {
              'name' => 'Datacenter',
              'width' => '5000',
              'depth' => '5000'
            },
        provider: 'c7000'
      )
    end

    it 'should be an instance of the provider Ruby' do
      expect(provider).to be_an_instance_of Puppet::Type.type(:oneview_datacenter).provider(:c7000)
    end

    it 'should return that the resource does not exists' do
      allow_any_instance_of(resource_type).to receive(:retrieve!).and_return(false)
      expect(provider.exists?).not_to be
    end

    it 'should create/add the datacenter' do
      allow_any_instance_of(resource_type).to receive(:retrieve!).and_return(false)
      allow_any_instance_of(resource_type).to receive(:add).and_return(test)
      provider.exists?
      expect(provider.create).to be
    end
  end

  context 'given the min parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_datacenter).new(
        name: 'Datacenter',
        ensure: 'found',
        provider: 'c7000'
      )
    end

    it 'should not return any datacenters' do
      allow(resource_type).to receive(:find_by).and_return([])
      provider.exists?
      expect { provider.found }.to raise_error(/No Datacenter with the specified data were found on the Oneview Appliance/)
    end
  end

  context 'given the min parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_datacenter).new(
        name: 'Datacenter',
        ensure: 'present',
        data:
            {
              'name' => 'Datacenter'
            },
        provider: 'c7000'
      )
    end

    before(:each) do
      allow(resource_type).to receive(:find_by).and_return([test])
      provider.exists?
    end

    it 'should be able to get the visual content' do
      visual_content = 'spec/support/fixtures/unit/provider/datacenter_visual_content.json'
      allow_any_instance_of(resource_type).to receive(:get_visual_content).and_return(File.read(visual_content))
      expect(provider.get_visual_content).to eq(true)
    end

    it 'deletes the resource' do
      expect_any_instance_of(resource_type).to receive(:remove).and_return(true)
      provider.exists?
      expect(provider.destroy).to be
    end
  end
end
