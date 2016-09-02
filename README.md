# Sonic Pi Autocomplete
###### Atom + Sonic Pi Integration with Super Cow Powers!!!

This plugin allows remote controlling [Sonic Pi](http://sonic-pi.net/) via [Atom](https://atom.io/).

Sonic Pi is fun to play with, but its built-in editor is very rudimentary.
With this plugin, you can do all the live coding in Atom instead.

![sonic-pi-atom-screenshot](https://raw.githubusercontent.com/rkh/atom-sonic/master/screenshot.png)

## Requirements

Sonic Pi needs to be running in the background.

## Default Key Bindings

 Key Binding  | Action                      | Description
--------------|-----------------------------|-----------------
 `ctrl-r`     | `atom-sonic:play-file`      | Sends content of the currently open buffer to Sonic Pi for instant playback
 `ctrl-alt-r` | `atom-sonic:play-selection` | Sends currently selected text to Sonic Pi for instant playback
 `ctrl-s`     | `atom-sonic:stop`           | Tells Sonic Pi to stop all playback



## Get Started

Try typing

```
play :c4,
```

Now type `adsr`, and hit enter to use the snippet.
Use `tab` and `shift-tab` to jump between the attack, decay, sustain and release values. Change them if you want!

Now key in `amp: 0.5, ` or some other slidable parameter. You'll know if it's slidable if
there's something on the right saying 'Slide Syn. Pms.' (Sliding Synth Parameters).

Now key in `slideshape`, hit enter, and bam! There will now be `amp_slide` and `amp_slide_shape` parameters

Key in the value for `amp_slide`, and `amp_slide_shape`... oh wait... was 1 a linear slide or a stepped slide?

Who cares! Just type in `linear`, `cubic`, or whatever you want, hit enter and you should have something like this:

```
play :c4, attack: 0.01, decay: 0, sustain: 1, release: 0.1, amp: 0.5, amp_slide: 1, amp_slide_shape: 1
```

## Features
#### Autocompletion
`sonic-pi-autocomplete` autocompletes synth, fx and sample names just when you need them,
and it also supports autocomplete for synth parameters like `amp:`, `cutoff:`, Sonic Pi functions
like `play` and `use_bpm`, and the likes, just like in the current Sonic Pi GUI

#### Snippets
Now this is the real deal. Express yourself with greater fluency and muse by focusing less on
the typing, and more on the coding.

`sonic-pi-autocomplete` has snippets for code block structures like `live_loop`, `in_thread`, `with_fx`,
but more importantly, it also has snippets which takes the pain out of all those synth
parameters (not fully implemented yet though!).

## What's new?

### v1.0.0: The fork
  - rkh seems to have stopped development on atom-sonic, so I decided to reincarnate it as sonic-pi-autocomplete
  - Improved autocomplete, now with context sensing
  - Fixed not able to run code, creds to [this](https://github.com/rkh/atom-sonic/compare/master...bengm:master) patch
  - Added necessary snippets from `live_loop`s to `amp_slide: 1, amp_slide_curve: 3`
  - Updated all synth names, samples, fx to the latest release: Sonic Pi v2.10
  - Added placeholders for things like `note_slide_shape`, because memorizing `0: Step, 1: Linear, etc...` won't cut

## TODO:
  - Make sure it does as one would expect
    - Making the autocomplete dialog pop up automatically when entering synth parameters
    - Auto formatting of snippets and autocompletes, especially for CSV synth and fx params.
    - Get rid of sloppy code causing TypeErrors (because undefined wasn't checked... lol)
  - Fully implement all possible synth params, and organize them into Slide, Controllable, or static_synth_params
  - Do the same thing for all FX params, which apparently does not have any autocomplete features so far
    - FX params should easily be able to have context sensing, as the params are always placed
