__I spent most of the week building this between interviews & meetings so I need to spend some more time on this doc__

#Jiminy

This module is designed to automate the setup of [dynamic environment](https://puppetlabs.com/blog/git-workflow-and-puppet-environments/) workflows in a fresh puppet enterprise install. The module will automatically configure sshkeys
and a bare repo (with an intial production branch). Is also automatically builds a set of git hooks that utilize mcollective agents.
This mcollective agent and application trigger automatic code updates on all masters using the [r10k](https://github.com/adrienthebo/r10k) gem. This will automatically create
sub folders for all environments and the dynamic module path will automatically be setup using augeas. It also sets up commit hooks that use `puppet parser validate` and [puppet-lint](https://github.com/rodjek/puppet-lint)

At the moment is was tested using Centos 6.3 and PE 2.7.0 , thus the commented out facts.d facti value  for is_master in params.
The masters were setup with ca_server in puppet.conf (Note: we normally do not do this in the advanced class on the classroom.puppetlabs.vm system ) and this acts as the default server the git repo is configured on.
I will provide more documentation on this setup later but its what puppet labs uses in its advanced classroom.

To Do:  
1. Well now that I got the POC working I need to test its dep graph on a new host as I built it using a few puppet runs.  
I have cleaned some of the code up but it still could use some love as the module.git is hardcoded.  
2. I currently copied the .mcollective file manually from peadmin and this should be automated form the ENC param (2.7.2) or some file resource.  
3. The post-receive hook is just calling synchronize but this actually can be told just to work on the respective environment for the push.  
4. I am focusing on getting this going turn key on PE but I should spend some time on FOSS  
5. I want to automatically setup config_version with the sha1 of the repo  
6. I need to PR some changes to r10k to allow for a vendor modules folder  
7. I need to build a type and provider for the Puppet Librarian format  
8. I need to add more sanity checks and check running partial catalogs perhaps using tags  
9. Puppet-rspec tests for the classes need to be built
10. I need to add changelog stuff to Modulefile

Requires:  
1. PuppetDB must be setup or exported records must be enabled  
2. ca_server Must be set on all masters including the ca_server itself.  
3. .mcollective or client.cfg must allow for the `root` user to run mco  
4. I tested this using the PL [training VMs](http://downloads.puppetlabs.com/training/) 2.7.0 setup using the [advanced](http://forge.puppetlabs.com/zack/advanced) module (& README)  
