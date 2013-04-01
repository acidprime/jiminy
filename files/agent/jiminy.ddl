metadata :name        => "jiminy",
         :description => "Syncs modules using git ",
         :author      => "Zack Smith",
         :license     => "MIT",
         :version     => "1.0",
         :url         => "http://puppetlabs.com",
         :timeout     => 120

  ['push',
   'pull',
   'status',
   'cache',
   'environment',
   'module',
   'synchronize',
   'sync'].each do |act|
  action act, :description => "#{act.capitalize} " do
    input :path,
          :prompt      => "Module path",
          :description => "Operating on #{act}",
          :type        => :string,
          :validation  => '.',
          :optional    => false,
          :maxlength   => 256

    display :always if act == 'status'
    output :path,
           :description => "Operating on #{act}",
           :display_as  => "Path"

    output :output,
           :description => "Output from git",
           :display_as  => "Output"

  end
end
# vim: set syntax=ruby:
