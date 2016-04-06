{CompositeDisposable} = require 'atom'
request = require 'request'
cheerio = require 'cheerio'
google = require 'google'

module.exports = TmxSourcerer =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'tmx-sourcerer:fetch': => @fetch()

  deactivate: ->
    @subscriptions.dispose()

  fetch: ->
    if editor = atom.workspace.getActiveTextEditor()
      query = editor.getSelectedText()
      language = editor.getGrammar().name

      getResult(query, language).then (url) ->
        atom.notifications.addSuccess "Googled result"
        download(url).then (body) ->
          atom.notifications.addSuccess "Downloaded SO Page"
          snippet = scrape body
          if snippet == ""
            atom.notifications.addWarning "No accepted answer :("
          else
            editor.insertText snippet
        , (err) ->
          atom.notifications.addWarning err.reason
      , (err) ->
        atom.notifications.addWarning err.reason

# Private functions - not part of module.exports
getResult = (query, language) ->
  return new Promise (resolve, reject) ->
    google.resultsPerPage = 1
    searchQuery = "#{query} in #{language} site:stackoverflow.com"

    google searchQuery, (err, res) ->
      if (err)
        reject reason: "Google search failed"

      if res.links.length == 0
        reject reason: "No results found"
      else
        resolve res.links[0].href

download = (url) ->
  return new Promise (resolve, reject) ->
    request url, (error, response, body) ->
      if !error && response.statusCode == 200
        resolve body
      else
        reject reason: "Unable to download page"

scrape = (body) ->
  $ = cheerio.load(body);
  return $('div.accepted-answer pre code').text()
