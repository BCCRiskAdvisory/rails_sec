$(() ->
  searchForm = $('#user-search-form')
  searchSubmit = searchForm.find('.submit-form')
  queryOutput = $('#query-output')
  userOutput = $('#user-search-output')

  renderUsers = (users) ->
    html = '<table class="users-table"><tr>'
    cols = (k for k, v of users[0])
    for col in cols
      html += '<th>' + col + '</th>'
    html += '</tr>'
    for user in users
      html += '<tr>'
      for col in cols
        html += '<td>' + user[col] + '</td>'
      html += '</tr>'
    html += "</table>"

  searchSubmit.click((e) ->
    e.preventDefault()
    $.get('/users.json', searchForm.serializeForm()).success((response) ->
      queryOutput.text(response.query)
      if response.users.length > 0
        userOutput.html(renderUsers(response.users))
      else
        userOutput.text('No matching users')

    )
  )

  listForm = $('#user-list-form')
  listRefresh = listForm.find('.submit-form')
  listOutput = $('#user-list-output')

  listUsers = () ->
    data = listForm.serializeForm()
    params = {}
    if data.reverse == 'true'
      params.reverse = true
    params.order = data.column
    $.get('/users.json', params).success((response) ->
      queryOutput.text(response.query)
      if response.users.length > 0
        listOutput.html(renderUsers(response.users))
      else
        listOutput.text('No users')
    )

  listUsers() if listForm.length > 0
  listRefresh.click((e) ->
    e.preventDefault()
    listUsers()
  )

)
