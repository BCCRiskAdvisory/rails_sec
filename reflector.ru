require 'json'

HTML_MIME = 'text/html, charset=utf-8'
JSON_MIME = 'application/json, charset=utf-8'

INDEX_HTML = File.read('reflector.html')

payloads = []

app = Proc.new do |env|
  request = env["REQUEST_METHOD"] + ':' + env["REQUEST_PATH"]

  query = {}
  env["QUERY_STRING"].split("&").each{ |part| part.split('=').tap{ |kv| query[kv[0]] = kv[1] } } 

  case request
  when 'GET:/', 'GET:', 'GET:index.html'
    ['200', {'Content-Type' => HTML_MIME}, [INDEX_HTML]]
  when 'GET:/reflect'
    payloads.push(query["payload"]) if query["payload"]
    ['204', {}, []]
  when 'GET:/update.json'
    resp = [JSON.dump(payloads)]
    payloads = []
    ['200', {'Content-Type' => JSON_MIME}, resp]    
  else
    ['404', {'Content-Type' => 'text/plain'}, ['Page not found.']]
  end  
end

run app