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

  getLastParamWord: (exprData) ->
    if exprData.params isnt undefined and exprData.params.length isnt 0
      helper.convertTokensArrayToString(exprData.params[exprData.params.length - 1]).trim()
    else
      undefined

  getNumOfValuesInObject: (object) ->
    numOfValues = 0
    for k, v of object
      ++numOfValues
    numOfValues

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

  # isKeyValueIn: (object, key, value) ->
  #   for k, v of object
  #     if key == k
  #       if value is v
  #         return true
  #
  #   return false
  #
  # keyValueInObjects: (objects, key, value) ->
  #   for object in objects
  #     return true if @isKeyValueIn object, key, value
  #   return false

  # NOTE: For exprData, it can either mean cursorContext, or blockExpression, depending on
  # where the function data is
  autocompleteFunctions: (suggestions, functionName, params, exprData, scopeData, prefix) ->
    lastWord = @getLastParamWord exprData
    currentFunctionAlias = undefined

    for alias in scopeData.aliases
      if alias.functionAlias
        if alias.alias == functionName
          currentFunctionAlias = alias

    if (params.length > 2 and functionName == "play_pattern_timed") or
       (params.length > 1 and functionName in ["play", "play_chord", "play_pattern"]) or
       (functionName in ['use_merged_synth_defaults', 'use_synth_defaults', 'with_merged_synth_defaults', 'with_synth_defaults']) or
       (params.length > 2 and functionName == "synth") or
       (currentFunctionAlias isnt undefined and
            currentFunctionAlias.functionName == "play" and
            params.length >= currentFunctionAlias.startSuggestingAt)

      if functionName == "synth"
        possibleParams = data.getSynthParams(helper.convertTokensArrayToString(params[0]).trim())
      else if currentFunctionAlias isnt undefined and currentFunctionAlias.synthName isnt undefined
        possibleParams = data.getSynthParams(currentFunctionAlias.synthName)
      else
        possibleParams = data.getSynthParams scopeData.currentSynth
      secondLastParam = params[params.length - 2] # may be undefined

      if lastWord isnt undefined
        [k, v] = lastWord.split(':').map((x) -> x.trim())
      else k = v = undefined
      if v isnt undefined
        if k.endsWith "_slide_shape"
          for shape, value of @completions.placeholders.slide_shape
            if v == shape.substring(0, v.length)
              suggestions.push
                text: value
                replacementPrefix: v
                type: 'snippet'
                displayText: shape
                rightLabel: 'Shape Enumeration'
        else
          param = data.extractParam k, possibleParams
          if param.waveMapping isnt undefined
            for shape, value of param.waveMapping
              if v == shape.substring(0, v.length)
                suggestions.push
                  text: "" + value
                  replacementPrefix: v
                  type: 'snippet'
                  displayText: shape
                  rightLabel: 'Shape Enumeration'
      else
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

    else if (functionName in ["use_synth", "with_synth"]) or
            (functionName is "synth" and params.length <= 1)
      spaced = prefix.endsWith(' ') or lastWord isnt undefined

      for synthName in data.listOfSynthNames
        if lastWord is undefined or lastWord == synthName.substring(0, lastWord.length)
          suggestions.push
            text: if spaced then synthName else ' ' + synthName
            replacementPrefix: if spaced then lastWord else ""
            type: 'property'
            rightLabel: 'Sonic Pi Synth'

    else if functionName == "control" or
            (currentFunctionAlias isnt undefined and currentFunctionAlias.functionName == "control")
      spaced = prefix.endsWith(' ')
      if lastWord is undefined or params.length is 1
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
        for sample in scopeData.sampleInstances
          if lastWord is undefined or lastWord == sample.identifier.substring(0, lastWord.length)
            suggestions.push
              text: if spaced then sample.identifier else ' ' + sample.identifier
              replacementPrefix: if spaced then lastWord else ""
              type: 'variable'
              rightLabel: 'Sample Instance'

      else if params.length > 1
        instanceName = helper.convertTokensArrayToString(params[0]).trim()
        for synth in scopeData.synthInstances
          if instanceName == synth.identifier
            possibleParams = data.getSynthParams synth.synthType
            for param in possibleParams
              if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
                if not param.static
                  suggestions.push
                    text: param.param + ": "
                    replacementPrefix: lastWord
                    type: 'property'
                    leftLabel: 'syn ' + synth.synthType
                    rightLabel: (if param.slide then 'Slidable' else if param.control then 'Controllable' else if param.static then 'Uncontrollable')
            break

        for fx in scopeData.fxInstances
          if instanceName == fx.identifier
            possibleParams = data.getFxParams fx.fxType
            for param in possibleParams
              if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
                if not param.static
                  suggestions.push
                    text: param.param + ": "
                    replacementPrefix: lastWord
                    type: 'property'
                    leftLabel: 'fx ' + fx.fxType
                    rightLabel: (if param.slide then 'Slidable' else if param.control then 'Controllable' else if param.static then 'Uncontrollable')
            break

        for sample in scopeData.sampleInstances
          if instanceName == sample.identifier
            possibleParams = data.sampleParams
            for param in possibleParams
              if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
                if not param.static
                  suggestions.push
                    text: param.param + ": "
                    replacementPrefix: lastWord
                    type: 'property'
                    leftLabel: 'Sample'
                    rightLabel: (if param.slide then 'Slidable' else if param.control then 'Controllable' else if param.static then 'Uncontrollable')
            break

    else if functionName == "with_fx"
      if params.length <= 1
        spaced = prefix.endsWith(' ') or lastWord isnt undefined
        for fxName in data.listOfFXNames
          if lastWord is undefined or lastWord == fxName.substring(0, lastWord.length)
            suggestions.push
              text: if spaced then fxName else ' ' + fxName
              replacementPrefix: if spaced then lastWord else ""
              type: 'property'
              rightLabel: 'Sonic Pi FX'
      else
        # This *should* contain the fxType as a string. May be undefined
        secondLastParam = helper.convertTokensArrayToString(params[params.length - 2]).trim()
        possibleParams = data.getFxParams secondLastParam
        for param in possibleParams
          if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
            suggestions.push
              text: param.param
              replacementPrefix: lastWord
              type: 'property'
              leftLabel: 'fx ' + secondLastParam
              rightLabel: (if param.slide then 'Slidable' else if param.control then 'Controllable' else if param.static then 'Uncontrollable')

    else if functionName == "kill"
      spaced = prefix.endsWith(' ') or lastWord isnt undefined

      for synth in scopeData.synthInstances
        if lastWord is undefined or lastWord == synth.identifier.substring(0, lastWord.length)
          suggestion =
            text: (if spaced then '' else ' ') + synth.identifier
            replacementPrefix: if spaced then lastWord else ""
            type: 'property'
            rightLabel: synth.synthType + " Instance"
          suggestions.push suggestion
          @suggestionsToDisableAutocomplete.push suggestion

    else if functionName == "sample"
      if params.length <= 1
        spaced = prefix.endsWith(' ') or lastWord isnt undefined
        for sample in data.sample
          if lastWord is undefined or lastWord == sample.substring(0, lastWord.length)
            suggestions.push
              text: (if spaced then '' else ' ') + sample
              replacementPrefix: if spaced then lastWord else ""
              type: 'property'
              rightLabel: "Sample"
      else
        for param in data.sampleParams
          if lastWord is undefined or lastWord == param.param.substring(0, lastWord.length)
            suggestions.push
              text: (if spaced then '' else ' ') + param.param + ": "
              replacementPrefix: if spaced then lastWord else ""
              type: 'property'
              rightLabel: "Sample Param"

    else
      # Param Completion
      if (@getNumOfValuesInObject(exprData) isnt 0) and (functionName.length isnt 0)
        for fnParam in data.fnParams
          if functionName == fnParam.name
            spaced = lastWord.endsWith(' ') or lastWord is undefined
            for param in fnParam.params
              if lastWord is undefined or lastWord == param.substring(0, lastWord.length)
                suggestion =
                  text: (if spaced then "" else ' ') + param + ": "
                  replacementPrefix: functionName
                  type: 'property'
                  rightLabel: fnParam.name + " Param"
                suggestions.push suggestion

      # Function name completion
      if (@getNumOfValuesInObject(exprData) is 0) or (params.length is 0 and lastWord is undefined) or
         (exprData.params[0] isnt undefined and helper.getNumberOfNonWhitespaceTokens(exprData.params[0]) is 0)
        for fn in data.fns
          if (@getNumOfValuesInObject(exprData) is 0) or
             (functionName == fn.substring(0, functionName.length))

            # All function snippets goes here
            if fn is 'play'
              suggestion =
                text: 'play '
                displayText: 'play'
                replacementPrefix: functionName
                type: 'snippet'
                rightLabel: 'Sonic Pi Fn'
              suggestions.push suggestion
            else if fn is 'with_fx'
              suggestion =
                snippet: 'with_fx :${1:reverb} do\n\t:${2}\nend'
                type: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'with_fx'
              suggestions.push suggestion
              @suggestionsToDisableAutocomplete.push suggestion
              suggestion =
                snippet: 'with_fx :${1:reverb} do | ${2:fx_instance} |\n\t${3}\nend'
                type: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'with_fx + controllable fx instance'
              suggestions.push suggestion
            else if fn is 'live_loop'
              suggestion =
                snippet: 'live_loop :${1:loop_name} do\n\t${2}\nend'
                type: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'live_loop'
              suggestions.push suggestion
              @suggestionsToDisableAutocomplete.push suggestion
              suggestion =
                snippet: 'live_loop :${1:loop_name} do\n\tsync :${2:sync_loop_name}\n${3}\nend'
                type: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'live_loop + sync'
              suggestions.push suggestion
              @suggestionsToDisableAutocomplete.push suggestion
            else if fn is 'in_thread'
              suggestion =
                snippet: 'in_thread do\n\t${1}\nend'
                type: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'in_thread'
              suggestions.push suggestion
              @suggestionsToDisableAutocomplete.push suggestion
              suggestion =
                snippet: 'in_thread name: :${1:thread_name} do\n\t${2}\nend'
                type: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'in_thread + Thread name'
              suggestions.push suggestion
              @suggestionsToDisableAutocomplete.push suggestion
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
                replacementPrefix: functionName
                type: 'snippet'
                rightLabel: 'Sonic Pi Fn'

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
      console.log "Lines Data:"
      console.log linesInCurrentScope

      scopeData = helper.createDatabase linesInCurrentScope
      console.log "Scope Data:"
      console.log scopeData

      # NOTE: with_fx, with_synth are also considered function calls in context.

      console.log "num of values: " + @getNumOfValuesInObject cursorContext

      if cursorContext.lineType is "function-call"
        @autocompleteFunctions suggestions,
                               cursorContext.functionName,
                               cursorContext.params,
                               cursorContext,
                               scopeData,
                               prefix

      else if cursorContext.lineType is "control-block-header"
        if @getNumOfValuesInObject(cursorContext.blockExpression) is 0
          @autocompleteFunctions suggestions,
                                 undefined,
                                 [],
                                 cursorContext.blockExpression,
                                 scopeData,
                                 prefix
        if cursorContext.blockExpression.lineType is 'function-call'
          @autocompleteFunctions suggestions,
                                 cursorContext.blockExpression.functionName,
                                 cursorContext.blockExpression.params,
                                 cursorContext.blockExpression,
                                 scopeData,
                                 prefix

      else if cursorContext.lineType is 'postfix-control'
        if @getNumOfValuesInObject(cursorContext.postfixExpression) is 0
          @autocompleteFunctions suggestions,
                                 undefined,
                                 [],
                                 cursorContext.postfixExpression,
                                 scopeData,
                                 prefix
        if cursorContext.postfixExpression.lineType is 'function-call'
          @autocompleteFunctions suggestions,
                                 cursorContext.postfixExpression.functionName,
                                 cursorContext.postfixExpression.params,
                                 cursorContext.postfixExpression,
                                 scopeData,
                                 prefix
      else if (@getNumOfValuesInObject cursorContext) is 0
        @autocompleteFunctions suggestions,
                               undefined,
                               [],
                               cursorContext,
                               scopeData,
                               prefix

      resolve(suggestions)
