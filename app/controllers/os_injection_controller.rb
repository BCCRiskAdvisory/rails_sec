class OsInjectionController < ApplicationController
  def index
  end

  def injectable
    output = `#{params['cmd']}`    
    render :text => output
  end

  def search_dir    
    output = `ls -l #{params['cmd']}`
    render :text => output
  end

  def search_dir_relative
    directory = Rails.root.join(params['cmd'])
    output = `ls -l #{directory}`
    render :text => output
  end

  def blind
    success = system("which #{params['cmd']}")
    render :text => success ? "Command available" : "Command not available"
  end
    
  def blacklist
    stripped = params['cmd'].gsub(/[;|`&$]/, "")
    cmd = "ls -l #{stripped}"
    puts "stripped command: #{cmd}"
    render :text => `#{cmd}`  
  end

end
