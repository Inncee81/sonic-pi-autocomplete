helper = require './helper'
data = require './data'

module.exports = provider =
  selector: '.source.ruby, .symbol.ruby'
  inclusionPriority: 0
  excludeLowerPriority: false

  #Note: fns, synth, fx, sample and etc. are all part of completions.
  completions:

    fn: [
      "play", "play_chord", "play_pattern", "play_pattern_timed",
      "control", "synth"
      "use_synth", "use_synth_defaults", "use_bpm",
      "with_fx", "live_loop", "in_thread",
      "all_sample_names",
      "sample"
    ]

    slidable_synth_params: [
      "amp", "pan",
      "note",
      "vibrato_rate", "vibrato_depth"
      "width",
      "cutoff", "res"
      "detune1", "detune2"
      "divisor", "depth"
    ]

    controllable_synth_params: [
      "note_resolution",  "room", "reverb_time", "ring", "noise"
    ]

    static_synth_params: [
      "attack", "decay", "sustain", "release",
      "attack_level", "decay_level", "sustain_level",
    ]

    synth: [
      ":beep", ":blade", ":bnoise", ":chipbass", ":chiplead", ":chipnoise", ":cnoise", ":dark_ambience",
      ":dpulse", ":dsaw", ":dtri", ":dull_bell",
      ":fm", ":gnoise", ":growl", ":hollow", ":hoover", ":mod_beep", ":mod_dsaw",
      ":mod_fm", ":mod_pulse", ":mod_saw", ":mod_sine", ":mod_tri", ":noise", ":piano", ":pluck",
      ":pnoise", ":pretty_bell", ":prophet", ":pulse", ":saw", ":sine", ":square",
      ":subpulse", ":supersaw", ":tb303", ":tri", ":zawa"]

    fx: [
      ":band_eq",
      ":bitcrusher", ":bpf", ":compressor", ":distortion", ":echo", ":flanger", ":hpf"
      ":ixi_techno", ":krush", ":level", ":lpf", ":momno", ":nbpf", ":nhpf", ":nlpf",
      ":normaliser", ":nrbpf", ":nrhpf", ":nrlpf", ":octaver", ":pan", ":panslicer",
      ":pitch_shift", ":rbpf", ":reverb", ":rhpf", ":ring_mod", ":rlpf", ":slicer",
      ":tanh", ":vowel", ":whammy", ":wobble" ]

    sample: [
      ":ambi_choir", ":ambi_dark_woosh", ":ambi_drone", ":ambi_glass_hum", ":ambi_glass_rub",
      ":ambi_haunted_hum", ":ambi_lunar_land", ":ambi_piano", ":ambi_soft_buzz", ":ambi_swoosh",
      ":bass_dnb_f", ":bass_drop_c", ":bass_hard_c", ":bass_hit_c", ":bass_thick_c", ":bass_voxy_c",
      ":bass_voxy_hit_c", ":bass_woodsy_c", ":bd_808", ":bd_ada", ":bd_boom", ":bd_fat", ":bd_gas",
      ":bd_haus", ":bd_klub", ":bd_pure", ":bd_sone", ":bd_tek", ":bd_zome", ":bd_zum",
      ":drum_bass_hard", ":drum_bass_soft", ":drum_cowbell", ":drum_cymbal_closed",
      ":drum_cymbal_hard", ":drum_cymbal_open", ":drum_cymbal_pedal", ":drum_cymbal_soft",
      ":drum_heavy_kick", ":drum_roll", ":drum_snare_hard", ":drum_snare_soft", ":drum_splash_hard",
      ":drum_splash_soft", ":drum_tom_hi_hard", ":drum_tom_hi_soft", ":drum_tom_lo_hard",
      ":drum_tom_lo_soft", ":drum_tom_mid_hard", ":drum_tom_mid_soft", ":elec_beep", ":elec_bell",
      ":elec_blip", ":elec_blip2", ":elec_blup", ":elec_bong", ":elec_chime", ":elec_cymbal",
      ":elec_filt_snare", ":elec_flip", ":elec_fuzz_tom", ":elec_hi_snare", ":elec_hollow_kick",
      ":elec_lo_snare", ":elec_mid_snare", ":elec_ping", ":elec_plip", ":elec_pop", ":elec_snare",
      ":elec_soft_kick", ":elec_tick", ":elec_triangle", ":elec_twang", ":elec_twip", ":elec_wood",
      ":guit_e_fifths", ":guit_e_slide", ":guit_em9", ":guit_harmonics", ":loop_amen", ":loop_amen_full",
      ":loop_breakbeat", ":loop_compus", ":loop_garzul", ":loop_industrial", ":loop_mika", ":loop_safari",
      ":loop_tabla", ":misc_burp", ":misc_cineboom", ":misc_crow", ":perc_bell", ":perc_snap", ":perc_snap2",
      ":perc_swash", ":perc_till", ":sn_dolf", ":sn_dub", ":sn_zome", ":tabla_dhec", ":tabla_ghe1", ":tabla_ghe2",
      ":tabla_ghe3", ":tabla_ghe4", ":tabla_ghe5", ":tabla_ghe6", ":tabla_ghe7", ":tabla_ghe8", ":tabla_ke1", "
      tabla_ke2", ":tabla_ke3", ":tabla_na", ":tabla_na_o", ":tabla_na_s", ":tabla_re", ":tabla_tas1", ":tabla_tas2",
      ":tabla_tas3", ":tabla_te1", ":tabla_te2", ":tabla_te_m", ":tabla_te_ne", ":tabla_tun1", ":tabla_tun2", ":tabla_tun3",
      ":vinyl_backspin", ":vinyl_hiss", ":vinyl_rewind", ":vinyl_scratch"]

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

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
    return new Promise (resolve) =>
      suggestions = []

      grammar = editor.getGrammar();

      tokens = grammar.tokenizeLines(editor.getText());

      prev_words_on_same_row = helper.splitWords editor.getTextInBufferRange([[bufferPosition.row, 0], bufferPosition]).trim()
      [first_word_of_row, ..., preceding_word_from_cursor] = prev_words_on_same_row
      [..., third_last_word_of_row, secondlast, last] = prev_words_on_same_row
      num_of_words_before_cursor = prev_words_on_same_row.length

      #console.log "DEBUG>> Prefix: " + prefix
      #console.log "DEBUG>> First: " + first_word_of_row + ", Preceding: " + preceding_word_from_cursor
      #console.log "DEBUG>> Third Last: " + third_last_word_of_row

      # Note that currentLine is an object containing tokens, linesPreceeded, and linesSuffixed
      currentLine = helper.getLine(tokens, bufferPosition.row)
      currentLineStr = helper.convertLineTokensToString currentLine.tokens

      console.log "Current Line: "
      console.log currentLineStr
      console.log currentLine

      helper.parseCursorContext currentLine, bufferPosition

      #Expecting Sample
      if first_word_of_row == "sample" and preceding_word_from_cursor != "sample"
        for item in @completions.sample when item.substring(1, prefix.length + 1) == prefix
          suggestions.push
            text: if not preceding_word_from_cursor.startsWith(":") then item else item.substring(1)
            type: 'value'
            rightLabel: "SP Sample"

      #Expecting FX
      else if first_word_of_row == "with_fx" and preceding_word_from_cursor != "with_fx"
        for item in @completions.fx when item.substring(1, prefix.length + 1) == prefix
          suggestions.push
            text: if not preceding_word_from_cursor.startsWith(":") then item else item.substring(1)
            type: 'value'
            rightLabel: "SP FX"

      #Expecting synth
      else if (first_word_of_row == "synth" and preceding_word_from_cursor != "synth") or
                                                  (first_word_of_row == "use_synth" and preceding_word_from_cursor != "use_synth")
        for item in @completions.synth when item.substring(1, prefix.length + 1) == prefix
          suggestions.push
            text: if not preceding_word_from_cursor.startsWith(":") then item else item.substring(1)
            type: 'value'
            rightLabel: "SP Synth"

      #Note Params
      else if first_word_of_row in ["play", "play_chord", "play_pattern", "play_pattern_timed"] and
              num_of_words_before_cursor >= 2

        for item in @completions.slidable_synth_params when item.substring(0, prefix.length) == prefix or activatedManually
          suggestions.push
            snippet: item + ': ${1}'
            type: 'property'
            rightLabel: "Slide Syn. Pms."
            displayText: item

        for item in @completions.controllable_synth_params when item.substring(0, prefix.length) == prefix or activatedManually
          suggestions.push
            snippet: item + ': ${1}'
            type: 'property'
            rightLabel: "Cont. Synth Pms"
            displayText: item

        for item in @completions.static_synth_params when item.substring(0, prefix.length) == prefix or activatedManually
          suggestions.push
            snippet: item + ': ${1}'
            type: 'property'
            rightLabel: "Static Synth Pms."
            displayText: item

      #Controllable & Slidable Params
      else if first_word_of_row == 'control' and num_of_words_before_cursor >= 2
        for item in @completions.slidable_synth_params when item.substring(0, prefix.length) == prefix
          suggestions.push
            snippet: item + ': ${1}'
            type: 'property'
            rightLabel: "Sonic Pi Slidable Synth Params"
            displayText: item

        for item in @completions.controllable_synth_params when item.substring(0, prefix.length) == prefix
          suggestions.push
            snippet: item + ': ${1}'
            type: 'property'
            rightLabel: "Sonic Pi Controllable Synth Params"
            displayText: item

      #Default

      for type, list of @completions
        if type == 'placeholders'
          for placeholder_context, placeholder_mappings of list
            if placeholder_context == 'slide_shape'
              for placeholder, value of placeholder_mappings when placeholder.substring(0, prefix.length) == prefix and
                    secondlast.endsWith('slide_shape:')
                suggestions.push
                  text: value
                  type: 'constant'
                  rightLabel: 'Sonic Pi Slide Shape'
                  displayText: placeholder
        else
          for item in list when item.substring(0, prefix.length) == prefix
            ###
            SNIPPETS
            ###

            if item == "with_fx"
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
            else if item == "live_loop"
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
            else if item == "in_thread"
              suggestions.push
                snippet: 'in_thread do\n\t${1}\nend'
                type: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'in_thread'
              suggestions.push
                snippet: 'in_thread :${1:thread_name} do\n\t${2}\nend'
                type: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'in_thread named'
            else if item == "use_synth"
              suggestions.push
                snippet: 'use_synth :'
                type: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'use_synth'
            else if item == "adsr"
              suggestions.push
                snippet: 'attack: ${1:0.01}, decay: ${2:0}, sustain: ${3:1}, release: ${4:0.1}${5}'
                typ: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'ADSR parameters'
            else if item == "asr"
              suggestions.push
                snippet: 'attack: ${1:0.01}, sustain: ${2:1}, release: ${3:0.1}${4}'
                typ: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'ASR parameters'
            else if item == "pluck"
              suggestions.push
                snippet: 'sustain: 0, release: ${1:0.25}${2}'
                typ: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'Plucked Envelope'

            else if item == "slide" and num_of_words_before_cursor >= 4
              affectedParameter = third_last_word_of_row.substring(0, third_last_word_of_row.length - 1)
              suggestions.push (
                snippet: affectedParameter + '_slide: ${1:1}${2}'
                typ: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'Param Slide'
              ) if affectedParameter in @completions.slidable_synth_params

            else if item == "slideshape" and num_of_words_before_cursor >= 4
              affectedParameter = third_last_word_of_row.substring(0, third_last_word_of_row.length - 1)
              suggestions.push (
                snippet: affectedParameter + '_slide: ${1:1}, ' + affectedParameter + '_slide_shape: ${2:1}${3}'
                typ: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'Param Slide + Shape'
              ) if affectedParameter in @completions.slidable_synth_params

            else if item == "slidecurve" and num_of_words_before_cursor >= 4
              affectedParameter = third_last_word_of_row.substring(0, third_last_word_of_row.length - 1)
              suggestions.push (
                snippet: affectedParameter + '_slide: ${1:1}, ' + affectedParameter + '_slide_curve: ${2:0}${3}'
                typ: 'snippet'
                rightLabel: 'Sonic Pi Snippet'
                displayText: 'Param Slide + Curve'
              ) if affectedParameter in @completions.slidable_synth_params

            else
              suggestions.push
                text: item
                type: 'snippet'
                rightLabel: "Sonic Pi"
      resolve(suggestions)
