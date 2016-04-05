$(() ->
  bulletList = $('.bullet-reveal')
  return unless bulletList.length

  listElements = ($(el) for el in bulletList.find('.bullet'))
  index = 0
  nextLink = $('a.next-slide-link')

  $(document).on('keypress', (e) ->
    if e.keyCode == 32
      el = listElements[index]
      if el
        el.addClass('revealed')
        index += 1
      else
        nextLink[0].click()
  )

)
