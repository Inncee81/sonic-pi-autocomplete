# A very trivial module for 'parsing' ruby
# Still a work in progress!

module.exports = Comprehension =

  

  # These are Sonic Pi-specific structures
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

  # This method is used for reading a single line at the cursor's point. Not for parsing.
  #
  # lines: the entire document tokenized
  # linesInRegard: The 'input' lines, which will be returned as remaining lines
  # lineNo: the current code line, not buffer line
  #
  # Returns the tokens of the line(s) as a tokens array. Multi-line expressions
  # will be converted into a single line.
  #
  # There are, so far, 4 ways of extending the line to multiple lines:
  # Through the use of line continuation \,
  # or through incomplete braces, brackets and parenthesis,
  # or through trailing operators
  # or through trailing opening control statement keywords
  getLine: (lines, lineNo) ->
    returnable = []
    # Backwards (closing paren will increase depth)
    braceDepth = 0; brackDepth = 0; parenDepth = 0
    for line in lines.split(0, lineNo).reverse()
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

      lastToken = @getLastNonWhitespaceToken(line)
      if (lastToken.value.trim() is "\\" and lastToken.scopes.length is 1) or
         not (braceDepth == brackDepth == parenDepth == 0) or
         @isOperatorScope lastToken
        line.splice(0, line.length - 2) if lastToken.value.trim() is "\\"
        returnable.unshift token for token in lines
      else
        break

    # Forwards (closing paren will decrease depth)
    braceDepth = 0; brackDepth = 0; parenDepth = 0
    for line in lines.split(lineNo)
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

      lastToken = @getLastNonWhitespaceToken(line)
      if (lastToken.value.trim() is "\\" and lastToken.scopes.length is 1) or
         not (braceDepth == brackDepth == parenDepth == 0) or
         @isOperatorScope lastToken
        line.splice(0, line.length - 2) if lastToken.value.trim() is "\\"
        returnable.push token for token in lines
      else
        break
    returnable

  # This one will return line as line: (which can consist of the actual array which belong as one line)
  # It will also return the remaining lines
  getLineAsLines: (lines, lineNo) ->
    returnable = []
    remaining = lines.splice() #duplicate
    # Backwards (closing paren will increase depth)
    braceDepth = 0; brackDepth = 0; parenDepth = 0
    for line in lines.split(0, lineNo).reverse()
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

      lastToken = @getLastNonWhitespaceToken(line)
      if (lastToken.value.trim() is "\\" and lastToken.scopes.length is 1) or
         not (braceDepth == brackDepth == parenDepth == 0) or
         @isOperatorScope lastToken or
         ("keyword.control.ruby" in lastToken.scopes and lastToken.value in syntaxBlockCreators)
        line.splice(0, line.length - 2) if lastToken.value.trim() is "\\"
        remaining.splice(remaining.indexOf lines)
        returnable.unshift token for token in lines
      else
        break

    # Forwards (closing paren will decrease depth)
    braceDepth = 0; brackDepth = 0; parenDepth = 0
    for line in lines.split(lineNo)
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

      lastToken = @getLastNonWhitespaceToken(line)
      if (lastToken.value.trim() is "\\" and lastToken.scopes.length is 1) or
         not (braceDepth == brackDepth == parenDepth == 0) or
         @isOperatorScope lastToken or
         ("keyword.control.ruby" in lastToken.scopes and lastToken.value in syntaxBlockCreators)
        line.splice(0, line.length - 2) if lastToken.value.trim() is "\\"
        returnable.push token for token in lines
      else
        break
    returnable

  # Returns true if the first non-whitespace word is in the given token `wordScope`
  # (and is inside `wordsList`) within the `lineTokens`.
  #
  # "identifier" can be passed to wordScope to mean that it is looking for an identifier.
  #
  # This method is to determine if a new code block should spawn, or not,
  # as some control keywords like `if` will be a one-liner if it is suffixing a statement.
  isFirstWord: (lineTokens, wordsList = [], wordScope) ->
    token = @getFirstNonWhitespaceToken()
    if   ((wordScope is "identifier" and token.scope.length is 1) or
          (wordScope is "keyword" and "keyword.control.ruby" in token.scope) or
          (wordScope in token.scope)) and
        (wordsList.length is 0 or token.value in wordsList)
      return true
    else
      return false

  getFirstNonWhitespaceToken: (lineTokes) ->
    for token in lineTokens
      if token.scope.length isnt 1 and token.value.trim().length isnt 0 #if not whitespace
        return token

  getLastNonWhitespaceToken: (lineTokens) ->
    for token in lineTokens.reverse()
      if token.scope.length isnt 1 and token.value.trim().length isnt 0
        return token

  isCreatingABlock: (lineTokens) ->
    @isFirstWord(lineTokens, @syntaxBlockCreators, "keyword") or
    @isFirstWord(lineTokens, @syntaxBlockPrecursors, "identifier")

  isEndingABlock: (lineTokens) ->
    @isFirstWord(lineTokens, ["end"], "keyword")

  # Refers to structural depth, not the expression depth
  getCurrentDepth: (lines, bufferPosition) ->
    depth = 0
    for line in lines.split(0, bufferPosition + 1)
      if @isCreatingABlock lines
        depth++
      else if @isEndingABlock lines
        depth--
    depth

  # Single-depth parsing. It will only ever parse one line or one block, and non-recursively
  # Returns: {
  #   type: "call" or "block" or "identifier"
  #   name:         all (block type, function name, or identifier name)
  #   params:       call
  #   blockHeader:  block
  #   blockBody:    block
  # }
  shallowParseLineOrBlock: (lines, bufferPosition) ->
    line = lines[0]

    if @isCreatingABlock line
      type = "block"
      name = @getFirstNonWhitespaceToken line
      blockHeader = @getLine(lines, 0)
      blockBody = undefined

  # Uses
  parse: (lines) ->
    undefined

  parseTopLevelBlock: (lines, bufferPosition) ->
    currDepth = @getCurrentDepth lines, bufferPosition
