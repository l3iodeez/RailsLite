require_relative 'routes'
require_relative 'controllers'

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create
end


server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end


trap('INT') { server.shutdown }
server.start
