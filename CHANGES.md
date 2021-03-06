# CH CH CH CHANGES! #

## v0.11.0 Thursday the 19th of December 2013 ##

* Run specs on Travis against Ruby 2.
* Use the latest Haml.

---


## v0.10.1 Thursday the 19th of December 2013 ##

* A couple of the specs weren't written correctly to check for failure. For some reason they pass on my machine but fail on Travis CI, so I've updated them and now they should be good!

----


## v0.10.0 Thursday the 19th of December 2013 ##

* The `name` attribute can now be overridden if needs be.

----


## v0.9.1 16th of December 2012 ##

* `labelled` can now take an attributes hash, so: `.labelled("Favourite tea:", class: "list")` will output `%label{ class: "list", for: "teas",  }`

----


## v0.9.0 16th of June 2012 ##

* Updated the README with info on using plugins, and how to contribute.
* `describe` in the Aria plugin no longer needs a tuple to create a list, it can take an array of single valued arrays as the missing part of the tuple will default to an empty hash.
* Added testing for the develop branch to Travis.
* Moved most of the code to a separate file that is then required back in by lib/campo.rb, as specs were affected by the order they were run in. Now, each spec only `require` the files it needs and clear the plugins before running, which means they can be run in any order and not be affected.

----

## v0.8.3b 14th of May 2012 ##

* `with_default` can now have the 'disabled' attribute turned off. 
* Added a lot of docs.

----

v0.8.2b Literals can have attributes passed. Aria plugin's `describe` can take a list of messages and create an unordered list.

v0.8.1b Added a Rakefile with a task to generate the docs, for convenience. Fixed a couple of typos in the docs.

v0.8.0b The Aria plugin's `describe` now takes options for adding attributes.

v0.7.1b Removed debugging statement that was being output.

v0.7.0b Use of [] in input names now allowed, for grouping inputs like an array.

v0.6.14b Lowercased aria.rb for bundler.

v0.6.12b Another mistake, an accidental move of a file - this will teach me to run the specs even for trivial changes!

v0.6.11b My mistake this time, not using lowercase for the file names was causing a problem deploying to Heroku.

v0.6.10b Removed ENV vars from gemspec as deployment to Heroku with Bundler is problematic.

v0.6.7b Added `describe` method, via the Aria plugin. It will help to keep the forms accessible.

v0.6.6b Validation rules are now built. Validations for required, digits and maxlength added.

v0.6.5b Labels get the "required" class too when using JQueryValidation, to make all our styling wishes come true!

v0.6.4b Default option for select tags now has its id attribute appended with "_default" to stop the id clashing with the select tag.

v0.6.3b Convenience method `submit` is now more convenient as it takes the value as part of the hash args without a pesky unused parameter getting in the way.

v0.6.2b Added easier labelling for textareas.

v0.6.1b The function for the JQuery validation wasn't right, fixed it now, and updated the specs a little for it.

v0.6.0b All form fields get an id. Added "hidden" input convenience method.

v0.5.2b Turns out that you can learn a lot if you run the specs, such as inners didn't need changing to default_proc, just atts.

v0.5.1b Hash defaults for form should work better now as moved to using Hash#default_proc which updates the key the way required.

v0.5.0b Added a JQuery validation plugin.

v0.4.0b Added an outputter class, currently hidden under old API. Improved argument passing, added before and after hooks for output. Extra args to Campo.output are now passed as options, and partials are done this way too instead of the clumsy prepended argument.

v0.3.6b removed need for block variables.

v0.3.5b Changed tabindex to use an instance variable, so now forms should be able to be nested and the tabindex update properly.

v0.3.4 Added `password` convenience method.

v0.3.2 Blocks are now passed on for .literal and .bit_of_ruby

v0.3.1 Fixed possible bit of dodgy interpolation in Haml_Ruby_Insert

v0.3.0 Improved passing of hash arguments for options to select tags. More specs.

v0.2.0 All Base fields can now take a block and the convenience methodsl, allowing them to nest other elements regardless of whether the parent is a form or a select. This basically makes it a lot easier to use a literal as the root of the document.

v0.1.1 Label naming a bit better... possibly! It breaks on _ and capitalises when trying for a default.

v0.1.0 Added support for helper methods in amongst haml attributes.  More convenience methods like `radio`. Support for nesting of fieldsets. `.select` takes a block too.

v0.0.30 Changed main output to allow a whole form to be wrapped in a literal, for instance when wanting to wrap it in a div. Fragments now require 'false' to be passed along with the tag class. No change for whole forms.

v0.0.29 Added more tests and a couple of convenience methods - bit_of_ruby and literal.

v0.0.28 Somehow a typo that caused a bug got committed. Fixed it.

v0.0.27 changes to allow fragments to be output without the variable declarations at the top, and for all children to output too.

v0.0.26 Bugfix

v0.0.25 Added checkbox convenience method.

v0.0.24 Fixed inners for textarea, properly evaluated now, and slight change to submit button so it's not passed on submit as a parameter.

v0.0.23 Inners are capitalised and attributes downcased, to make using convenience methods more convenient.

v0.0.22 Bugfixes, bit of internal rejigging, and fieldset convenience method now takes a block, it's more natural.

v0.0.21 Added convenience method for Textarea.

v0.0.20 Bugfixes to Textarea and some other bits of assignment code, as it just didn't work.

v0.0.19 Added convenience method for submit button.

v0.0.18 Fix to errors caused by attributes that aren't strings; labelling can be added by .method or by push.

v0.0.17 Bug fix/internal API change, forced by changes in 0.0.16

v0.0.16 can pass a ruby insert for Haml to a select tag

v0.0.15 Select#with_default can now be used with an and array and/or a block.

v0.0.14 Added some specs and made minor changes to code.

v0.0.13 Added convenience methods for adding text and select tags (with a default option tag), and problem with spaces in names/values for attribute methods.

v0.0.12 Tab index for fields is automatically generated.

v0.0.11 No need to explicitly give a label the name, it picks it up from the field.

v0.0.10 All options get id's and locals too.

v0.0.9 Added fieldsets and legends.

v0.0.8 Adds id's to input fields, making accessible labels.

v0.0.7 Select tags with dynamic option tags possible.

v0.0.6 Added in another local, called inners for dynamic inner stuff. Changed locals to atts as it was messing up sinatra/haml. Added in more defaults to locals to avoid errors.

v0.0.5 Added in locals, which makes the parts of the form (possibly) dynamic.

v0.0.4 Moved output delegates to blocks on path to adding locals easier.

v0.0.3 Simplified API, removed unnecessary classes

v0.0.2 Submit button and convenience method for output.

v0.0.1 Input text fields, textarea, with labels.
