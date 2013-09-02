--
-- Public domain
--
local socket = require("socket")
local ssl    = require("ssl")

local params = {
   mode = "server",
   protocol = "sslv3",
   key = "../../certs/serverAkey.pem",
   certificate = "../../certs/serverA.pem",
   cafile = "../../certs/rootA.pem",
   verify = {"peer", "fail_if_no_peer_cert"},
   options = {"all", "no_sslv2"},
}


-- [[ SSL context
local ctx = assert(ssl.newcontext(params))
--]]

ctx:setverifyext("lsec_continue", "crl_check", "crl_check_chain")

local server = socket.tcp()
server:setoption('reuseaddr', true)
assert( server:bind("127.0.0.1", 8888) )
server:listen()

local peer = server:accept()

-- [[ SSL wrapper
peer = assert( ssl.wrap(peer, ctx) )
assert( peer:dohandshake() )
--]]

local succ, errs = peer:getpeerverification()
print(succ, errs)
for i, err in pairs(errs) do
  for j, msg in ipairs(err) do
    print("depth = " .. i, "error = " .. msg)
  end
end

peer:send("oneshot test\n")
peer:close()