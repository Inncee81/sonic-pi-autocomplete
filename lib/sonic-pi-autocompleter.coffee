helper = require './helper'
data = require './data'

module.exports = provider =
  selector: '.source.ruby, .symbol.ruby'
  inclusionPriority: 10
  excludeLowerPriority: false

  autocompleteDisabledFlag: false
  autocompleteDisableCount: 0
  # Anything inside this array will call @temporarilyDisableAutocomplete if inserted onDidInsertSuggestion
  suggestionsToDisableAutocomplete: []

  snippets:
    play: [
      'adsr', 'asr', 'pluck', 'slide', 'slideshape', 'slidecurve'
    ]

  completions:
    placeholders:
      slide_shape:
        "step": '0'
        "linear": '1'
        "sine": '3'
        "welch": '4'
        "squared": '6'
        "cubed": '7'

  getLastParamWord: (cursorContext) ->
    if cursorContext.params.length isnt 0
      helper.convertTokensArrayToString(cursorContext.params[cursorContext.params.length - 1]).trim()

  getNumOfValuesInObject: (object) ->
    numOfValues = 0
    for k, v of object
      ++numOfValues

  getTokensWithoutWhitespace: (tokens) ->
    returnable = []
    for token in tokens
      returnable.push(token) unless token.value.trim().length is 0 and token.scopes.length is 1

    returnable

  temporarilyDisableAutocomplete: (editor) ->
    @autocompleteDisabledFlag = true
    @autocompleteDisableCount = 2
    @excludeLowerPriority = true
    atom.commands.dispatch(editor, 'sonic-pi-autocomplete:cancel')

  onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->
    atom.commands.dispatch(editor, 'sonic-pi-autocomplete:cancel')
    if suggestion in @suggestionsToDisableAutocomplete
      @temporarilyDisableAutocomplete(editor)
      @suggestionsToDisableAutocomplete = []


  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
    if @autocompleteDisableCount isnt 0
      @autocompleteDisableCount--
    if @autocompleteDisableCount is 0
      @autocompleteDisabledFlag = false
    if @autocompleteDisabledFlag and (not activatedManually)
      atom.commands.dispatch(editor, 'sonic-pi-autocomplete:cancel')
      @excludeLowerPriority = true
      return new Promise (resolve) => resolve([])
    else
      @excludeLowerPriority = false

    return new Promise (resolve) =>

      suggestions = []

      grammar = editor.getGrammar();

      tokens = grammar.tokenizeLines(editor.getText());

      # Note that currentLine is an object containing tokens, linesPreceeded, and linesSuffixed
      currentLine = helper.getLine(tokens, bufferPosition.row)
      currentLineStr = helper.convertNewlinesArrayToString currentLine.tokens

      #console.log "Current Line: "
      #console.log currentLineStr
      #console.log currentLine

      cursorContext = helper.parseCursorContext currentLine, bufferPosition
      console.log "Cursor context:"
      console.log cursorContext

      linesInCurrentScope = helper.getLinesInCurrentScope tokens, bufferPosition
      #console.log "Lines Data:"
      #console.log linesInCurrentScope

      scopeData = helper.createDatabase linesInCurrentScope
      console.log "Scope Data:"
      console.log scopeData

      # NOTE: with_fx, with_synth are also considered function calls in context.

      if cursorContext.lineType is "function-call"
        lastWord = @getLastParamWord cursorContext

        if (cursorContext.params.length > 2 and cursorContext.functionName == "play_pattern_timed") or
           (cursorContext.params.length > 1 and cursorContext.functionName in ["play", "play_chord", "play_pattern"]) or
           (cursorContext.functionName in ['use_merged_synth_defaults', 'use_synth_defaults', 'with_merged_synth_defaults', 'with_synth_defaults']) or
           (cursorContext.params.length > 2 and cursorContext.functionName == "synth")
          if cursorContext.functionName == "synth"
            possibleParams = data.getSynthParams(helper.convertTokensArrayToString(cursorContext.params[0]).trim())
          else
            possibleParams = data.getSynthParams scopeData.currentSynth
          secondLastParam = cursorContext.params[cursorContext.params.length - 2] # may be undefined

          for param in possibleParams
            if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
              suggestions.push
                text: param.param + ": "
                replacementPrefix: lastWord
                type: 'property'
                leftLabel: 'syn ' + scopeData.currentSynth
                rightLabel: (if param.slide then 'Slidable' else if param.control then 'Controllable' else if param.static then 'Uncontrollable')
          for snippet in @snippets.play
            if lastWord is undefined or lastWord == snippet.substring(0, lastWord.length)
              if snippet is 'adsr'
                suggestions.push
                  snippet: 'attack: ${1:0.01}, decay: ${2:0}, sustain: ${3:1}, release: ${4:0.1}${5}'
                  type: 'snippet'
                  rightLabel: 'Envelope'
                  displayText: 'ADSR parameters'
              else if snippet is 'asr'
                suggestions.push
                  snippet: 'attack: ${1:0.01}, sustain: ${2:1}, release: ${3:0.1}${4}'
                  type: 'snippet'
                  rightLabel: 'Envelope'
                  displayText: 'ASR parameters'
              else if snippet is 'pluck'
                suggestions.push
                  snippet: 'sustain: 0, release: ${1:0.25}${2}'
                  type: 'snippet'
                  rightLabel: 'Envelope'
                  displayText: 'SR parameters'
              else if secondLastParam isnt undefined
                if (not ("constant.other.symbol.ruby" in @getTokensWithoutWhitespace(secondLastParam)[0].scopes))
                  secondLastParamKey = helper.convertTokensArrayToString(secondLastParam).split(':')[0].trim()
                  if data.extractParam(secondLastParamKey, possibleParams).slide
                    if snippet is 'slide'
                      suggestions.push
                        snippet: secondLastParamKey + '_slide: ${1:1}${2}'
                        type: 'snippet'
                        rightLabel: 'Sonic Pi Snippet'
                        displayText: secondLastParamKey + ' Slide'
                    else if snippet is 'slideshape'
                      suggestions.push
                        snippet: secondLastParamKey + '_slide: ${1:1}, ' + secondLastParamKey + '_slide_shape: ${2:1}${3}'
                        type: 'snippet'
                        rightLabel: 'Sonic Pi Snippet'
                        displayText: secondLastParamKey + ' Slide + Shape'
                    else if snippet is 'slidecurve'
                      suggestions.push
                        snippet: secondLastParamKey + '_slide: ${1:1}, ' + secondLastParamKey + '_slide_curve: ${2:0}${3}'
                        type: 'snippet'
                        rightLabel: 'Sonic Pi Snippet'
                        displayText: secondLastParamKey + ' Slide + Curve'

        else if (cursorContext.functionName in ["use_synth", "with_synth"]) or
                (cursorContext.functionName is "synth" and cursorContext.params.length <= 1)
          spaced = prefix.endsWith(' ') or lastWord isnt undefined

          for synthName in data.listOfSynthNames
            if lastWord is undefined or lastWord == synthName.substring(0, lastWord.length)
              suggestions.push
                text: if spaced then synthName else ' ' + synthName
                replacementPrefix: if spaced then lastWord else ""
                type: 'value'
                rightLabel: 'Sonic Pi Synth'

        else if cursorContext.functionName == "control"
          spaced = prefix.endsWith(' ')
          if lastWord is undefined or cursorContext.params.length is 1
            for synth in scopeData.synthInstances
              if lastWord is undefined or lastWord == synth.identifier.substring(0, lastWord.length)
                suggestions.push
                  text: if spaced then synth.identifier else ' ' + synth.identifier
                  replacementPrefix: if spaced then lastWord else ""
                  type: 'variable'
                  leftLabel: 'syn ' + synth.synthType
                  rightLabel: 'Synth Instance'
            for fx in scopeData.fxInstances
              if lastWord is undefined or lastWord == fx.identifier.substring(0, lastWord.length)
                suggestions.push
                  text: if spaced then fx.identifier else ' ' + fx.identifier
                  replacementPrefix: if spaced then lastWord else ""
                  type: 'variable'
                  leftLabel: 'fx ' + fx.fxType
                  rightLabel: 'FX Instance'

          else if cursorContext.params.length > 1
            instanceName = helper.convertTokensArrayToString(cursorContext.params[0]).trim()
            for synth in scopeData.synthInstances
              if instanceName == synth.identifier
                possibleParams = data.getSynthParams synth.synthType
                for param in possibleParams
                  if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
                    if not param.static
                      suggestions.push
                        text: param.param
                        replacementPrefix: lastWord
                        type: 'property'
                        leftLabel: 'syn ' + synth.synthType
                        rightLabel: (if param.slide then 'Slidable' else if param.control then 'Controllable' else if param.static then 'Uncontrollable')
                break

            for fx in scopeData.fxInstances
              if instanceName == fx.identifier
                possibleParams = data.getFxParams fx.fxType
                for param in possibleParams
                  console.log param
                  if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
                    if not param.static
                      suggestions.push
                        text: param.param
                        replacementPrefix: lastWord
                        type: 'property'
                        leftLabel: 'fx ' + fx.fxType
                        rightLabel: (if param.slide then 'Slidable' else if param.control then 'Controllable' else if param.static then 'Uncontrollable')
                break

        else if cursorContext.functionName == "with_fx"
          if cursorContext.params.length <= 1
            spaced = prefix.endsWith(' ') or lastWord isnt undefined
            for fxName in data.listOfFXNames
              if lastWord is undefined or lastWord == fxName.substring(0, lastWord.length)
                suggestions.push
                  text: if spaced then fxName else ' ' + fxName
                  replacementPrefix: if spaced then lastWord else ""
                  type: 'value'
                  rightLabel: 'Sonic Pi FX'
          else
            # This *should* contain the fxType as a string. May be undefined
            secondLastParam = helper.convertTokensArrayToString(cursorContext.params[cursorContext.params.length - 2]).trim()
            possibleParams = data.getFxParams secondLastParam
            for param in possibleParams
              if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
                suggestions.push
                  text: param.param
                  replacementPrefix: lastWord
                  type: 'property'
                  leftLabel: 'fx ' + fx.fxType
                  rightLabel: (if param.slide then 'Slidable' else if param.control then 'Controllable' else if param.static then 'Uncontrollable')

        else if cursorContext.functionName == "kill"
          spaced = prefix.endsWith(' ') or lastWord isnt undefined

          for synth in scopeData.synthInstances
            if lastWord is undefined or lastWord == synth.identifier.substring(0, lastWord.length)
              suggestions.push
                text: (if spaced then '' else ' ') + synth.identifier
                replacementPrefix: if spaced then lastWord else ""
                type: 'variable'
                rightLabel: synth.synthType + " Instance"
              suggestions.push suggestion
              @suggestionsToDisableAutocomplete.push suggestion

        else if cursorContext.functionName == "sample"
          if cursorContext.params.length <= 1
            spaced = prefix.endsWith(' ') or lastWord isnt undefined
            for sample in data.sample
              if lastWord is undefined or lastWord == sample.substring(0, lastWord.length)
                suggestions.push
                  text: (if spaced then '' else ' ') + sample
                  replacementPrefix: if spaced then lastWord else ""
                  type: 'value'
                  rightLabel: "Sample"
          else
            for param in data.sampleParams
              if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
                suggestions.push
                  text: (if spaced then '' else ' ') + param.param
                  replacementPrefix: if spaced then lastWord else ""
                  type: 'variable'
                  rightLabel: "Sample Param"

        else
          if cursorContext.params.length is 0
            for fn in data.fns
              if (@getNumOfValuesInObject(cursorContext) is 0) or
                 (cursorContext.functionName == fn.substring(0, cursorContext.functionName.length))

                # All function snippets goes here
                if fn is 'play'
                  suggestions.push
                    text: 'play '
                    displayText: 'play'
                    replacementPrefix: cursorContext.functionName
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Fn'
                else if fn is 'with_fx'
                  suggestions.push
                    snippet: 'with_fx :${1:reverb} do\n\t:${2}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'with_fx'
                  suggestions.push
                    snippet: 'with_fx :${1:reverb} do | ${2:fx_instance} |\n\t${3}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'with_fx + controllable fx instance'
                else if fn is 'live_loop'
                  suggestions.push
                    snippet: 'live_loop :${1:loop_name} do\n\t${2}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'live_loop'
                  suggestions.push
                    snippet: 'live_loop :${1:loop_name} do\n\tsync :${2:sync_loop_name}\n${3}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'live_loop + sync'
                else if fn is 'in_thread'
                  suggestions.push
                    snippet: 'in_thread do\n\t${1}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'in_thread'
                  suggestions.push
                    snippet: 'in_thread :${1:thread_name} do\n\t${2}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'in_thread + Thread name'
                else if fn is 'with_synth'
                  suggestions.push
                    snippet: 'with_synth :${1:beep} do\n\t${2}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'with_synth'
                else if fn is 'with_synth_defaults'
                  suggestions.push
                    snippet: 'with_synth_defaults ${1:params} do\n\t${2}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'with_synth_defaults'
                else if fn is 'with_merged_synth_defaults'
                  suggestions.push
                    snippet: 'with_merged_synth_defaults ${1:params} do\n\t${2}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'with_merged_synth_defaults'
                else if fn is 'with_sample_defaults'
                  suggestions.push
                    snippet: 'with_sample_defaults ${1:params} do\n\t${2}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'with_sample_defaults'
                else if fn is 'with_merged_sample_defaults'
                  suggestions.push
                    snippet: 'with_merged_sample_defaults ${1:params} do\n\t${2}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'with_merged_sample_defaults'
                else if fn is 'at'
                  suggestions.push
                    snippet: 'at ${1:1} do\n\t${2}\nend'
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Snippet'
                    displayText: 'at'
                else
                  suggestions.push
                    text: fn + " "
                    replacementPrefix: cursorContext.functionName
                    type: 'snippet'
                    rightLabel: 'Sonic Pi Fn'

      resolve(suggestions)
