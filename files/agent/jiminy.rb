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
       ['push',
        'pull',
        'status',
        'cache',
        'environment',
        'module',
        'synchronize',
        'sync'].each do |act|
        action act do
          validate :path, :shellsafe

          path = request[:path]
          reply.fail "Path not found #{path}" unless File.exists?(path)

          return unless reply.statuscode == 0
          run_cmd act, path
          reply[:path]   = path
        end
      end

      private

      def run_cmd(action,path=nil)
        output = ''
        git  = ['/usr/bin/git']
        r10k = ['/usr/bin/r10k']
        case action
        when 'push','pull','status'
          cmd = git
          cmd << 'push'   if action == 'push'
          cmd << 'pull'   if action == 'pull'
          cmd << 'status' if action == 'status'
        when 'cache','environment','module','synchronize','sync'
          cmd = r10k
          cmd << 'cache'       if action == 'cache'
          cmd << 'synchronize' if action == 'synchronize' or action == 'sync'
          cmd << 'environment' if action == 'environment'
          cmd << 'module'      if action == 'module'
        end
        reply[:status] = run(cmd, :stderr => :error, :stdout => :output, :chomp => true, :cwd => path )
      end
    end
  end
end
