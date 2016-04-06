{CompositeDisposable} = require 'atom'

module.exports = TmxSourcerer =
  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'tmx-sourcerer:fetch': => @fetch()

  deactivate: ->
    @subscriptions.dispose()

  fetch: ->
    atom.notifications.addSuccess "Fetch called!"
