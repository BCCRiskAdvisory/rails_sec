class XssController < ApplicationController
  def index
  end

  def raw
    @output = params['cmd']
  end

  def encoded
    @output = params['cmd']
  end

  def attrs
    @output = params['cmd']
  end

  def js_encoded
    @output = params['cmd']
  end

end