# polythrough

polythrough is a fork of [passthrough](https://github.com/nattog/passthrough), but supports sending midi across multiple channels.

Please see pass through for instructions.

polythrough is a Norns mod, so you must enable it, then go to system > mods > polythrough for options.

## Additional Channels

The mod menu includes one new option called "Additional channels". You can specify a number between 0-15, which will cause polythrough to send midi across _n_ number of additional channels.

For example, if you have "Output channel" set to 1 and "Additional channels" set to 2, then midi received will go out on channels 1, 2, and 3.
