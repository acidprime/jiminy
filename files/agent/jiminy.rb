module MCollective
  module Agent
    class Jiminy<RPC::Agent
      metadata :name        => 'jiminy',
               :description => 'Triggers git pulls on multi-master',
               :author      => 'Zack Smith',
               :license     => 'MIT',
               :version     => '1.0',
               :url         => 'http://puppetlabs.com',
               :timeout     => 120

      ['pull','push'].each do |act|
        action act do
          validate :path, :shellsafe
          run_git act, request[:path]
        end
      end
      action 'status' do
        run_git 'status'
      end

      private
      def run_git(action,path=nil)
        output = ''
        cmd = ['/usr/bin/git']
        case action
        when 'pull','push'
          cmd << 'pull' if action == 'pull'
          cmd << 'push' if action == 'push'
          reply[:path] = path
        when 'status'
          cmd << 'status'
        end
        reply[:status] = run(cmd, :stdout => :output, :chomp => true, :cwd => path )
      end
    end
  end
end
