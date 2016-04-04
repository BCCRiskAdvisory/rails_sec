$.fn.serializeForm = () ->
  ret = {}
  for el in this.serializeArray()
    ret[el.name] = el.value
  ret
