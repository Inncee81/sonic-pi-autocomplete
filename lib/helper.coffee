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
    "if"
    "unless"
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
      return true if ((scope.startsWith "keyword.operator") or (scope.startsWith "punctuation.separator")) and
                      token.value.trim() isnt "|"
    return false

  isBlockButNotDo: (token) ->
    if token.scopes isnt undefined
      for scope in token.scopes
        return true if scope is 'keyword.control.ruby' or scope is 'keyword.control.def.ruby'
    return false
  tokenScopeStartsWith: (token, targetScope) ->
    for scope in token.scopes
      return true if scope.startsWith targetScope
    return false

  # This works for an array of lines
  convertNewlinesArrayToString: (lines) ->
    str = ""
    for line in lines
      for token in line
        str += token.value
      str += "\n"
    return str

  convertTokensArrayToString: (tokens) ->
    str = ""
    str += token.value for token in tokens
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
    braceDepth = 0; brackDepth = 0; parenDepth = 0; variableScope = false;
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
        else if "meta.syntax.ruby.start-block" in token.scopes
          braceDepth--
        else if "punctuation.section.scope.end.ruby" in token.scopes
          braceDepth++
        else if "keyword.operator.other.ruby" in token.scopes
          if token.value.trim() is "|"
            variableScope = not variableScope

      lastToken = @getLastNonWhitespaceToken line #note: line can be empty and lastToken can be undefined

      if lastToken isnt undefined and (
           (lastToken.value.trim() is "\\" and lastToken.scopes.length is 1)                or
            (not (braceDepth == brackDepth == parenDepth == 0) or variableScope)            or
            (@isOperatorScope lastToken)                                                    or
            (@isBlockButNotDo lastToken and lastToken.value.trim() in @syntaxBlockCreators) or
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
    braceDepth = 0; brackDepth = 0; parenDepth = 0; variableScope = false;

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
        else if "meta.syntax.ruby.start-block" in token.scopes
          braceDepth++
        else if "punctuation.section.scope.end.ruby" in token.scopes
          braceDepth--
        else if "keyword.operator.other.ruby" in token.scopes
          if token.value.trim() is "|"
            variableScope = not variableScope

      lastToken = @getLastNonWhitespaceToken line

      # if lastToken isnt undefined
      #   console.log "Last token: " + lastToken.value
      #   if lastToken.value.trim() is "|"
      #     console.log "PIPE DETECTED"
      #     console.log "PIPE SCOPES:"
      #     console.log lastToken.scopes
      #     console.log "Is operator? " + @isOperatorScope(lastToken)

      if FLAG_ADD_NEXT_ROUND is true
        lineToAdd = []
        lineToAdd.push token for token in line
        returnable.push lineToAdd
        linesSuffixed++
        FLAG_ADD_NEXT_ROUND = false # RESET!
      else
        break

      if lastToken isnt undefined and (
           (lastToken.value.trim() is "\\" and lastToken.scopes.length is 1)                or
            (not (braceDepth == brackDepth == parenDepth == 0) and variableScope)           or
            (@isOperatorScope lastToken)                                                    or
            (@isBlockButNotDo lastToken and lastToken.value.trim() in @syntaxBlockCreators) or
            "punctuation.separator.object.ruby" in lastToken.scopes
         )
        line.splice(0, line.length - 2) if lastToken.value.trim() is "\\" # Delete the trailing \
        FLAG_ADD_NEXT_ROUND = true                                        # When the next line comes,
                                                                          # add it.

    tokens: returnable
    linesPreceeded: linesPreceeded
    linesSuffixed: linesSuffixed - 1 # `- 1` is for the line the cursor is already on
    flagAddNextRound: FLAG_ADD_NEXT_ROUND # this is solely for debugging purposes.. hopefully

  getTokenLength: (token) ->
    token.value.length

  getTokensInRegard: (lineObject, bufferPosition) ->
    lines = lineObject.tokens
    linesPreceedingCursor = lineObject.linesPreceeded
    tokensInRegard = []

    #fill up tokensInRegard with all necessary preceeding lines
    for i in [0...linesPreceedingCursor] #exclusive range is three dots so 0...0 is empty
      tokensInRegard.push lines[i]

    #find out how many tokens of the line at bufferPosition.row is in regard
    currentLineTokens = lines[linesPreceedingCursor]
    currentCumulativeColumn = 0;
    targetColumn = bufferPosition.column
    linesToAddInRegard = []
    for token in currentLineTokens
      currentCumulativeColumn += @getTokenLength token
      linesToAddInRegard.push token
      if currentCumulativeColumn >= targetColumn
        break

    tokensInRegard.push linesToAddInRegard

    tokensInRegard

  # Flattens lines of tokens into a single line of tokens
  flatten: (tokensInRegard) ->
    singleDepthTokens = []
    for line in tokensInRegard
      singleDepthTokens.push token for token in line

    singleDepthTokens

  # Somehow, the in-built ruby lexer seems to combine a user-defined function
  # with the parameter as a single token....
  # This fixes it
  correctLineExprTokens: (lineExprTokens) ->
    originalCopy = lineExprTokens.slice()
    returnableTokens = []
    while originalCopy isnt undefined and originalCopy.length isnt 0
      currToken = originalCopy.shift()
      stringToAdd = ""
      WHITESPACE_FLAG = false
      tokensToUnshift = []
      for char in currToken.value
        if ((char is ' ') or (String(char).trim().length is 0)) and (not WHITESPACE_FLAG)
          # toggle WHITESPACE_FLAG, and add the current stringToAdd to the tokensToUnshift
          WHITESPACE_FLAG = true
          tokensToUnshift.push {
            scopes: currToken.scopes
            value: stringToAdd
          }
          stringToAdd = ""
        else if (not ((char is ' ') or (String(char).trim().length is 0))) and WHITESPACE_FLAG
          WHITESPACE_FLAG = false
          # now it's adding whitespace
          tokensToUnshift.push {
            scopes: ["source.ruby"]
            value: stringToAdd
          }
          stringToAdd = ""

        stringToAdd += char

      # Add the remaining (and possible, only) one
      tokensToUnshift.push {
        scopes: currToken.scopes
        value: stringToAdd
      }

      returnableTokens.push token for token in tokensToUnshift.slice()

    return returnableTokens

  getNumberOfNonWhitespaceTokens: (tokens) ->
    numberOfNonWhitespaceTokens = 0
    for token in tokens
      unless token.scopes.length is 1 and token.value.trim().length is 0
        numberOfNonWhitespaceTokens++

    numberOfNonWhitespaceTokens

  # This method will be used for determining what function / control
  # the cursor is giving parameters to. Useful for autocomplete
  #
  # lineObject: the object returned from the getLine() command
  # Note that in this method, the number of lines in relation to the actual code
  # will not be taken into consideration, as the sole purpose of this function
  # is to determine the autocomplete type.
  #
  # IMPORTANT: when the cursor is at a Sonic Pi block header e.g. with_fx,
  # it is actually a function-call, and will be treated by this function as such.
  #
  # lineType: function-call
  #       functionName: Name of the function that is being called
  #       params: Array of parameters. Each parameter is an array of tokens
  # lineType: postfix-control
  #       postfixType: The token of the keyword delimiting the postfix
  #       postfixExpression: Tokens in the postfix expression
  # lineType: expression
  #       tokens: The tokens of the expression
  # lineType: "control-block-header"
  #       blockType: The type of the control block (e.g. if, for, while)
  #       blockExpression: The tokens suffixing the control keyword.
  # lineType: "block-do"
  #       variables: array of tokens of variables between the pipe symbols |x, y|
  # lineType: "block-end"
  # lineType: "array"
  #       values: array of values in the array, each value is an array of tokens
  # lineType: "hash"
  #       values: array of hash mappings in the array, each hash mapping is an array of tokens
  parseCursorContext: (lineObject, bufferPosition) ->
    #"lines" as in a single expression that can span over multiple lines
    tokensInRegard = @getTokensInRegard lineObject, bufferPosition
    #console.log "tokensInRegard: "
    #console.log tokensInRegard
    tokens = @flatten tokensInRegard
    tokens = @correctLineExprTokens tokens

    returnable = {}

    determiningToken = @getFirstNonWhitespaceToken tokens

    if determiningToken is undefined
      return returnable

    if determiningToken.value in @syntaxBlockCreators
      returnable.lineType = "control-block-header"
      returnable.blockType = tokens.slice(0, 1)
      lineObjectToParse =
        tokens: [tokens.slice(tokens.indexOf(determiningToken) + 1)]
        linesPreceeded: 0
        linesSuffixed: 0
        #flagAddNextRound: false

      returnable.blockExpression = @parseCursorContext(lineObjectToParse, bufferPosition)
      return returnable

    lastToken = tokens[tokens.length - 1]
    if lastToken isnt undefined
      if 'comment.line.number-sign.ruby' in lastToken.scopes
        returnable.lineType = "comment"
        commentTokens = []
        for token in tokens.slice().reverse()
          commentTokens.unshift token
          break if 'punctuation.definition.comment.ruby' in token.scopes

        returnable.comment = @convertTokensArrayToString(commentTokens)

        return returnable


    # Can be postfix controls, or method calls
    # postfix controls are delimited by a
    parenDepth = 0; brackDepth = 0; braceDepth = 0

    maybeListOfParams = [] # Array containing the contents of comma separated expressions
    parameterTokensToAdd = [] # Contains the tokens for the current expression (see above)
    doEndBlockVariables = [] # Contains tokens of do..end block variables
    CHECK_FOR_FUNCTION_CALL_USING_PAREN = false
    for token in tokens.slice().reverse()     # BACKWARDS
      if "punctuation.section.function.ruby" in token.scopes
        if token.value.trim() is "("
          parenDepth--
        else if token.value.trim() is ")"
          parenDepth++
      if "punctuation.section.array.begin.ruby" in token.scopes
        brackDepth--
      else if "punctuation.section.array.end.ruby" in token.scopes
        brackDepth++
      else if "punctuation.section.scope.begin.ruby" in token.scopes
        braceDepth--
      else if "punctuation.section.scope.end.ruby" in token.scopes
        braceDepth++

      # PAREN METHOD
      if CHECK_FOR_FUNCTION_CALL_USING_PAREN # f(x) type of function call
        followingToken = @getFirstNonWhitespaceToken parameterTokensToAdd
        if (followingToken isnt undefined) and
           (token.scopes.length is 1 or "support.function.kernel.ruby" in token.scopes) and
           ("punctuation.section.function.ruby" in followingToken.scopes and followingToken.value.trim() is "("  and # Function call with brackets
               parenDepth is -1 and brackDepth is braceDepth is 0)
          if token.value.trim().length isnt 0
            returnable.lineType = "function-call"
            returnable.functionName = token.value.trim()
            returnable.params = []
            returnable.params.push parameterTokensToAdd.slice(1)
            returnable.params.push param for param in maybeListOfParams

            return returnable
          else
            returnable.lineType = 'function-call'
            returnable.functionName = @convertTokensArrayToString(parameterTokensToAdd.slice(1)).trim()
            returnable.params = []
            return returnable
        else
          returnable.lineType = "expression"
          returnable.tokens = parameterTokensToAdd.slice()
          for segment in maybeListOfParams
            returnable.tokens.push segmentToken for segmentToken in segment

      if parenDepth is brackDepth is braceDepth is 0 # top level
        # COMMA
        if "punctuation.separator.object.ruby" in token.scopes
          maybeListOfParams.unshift parameterTokensToAdd # Add tokens that have been collected in between commas
          parameterTokensToAdd = []
          continue

        # POSTFIX
        else if "keyword.control.ruby" in token.scopes and token.value in @postfixControlKeywords
          postfixTokensList = []
          postfixTokensList = parameterTokensToAdd.slice()
          for commaSeparatedSegment in maybeListOfParams # Just in case something made it think this way
            postfixTokensList.push segmentToken for segmentToken in commaSeparatedSegment
          returnable.lineType = "postfix-control"
          lineObjectToParse =
            tokens: [postfixTokensList]
            linesPreceeded: 0
            linesSuffixed: 0
          returnable.postfixExpression = @parseCursorContext lineObjectToParse, bufferPosition
          returnable.postfixType = token
          return returnable

        # METHOD
        else if (not @whitespaceToken token) and
                ((token.scopes.length is 1) or ("support.function.kernel.ruby" in token.scopes))
          followingToken = @getFirstNonWhitespaceToken parameterTokensToAdd
          if (followingToken isnt undefined) and
             (not (@isOperatorScope followingToken)) and
             (not ("punctuation.separator.object.ruby" in followingToken.scopes))
            if ("punctuation.section.function.ruby" in followingToken.scopes) and followingToken.value.trim() is "("
              returnable.lineType = "expression"
              parameterTokensToAdd.unshift token
              returnable.tokens = parameterTokensToAdd.slice()
              for segment in maybeListOfParams
                returnable.tokens.push segmentToken for segmentToken in segment
            else if followingToken.value.trim() isnt "["
              console.log "two number 9s, a number 9 large"
              console.log token
              console.log followingToken
              returnable.lineType = "function-call"
              returnable.functionName = token.value.trim()
              returnable.params = []
              maybeListOfParams.unshift parameterTokensToAdd.slice()
              returnable.params.push param for param in maybeListOfParams
              # console.log "tokenAtReturnable"
              # console.log token
              return returnable


          else if @getNumberOfNonWhitespaceTokens(tokens) is 1 # There's no params
            returnable.lineType = "function-call"
            returnable.functionName = token.value.trim()
            returnable.params = []
            return returnable

        # Assignment, but treat it as function call of the rhs
        else if "keyword.operator.assignment.ruby" in token.scopes
          followingToken = @getFirstNonWhitespaceToken(parameterTokensToAdd)
          if (followingToken.scopes.length is 1) or ("support.function.kernel.ruby" in followingToken.scopes)
            returnable.lineType = "function-call"
            returnable.functionName = followingToken.value.trim()
            returnable.params = []
            return returnable

        # do Keyword
        else if "keyword.control.start-block.ruby" in token.scopes # do keyword
          returnable.lineType = "block-do"
          returnable.variables = doEndBlockVariables
          return returnable

      else
        if parenDepth is -1
          CHECK_FOR_FUNCTION_CALL_USING_PAREN = true
        else if brackDepth < 0
          CSV = []
          CSV.push parameterTokensToAdd.slice()
          CSV.push value for value in maybeListOfParams
          returnable.lineType = "array"
          returnable.values = CSV
          return returnable
        else if braceDepth < 0
          CSV = []
          CSV.push parameterTokensToAdd.slice()
          CSV.push value for value in maybeListOfParams
          returnable.lineType = "hash"
          returnable.values = CSV
          return returnable

      parameterTokensToAdd.unshift token

      if "variable.other.block.ruby" in token.scopes
        doEndBlockVariables.push token

      if "keyword.control.ruby" in token.scopes and token.value.trim() is "end"
        returnable.lineType = "block-end"
        return returnable


    returnable

  lineEndsWithDo: (lineExpr) ->
    for token in lineExpr.slice().reverse()
      #console.log "LEWD TOKEN: " + token.value
      if (@tokenScopeStartsWith token, "variable") or
         ("punctuation.separator.variable.ruby" in token.scopes) or
         ("punctuation.separator.object.ruby" in token.scopes) or
         (token.value.trim().length is 0 and token.scopes.length is 1)
        #console.log 'CONTINUED'
        continue #do nothing, variable identifiers, pipes, commas and whitespace can suffix a do
      else if "keyword.control.start-block.ruby" in token.scopes # do
        #console.log 'IT ENDS WITH DO!'
        return true
      else
        #console.log 'IT DOESN\'T!!???'
        return false

  getTokensWithoutFurtherAdo: (lineExpr) ->
    tokensWithoutFurtherAdo = []
    for token in lineExpr
      if "keyword.control.start-block.ruby" in token.scopes
        return tokensWithoutFurtherAdo
      else
        tokensWithoutFurtherAdo.push token

  # functionName: String of function name
  # params: array of params, each entity is an array of tokens attributed to that param.
  parseFunctionCall: (tokens) ->
    parenDepth = 0; brackDepth = 0; braceDepth = 0
    functionToken = @getFirstNonWhitespaceToken tokens
    returnable = {
      functionName: functionToken.value.trim()
      params: []
    }
    parameterTokensToAdd = []

    # This flag, when true, will concatenate all the previous 'params' tokens into one param
    # This is necessary as if the first parameter of a function is within parenthesis,
    # it will be initially treated as a function call with the contents of the paren as
    # parameters. This flag will be reset to false after the concatenation
    PAREN_CALL_NOT_CONCATENATED = false

    # This flag marks the 'outermost scope' as 1 paren level deeper
    INSIDE_PAREN_CALL = false

    # This flag is used to mark a trailing parameter, as in `f1 x, f2 a, b, c`,
    # "f2, a, b, c" is all part of one parameter.
    # The flag can be reset once if the concatenation of earlier params happen, but not any more
    # It will be set to true if another function call is found in outermost scope depth
    # (i.e., the most recent non-whitesapce token is an identifier or kernel function scope,
    # and the current token is non-comma and non-operator,
    # with the exception of the operator being a prefix + or - operator, in which
    # the following token is not a whitespace.)
    TRAILING_PARAMETER = false

    truncatedTokens = tokens.slice(tokens.indexOf(functionToken) + 1)
    maybeParenFunctionCallToken = @getFirstNonWhitespaceToken(truncatedTokens)
    if  maybeParenFunctionCallToken isnt undefined and
        "punctuation.section.function.ruby" in maybeParenFunctionCallToken.scopes and
        maybeParenFunctionCallToken.value.trim() is "("
      PAREN_CALL_NOT_CONCATENATED = INSIDE_PAREN_CALL = true

    for token, index in truncatedTokens
      if "punctuation.section.function.ruby" in token.scopes
        if token.value.trim() is "("
          parenDepth++
        else if token.value.trim() is ")"
          parenDepth--
      if "punctuation.section.array.begin.ruby" in token.scopes
        brackDepth++
      else if "punctuation.section.array.end.ruby" in token.scopes
        brackDepth--
      else if "punctuation.section.scope.begin.ruby" in token.scopes
        braceDepth++
      else if "punctuation.section.scope.end.ruby" in token.scopes
        braceDepth--

      # OUTERMOST SCOPE
      if parenDepth is (if INSIDE_PAREN_CALL then 1 else 0) and braceDepth is brackDepth is 0
        # NOT TRAILING_PARAMETER and COMMA ==> new param!
        if (not TRAILING_PARAMETER) and ("punctuation.separator.object.ruby" in token.scopes)
          if PAREN_CALL_NOT_CONCATENATED and (not INSIDE_PAREN_CALL)
            # Perform concatenation of params into a single param
            concatenatedParamsTokens = []
            for param in returnable.params
              concatenatedParamsTokens.push ptoken for ptoken in param
            # Reset returnable params and flag
            returnable.params = []
            PAREN_CALL_NOT_CONCATENATED = false

            parameterTokensToAdd = concatenatedParamsTokens

          returnable.params.push parameterTokensToAdd
          parameterTokensToAdd = []
          continue

        mostRecentNonwhitespaceToken = @getLastNonWhitespaceToken parameterTokensToAdd
        # if prev token is possible function candidate
        if  mostRecentNonwhitespaceToken isnt undefined and
            (not @whitespaceToken mostRecentNonwhitespaceToken) and
                (mostRecentNonwhitespaceToken.scopes.length is 1 or
                  "support.function.kernel.ruby" in mostRecentNonwhitespaceToken.scopes)
          # if this token isn't a comma
          if (not ("punctuation.separator.object.ruby" in token.scopes))
            # and this token isn't an operator
            if not @isOperatorScope token
              TRAILING_PARAMETER = true

            # or if it may be a prefix unary operator...
            else if ("keyword.operator.arithmetic.ruby" in token.scopes) and
                    (token.value is "+" or token.value is "-")
              # and as such the next token isn't whitespace
              if not @whitespaceToken truncatedTokens[index + 1]
                TRAILING_PARAMETER = true

      if INSIDE_PAREN_CALL and parenDepth is 0
        # Reset INSIDE_PAREN_CALL flag, and TRAILING_PARAMETER flag
        INSIDE_PAREN_CALL = false
        TRAILING_PARAMETER = false
        # Don't continue! Keep the closing parenthesis in case!

      parameterTokensToAdd.push token

    if @convertTokensArrayToString(parameterTokensToAdd).trim().length isnt 0
      returnable.params.push parameterTokensToAdd
    # Remove the prefixing and trailing parenthesis of the first and last tokens of the
    # first and last parameters respectively
    if (not INSIDE_PAREN_CALL) and PAREN_CALL_NOT_CONCATENATED
      returnable.params[0] = ((paramTokens) ->
        loop
          firstToken = paramTokens.unshift()
          # shift out the first token until a non-whitespace token is shifted
          break if firstToken.scopes is undefined
          break if not helper.whitespaceToken(firstToken)
        paramTokens
      )(returnable.params[0])

      returnable.params[returnable.params.length - 1] = ((paramTokens) ->
        loop
          lastToken = paramTokens.pop()
          # shift out the last token until a non-whitespace token is shifted
          break if lastToken.scopes is undefined
          break if not helper.whitespaceToken(lastToken)
      )(returnable.params[returnable.params.length - 1])

    return returnable

  # NOTE: This is only for non-augmenting assignments.
  # things like += /= and the like will NOT be parsed
  # This function will return lhslist as empty if its trying to parse something
  # that isn't a assignment line.
  # lhslist: array of left-hand-side expressions, each entity will containt tokens attributed to the lhs expression
  # rhs: an array of tokens of the expression of the right-hand-side
  parseAssignment: (lineExpr) ->
    returnable = {
      lhslist: []
      rhs: undefined
    }
    tokensToAdd = []
    # Add all mid-assignment variable name tokens but the last one to lhslist
    for token in lineExpr
      if "keyword.operator.assignment.ruby" in token.scopes
        returnable.lhslist.push tokensToAdd
        tokensToAdd = []
        continue

      tokensToAdd.push token
    # Add the final one as rhs
    returnable.rhs = tokensToAdd

    return returnable

  # variables: an array of variables, each entity containing an array of tokens attributed to that variable
  parseDoBlockVariables: (lineExpr) ->
    returnable = []
    for token in lineExpr
      if "variable.other.block.ruby" in token.scopes
        returnable.push token

    returnable

  # Note: This is different from the lineType in parseCursorContext, because
  # parse cursor context gets the current context at the cursor's position,
  # not as the line per se
  #
  # Note that this function only goes into detail for NON-AUGMENTING assignments, function calls, and
  # special Sonic Pi blocks. Other types of line expressions will return just the line type..
  getLineData: (lineExpr) ->
    lineExpr = @correctLineExprTokens lineExpr
    determiningToken = @getFirstNonWhitespaceToken lineExpr
    if 'comment.line.number-sign.ruby' in determiningToken.scopes
      return {
        lineType: "comment"
        comment: @convertTokensArrayToString lineExpr
      }
    if @isBlockButNotDo determiningToken
      if determiningToken.value.trim() in @syntaxBlockCreators
        return {
          lineType: "block-start-ruby"
          blockType: determiningToken
        }
      else if determiningToken.value.trim() is "end"
        return {
          lineType: "block-end"
        }
    else if determiningToken.scopes.length is 1 and determiningToken.value.trim() in @syntaxBlockPrecursors
      # Get just the part which looks like a function call (which actually is a function call)
      functionCallTokens = @getTokensWithoutFurtherAdo lineExpr
      variablesList = @parseDoBlockVariables lineExpr
      return {
        lineType: "block-start-sonic-pi"
        blockType: determiningToken
        functionData: @parseFunctionCall functionCallTokens
        variables: variablesList
      }
    else if @lineEndsWithDo lineExpr
      return {
        lineType: "block-start-do"
      }
    else
      # First, try to parse as assignment
      assignmentData = @parseAssignment lineExpr
      if assignmentData.lhslist.length isnt 0
        return {
          lineType: "assignment"
          assignmentData: assignmentData
        }

      # If not, try Parse function call
      functionData = @parseFunctionCall lineExpr
      if functionData.params.length isnt 0
        return {
          lineType: "function-call"
          functionData: functionData
        }

      # No idea how it got here.
      return {
        lineType: "expression"
      }

  # Returns an array of lineTypes from the getLine method
  getLinesInCurrentScope: (allTokens, bufferPosition) ->
    # Gets all the newlines up to bufferPosition's row, exlusively
    lines = allTokens.slice(0, bufferPosition.row)

    linesData = [] # This will be the returnable value

    # Check if the last new-line is part of the line(expr) at bufferPosition.row, and remove those new-lines
    # so that the entire line (expression) at bufferPosition is not in `lines`
    testLines = @getLine allTokens, bufferPosition.row - 1
    debugPopCounter = 0
    if testLines.linesSuffixed > 0 # the current newline at bufPos is actually part of an existing line
      lines.pop()
      debugPopCounter++
      # Remove any additional preceeding lines if part of the current line expression
      for i in [0...testLines.linesPreceeded]
        lines.pop()
        debugPopCounter++



    # Reverse parsing!

    # When a block end is found, relativeDepth increases,
    # When a block start is found, relativeDepth decreases

    # Method:
    #1: Start with the last newline of newLinesLeft
    #2: Get line, to find out how many newlines that line consists of
    #3: Pop out that many lines from newLinesLeft
    #4: Use getLineData function to determine if the line is a normal expression, block header, or block end
    #5: If the line data is a block header, the currentScopeShallowness will increase,
    #       and if it is a block end, the currentScopeShallowness will decrease
    #6: If currentScopeShallowness reaches a new high, update scopesClimbed to that level
    #7: As long as the currentScopeShallowness is equal to scopesClimbled at this point in time,
    #       add lineData to linesData
    #0|8: Exit the loop once newLinesLeft is empty

    # IMPORTANT NOTE: It is possible for a block-start to be 'in the scope',
    # however, note the difference between 'in scope' and actually affecting the scope.
    # Block-starts that don't bring scopesClimbed to a new high may not affect the scope.
    #   NOTE NOTE NOTE NOTE NOTE AS SUCH, NOTE NOTE NOTE NOTE NOTE
    # The following flag will be set true when currentScopeShallowness has increased, and
    # will be set to false when it scopesClimbed reaches a new high.
    # Only when the flag is false, will the lineData be added to linesData
    BLOCK_START_MAY_NOT_AFFECT_SCOPE = false

    scopesClimbed = 0
    currentScopeShallowness = 0 # Higher number = more globalised scope
    newLinesLeft = lines.slice() # Make a copy for mutations to be done on this one.

    loop
      # RESET FLAG!
      BLOCK_START_MAY_NOT_AFFECT_SCOPE = false
      # Step 0 (or 8)
      if newLinesLeft.length is 0
        break
      #                   Step 2 vv                 Step 1 vv
      lastLineExpression = @getLine newLinesLeft, newLinesLeft.length - 1

      # Step 3
      newLinesLeft.pop() for i in [0..lastLineExpression.linesPreceeded] # there will only be preceeding lines

      # Go back to step 1 if the line is blank:
      if @convertNewlinesArrayToString(lastLineExpression.tokens).trim().length is 0
        continue

      # Step 4
      lastLineExpressionLineTokens = @flatten lastLineExpression.tokens


      lineData = @getLineData lastLineExpressionLineTokens
      #XXX
      if lineData is undefined
        continue
      # console.log "lineData:"
      # console.log lineData
      # Step 5
      if lineData.lineType in ["block-start-sonic-pi", "block-start-do", "block-start-ruby"]
        currentScopeShallowness++
        BLOCK_START_MAY_NOT_AFFECT_SCOPE = true
      else if lineData.lineType is "block-end"
        currentScopeShallowness--

      # Step 6
      if currentScopeShallowness > scopesClimbed
        scopesClimbed = currentScopeShallowness
        BLOCK_START_MAY_NOT_AFFECT_SCOPE = false

      # console.log "---------------------------"
      # console.log "at: " + @convertTokensArrayToString lastLineExpressionLineTokens
      # console.log "currentShallowness: " + currentScopeShallowness
      # console.log "scopesClimbed: " + scopesClimbed

      # Step 7 FIXME: Some same-level block headers do affect the outer scope, e.g. live_loop, define,...
      if currentScopeShallowness is scopesClimbed and
          ((not BLOCK_START_MAY_NOT_AFFECT_SCOPE) or
            lineData.lineType in ['comment', 'block-start-sonic-pi', 'block-start-ruby'])
        console.log "pushing line"
        linesData.push lineData

    return linesData.slice().reverse()

  createDatabase: (linesData) ->
    currentSynth = ":beep"
    fxInstances = [] # { fxType: <name with colon delim>, identifier: <variable name> }
    synthInstances = [] # { synthType: <name with colon delim>, identifier: <variable name> }
    sampleInstances = [] # { identifier: }
    aliases = [] # { functionAlias: true, functionName: 'control', alias: 'c' }
                 # { functionAlias: true, functionName: 'play', alias: 'waw', startSuggestingAt: 2, synthName: ':tb303' }
                 # { synthInstanceAlias: true, synthName: ':tb303', alias: 'x'}

    # What would affect the database:
    # [function-call]         use_synth: sets the value of currentSynth
    # [function-call]         reset: changes currentSynth back to ":beep"
    # [block-start-sonic-pi]  with_synth: sets the value of currentSynth
    # [block-start-sonic-pi]  with_fx: may add a fx-to-identifier mapping to fxInstances if instance variable exists
    # [assignment]            identifier = play/play_chord/play_pattern/play_pattern_timed ...
    #                                      ...will add mapping to synthInstaces

    for lineData in linesData
      if lineData.lineType is "function-call"
        if lineData.functionData.functionName.trim() is "use_synth"
          currentSynth = @convertTokensArrayToString(lineData.functionData.params[0]).trim()
        else if lineData.functionData.functionName.trim() is "reset"
          currentSynth = ":beep"

      else if lineData.lineType is "block-start-sonic-pi"
        if lineData.blockType.value.trim() is "with_synth"
          currentSynth = @convertTokensArrayToString(lineData.functionData.params[0]).trim()
        else if lineData.blockType.value.trim() is "with_fx"
          if lineData.variables isnt undefined and lineData.variables.length > 0
            fxInstances.push
              identifier: lineData.variables[0].value.trim()
              fxType: @convertTokensArrayToString(lineData.functionData.params[0]).trim()
      else if lineData.lineType is "assignment"
        rightHandSideWords = @convertTokensArrayToString(lineData.assignmentData.rhs).trim().split(/\s+/)
        functionName = rightHandSideWords[0]
        playFnNames = aliases.filter((x) -> x.functionAlias and x.functionName is 'play').map((x) -> x.alias)
        if functionName in ["play", "play_chord", "play_pattern", "play_pattern_timed"].concat(playFnNames)
          for lhsIdentifier in lineData.assignmentData.lhslist
            synthInstances.push
              identifier: @convertTokensArrayToString(lhsIdentifier).trim()
              synthType: currentSynth
        else if functionName is "synth"
          firstParam = rightHandSideWords[1].substring(0, rightHandSideWords[1].length - 1)
          for lhsIdentifier in lineData.assignmentData.lhslist
            synthInstances.push
              identifier: @convertTokensArrayToString(lhsIdentifier).trim()
              synthType: firstParam
        else if functionName is "sample"
          for lhsIdentifier in lineData.assignmentData.lhslist
            sampleInstances.push
              identifier: @convertTokensArrayToString(lhsIdentifier).trim()
      else if lineData.lineType is "comment"
        # Possible directives
        # #$ :synthname -> treated like a use_synth :synthname
        # #@ control c -> aliases functionName: c with functionName: control
        # #@ play <fnName> <opt Number param no. to start suggesting> <opt :synthname>
        #       -> aliases fnName as play, giving parameter suggestions for either currentSynth, or
        #          :synthname, if specified, starting from the param no.th
        #          param no. defaults to 2 (meaning 2nd parameter)
        # #@ :synthname <identifier> -> aliases identifier as an instance of :synthname to control
        # NOTE: For :synthname, the initial colon can be omitted
        if lineData.comment.startsWith('#$')
          synthname = lineData.comment.substring(2).trim()
          currentSynth = (if synthname.startsWith(':') then "" else ":") + synthname
        else if lineData.comment.startsWith('#@')
          words = lineData.comment.substring(2).trim().split(/\s+/).map((x) -> x.trim())
          console.log words
          if words[0] is 'control'
            aliases.push
              functionAlias: true
              functionName: 'control'
              alias: words[1]
          else if words[0] is 'play'
            alias = {}
            alias.functionAlias = true
            alias.functionName = 'play'
            alias.startSuggestingAt = 2 # Default setting
            alias.alias = words[1]
            if words[2] isnt undefined
              if not isNaN(Number(words[2]))
                alias.startSuggestingAt = Number(words[2])
              else
                alias.synthName = (if words[2].startsWith(':') then "" else ":") + words[2]
            if words[3] isnt undefined
              if not isNaN(Number(words[3]))
                alias.startSuggestingAt = Number(words[3])
              else if alias.synthName is undefined
                alias.synthName = (if words[3].startsWith(':') then "" else ":") + words[3]
            aliases.push alias
          else if words[1] isnt undefined
            synthInstances.push
              synthType: words[0]
              identifier: words[1]

    currentSynth: currentSynth
    fxInstances: fxInstances
    synthInstances: synthInstances
    sampleInstances: sampleInstances
    aliases: aliases
