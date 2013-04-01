pubkey = '/root/.ssh/id_rsa.pub'
if File.exists?(pubkey)
  Facter.add('root_ssh_key') do
    setcode do
      File.read(pubkey).split[1]
    end
  end
end

