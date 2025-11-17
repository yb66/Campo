## Campo ##

A static dynamic form builder into haml. Yep, static _and_ dynamic. Use it to statically create a form into haml, but you may notice it's taken advantage of haml's "add a hash to the front of the attributes and it'll get merged" property. [See Haml docs for more](http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html#attribute_methods). More on that below.

Btw, I'll be using this with Sinatra, if you're using Rails you'll need to work out how that's done as I don't know.

### Build status ###

Master branch:
[![Build Status for development branch](https://secure.travis-ci.org/yb66/Campo.png?branch=master)](http://travis-ci.org/yb66/Campo)

Develop branch:
[![Build Status for development branch](https://secure.travis-ci.org/yb66/Campo.png?branch=develop)](http://travis-ci.org/yb66/Campo)

### Note! ###

As always, keep in mind this is an open source project (licence below) and you can contribute! If you find a problem or would like a feature changed or added, let me know, or even better, fork the project and send me a pull request. See the "Contributing" section for some notes on how to do that.

### Double note! ###

I use Campo myself, and I'm trying to improve it. As I don't want to push new stuff out before I've had a chance to give it a whirl and see if it makes sense and works (through experience, specs aren't everything) I'll have several versions of this up here, some unreleased. I tend to append a 'b' to the end of an unreleased version. Please make sure you're reading the documentation for the version you're using!

### Version numbers ###

You'll notice this library is well past version 0.0.1. Some people take this to mean something like "it works brilliantly", but in fact, I'm attempting to use the [semver standard](http://semver.org/). In essence, it tells you about changes to the API, not about code quality - that's what the specs/tests are for. It's worth a read.

### Why write this? ###

However nice Haml is, it's still a lot of effort to build a form. If you've got lots of forms it's worse. The long term plan is to link this in to Sequel.

### Example! ###

Here's an example form:

    # This bit is to simulate the output I'd usually get from calling a database model for a lookup table
    genders = [["1", "Male"], ["2", "Female"]]

    # Now starts the real action #
    
    form = Campo.form "personal_details", action: %Q!"uri("/my/personal_details/update/")!  do
      fieldset "Your details" do              
        text "full_name", "Full name: ", size: 60 
        text "dob", "Date of birth: ", size: 10  #TODO change this
        fieldset "Gender: "  do
          radio "gender", "Male", value: 1 
          radio "gender", "Female", value: 2 
        end
        select("teas").with_default.option("ceylon").option("breakfast").option("earl grey").labelled("Favourite tea:")
        text "occupation", "Occupation: ", size: 60 
        text "phone_landline", "Phone (landline): ", size: 20 
        text "phone_mobile", "Phone (mobile): ", size: 20 
        fieldset "May we contact you..."  do
          checkbox "contactable", "In the day?", value: "day" 
          checkbox "contactable",  "In the evening?", value: "evening" 
        end
        submit "Save"
      end
    end
    
    
    puts Campo.output( form )

and the output:

    - atts = {} if atts.nil?
    - atts.default_proc = proc {|hash, key| hash[key] = {} } if atts.default_proc.nil?
    - inners = {} if inners.nil?
    - inners.default = "" if inners.default.nil?
    - @campo_tabindex ||= 0 # for tabindex
    %form{ atts[:personal_details], id: "personal_details", method: "POST", action: uri("/my/personal_details/update/"), name: "personal_details",  }
      %fieldset{  }
        %legend{  }Your details
        %label{ for: "full_name",  }
          Full name: 
          %input{ atts[:full_name], tabindex: "#{@campo_tabindex += 1}", id: "full_name", type: "text", size: "60", name: "full_name",  }
        %label{ for: "dob",  }
          Date of birth: 
          %input{ atts[:dob], tabindex: "#{@campo_tabindex += 1}", id: "dob", type: "text", size: "10", name: "dob",  }
        %fieldset{  }
          %legend{  }Gender: 
          %label{ for: "gender_1",  }
            Male
            %input{ atts[:gender_1], tabindex: "#{@campo_tabindex += 1}", id: "gender_1", type: "radio", value: "1", name: "gender",  }
          %label{ for: "gender_2",  }
            Female
            %input{ atts[:gender_2], tabindex: "#{@campo_tabindex += 1}", id: "gender_2", type: "radio", value: "2", name: "gender",  }
        %label{ for: "teas",  }
          Favourite tea:
          %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", id: "teas", name: "teas",  }
            %option{ atts[:teas], id: "teas", value: "", disabled: "disabled", name: "teas",  }Choose one:
            %option{ atts[:teas_ceylon], id: "teas_ceylon", value: "ceylon", name: "teas",  }Ceylon
            %option{ atts[:teas_breakfast], id: "teas_breakfast", value: "breakfast", name: "teas",  }Breakfast
            %option{ atts[:teas_earl_grey], id: "teas_earl_grey", value: "earl grey", name: "teas",  }Earl grey
        %label{ for: "occupation",  }
          Occupation: 
          %input{ atts[:occupation], tabindex: "#{@campo_tabindex += 1}", id: "occupation", type: "text", size: "60", name: "occupation",  }
        %label{ for: "phone_landline",  }
          Phone (landline): 
          %input{ atts[:phone_landline], tabindex: "#{@campo_tabindex += 1}", id: "phone_landline", type: "text", size: "20", name: "phone_landline",  }
        %label{ for: "phone_mobile",  }
          Phone (mobile): 
          %input{ atts[:phone_mobile], tabindex: "#{@campo_tabindex += 1}", id: "phone_mobile", type: "text", size: "20", name: "phone_mobile",  }
        %fieldset{  }
          %legend{  }May we contact you...
          %label{ for: "contactable_day",  }
            In the day?
            %input{ atts[:contactable_day], tabindex: "#{@campo_tabindex += 1}", id: "contactable_day", type: "checkbox", value: "day", name: "contactable",  }
          %label{ for: "contactable_evening",  }
            In the evening?
            %input{ atts[:contactable_evening], tabindex: "#{@campo_tabindex += 1}", id: "contactable_evening", type: "checkbox", value: "evening", name: "contactable",  }
        %input{ atts[:Save], tabindex: "#{@campo_tabindex += 1}", id: "Save", type: "submit", value: "Save",  }


### Haml attributes ###

Back to the dynamic attributes mentioned earlier. What does this mean? You can pass in a local to dynamically alter the form based on server side logic.

These get added to the top when calling `Campo.output`, to provide sane defaults:

    - atts = {} if atts.nil?
    - atts.default = {} if atts.default.nil?
    - inners = {} if inners.nil?
    - inners.default = "" if inners.default.nil?
    - @campo_tabindex ||= 0 # for tabindex

Note: if you don't want these added, you can do:

    Campo.output name-of-tag-here, :partial => true
    
e.g

    Campo.output form, :partial => true
    

Here's some Campo code for a select tag with options:

    form = Campo.form "best_bands", action: "/best/bands/" do
      select("bands").option("Suede").option("Blur").option("Oasis").option("Echobelly").option("Pulp").option("Supergrass").with_default.labelled("Favourite band:")
    end
    
or

    form = Campo.form "best_bands", action: "/best/bands/" do
      select "bands" do
        with_default
        option "Suede"
        option "Blur"
        option "Oasis"
        option "Echobelly"
        option "Pulp"
        option "Supergrass"
      end.labelled("Favourite band:")
    end
    
or an array of arrays:

    form = Campo.form "best_bands", action: "/best/bands/" do
      select( "bands", opts: [ 
        ["Suede"],
        ["Blur"],
        ["Oasis"],
        ["Echobelly"],
        ["Pulp"],
        ["Supergrass"],
      ] ).with_default.labelled("Favourite band:")
    end
    
or mix and match blocks, .new, arrays and hashes as you see fit.

 
Generate the haml:
    
    Campo.output form

And the Haml generated:

    - atts = {} if atts.nil?
    - atts.default_proc = proc {|hash, key| hash[key] = {} } if atts.default_proc.nil?
    - inners = {} if inners.nil?
    - inners.default = "" if inners.default.nil?
    - @campo_tabindex ||= 0 # for tabindex
    %form{ atts[:best_bands], id: "best_bands", method: "POST", action: "/best/bands/", name: "best_bands",  }
      %label{ for: "bands",  }
        Favourite band:
        %select{ atts[:bands], tabindex: "#{@campo_tabindex += 1}", id: "bands", name: "bands",  }
          %option{ atts[:bands], id: "bands", value: "", disabled: "disabled", name: "bands",  }Choose one:
          %option{ atts[:bands_suede], id: "bands_suede", value: "Suede", name: "bands",  }Suede
          %option{ atts[:bands_blur], id: "bands_blur", value: "Blur", name: "bands",  }Blur
          %option{ atts[:bands_oasis], id: "bands_oasis", value: "Oasis", name: "bands",  }Oasis
          %option{ atts[:bands_echobelly], id: "bands_echobelly", value: "Echobelly", name: "bands",  }Echobelly
          %option{ atts[:bands_pulp], id: "bands_pulp", value: "Pulp", name: "bands",  }Pulp
          %option{ atts[:bands_supergrass], id: "bands_supergrass", value: "Supergrass", name: "bands",  }Supergrass


In the examples above, notice how the output for each tag gets a local variable added to the front. 

> %option{ **atts[:bands_supergrass]**, id: "bands_supergrass", value: "Supergrass", name: "bands",  }Supergrass

You can either fill that variable with a hash pair, or an empty hash gets passed and nothing happens. Read the Haml docs link at the top of the readme for more info.


If you wanted to select "Blur" dynamically (and you should, but I'd accept Suede) you might do:

    atts[:bands_blur] = {selected: "selected"}

and pass it in to the form when the view is rendered, and the tag would change from:

    <option id='bands_blur' name='bands' value='Blur'>Blur</option>

to:

    <option selected='selected' id='bands_blur' name='bands' value='Blur'>Blur</option>

You can do this with any kind of attribute you wish to add. For example:


    atts[:bands_blur] = {not_worth_listening_to: "selected"}
    
    #=> <option not_worth_listening_to='selected' id='bands_blur' name='bands' value='Blur'>Blur</option>
    
But I doubt your name is Noel Gallagher, which makes this a spurious example.

    
### Be selective ###
    
    opts = [
      ["ceylon"], 
      ["english_breakfast", :selected], 
      ["earl_grey"]
    ]
    
    form = Campo.form "selective_example"
    form.select "teas", opts: opts
    
    Campo.output form

Output:
    
    - atts = {} if atts.nil?
    - atts.default_proc = proc {|hash, key| hash[key] = {} } if atts.default_proc.nil?
    - inners = {} if inners.nil?
    - inners.default = "" if inners.default.nil?
    - @campo_tabindex ||= 0 # for tabindex
    %form{ atts[:selective_example], id: "selective_example", method: "POST", name: "selective_example",  }
      %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", id: "teas", name: "teas",  }
        %option{ atts[:teas_ceylon], id: "teas_ceylon", value: "ceylon", name: "teas",  }Ceylon
        %option{ atts[:teas_english_breakfast], id: "teas_english_breakfast", value: "english_breakfast", selected: "selected", name: "teas",  }English breakfast
        %option{ atts[:teas_earl_grey], id: "teas_earl_grey", value: "earl_grey", name: "teas",  }Earl grey
        
### Pass a hash ###

    opts = {
      "ceylon"=>"Ceylon",
      "english_breakfast"=>"English Breakfast",
      "earl_grey"=>"Earl Grey"
    }
    # the keys can be symbols too, it makes no difference to the output
    
    form = Campo.form "simple_hash_example"
    form.select "teas", opts: opts
    
    Campo.output form, partial: true
    
Output:
    
    %form{ atts[:simple_hash_example], id: "simple_hash_example", method: "POST", name: "simple_hash_example",  }
      %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", id: "teas", name: "teas",  }
        %option{ atts[:teas_ceylon], id: "teas_ceylon", value: "ceylon", name: "teas",  }Ceylon
        %option{ atts[:teas_english_breakfast], id: "teas_english_breakfast", value: "english_breakfast", name: "teas",  }English Breakfast
        %option{ atts[:teas_earl_grey], id: "teas_earl_grey", value: "earl_grey", name: "teas",  }Earl Grey

With an array for the value:

    opts = {
      "ceylon"=>["Ceylon"], 
      "english_breakfast"=>["English Breakfast", :selected], 
      "earl_grey"=>["Earl Grey"]
    }
    
    form = Campo.form "hash_with_array_example"
    form.select "teas", opts: opts
    
    Campo.output form, :partial => true

Output:
    
    %form{ atts[:hash_with_array_example], id: "hash_with_array_example", method: "POST", name: "hash_with_array_example",  }
      %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", id: "teas", name: "teas",  }
        %option{ atts[:teas_ceylon], id: "teas_ceylon", value: "ceylon", name: "teas",  }Ceylon
        %option{ atts[:teas_english_breakfast], id: "teas_english_breakfast", value: "english_breakfast", selected: "selected", name: "teas",  }English Breakfast
        %option{ atts[:teas_earl_grey], id: "teas_earl_grey", value: "earl_grey", name: "teas",  }Earl Grey

### Adding in helpers ###

If you want to use helpers in the attributes, like sinatra's `uri` helper, then add a double-quote to the front:

    form = Campo::Form.new "best_bands", action: %Q!"uri("/best/bands/")!

outputs:

    %form{ atts[:best_bands], method: "POST", action: uri("/best/bands/"), name: "best_bands",  }
    
If the helper isn't among the attributes, add a "=" to the front as you would in the haml:

    form.bit_of_ruby( "= 5 + 1" ) }

outputs:
    
    %form{ atts[:best_bands], method: "POST", action: uri("/best/bands/"), name: "best_bands",  }
      = 5 + 1
      
Although, if you forget the "=" sign it will add it for you.

### And literals ###

`bit_of_ruby` is really just a literal with a shortcut. Here are some examples using literals:


    form = Campo.form "favourite_teas", action: %Q!"uri("/fav/teas/")! do
      select("teas").with_default.option("ceylon").option("breakfast").option("earl grey").labelled("Favourite tea:") 
      literal %Q<%p= "I like tea!">
    end
    
    puts Campo.output form
  
    - atts = {} if atts.nil?
    - atts.default_proc = proc {|hash, key| hash[key] = {} } if atts.default_proc.nil?
    - inners = {} if inners.nil?
    - inners.default = "" if inners.default.nil?
    - @campo_tabindex ||= 0 # for tabindex
    %form{ atts[:favourite_teas], id: "favourite_teas", method: "POST", action: uri("/fav/teas/"), name: "favourite_teas",  }
      %label{ for: "teas",  }
        Favourite tea:
        %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", id: "teas", name: "teas",  }
          %option{ atts[:teas], id: "teas", value: "", disabled: "disabled", name: "teas",  }Choose one:
          %option{ atts[:teas_ceylon], id: "teas_ceylon", value: "ceylon", name: "teas",  }Ceylon
          %option{ atts[:teas_breakfast], id: "teas_breakfast", value: "breakfast", name: "teas",  }Breakfast
          %option{ atts[:teas_earl_grey], id: "teas_earl_grey", value: "earl grey", name: "teas",  }Earl grey
      %p= "I like tea!"
    
You can use literals to wrap forms in divs too:
    
    doc = Campo.literal ".centred.form" do |wrapper|
      wrapper << form # the form defined already above
    end
    
    puts Campo.output doc, partial: true

    .centred.form
      %form{ atts[:favourite_teas], id: "favourite_teas", method: "POST", action: uri("/fav/teas/"), name: "favourite_teas",  }
        %label{ for: "teas",  }
          Favourite tea:
          %select{ atts[:teas], tabindex: "#{@campo_tabindex += 1}", id: "teas", name: "teas",  }
            %option{ atts[:teas], id: "teas", value: "", disabled: "disabled", name: "teas",  }Choose one:
            %option{ atts[:teas_ceylon], id: "teas_ceylon", value: "ceylon", name: "teas",  }Ceylon
            %option{ atts[:teas_breakfast], id: "teas_breakfast", value: "breakfast", name: "teas",  }Breakfast
            %option{ atts[:teas_earl_grey], id: "teas_earl_grey", value: "earl grey", name: "teas",  }Earl grey
        %p= "I like tea!"

        
### tabindex ###

Each field gets `@campo_tabindex += 1` added to its attributes. This will generate a tabindex easily for you.

Since it's an instance variable it can be passed through easily to nested partials and the count will still be right.

### Blocks ###

Most fields will accept a block, so you can nest whatever you like. Generally I just use this for forms, fieldsets and selects (and those have specs) but if you want to try something new, do it! Let me know if it breaks. You don't have to use the `|var|` notation unless you feel it's helpful.

    form = Campo.literal "%div" do |div| 
      div << Campo.form( "nested" ) do
        fieldset "Nest" do
          select "blurg" do
            option "oopsie"
            option "daisies"
          end.labelled "splat"
          text "blah"
        end
      end
    end
    
    puts Campo.output form

Output:
    
    - atts = {} if atts.nil?
    - atts.default_proc = proc {|hash, key| hash[key] = {} } if atts.default_proc.nil?
    - inners = {} if inners.nil?
    - inners.default = "" if inners.default.nil?
    - @campo_tabindex ||= 0 # for tabindex
    %div
      %form{ atts[:nested], id: "nested", method: "POST", name: "nested",  }
        %fieldset{  }
          %legend{  }Nest
          %label{ for: "blurg",  }
            splat
            %select{ atts[:blurg], tabindex: "#{@campo_tabindex += 1}", id: "blurg", name: "blurg",  }
              %option{ atts[:blurg_oopsie], id: "blurg_oopsie", value: "oopsie", name: "blurg",  }Oopsie
              %option{ atts[:blurg_daisies], id: "blurg_daisies", value: "daisies", name: "blurg",  }Daisies
          %label{ for: "blah",  }
            Blah
            %input{ atts[:blah], tabindex: "#{@campo_tabindex += 1}", id: "blah", type: "text", name: "blah",  }

### Plugins ###

I've written a couple of plugins. If you wish to write one yourself you'll need to look for the code for now until I write some proper instructions.

To load a plugin called "Aria":

    Campo.plugin :Aria

### Aria ###

Helpful methods for outputting forms that add in the [WAI-ARIA](http://www.w3.org/WAI/intro/aria) attributes into your forms.

Here's an example of how I've used this with an account registration form to provide information about each field:

    require 'campo'

    Campo.plugin :Aria

    div = Campo.literal "#session.form" do
      self << Campo.form( "register" ) do
        fieldset "Register" do
          literal "%p.warning" do
            literal "Fields marked with an <em>*</em> are required."
          end
          text( "email_address", size: 40 ).describe("A valid email address, please.", class: "validation info description")
          text( "username", size: 40 ).describe([["Must be 3 characters at least.", {class: 'validate_username required', id: 'username_length'}], ["No spaces or punctuation, only numbers, letters and underscores, please.", {class: 'validate_username required', id: 'username_specialchars'}], ["You may not use your email address as a username.", {class: 'validate_username required', id: 'username_not_email_address'}]], class: "validation info description")
          password( "password", size: 40 ).describe([["Must be 8 characters at least.",{class: 'validate_password required', id: 'password_length'}],["It's better to add some numbers/punctuation.", class: 'validate_password', id: 'password_specialchars'],["You may not use your email address or username as a password.", {class: 'validate_password required', id: 'password_not_email_address'}],["For strength, try to make it a phrase, and not to be something you've previously used.",{}]], class: "validation info description")
          bit_of_ruby "= Rack::Csrf.tag(env)"
          literal "#validation_overall_result.validation.hidden" do
            literal "There were problems with the form entries. Please check the highlighted fields."
          end
          submit
        end
      end
    end
    
    
    
    puts Campo.output div

Now let's take a look at the output of the email_address field:

    %label{ for: "email_address",  }
      Email address
      %span{id: "email_address_description", class: "validation info description", }
        A valid email address, please.
      %input{ atts[:email_address], tabindex: "#{@campo_tabindex += 1}", id: "email_address", type: "text", size: "40", name: "email_address", :"aria-describedby" => "email_address_description",  }
      
Notice how the label contains a span that precedes the input field - this is helpful for screen readers because those that aren't using ARIA will still hit the description. The input field refers to this span using the aria-describedby attribute.

For a more complex example, look at the output for username:

    %label{ for: "username",  }
      Username
      %span{id: "username_description", class: "validation info description", }
        %ul
          %li{ id: "username_length", class: "validate_username required", }
            Must be 3 characters at least.
          %li{ id: "username_specialchars", class: "validate_username required", }
            No spaces or punctuation, only numbers, letters and underscores, please.
          %li{ id: "username_not_email_address", class: "validate_username required", }
            You may not use your email address as a username.
      %input{ atts[:username], tabindex: "#{@campo_tabindex += 1}", id: "username", type: "text", size: "40", name: "username", :"aria-describedby" => "username_description",  }

For the campo code, we added an array of tuples to the `describe` method. These tuples are then made into an unordered list within the span. The first part of each tuple is the text description, the second part any attributes you with the list item to have. I've used this in a project in conjunction with JQuery to produce dynamic information back to the user of the form. You don't have to pass the second part of the tuple, in other words you can do:

    text("d").describe([["You"], ["Me"], ["Them"]])

But I would usually expect that you'd want to pass each item an id. It's up to you.

### Contributing ###

When contributings, most of all, remember that **any** contribution you can make will be valuable, whether that is putting in a ticket for a feature request (or a bug, but they don't happen here;), cleaning up some grammar, writing some documentation (or even a blog post, let me know!) or a full blooded piece of code - it's **all** welcome and encouraged.

To contribute some code:

1. Fork this, then:
* `git clone git@github.com:YOUR-USERNAME/Campo.git`
* `git remote add upstream git@github.com:yb66/Campo.git`
* `git fetch upstream`
* `git checkout develop`
* Decide on the feature you wish to add.  
    - Give it a snazzy name, such as **kitchen_sink**.  
    - `git checkout -b kitchen_sink`
* Install Bundler.  
    - `gem install bundler -r --no-ri --no-rdoc`
* Install gems from Gemfile.  
    - `bundle install --binstubs --path vendor`  
    - Any further updates needed, just run `bundle install`, it'll remember the rest.
* Write some specs.
* Write some code. (Yes, I believe that is the correct order, and you'll never find me doing any different;)
* Write some documentation using Yard comments - see [Yard's Getting Started](http://rubydoc.info/docs/yard/file/docs/GettingStarted.md)  
  - Use real English (i.e. full stops and commas, no l33t or LOLZ). I'll accept American English even though it's ugly. Don't be surprised if I 'correct' it.  
  - Code without comments won't get in, I don't have the time to work out what you've done if you're not prepared to spend some time telling me (and everyone else).
* Run `reek PATH_TO_FILE_WITH_YOUR_CHANGES` and see if it gives you any good advice. You don't have to do what it says, just consider it.
* Run specs to make sure you've not broken anything. If it doesn't pass all the specs it doesn't get in.  
  - Have a look at coverage/index.htm and see if all your code was checked. We're trying for 100% code coverage.
* Run `bin/rake docs` to generate documentation.  
    - Open up docs/index.html and check your documentation has been added and is clear.
* Add a short summary of your changes to the CHANGES file. Add your name and a link to your bio/website if you like too.
* Send me a pull request.  
    - Don't merge into the develop branch!  
    - Don't merge into the master branch!  
    - see [http://nvie.com/posts/a-successful-git-branching-model/](http://nvie.com/posts/a-successful-git-branching-model/) for more on how this is supposed to work.
* Wait for worldwide fame.
* Shrug and get on with your life when it doesn't arrive, but know you helped quite a few people in their life, even in a small way - 1000 raindrops will fill a bucket!


### Licence ###

This is under the MIT Licence.

Copyright (c) 2012 Iain Barnett

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

In other words, be good.    

