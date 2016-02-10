$(() ->
  $('.simple-io').each(() ->
    el = $(@)
    action = el.attr('action')
    method = el.attr('method')
    submitBtn = el.find('.submit')
    input = el.find('.input')
    output = el.find('.output')
    clear = el.find('.clear')
    submitBtn.click((e) ->
      e.preventDefault()
      $.ajax(action, {
        method: method        
        data: el.serialize()
        success: (data) ->
          output.text(data)
      })
    )
    clear.click((e) ->
      e.preventDefault()
      output.text("")
    )
  )
)