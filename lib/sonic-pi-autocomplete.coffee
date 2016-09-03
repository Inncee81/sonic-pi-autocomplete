{CompositeDisposable} = require 'atom'
osc                   = require 'node-osc'
provider              = require './sonic-pi-autocompleter'

module.exports = SonicPiAutocomplete =
  subscriptions: null
  provide: -> provider

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add(atom.commands.add 'atom-workspace',
      'sonic-pi-autocomplete:play-file':                            => @play('getText'),
      'sonic-pi-autocomplete:play-selection':                       => @play('getSelectedText'),
      'sonic-pi-autocomplete:stop':                                 => @stop(),
      'sonic-pi-autocomplete:save-and-run-buffer-via-local-file':   => @save_and_play())

  deactivate: ->
    @subscriptions.dispose()

  play: (selector) ->
    editor = atom.workspace.getActiveTextEditor()
    source = editor[selector]()
    @send '/run-code', 'SONIC_PI_CLI', source
    atom.notifications.addSuccess "Sent source code to Sonic Pi."

  save_and_play: ->
    editor = atom.workspace.getActiveTextEditor()
    fullPath = editor.getPath()

    @send '/save-and-run-buffer-via-local-file', 'Atom', 'workspace_9', fullPath, 'workspace_9'
    atom.notifications.addSuccess "Saved " + editor.getTitle() + " to buffer 6 and ran it"

  stop: ->
    @send '/stop-all-jobs', 'SONIC_PI_CLI'
    atom.notifications.addInfo "Told Sonic Pi to stop playing."

  send: (args...) ->
    client = new osc.Client('localhost', 4557)
    client.send args..., -> client.kill()
