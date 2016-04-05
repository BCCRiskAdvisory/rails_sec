require 'optparse'
require 'socket'
require 'json'
require 'byebug'

options = {:port => 3001}
opt_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: reflector.rb [options]'
  opts.on('-p', '--port [PORT]', Integer, 'Set port') do |p|
    options[:port] = p
  end
  opts.on_tail('-h', '--help', 'Show this message') do 
    puts opts
    exit
  end
end

opt_parser.parse!(ARGV)

CODE_VALUES = {200 => 'OK', 204 => 'No Content', 404 => 'Not Found', 500 => 'Server Error'}

HTML_MIME = 'text/html, charset=uft-8'
JSON_MIME = 'application/json, charset=uft-8'
PLAIN_MIME = 'text/plain, charset=uft-8'
ICON_MIME = 'image/x-icon'

class Request
  attr_accessor :method, :uri, :raw, :http_version, :body

  def initialize(top_line)
    @raw = top_line
    @finished = false
    @headers_finished = false
    @body = ""
    @headers = {}
    parts = top_line.split(" ")
    @method = parts[0]
    @uri = parts[1]
    @http_version = parts[2]
  end

  def parse_line(line)
    @raw += line
    if line.strip.length == 0
      @headers_finished = true
      if !@content_length_header
        @finished = true
      end
      return      
    end
    if @headers_finished
      @body += line
    else
      parse_header(line)
    end
  end

  def parse_header(line)
    parts = line.split(": ")
    @headers[parts[0]] = parts[1]
    if parts[0].upcase == "CONTENT-LENGTH"
      @content_length_header = true
      @remaining_content = parts[1].to_i
    end
  end

  def parse_body(line)
    @body += line
    @remaining_content -= line.length
    if @remaining_content <= 0
      @finished = true
    end
  end

  def finished?
    @finished
  end
end

server = TCPServer.new options[:port]

class ReflectorWorker

  INDEX_HTML = File.read('reflector.html')
  FAVICON = File.read('reflector.ico')

  def retrieve_payloads; self.class.retrieve_payloads; end
  def add_payload(val); self.class.add_payload(val); end

  def self.retrieve_payloads
    val = @payloads || []
    @payloads = []
    val
  end

  def self.add_payload(val)
    (@payloads ||= []).push(val)
  end

  def process(req)
    begin      
      if req.method == 'GET' && ['/', '/index.html', '/index'].include?(req.uri)
        puts "rendering index"
        make_response(200, INDEX_HTML, HTML_MIME)
      elsif req.method == 'GET' && req.uri == '/favicon.ico'
        puts "rendering favicon"
        make_response(200, FAVICON, ICON_MIME)
      elsif req.method == 'GET' && req.uri == '/update.json'
        puts "rendering update"
        resp = JSON.dump({:payloads => retrieve_payloads})      
        make_response(200, resp, JSON_MIME)
      else
        puts "rendering 204"
        add_payload(req.raw)
        make_response(204)
      end
    rescue Exception => e
      body = e.to_s
      body += "\n"
      body += e.backtrace.join("\n")
      make_response(500, body, PLAIN_MIME)
    end
  end

  def make_response(code, body = nil, content_type = nil)
    lines = []
    lines.push("HTTP/1.1 #{code} #{CODE_VALUES[code]}")
    lines.push("Content-Type: #{content_type}") if content_type
    lines.push("Content-Length: #{body ? body.length : 0}")
    lines.push("Connection: close")
    lines.push("")
    lines.push(body) if body
    lines.push("", "")
    lines.join("\r\n")
  end

end

loop do
  Thread.start(server.accept) do |client|
    begin
      line = client.gets
      puts line      
      req = Request.new(line)
      while (!req.finished?) do
        line = client.gets
        puts line
        req.parse_line(line)
      end
      
      response = ReflectorWorker.new.process(req) 
      client.puts(response)
    rescue Exception => e
      puts e
      puts e.backtrace.join("\n")
    ensure
      client.close
    end
  end
end

