require 'webrick'
require 'stringio'

PORT = 8888
REPO_NAME = "test"

# Git Smart HTTP service header helpers
def pkt_line(str)
  (str.length + 4).to_s(16).rjust(4, '0') + str
end

def flush_pkt
  "0000"
end

server = WEBrick::HTTPServer.new(
  Port: PORT,
  BindAddress: '0.0.0.0',
  Logger: WEBrick::Log.new('/dev/null'),
  AccessLog: []
)

server.mount_proc "/#{REPO_NAME}.git/info/refs" do |req, res|
  if req.query['service'] == 'git-upload-pack'
    # Fake a single ref: master -> deadbeef...
    ref = "deadbeefdeadbeefdeadbeefdeadbeefdeadbeef"
    ref_name = "refs/heads/master"

    response = StringIO.new
    response << pkt_line("# service=git-upload-pack\n")
    response << flush_pkt
    response << pkt_line("#{ref} #{ref_name}\0report-status\n")
    response << flush_pkt

    res.status = 200
    res['Content-Type'] = 'application/x-git-upload-pack-advertisement'
    res.body = response.string
  else
    res.status = 404
    res.body = "Not Found"
  end
end

trap("INT") { server.shutdown }
puts "Mock Git server running on http://localhost:#{PORT}/#{REPO_NAME}.git"
server.start