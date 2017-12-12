require 'oneview-sdk'
require_relative '../provider/login'

Facter.add(:oneview_version) do
  setcode do
    client = OneviewSDK::Client.new(login)
    resource_type = OneviewSDK.resource_named(:Version, login[:api_version], login[:hardware_variant])
    resource_type.get_version(client)
  end
end
