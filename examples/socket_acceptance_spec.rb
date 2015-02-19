# This file is part of ruby-flores.
# Copyright (C) 2015 Jordan Sissel
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# encoding: utf-8
require "randomized"
require "socket"
require "rspec/stress_it"

RSpec.configure do |c|
  c.extend RSpec::StressIt
end

# A factory for encapsulating behavior of a tcp server and client for the
# purposes of testing.
#
# This is probably not really a "factory" in a purist-sense, but whatever.
class TCPIntegrationTestFactory
  def initialize(port)
    @listener = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    @client = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    @port = port
  end

  def teardown
    @listener.close unless @listener.closed?
    @client.close unless @listener.closed?
  end

  def sockaddr
    Socket.sockaddr_in(@port, "127.0.0.1")
  end

  def setup
    @listener.bind(sockaddr)
    @listener.listen(5)
  end

  def send_and_receive(text)
    @client.connect(sockaddr)
    server, _ = @listener.accept

    @client.syswrite(text)
    @client.close
    server.read
  ensure
    @client.close unless @client.closed?
    server.close unless server.nil? || server.closed?
  end
end

describe "TCPServer+TCPSocket" do
  let(:port) { Randomized.number(1024..65535) }
  let(:text) { Randomized.text(1..10000) }
  subject { TCPIntegrationTestFactory.new(port) }
  
  describe "using stress_it" do
    stress_it "should send data correctly" do
      begin
        subject.setup
      rescue Errno::EADDRINUSE
        next # Skip port bindings that are in use
      end

      begin
        received = subject.send_and_receive(text)
        expect(received).to(be == text)
      ensure
        subject.teardown
      end
    end
  end
end
