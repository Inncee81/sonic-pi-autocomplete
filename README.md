# Sonic Pi Autocomplete
###### Atom + Sonic Pi Integration with Ultra Cow Powers!!!

This plugin allows remote controlling [Sonic Pi](http://sonic-pi.net/) via [Atom](https://atom.io/).

Sonic Pi is fun to play with, but its built-in editor is very rudimentary.
With this plugin, you can livecode without having to worry about nitty things like which parameters can you slide or control, or what are the currently available parameters for all synths, fx, samples, and functions. Or whether 1 stood for linear slide_shape for one parameter, or saw mod_wave for another.

![sonic-pi-atom-screenshot](https://raw.githubusercontent.com/euwbah/sonic-pi-autocomplete/master/screenshot.png)

### Usage

Start up Sonic Pi or the Sonic Pi server (over UDP), and get live coding in Atom!

Note that the support for executing huge files with the `Play Huge File` command,
will only work with Sonic Pi 2.11, which is currently yet to be released.
(You can try compile it from source though, good luck!)

### Default Key Bindings

 Key Binding  | Action                      | Description
--------------|-----------------------------|-----------------
 `alt-r`      | `sonic-pi-autocomplete:play-file`      | Sends content of the currently open buffer to Sonic Pi for instant playback
 `ctrl-alt-r` | `sonic-pi-autocomplete:play-selection` | Sends currently selected text to Sonic Pi for instant playback
 `alt-shift-r`| `sonic-pi-autocomplete:stop`           | Tells Sonic Pi to stop all playback
 unbinded     | `sonic-pi-autocomplete:play-huge-file` | Plays a large file that can't be sent over a single OSC message



## Get Started

### Basic Usage

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

Add `x = ` in front to get something like this: `x = play :c4, attack: 0.01, ....`

Try typing `control` on a new line, you should be able to see `x` as a `:beep` synth instance. Now you'll be able to see what parameters you can control or slide for `:beep`.

This works for all synths, the most recent `use_synth` available in the current scope will determine the synth played. This also works if you use `x = synth :tb303, :c4, attack: 0.01` or whatever function that returns a synth instance.

### Parsing directives

Sometimes, you may want to use `control` a lot, and you end up defining a helper function like this:

```ruby
def c(*args)
  control *args
end
```

Now if you want to alias this shortened `c` function with the original `control` function, you can create a comment on a new line that goes like this:
```ruby
#@ control c
```

And now whenever you are in scope of the alias comment, you will be able to get autocompletion for `c` just as you would in `control`

In the same way, if you have a function that changes synths, but the `use_synth` is not in scope, you can use `#$ :synthname` like this:
```ruby
define :waw do
  use_synth :tb303
end

waw
#$ :tb303
play :c4, cutoff: 80, cutoff_min: 60
```
to get autocompletions for the `tb303` synth.

Another directive that can come in handy is the `#@ play <alias_name> <optional: parameter index to start suggestions> <optional: synth_used>`

This will let you control at which parameter of the aliased `alias_name` function will autocompletions for the synth parameters appear for either the current synth, (or `synth_used`, if provided). It doesn't have to be for the `play` command, as demonstrated in the example below:

```ruby
drone = synth :dark_ambience, sustain: 56, release: 8

#@ play ctldrone 0 :dark_ambience
define :ctldrone do |*args|
  control drone, *args
end

```
-----
## Full list of autocomplete features:
##### Functions, Names and Parameters:
  - All Synth symbols
  - All FX symbols
  - All Sample symbols
  - All functions
  - All parameters + parameter type

##### Smart Snippets
  - `adsr`
    - attack, decay, sustain, release
  - `asr`
    - attack, sustain, release`
  - `pluck`
    - `sustain: 0`, release
  - `slide`
    - adds a `_slide` setting for the parameter just before the cursor
  - `slidecurve`
    - same as `slide` but also adds a `_slide_curve` parameter
  - `slideshape`
    - same as `slide` but also adds a `_slide_shape` parameter
  - All integer enumerations representing wave shapes in wave shape / slide shape parameters
    - `step`
    - `linear`
    - `sine`
    - `welch`
    - `squared`
    - `cubed`
    - `saw`
    - `pulse`
    - `triangle`
    - `sine`

## What's new?

### v.2.0: HUGE UPDATE
  - Much smarter autocompletion.
  - Support for ALL samples, synths, fxs, functions, and their respective params
  - Smart scope-based contextual autocompletion with pre-parsing features
  - Added autocompletion directives

### v.1.1: No file size limit! (for Sonic Pi 2.11, still in dev)
  - Previously, sending OSC messages over UDP to the Sonic Pi server directly limited the maximum file size
  - Sonic Pi v.2.11 (still under dev) now supports loading files into the buffer and playing it directly with the /save-and-run-buffer-via-local-file OSC command
  - This feature can be accessed via the command palatte (ctrl-shift-P) as `Play Huge File`, but you can create your own keybindings.

### v1.0: The fork
  - rkh seems to have stopped development on atom-sonic, so I decided to reincarnate it as sonic-pi-autocomplete
  - Improved autocomplete, now with context sensing
  - Fixed not able to run code, creds to [this](https://github.com/rkh/atom-sonic/compare/master...bengm:master) patch
  - Added necessary snippets from `live_loop`s to `amp_slide: 1, amp_slide_curve: 3`
  - Updated all synth names, samples, fx to the latest release: Sonic Pi v2.10
  - Added placeholders for things like `note_slide_shape`, because memorizing `0: Step, 1: Linear, etc...` won't cut

## TODO:
  - Add autocomplete for `cue` and `sync`
  - Allow function aliasing directives to be placed right before functions so that the redundant alias name parameter needn't be there.
