# Campo #

A static dynamic form builder into haml. Yep, static _and_ dynamic. Use it to statically create a form into haml, but you may notice it's taken advantage of haml's "add a hash to the front of the attributes and it'll get merged" property. [See Haml docs for more](http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html#attribute_methods). More on that below.

Btw, I'll be using this with Sinatra, if you're using Rails you'll need to work out how that's done as I don't know.

## Note! ##

As always, keep in mind this is an open source project (licence below) and you can contribute! If you find a problem or would like a feature changed or added, let me know, or even better, fork the project and send me a pull request.

## Double note! ##

I use Campo myself, and I'm trying to improve it. As I don't want to push new stuff out before I've had a chance to give it a whirl and see if it makes sense and works (through experience, specs aren't everything) I'll have several versions of this up here, some unreleased. I tend to append a 'b' to the end of an unreleased version. Please make sure you're reading the documentation for the version you're using!

## Why write this? ##

However nice Haml is, it's still a lot of effort to build a form. If you've got lots of forms it's worse. The long term plan is to link this in to Sequel.

## Example! ##

Here's an example form:

    # This bit is to simulate the output I'd usually get from calling a database model for a lookup table
    genders = [["1", "Male"], ["2", "Female"]]

    # Now starts the real action #
    
    form = Campo.form "personal_details", action: %Q!"uri("/my/personal_details/update/")!  do
      fieldset("Your details") do              
        text( "full_name", "Full name: ", size: 60 )
        text( "dob", "Date of birth: ", size: 10 ) #TODO change this
        fieldset( "Gender: " ) do
          radio( "gender", "Male", value: 1 )
          radio( "gender", "Female", value: 2 )
        end
        select("teas").with_default.option("ceylon").option("breakfast").option("earl grey").labelled("Favourite tea:")
        text( "occupation", "Occupation: ", size: 60 )
        text( "phone_landline", "Phone (landline): ", size: 20 )
        text( "phone_mobile", "Phone (mobile): ", size: 20 )
        fieldset( "May we contact you..." ) do
          checkbox( "contactable", "In the day?", value: "day" )
          checkbox( "contactable",  "In the evening?", value: "evening" )
        end
        submit("Save")
      end
    end

and the output:


    puts Campo.output( form )

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


## Haml attributes ##

Back to the dynamic attributes mentioned earlier. What does this mean? You can pass in a local to dynamically alter the form based on server side logic.

These get added to the top when calling `Campo.output`, to provide sane defaults:

    - atts = {} if atts.nil?
    - atts.default = {} if atts.default.nil?
    - inners = {} if inners.nil?
    - inners.default = "" if inners.default.nil?

Note: if you don't want these added, you can do:

    Campo.output your_tag, :partial => true

Here's some Campo code for a select tag with options:

    form = Campo.form "best_bands", action: "/best/bands/" do
      select("bands").option("Suede").option("Blur").option("Oasis").option("Echobelly").option("Pulp").option("Supergrass").with_default.labelled("Favourite band:")
    end
    
or

    form = Campo.form "best_bands", action: "/best/bands/" do
      select("bands") do
        with_default
        option("Suede")
        option("Blur")
        option("Oasis")
        option("Echobelly")
        option("Pulp")
        option("Supergrass")
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

> %option{ *atts[:bands_supergrass]*, id: "bands_supergrass", value: "Supergrass", name: "bands",  }Supergrass

You can either fill that variable with a hash pair, or an empty hash gets passed and nothing happens. Read the Haml docs link at the top of the readme for more info.


If you wanted to select "Blur" dynamically (and you should, but I'd accept Suede) you might do:

    atts[:bands_blur] = {selected: "selected"}

and pass it in to the form when the view is rendered, and the tag would change from:

    <option id='bands_blur' name='bands' value='Blur'>Blur</option>

to:

    <option selected='selected' id='bands_blur' name='bands' value='Blur'>Blur</option>

You can do this with any kind of attribute you wish to add. For example:


    atts[:bands_blur] = {not_worth_listening_to: "selected"}
    
But I doubt your name is Noel Gallagher, which makes this a spurious example.

    
## Be selective ##
    
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
        
## Pass a hash ##

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

## Adding in helpers ##

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

## And literals ##

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

        
## tabindex ##

Each field gets `@campo_tabindex += 1` added to its attributes. This will generate a tabindex easily for you.

Since it's an instance variable it can be passed through easily to nested partials and the count will still be right.

## Blocks ##

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
    
## Licence ##

This is under the MIT Licence.

Copyright (c) 2012 Iain Barnett

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

In other words, be good.    

