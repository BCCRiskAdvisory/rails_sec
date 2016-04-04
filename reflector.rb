require 'optparse'
require 'socket'
require 'json'

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

  def process(request)
    begin      
      @request = request
      puts "@request: #{@request}"
      parse_request
      puts "#{@method} #{@uri}"
      if @method == 'GET' && ['/', '/index.html', '/index'].include?(@uri)
        puts "rendering index"
        make_response(200, INDEX_HTML, HTML_MIME)
      elsif @method == 'GET' && @uri == '/favicon.ico'
        puts "rendering favicon"
        make_response(200, FAVICON, ICON_MIME)
      elsif @method == 'GET' && @uri == '/update.json'
        puts "rendering update"
        resp = JSON.dump({:payloads => retrieve_payloads})      
        make_response(200, resp, JSON_MIME)
      else
        puts "rendering 204"
        add_payload(request)
        make_response(204)
      end
    rescue Exception => e
      body = e.to_s
      body += "\n"
      body += e.backtrace.join("\n")
      make_response(500, body, PLAIN_MIME)
    end
  end

  def parse_request    
    lines = @request.lines.to_a
    top_line = lines.shift
    parts = top_line.split(" ")
    @method = parts[0]
    @uri = parts[1]
    @http_version = parts[2]
    @headers = {}
    lines.each do |line|
      parts = line.split(": ")
      header_name = parts.shift
      header_value = parts.join(": ")      
      @headers[header_name] = header_value
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
      req = ""
      loop do
        begin
          data = client.recv_nonblock(32)        
          if data.length == 0
            break
          else
            req += data
          end
        rescue Errno::EAGAIN
          break
        rescue IO::WaitReadable
          IO.select([client])        
        end
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

