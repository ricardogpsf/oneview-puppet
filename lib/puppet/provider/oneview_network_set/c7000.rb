################################################################################
# (C) Copyright 2016-2017 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

require_relative '../oneview_resource'

Puppet::Type.type(:oneview_network_set).provide :c7000, parent: Puppet::OneviewResource do
  desc 'Provider for OneView Network Sets using the C7000 variant of the OneView API'

  confine feature: :oneview
  confine true: login[:hardware_variant] == 'C7000'

  mk_resource_methods

  def exists?
    # assignments and deletions from @data
    prepare_environment
    network_uris
    empty_data_check([nil, :found, :get_without_ethernet])
    !@resource_type.find_by(@client, @data).empty?
  end

  def get_without_ethernet
    Puppet.notice("\n\nNetwork Set Without Ethernet\n")
    if @data.empty?
      list = @resource_type.get_without_ethernet(@client)
      raise('There is no Network Set without ethernet in the Oneview appliance.') if list.empty?
      list.each { |item| pretty item }
    else
      item = get_single_resource_instance.get_without_ethernet
      raise('There is no Network Set without ethernet in the Oneview appliance.') unless item
      pretty item
    end
    true
  end

  def network_uris
    return unless @data['networkUris']
    list = []
    Puppet.debug("\n\nAPI VERSION: #{api_version} and \nRESOURCE VARIANT: #{resource_variant} \n")
    @data['networkUris'].each do |item|
      net = OneviewSDK.resource_named(:EthernetNetwork, api_version, resource_variant).find_by(@client, name: item)
      raise("The network #{name} does not exist.") unless net.first
      list.push(net.first['uri'])
    end
    @data['networkUris'] = list
  end
end
