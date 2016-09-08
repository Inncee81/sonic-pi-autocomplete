{CompositeDisposable} = require 'atom'
osc                   = require 'node-osc'
#first-mate            = require 'first-mate'
provider              = require './sonic-pi-autocompleter'
data                  = require './data'

module.exports = SonicPiAutocomplete =
  subscriptions: null
  provide: -> provider

  activate: (state) ->
    data.initialiseDatabase()
    @subscriptions = new CompositeDisposable
    @subscriptions.add(atom.commands.add 'atom-workspace',
      'sonic-pi-autocomplete:play-file':                            => @play('getText'),
      'sonic-pi-autocomplete:play-selection':                       => @play('getSelectedText'),
      'sonic-pi-autocomplete:stop':                                 => @stop(),
      'sonic-pi-autocomplete:play-huge-file':                       => @save_and_play())

  deactivate: ->
    @subscriptions.dispose()

  play: (selector) ->
    editor = atom.workspace.getActiveTextEditor()
    source = editor[selector]()
    @send '/run-code', 'SONIC_PI_CLI', source
    atom.notifications.addSuccess "Sent source code to Sonic Pi."

  save_and_play: ->
    editor = atom.workspace.getActiveTextEditor()
    editor.save();
    fullPath = editor.getPath()
    title = editor.getTitle()

    @send '/save-and-run-buffer-via-local-file', 'Atom', title, fullPath, title
    atom.notifications.addSuccess "Saved " + title + " and running in buffer 10 (hidden)"

  stop: ->
    @send '/stop-all-jobs', 'SONIC_PI_CLI'
    atom.notifications.addInfo "Told Sonic Pi to stop playing."

  send: (args...) ->
    client = new osc.Client('localhost', 4557)
    client.send args..., -> client.kill()
