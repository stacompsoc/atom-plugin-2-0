{CompositeDisposable} = require 'atom'
request = require 'request'
cheerio = require 'cheerio'
google = require 'google'

google.resultsPerPage = 1

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
      getUrl(query, language).then (url)->
        atom.notifications.addSuccess "Gor the url!"
        download(url).then (body) ->
          code = scrape body
          atom.notifications.addSuccess "Gor snippet!"
          if code != ""
            editor.insertText code
          else
            atom.notifications.addWarning "No code found"
        , (error) ->
          atom.notifications.addWarning(error.reason)
      , (err) ->
        atom.notifications.addWarning(err.reason)

download = (url) ->
  return new Promise (resolve, reject) ->
    request url, (error, response, body) ->
      if !error && response.statusCode == 200
        resolve body
      else
        reject reason: "Couldn't download the page"

scrape = (body) ->
  $ = cheerio.load(body)
  return $("div.accepted-answer pre code").text()

getUrl = (query, language) ->
  return new Promise (resolve, reject) ->
    searchString = "#{query} in #{language} site:stackoverflow.com"
    atom.notifications.addInfo "Fetching..."
    google searchingString, (err, res) ->
      if err
        reject reason: "A search error occured"
      else if res.links.length == 0
        reject reason: "No links were found"
      else
        atom.notifications.addError "message"
        resolve res.links[0].href
