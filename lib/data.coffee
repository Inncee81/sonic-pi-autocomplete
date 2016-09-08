module.exports = data =
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

  fns: [
    'all_sample_names', 'assert', 'assert_equal', 'at',
    'beat', 'block_duration', 'block_slept?', 'bools', 'bt',
    'choose', 'chord', 'chord_degree', 'chord_invert', 'chord_names', 'clear', 'comment', 'control'
    'cue', 'current_arg_checks', 'current_beat_duration', 'current_bpm', 'current_cent_tuning',
    'current_debug', 'current_octave', 'current_random_seed', 'current_sample_defaults',
    'current_sched_ahead_time', 'current_synth', 'current_synth_defaults', 'current_transpose',
    'current_volume',
    'dec', 'define', 'defonce', 'degree', 'density', 'dice', 'doubles',
    'factor?', 'fx_names',
    'halves', 'hz_to_midi',
    'in_thread', 'inc',
    'kill', 'knit',
    'line', 'live_loop', 'load_buffer', 'load_example', 'load_sample', 'load_samples', 'load_synthdefs', 'look',
    'midi_notes', 'midi_to_hz',
    'ndefine', 'note', 'note_info', 'note_range',
    'octs', 'on', 'one_in', 'pick', 'pitch_to_ratio', 'play', 'play_chord', 'play_pattern', 'play_pattern_timed',
    'print', 'puts', 'quantise',
    'ramp', 'rand', 'rand_back', 'rand_i', 'rand_i_look', 'rand_look', 'rand_reset', 'rand_skip',
    'range', 'ratio_to_pitch', 'rdist', 'reset', 'reset_mixer!', 'rest?', 'ring', 'rrand', 'rrand_i',
    'rt', 'run_code', 'run_file',
    'sample', 'sample_buffer', 'sample_duration', 'sample_free', 'sample_free_all', 'sample_groups',
    'sample_info', 'sample_loaded?', 'sample_names', 'sample_paths', 'scale', 'scale_names',
    'set_cent_tuning!', 'set_control_delta!', 'set_mixer_control!', 'set_sched_ahead_time!', 'set_volume!',
    'shuffle', 'sleep', 'spark', 'spark_graph', 'spread', 'status', 'stop', 'stretch', 'sync', 'sync_bpm',
    'synth', 'synth_names',
    'tick', 'tick_reset', 'tick_reset_all', 'tick_set', 'time_shift',
    'uncomment', 'use_arg_bpm_scaling', 'use_arg_checks', 'use_bpm', 'use_bpm_mul', 'use_cent_tuning',
    'use_cue_logging', 'use_debug', 'use_merged_sample_defaults', 'use_merged_synth_defaults',
    'use_octave', 'use_random_seed', 'use_sample_bpm', 'use_sample_defaults', 'use_synth', 'use_synth_defaults',
    'use_timing_guarantees', 'use_transpose', 'use_tuning'
    'vector', 'version', 'vt'
    'wait', 'with_arg_bpm_scaling', 'with_arg_checks', 'with_bpm', 'with_bpm_mul', 'with_cent_tuning',
    'with_cue_logging', 'with_debug', 'with_fx', 'with_merged_sample_defaults', 'with_merged_synth_defaults',
    'with_octave', 'with_random_seed', 'with_sample_bpm', 'with_sample_defaults', 'with_synth', 'with_synth_defaults',
    'with_timing_guarantees', 'with_transpose', 'with_tuning'
  ]

  initialiseDatabase: () ->
    for synth in @synths.synths
      @listOfSynthNames.push synth.name
    for fx in @fx.fx
      @listOfFXNames.push fx.name

  getSynthParams: (synthName) ->
    for synth in @synths.synths
      if synth.name is synthName
        return @synths.defaultParams.concat synth.params

    return @synths.defaultParams

  getFxParams: (fxName) ->
    for fx in @fx.fx
      if fx.name is fxName
        return @fx.defaultParams.concat fx.params
    return @fx.defaultParams

  listOfSynthNames: []
  listOfFXNames: []

  # Params present in all synths: note, amp, pan, attack, decay, sustain, release,
  # attack_level, decay_level, sustain_level, env_curve
  synths:
    defaultParams: [
      {
        param: 'on'
        static: true
      }
      {
        param: 'slide'
        static: true
      }
      {
        param: 'pitch'
        static: true
      }
      {
        param: 'note'
        slide: true
      }
      {
        param: 'amp'
        slide: true
      }
      {
        param: 'pan'
        slide: true
      }
      {
        param: 'attack'
        static: true
      }
      {
        param: 'decay'
        static: true
      }
      {
        param: 'sustain'
        static: true
      }
      {
        param: 'release'
        static: true
      }
      {
        param: 'attack_level'
        static: true
      }
      {
        param: 'decay_level'
        static: true
      }
      {
        param: 'sustain_level'
        static: true
      }
      {
        param: 'env_curve'
        static: true
        curveShape: true
      }
    ]
    synths: [
      {
        name: ':beep'
        params: []
      }
      {
        name: ':blade'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'vibrato_rate'
            slide: true
          }
          {
            param: 'vibrato_depth'
            slide: true
          }
          {
            param: 'vibrato_delay'
            static: true
          }
          {
            param: 'vibrato_onset'
            static: true
          }
        ]
      }
      {
        name: ':bnoise'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
        ]
      }
      {
        name: ':chipbass'
        params: []
      }
      {
        name: ':chiplead'
        params: [
          {
            param: 'width'
            control: true
          }
        ]
      }
      {
        name: ':chipnoise'
        params: [
          {
            param: 'freq_band'
            slide: true
          }
        ]
      }
      {
        name: ':cnoise'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
        ]
      }
      {
        name: ':dark_ambience'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
          {
            param: 'detune1'
            slide: true
          }
          {
            param: 'detune2'
            slide: true
          }
          {
            param: 'noise'
            control: true
          }
          {
            param: 'ring'
            control: true
          }
          {
            param: 'reverb_time'
            static: true
          }
        ]
      }
      {
        name: ':dpulse'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'detune'
            slide: true
          }
          {
            param: 'pulse_width'
            slide: true
          }
          {
            param: 'dpulse_width'
            slide: true
          }
        ]
      }
      {
        name: ':dsaw'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'detune'
            slide: true
          }
        ]
      }
      {
        name: ':dtri'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'detune'
            slide: true
          }
        ]
      }
      {
        name: ':dull_bell'
        params: []
      }
      {
        name: ':fm'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'divisor'
            slide: true
          }
          {
            param: 'depth'
            slide: true
          }
          {
            param: 'cutoff'
            slide: true
          }
        ]
      }
      {
        name: ':gnoise'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
        ]
      }
      {
        name: ':growl'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
        ]
      }
      {
        name: ':hollow'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
          {
            param: 'noise'
            control: true
          }
          {
            param: 'norm'
            control: true
          }
        ]
      }
      {
        name: ':hoover'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
        ]
      }
      {
        name: ':mod_beep'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'mod_phase'
            slide: true
          }
          {
            param: 'mod_range'
            slide: true
          }
          {
            param: 'mod_pulse_width'
            slide: true
          }
          {
            param: 'mod_phase_offset'
            static: true
          }
          {
            param: 'mod_invert_wave'
            control: true
          }
          {
            param: 'mod_wave'
            control: true
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
              "sine":     3
            }
          }
        ]
      }
      {
        name: ':mod_dsaw'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'mod_phase'
            slide: true
          }
          {
            param: 'mod_range'
            slide: true
          }
          {
            param: 'mod_pulse_width'
            slide: true
          }
          {
            param: 'mod_phase_offset'
            static: true
          }
          {
            param: 'mod_invert_wave'
            control: true
          }
          {
            param: 'mod_wave'
            control: true
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
              "sine":     3
            }
          }
          {
            param: 'detune'
            slide: true
          }
        ]
      }
      {
        name: ':mod_fm'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'divisor'
            slide: true
          }
          {
            param: 'depth'
            slide: true
          }
          {
            param: 'mod_phase'
            slide: true
          }
          {
            param: 'mod_range'
            slide: true
          }
          {
            param: 'mod_pulse_width'
            slide: true
          }
          {
            param: 'mod_phase_offset'
            static: true
          }
          {
            param: 'mod_invert_wave'
            control: true
          }
          {
            param: 'mod_wave'
            control: true
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
              "sine":     3
            }
          }
        ]
      }
      {
        name: ':mod_pulse'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'mod_phase'
            slide: true
          }
          {
            param: 'mod_range'
            slide: true
          }
          {
            param: 'mod_pulse_width'
            slide: true
          }
          {
            param: 'mod_phase_offset'
            static: true
          }
          {
            param: 'mod_invert_wave'
            control: true
          }
          {
            param: 'mod_wave'
            control: true
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
              "sine":     3
            }
          }
          {
            param: 'pulse_width'
            slide: true
          }
        ]
      }
      {
        name: ':mod_saw'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'mod_phase'
            slide: true
          }
          {
            param: 'mod_range'
            slide: true
          }
          {
            param: 'mod_pulse_width'
            slide: true
          }
          {
            param: 'mod_phase_offset'
            static: true
          }
          {
            param: 'mod_invert_wave'
            control: true
          }
          {
            param: 'mod_wave'
            control: true
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
              "sine":     3
            }
          }
        ]
      }
      {
        name: ':mod_sine'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'mod_phase'
            slide: true
          }
          {
            param: 'mod_range'
            slide: true
          }
          {
            param: 'mod_pulse_width'
            slide: true
          }
          {
            param: 'mod_phase_offset'
            static: true
          }
          {
            param: 'mod_invert_wave'
            control: true
          }
          {
            param: 'mod_wave'
            control: true
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
              "sine":     3
            }
          }
        ]
      }
      {
        name: ':mod_tri'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'mod_phase'
            slide: true
          }
          {
            param: 'mod_range'
            slide: true
          }
          {
            param: 'mod_pulse_width'
            slide: true
          }
          {
            param: 'mod_phase_offset'
            static: true
          }
          {
            param: 'mod_invert_wave'
            control: true
          }
          {
            param: 'mod_wave'
            control: true
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
              "sine":     3
            }
          }
        ]
      }
      {
        name: ':noise'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
        ]
      }
      {
        name: ':piano'
        params: [
          {
            param: 'hard'
            static: true
          }
          {
            param: 'stereo_width'
            static: true
          }
        ]
      }
      {
        name: ':pluck'
        params: [
          {
            param: 'noise_amp'
            static: true
          }
          {
            param: 'max_delay_time'
            static: true
          }
          {
            param: 'pluck_decay'
            static: true
          }
          {
            param: 'coef'
            static: true
          }
        ]
      }
      {
        name: ':pnoise'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
        ]
      }
      {
        name: ':pretty_bell'
        params: []
      }
      {
        name: ':prophet'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
        ]
      }
      {
        name: ':pulse'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'pulse_width'
            slide: true
          }
        ]
      }
      {
        name: ':saw'
        params: []
      }
      {
        name: ':sine'
        params: []
      }
      {
        name: ':sound_in'
        params: [
          {
            param: 'input'
            control: true
          }
        ]
      }
      {
        name: ':sound_in_stereo'
        params: [
          {
            param: 'input'
            control: true
          }
        ]
      }
      {
        name: ':square'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
        ]
      }
      {
        name: ':subpulse'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'pulse_width'
            slide: true
          }
          {
            param: 'sub_amp'
            slide: true
          }
          {
            param: 'sub_detune'
            slide: true
          }
        ]
      }
      {
        name: ':supersaw'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
        ]
      }
      {
        name: ':tb303'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'cutoff_min'
            slide: true
          }
          {
            param: 'cutoff_attack'
            static: true
          }
          {
            param: 'cutoff_decay'
            static: true
          }
          {
            param: 'cutoff_sustain'
            static: true
          }
          {
            param: 'cutoff_release'
            static: true
          }
          {
            param: 'cutoff_attack_level'
            static: true
          }
          {
            param: 'cutoff_decay_level'
            static: true
          }
          {
            param: 'cutoff_sustain_level'
            static: true
          }
          {
            param: 'res'
            slide: true
          }
          {
            param: 'wave'
            control: true
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
            }
          }
          {
            param: 'pulse_width'
            slide: true
          }
        ]
      }
      {
        name: ':tech_saws'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
        ]
      }
      {
        name: ':tri'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'pulse_width'
            slide: true
          }
        ]
      }
      {
        name: ':zawa'
        params: [
          {
            param: 'cutoff'
            slide: true
          }
          {
            param: 'res'
            slide: true
          }
          {
            param: 'phase'
            static: true
          }
          {
            param: 'phase_offset'
            static: true
          }
          {
            param: 'wave'
            control: true
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
              "sine":     3
            }
          }
          {
            param: 'invert_wave'
            control: true
          }
          {
            param: 'range'
            slide: true
          }
          {
            param: 'disable_wave'
            control: true
          }
          {
            param: 'pulse_width'
            slide: true
          }
        ]
      }
    ]

  fx:
    defaultParams: [
      {
        param: 'reps'
        static: true
      }
      {
        param: 'kill_delay'
        static: true
      }
      {
        param: 'amp'
        slide: true
      }
      {
        param: 'mix'
        slide: true
      }
      {
        param: 'pre_mix'
        slide: true
      }
      {
        param: 'pre_amp'
        slide: true
      }
    ]
    fx: [
      {
        name: ':band_eq'
        params: [
          { name: 'freq', slide: true }
          { name: 'res', slide: true }
          { name: 'db', slide: true }
        ]
      }
      {
        name: ':bitcrusher'
        params: [
          { name: 'sample_rate', slide: true }
          { name: 'bits', slide: true }
          { name: 'cutoff', slide: true }
        ]
      }
      {
        name: ':bpf'
        params: [
          { name: 'centre', slide: true }
          { name: 'res', slide: true }
        ]
      }
      {
        name: ':compressor'
        params: [
          { name: 'threshold', slide: true }
          { name: 'clamp_time', slide: true }
          { name: 'slope_above', slide: true }
          { name: 'slope_below', slide: true }
          { name: 'relax_time', slide: true }
        ]
      }
      {
        name: ':distortion'
        params: [
          { name: 'distort', slide: true }
        ]
      }
      {
        name: ':echo'
        params: [
          { name: 'phase', slide: true }
          { name: 'decay', slide: true }
          { name: 'max_phase', static: true }
        ]
      }
      {
        name: ':flanger'
        params: [
          { name: 'phase', slide: true }
          { name: 'phase_offset', static: true }
          {
            name: 'wave'
            control: true
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
              "sine":     3
              "cubic":    4
            }
          }
          { name: 'invert_wave', control: true }
          { name: 'stereo_invert_wave', control: true }
          { name: 'delay', slide: true }
          { name: 'max_delay', static: true }
          { name: 'depth', slide: true }
          { name: 'decay', slide: true }
          { name: 'feedback', slide: true }
          { name: 'invert_flange', control: true }
        ]
      }
      {
        name: ':gverb'
        params: [
          { name: 'spread', slide: true }
          { name: 'damp', slide: true }
          { name: 'pre_damp', slide: true }
          { name: 'dry', slide: true }
          { name: 'room', control: true }
          { name: 'release', control: true }
          { name: 'ref_level', control: true }
          { name: 'tail_level', control: true }
        ]
      }
      {
        name: ':hpf'
        params: [
          { name: 'cutoff', slide: true }
        ]
      }
      {
        name: ':ixi_techno'
        params: [
          { name: 'phase', slide: true }
          { name: 'phase_offset', static: true }
          { name: 'cutoff_min', slide: true }
          { name: 'cutoff_max', slide: true }
          { name: 'res', slide: true }
        ]
      }
      {
        name: ':krush'
        params: [
          { name: 'gain', slide: true }
          { name: 'cutoff', slide: true }
          { name: 'res', slide: true }
        ]
      }
      {
        # This one is special, only has :amp
        name: ':level'
        params: []
      }
      {
        name: ':lpf'
        params: [
          { name: 'cutoff', slide: true }
        ]
      }
      {
        name: ':mono'
        params: [
          { name: 'pan', slide: true }
        ]
      }
      {
        name: ':nbpf'
        params: [
          { name: 'centre', slide: true }
          { name: 'res', slide: true }
        ]
      }
      {
        name: ':nhpf'
        params: [
          { name: 'cutoff', slide: true }
        ]
      }
      {
        name: ':nlpf'
        params: [
          { name: 'cutoff', slide: true }
        ]
      }
      {
        name: ':normaliser'
        params: [
          { name: 'level', slide: true }
        ]
      }
      {
        name: ':nrbpf'
        params: [
          { name: 'centre', slide: true }
          { name: 'res', slide: true }
        ]
      }
      {
        name: ':nrlpf'
        params: [
          { name: 'cutoff', slide: true }
          { name: 'res', slide: true }
        ]
      }
      {
        name: ':nrlpf'
        params: [
          { name: 'cutoff', slide: true }
          { name: 'res', slide: true }
        ]
      }
      {
        name: ':octaver'
        params: [
          { name: 'super_amp', slide: true }
          { name: 'sub_amp', slide: true }
          { name: 'subsub_amp', slide: true }
        ]
      }
      {
        name: ':octaver'
        params: [
          { name: 'super_amp', slide: true }
          { name: 'sub_amp', slide: true }
          { name: 'subsub_amp', slide: true }
        ]
      }
      {
        name: ':pan'
        params: [
          { name: 'pan', slide: true }
        ]
      }
      {
        name: ':panslicer'
        params: [
          { name: 'phase', slide: true }
          { name: 'amp_min', slide: true }
          { name: 'amp_max', slide: true }
          { name: 'pulse_width', slide: true }
          { name: 'phase_offset', static: true }
          {
            name: 'wave'
            control: true
            waveMapping: {
              "saw": 0
              "pulse": 1
              "triangle": 2
              "sine": 3
            }
          }
          { name: 'invert_wave', control: true }
          { name: 'probability', slide: true }
          { name: 'prob_pos', slide: true }
          { name: 'seed', static: true }
          { name: 'smooth', slide: true }
          { name: 'smooth_up', slide: true }
          { name: 'smooth_down', slide: true }
          { name: 'pan_min', slide: true }
          { name: 'pan_max', slide: true }
        ]
      }
      {
        name: ':pitch_shift'
        params: [
          { name: 'window_size', slide: true }
          { name: 'pitch', slide: true }
          { name: 'pitch_dis', slide: true }
          { name: 'time_dis', slide: true }
        ]
      }
      {
        name: ':rbpf'
        params: [
          { name: 'centre', slide: true }
          { name: 'res', slide: true }
        ]
      }
      {
        name: ':reverb'
        params: [
          { name: 'room', slide: true }
          { name: 'damp', slide: true }
        ]
      }
      {
        name: ':rbpf'
        params: [
          { name: 'cutoff', slide: true }
          { name: 'res', slide: true }
        ]
      }
      {
        name: ':ring_mod'
        params: [
          { name: 'freq', slide: true }
          { name: 'mod_amp', slide: true }
        ]
      }
      {
        name: ':rbpf'
        params: [
          { name: 'cutoff', slide: true }
          { name: 'res', slide: true }
        ]
      }
      {
        name: ':slicer'
        params: [
          { name: 'phase_offset', static: true }
          {
            name: 'wave'
            control: true
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
              "sine":     3
            }
          }
          { name: 'invert_wave', control: true }
          { name: 'probability', slide: true }
          { name: 'prob_pos', slide: true }
          { name: 'seed', static: true }
          { name: 'smooth', slide: true }
          { name: 'smooth_up', slide: true }
          { name: 'smooth_down', slide: true }
        ]
      }
      {
        name: ':tanh'
        params: [
          { name: 'krunch', slide: true }
        ]
      }
      {
        name: ':vowel'
        params: [
          { name: 'vowel_sound', control: true }
          { name: 'voice', control: true }
        ]
      }
      {
        name: ':whammy'
        params: [
          { name: 'transpose', slide: true }
          { name: 'max_delay_time', static: true }
          { name: 'deltime', static: true }
          { name: 'grainsize', static: true }
        ]
      }
      {
        name: ':wobble'
        params: [
          { name: 'phase', slide: true }
          { name: 'phase_offset', static: true }
          {
            name: 'wave',
            control: true,
            waveMapping: {
              "saw":      0
              "pulse":    1
              "triangle": 2
              "sine":     3
            }
          }
          { name: 'invert_wave', control: true }
          { name: 'probability', slide: true }
          { name: 'prob_pos', slide: true }
          { name: 'seed', static: true }
          { name: 'smooth', slide: true }
          { name: 'smooth_up', slide: true }
          { name: 'smooth_down', slide: true }
        ]
      }

    ]
