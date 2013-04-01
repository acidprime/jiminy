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

      ['push','pull','status'].each do |act|
        action act do
          validate :path, :shellsafe

          path = request[:path]
          reply.fail "Path not found #{path}" unless File.exists?(path)

          return unless reply.statuscode == 0
          run_git act, path
        end
      end

      private

      def run_git(action,path=nil)
        output = ''
        cmd = ['/usr/bin/git']
        case action
        when 'push','pull'
          cmd << 'push' if action == 'push'
          cmd << 'pull' if action == 'pull'
        when 'status'
          cmd << 'status'
        end
        reply[:path] = path
        reply[:status] = run(cmd, :stdout => :output, :chomp => true, :cwd => path )
      end
    end
  end
end
