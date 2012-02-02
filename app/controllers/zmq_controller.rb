
require "ffi-rzmq"

#http://zeromq.github.com/rbzmq/

class ZmqController < ApplicationController

  @@data = '{"toto":1}'
  @@port = 5000
  @@context = ZMQ::Context.new

  def test

    socket = @@context.socket(ZMQ::REQ)
    socket.connect("tcp://127.0.0.1:#{@@port}")

    socket.send_string(@@data, 0)
    socket.recv_string(@@data, 0)

    @@port = @@port < 5009 ? @@port + 1 : 5000
    print @@port

    render :text => @@data
  end

end
