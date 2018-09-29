# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'http/protocol/http11/connection'
require_relative 'connection_context'

RSpec.describe HTTP::Protocol::HTTP11::Connection do
	include_context HTTP::Protocol::HTTP11::Connection
	
	it "reads request without body" do
		client.io.write "GET / HTTP/1.1\r\nHost: localhost\r\nAccept: */*\r\nHeader-0: value 1\r\n\r\n"
		client.io.close
		
		authority, method, target, version, headers, body = server.read_request
		
		expect(method).to be == 'GET'
		expect(target).to be == '/'
		expect(version).to be == 'HTTP/1.1'
		expect(headers).to be == {'host' => 'localhost', 'accept' => ['*/*'], 'header-0' => ["value 1"]}
		expect(body).to be_nil
	end
	
	it "reads request with fixed body" do
		client.io.write "GET / HTTP/1.1\r\nHost: localhost\r\nContent-Length: 11\r\n\r\nHello World"
		client.io.close
		
		authority, method, target, version, headers, body = server.read_request
		
		expect(method).to be == 'GET'
		expect(target).to be == '/'
		expect(version).to be == 'HTTP/1.1'
		expect(headers).to be == {'host' => 'localhost', 'content-length' => "11"}
		expect(body).to be == "Hello World"
	end
	
	it "reads request with chunked body" do
		client.io.write "GET / HTTP/1.1\r\nHost: localhost\r\nTransfer-Encoding: chunked\r\n\r\nb\r\nHello World\r\n0\r\n\r\n"
		client.io.close
		
		authority, method, target, version, headers, body = server.read_request
		
		expect(method).to be == 'GET'
		expect(target).to be == '/'
		expect(version).to be == 'HTTP/1.1'
		expect(headers).to be == {'host' => 'localhost', 'transfer-encoding' => ["chunked"]}
		expect(body).to be == "Hello World"
		expect(server).to be_persistent(headers)
	end
	
	it "should be persistent by default" do
		expect(client).to be_persistent({})
		expect(server).to be_persistent({})
	end
end
