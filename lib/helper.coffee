module.exports = helper =

  syntaxBlockCreators: [
    "begin"     #keyword.control.ruby
    "case"      #keyword.control.ruby
    "class"     #keyword.control.ruby
    "def"       #keyword.control.ruby
    "do"        #keyword.control.start.block.ruby (this is different)
    "for"       #keyword.control.ruby
    "if"        #keyword.control.ruby
    "module"    #keyword.control.ruby
    "until"     #keyword.control.ruby
    "while"     #keyword.control.ruby
  ]

  postfixControlKeywords: [
    "until"
    "while"
  ]

  syntaxBlockPrecursors: [
    'at'
    'block_duration'
    'comment'                       # May affect parsing
    'define'                        # Should affect parsing
    'defonce'                       # Should affect parsing
    'in_thread'
    'live_loop'
    'on'
    'uncomment'
    'with_arg_bpm_scaling'
    'with_arg_checks'
    'with_bpm'
    'with_bpm_mul'
    'with_cent_tuning'
    'with_cue_logging'
    'with_debug'
    'with_fx'                       # Affects autocomplete
    'with_merged_sample_defaults'
    'with_merged_synth_defaults'
    'with_octave'
    'with_random_seed'
    'with_sample_bpm'
    'with_sample_defaults'
    'with_synth'                    # Affects autocomplete
    'with_synth_defaults'
    'with_timing_guarantees'
    'with_transpose'
    'with_tuning'
  ]

  isOperatorScope: (token) ->
    for scope in token.scopes
      return true if scope.startsWith "keyword.operator"
    return false

  tokenScopeStartsWith: (token, targetScope) ->
    for scope in token.scopes
      return true if scope.startsWith targetScope
    return false

  # This works for an array of lines
  convertLineTokensToString: (lines) ->
    str = ""
    for line in lines
      for token in line
        str += token.value
      str += "\n"
    return str

  whitespaceToken: (token) ->
    token.scopes.length is 1 and token.value.trim().length is 0

  getFirstNonWhitespaceToken: (lineTokens) ->
    for token in lineTokens
      if not @whitespaceToken token
        return token

  getLastNonWhitespaceToken: (lineTokens) ->
    for token in lineTokens.slice().reverse()
      if not @whitespaceToken token
        return token

  splitWords: (text) ->
    text.split(/\s+/)

  # Returns tokens in line in lines, and the number of lines preceeded and suffixed in relation to lineNo
  getLine: (lines, lineNo) ->
    returnable = []
    linesPreceeded = 0
    linesSuffixed = 0

    # Backwards (closing paren will increase depth)
    braceDepth = 0; brackDepth = 0; parenDepth = 0
    for line in lines.slice(0, lineNo).reverse()
      for token in line
        if "punctuation.section.function.ruby" in token.scopes
          if token.value.trim() is "("
            parenDepth--
          else
            parenDepth++
        if "punctuation.section.array.begin.ruby" in token.scopes
          brackDepth--
        else if "punctuation.section.array.end.ruby" in token.scopes
          brackDepth++
        else if "punctuation.section.scope.begin.ruby" in token.scopes
          braceDepth--
        else if "punctuation.section.scope.end.ruby" in token.scopes
          braceDepth++

      lastToken = @getLastNonWhitespaceToken line #note: line can be empty and lastToken can be undefined

      if lastToken isnt undefined and (
           (lastToken.value.trim() is "\\" and lastToken.scopes.length is 1)  or
            (not (braceDepth == brackDepth == parenDepth == 0))               or
            (@isOperatorScope lastToken)                                      or
            ("keyword.control.ruby" in lastToken.scopes and lastToken.value.trim() in @syntaxBlockCreators) or
            "punctuation.separator.object.ruby" in lastToken.scopes
         )
        line.splice(0, line.length - 2) if lastToken.value.trim() is "\\"
        lineToAdd = []
        lineToAdd.push token for token in line
        returnable.unshift lineToAdd
        linesPreceeded++
      else
        break

    # Forwards (closing paren will decrease depth)
    braceDepth = 0; brackDepth = 0; parenDepth = 0

    FLAG_ADD_NEXT_ROUND = true #initially set to true to push the current line at cursor

    for line in lines.slice(lineNo)
      for token in line
        if "punctuation.section.function.ruby" in token.scopes
          if token.value.trim() is "("
            parenDepth++
          else
            parenDepth--
        if "punctuation.section.array.begin.ruby" in token.scopes
          brackDepth++
        else if "punctuation.section.array.end.ruby" in token.scopes
          brackDepth--
        else if "punctuation.section.scope.begin.ruby" in token.scopes
          braceDepth++
        else if "punctuation.section.scope.end.ruby" in token.scopes
          braceDepth--

      lastToken = @getLastNonWhitespaceToken line

      if FLAG_ADD_NEXT_ROUND is true
        lineToAdd = []
        lineToAdd.push token for token in line
        returnable.push lineToAdd
        linesSuffixed++
        FLAG_ADD_NEXT_ROUND = false # RESET!
      else
        break

      if lastToken isnt undefined and (
           (lastToken.value.trim() is "\\" and lastToken.scopes.length is 1)  or
            (not (braceDepth == brackDepth == parenDepth == 0))               or
            (@isOperatorScope lastToken)                                      or
            ("keyword.control.ruby" in lastToken.scopes and lastToken.value.trim() in @syntaxBlockCreators) or
            "punctuation.separator.object.ruby" in lastToken.scopes
         )
        line.splice(0, line.length - 2) if lastToken.value.trim() is "\\" # Delete the trailing \
        FLAG_ADD_NEXT_ROUND = true                                        # When the next line comes,
                                                                          # add it.

    tokens: returnable
    linesPreceeded: linesPreceeded
    linesSuffixed: linesSuffixed

  # Parses a single 'line' (can be across multiple new-lines)
  # This method is useful for the understanding of context
  parseLine: (lines) ->
    undefined

  getTokenLength: (token) ->
    token.value.length

  getLinesInRegard: (lineObject, bufferPosition) ->
    lines = lineObject.tokens
    linesPreceedingCursor = lineObject.linesPreceeded
    linesInRegard = []

    #fill up linesInRegard with all necessary preceeding lines
    for i in [0...linesPreceedingCursor] #exclusive range is three dots so 0...0 is empty
      linesInRegard.push lines[i]

    #find out how many tokens of the line at bufferPosition.row is in regard
    currentLineTokens = lines[linesPreceedingCursor]
    currentCumulativeColumn = 0;
    targetColumn = bufferPosition.column
    linesToAddInRegard = []
    for token in currentLineTokens
      currentCumulativeColumn += @getTokenLength token
      linesToAddInRegard.push token
      if currentCumulativeColumn is targetColumn
        break
    linesInRegard.push linesToAddInRegard

    linesInRegard

  # Used only for basic shallow parsing at cursor context
  flatten: (linesInRegard) ->
    singleDepthTokens = []
    for line in linesInRegard
      singleDepthTokens.push token for token in line

    singleDepthTokens

  # This method will be used for determining what function / control
  # the cursor is giving parameters to. Useful for autocomplete
  # lineObject: the object returned from the getLine() command
  # Note that in this method, the number of lines in relation to the actual code
  # will not be taken into consideration, as the sole purpose of this function
  # is to determine the autocomplete type.
  #
  # If lineType: identifier,
  #   it means that there is only a single non-whitespace token in the line
  #   it doesn't really mean 'identifier', as it could be a function call that
  #   has yet to have any arguments, or none at all.
  #       identifier: the name of the identifier
  # If lineType: method-call,
  #   delimited by either a token with scope 'support.function.kernel.ruby' or a token with no
  #   special scope, but placed beside a non-operator (not isOperatorScope), and non-whitespace
  #   token without any comma in between.
  #       method: name of the method
  #       params: array of parameter tokens
  # If lineType:
  parseCursorContext: (lineObject, bufferPosition) ->
    #"lines" as in a single expression that can span over multiple lines
    linesInRegard = @getLinesInRegard lineObject, bufferPosition
    tokens = @flatten linesInRegard

    returnable = {}

    determiningToken = @getFirstNonWhitespaceToken tokens
    returnable.name = determiningToken.value

    if determiningToken in syntaxBlockCreators
      returnable.lineType = "ruby-control" # Standard Ruby Syntax
    else if determiningToken in syntaxBlockPrecursors
      returnable.lineType = "sonicpi-control" # Sonic Pi special do...end blocks
    else if @tokenScopeStartsWith tokens[1], "keyword.operator.assignment"
      returnable.lineType = "assignment"
    else
      # Can be postfix controls, or method calls
      # postfix controls are delimited by a
      parenDepth = 0; brackDepth = 0; braceDepth = 0

      maybeListOfParams = [] # Array containing the contents of comma separated expressions
      parameterTokensToAdd = [] # Contains the tokens for the current expression (see above)
      for token in tokens.split().reverse()
        if "punctuation.section.function.ruby" in token.scopes
          if token.value.trim() is "("
            parenDepth++
          else
            parenDepth--
        if "punctuation.section.array.begin.ruby" in token.scopes
          brackDepth++
        else if "punctuation.section.array.end.ruby" in token.scopes
          brackDepth--
        else if "punctuation.section.scope.begin.ruby" in token.scopes
          braceDepth++
        else if "punctuation.section.scope.end.ruby" in token.scopes
          braceDepth--

        if parenDepth is brackDepth is braceDepth is 0 # top level
          if "punctuation.separator.object.ruby" in token.scopes # comma
            maybeListOfParams.unshift parameterTokensToAdd
            parameterTokensToAdd = []
            continue
          else if "keyword.control.ruby" in token.scopes and token.value in postfixControlKeywords
            postfixTokensList = []
            postfixTokensList = parameterTokensToAdd.split() # make sure it's a new instance
            for commaSeparatedSegment in maybeListOfParams # Just in case something made it think this way
              postfixTokensList.push token for token in commaSeparatedSegment
            returnable.lineType = "postfix-control"
            returnable.postfixTokensList = postfixTokensList


    returnable
