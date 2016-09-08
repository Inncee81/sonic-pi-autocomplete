helper = require './helper'
data = require './data'

module.exports = provider =
  selector: '.source.ruby, .symbol.ruby'
  inclusionPriority: 0
  excludeLowerPriority: false

  #Note: fns, synth, fx, sample and etc. are all part of completions.
  completions:

    snippets: [
      "adsr", "asr", "pluck"
      "slide", "slideshape", "slidecurve"
    ]

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

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
    return new Promise (resolve) =>
      suggestions = []

      grammar = editor.getGrammar();

      tokens = grammar.tokenizeLines(editor.getText());

      # Note that currentLine is an object containing tokens, linesPreceeded, and linesSuffixed
      currentLine = helper.getLine(tokens, bufferPosition.row)
      currentLineStr = helper.convertNewlinesArrayToString currentLine.tokens

      console.log "Current Line: "
      #console.log currentLineStr
      #console.log currentLine

      cursorContext = helper.parseCursorContext currentLine, bufferPosition
      console.log "Cursor context:"
      console.log cursorContext

      linesInCurrentScope = helper.getLinesInCurrentScope tokens, bufferPosition
      console.log "Lines Data:"
      console.log linesInCurrentScope

      scopeData = helper.createDatabase linesInCurrentScope
      console.log "Scope Data:"
      console.log scopeData

      # NOTE: with_fx, with_synth are also considered function calls in context.

      if cursorContext.lineType is "function-call"
        if (cursorContext.params.length > 2 and cursorContext.functionName == "play_pattern_timed") or
           (cursorContext.params.length > 1 and cursorContext.functionName in ["play", "play_chord", "play_pattern"]) or
           (cursorContext.functionName in ['use_merged_synth_defaults', 'use_synth_defaults', 'with_merged_synth_defaults', 'with_synth_defaults'])
          possibleParams = data.getSynthParams scopeData.currentSynth
          lastWord = @getLastParamWord cursorContext
          for param in possibleParams
            if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
              suggestions.push
                text: param.param
                replacementPrefix: lastWord
                type: 'property'
                leftLabel: 'syn ' + scopeData.currentSynth
                rightLabel: (if param.slide then 'Slidable' else if param.control then 'Controllable' else if param.static then 'Uncontrollable')

        else if cursorContext.functionName in ["use_synth", "with_synth"]
          lastWord = @getLastParamWord cursorContext
          for synthName in data.listOfSynthNames
            if lastWord is undefined or lastWord == synthName.substring(0, lastWord.length)
              suggestions.push
                text: synthName
                replacementPrefix: lastWord
                type: 'value'
                rightLabel: 'Sonic Pi Synth'

        else if cursorContext.functionName == "control"
          lastWord = @getLastParamWord cursorContext
          if lastWord is undefined or cursorContext.params.length is 1
            for synth in scopeData.synthInstances
              if lastWord is undefined or lastWord == synth.identifier.substring(0, lastWord.length)
                suggestions.push
                  text: if prefix.endsWith(' ') then synth.identifier else ' ' + synth.identifier
                  replacementPrefix: if lastWord isnt 'control' then lastWord else ""
                  type: 'variable'
                  leftLabel: 'syn ' + synth.synthType
                  rightLabel: 'Synth Instance'
            for fx in scopeData.fxInstances
              if lastWord is undefined or lastWord == fx.identifier.substring(0, lastWord.length)
                suggestions.push
                  text: if prefix.endsWith(' ') then fx.identifier else ' ' + fx.identifier
                  replacementPrefix: lastWord
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
                    suggestions.push
                      text: param.param
                      replacementPrefix: lastWord
                      type: 'property'
                      leftLabel: 'syn ' + scopeData.currentSynth
                      rightLabel: (if param.slide then 'Slidable' else if param.control then 'Controllable' else if param.static then 'Uncontrollable')
                break

            for fx in scopeData.fxInstances
              if instanceName == fx.identifier
                possibleParams = data.getFxParams fx.fxType
                for param in possibleParams
                  console.log param
                  if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
                    suggestions.push
                      text: param.param
                      replacementPrefix: lastWord
                      type: 'property'
                      leftLabel: 'fx ' + fx.fxType
                      rightLabel: (if param.slide then 'Slidable' else if param.control then 'Controllable' else if param.static then 'Uncontrollable')
                break
        else
          if cursorContext.params.length is 0
            for fn in data.fns
              if (@getNumOfValuesInObject(cursorContext) is 0) or
                 (cursorContext.functionName == fn.substring(0, cursorContext.functionName.length))

                # All function snippets goes here
                if fn is 'play'
                  suggestions.push
                    text: 'play :'
                    displayText: 'play'
                    replacementPrefix: cursorContext.functionName
                    type: 'function'
                    rightLabel: 'Sonic Pi Fn'
                else
                  suggestions.push
                    text: fn
                    replacementPrefix: cursorContext.functionName
                    type: 'function'
                    rightLabel: 'Sonic Pi Fn'

            # if item == "with_fx"
            #   suggestions.push
            #     snippet: 'with_fx :${1:reverb} do\n\t:${2}\nend'
            #     type: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'with_fx'
            #   suggestions.push
            #     snippet: 'with_fx :${1:reverb} do | ${2:fx_instance} |\n\t${3}\nend'
            #     type: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'with_fx + controllable fx instance'
            # else if item == "live_loop"
            #   suggestions.push
            #     snippet: 'live_loop :${1:loop_name} do\n\t${2}\nend'
            #     type: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'live_loop'
            #   suggestions.push
            #     snippet: 'live_loop :${1:loop_name} do\n\tsync :${2:sync_loop_name}\n${3}\nend'
            #     type: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'live_loop + sync'
            # else if item == "in_thread"
            #   suggestions.push
            #     snippet: 'in_thread do\n\t${1}\nend'
            #     type: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'in_thread'
            #   suggestions.push
            #     snippet: 'in_thread :${1:thread_name} do\n\t${2}\nend'
            #     type: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'in_thread named'
            # else if item == "use_synth"
            #   suggestions.push
            #     snippet: 'use_synth :'
            #     type: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'use_synth'
            # else if item == "adsr"
            #   suggestions.push
            #     snippet: 'attack: ${1:0.01}, decay: ${2:0}, sustain: ${3:1}, release: ${4:0.1}${5}'
            #     typ: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'ADSR parameters'
            # else if item == "asr"
            #   suggestions.push
            #     snippet: 'attack: ${1:0.01}, sustain: ${2:1}, release: ${3:0.1}${4}'
            #     typ: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'ASR parameters'
            # else if item == "pluck"
            #   suggestions.push
            #     snippet: 'sustain: 0, release: ${1:0.25}${2}'
            #     typ: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'Plucked Envelope'
            #
            # else if item == "slide" and num_of_words_before_cursor >= 4
            #   affectedParameter = third_last_word_of_row.substring(0, third_last_word_of_row.length - 1)
            #   suggestions.push (
            #     snippet: affectedParameter + '_slide: ${1:1}${2}'
            #     typ: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'Param Slide'
            #   ) if affectedParameter in @completions.slidable_synth_params
            #
            # else if item == "slideshape" and num_of_words_before_cursor >= 4
            #   affectedParameter = third_last_word_of_row.substring(0, third_last_word_of_row.length - 1)
            #   suggestions.push (
            #     snippet: affectedParameter + '_slide: ${1:1}, ' + affectedParameter + '_slide_shape: ${2:1}${3}'
            #     typ: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'Param Slide + Shape'
            #   ) if affectedParameter in @completions.slidable_synth_params
            #
            # else if item == "slidecurve" and num_of_words_before_cursor >= 4
            #   affectedParameter = third_last_word_of_row.substring(0, third_last_word_of_row.length - 1)
            #   suggestions.push (
            #     snippet: affectedParameter + '_slide: ${1:1}, ' + affectedParameter + '_slide_curve: ${2:0}${3}'
            #     typ: 'snippet'
            #     rightLabel: 'Sonic Pi Snippet'
            #     displayText: 'Param Slide + Curve'
            #   ) if affectedParameter in @completions.slidable_synth_params
            #
            # else
            #   suggestions.push
            #     text: item
            #     type: 'snippet'
            #     rightLabel: "Sonic Pi"
      resolve(suggestions)
