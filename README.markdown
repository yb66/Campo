# Campo #

A static dynamic form builder into haml. Yep, static _and_ dynamic. Use it to statically create a form into haml, but you may notice it's taken advantage of haml's "add a hash to the front of the attributes and it'll get merged" property. [See Haml docs for more](http://haml-lang.com/docs/yardoc/file.HAML_REFERENCE.html#attribute_methods). More on that below.

Btw, I'll be using this with Sinatra, if you're using Rails you'll need to work out how that's done as I don't know.

## Note! ##

As always, keep in mind this is an open source project (licence below) and you can contribute! If you find a problem or would like a feature changed or added, let me know, or even better, fork the project and send me a pull request.


## Why write this? ##

However nice Haml is, it's still a lot of effort to build a form. If you've got lots of forms it's worse. The long term plan is to link this in to Sequel.

## Example! ##

Here's an example form:

    # This bit is to simulate the output I'd usually get from calling a database model for a lookup table
    genders = [["1", "Male"], ["2", "Female"]]

    # Now starts the real action #
    
    form = Campo.form "myform", action: "/my/form/update/"

    form.fieldset "Your details" do |f|
      f.text "full_name",  size: 60 
      f.text "dob", "Date of birth: ", size: 8
      
      f.select( "gender_id", {opts: genders }).with_default.labelled( "Gender: " )
      
      f.select "teas" do |s|
        s.with_default
        s.option("ceylon")
        s.option("breakfast")
        s.option("earl grey")
        s.option("oolong")
        s.option("sencha")
      end.labelled "Favourite tea:"
      
      f.text "occupation", "Occupation: ", size: 60  
      f.text "phone_landline", "Phone  landline : ", size: 20  
      f.text "phone_mobile", "Phone  mobile : ", size: 20  

      f.submit "Save"
  
    end

and the output:


    puts Campo.output( form )

    - atts = {} if atts.nil?
    - atts.default = {} if atts.default.nil?
    - inners.default = "" if inners.default.nil?
    - i = 0 # for tabindex

    %form{ atts[:myform], method: "POST", action: "/my/form/update/", name: "myform",  }
      %fieldset{  }
        %legend{  }Your details
        %label{ for: "full_name",  }
          Full name: 
          %input{ atts[:full_name], tabindex: "#{i += 1}", type: "text", id: "full_name", size: "60", name: "full_name",  }
        %label{ for: "dob",  }
          Date of birth: 
          %input{ atts[:dob], tabindex: "#{i += 1}", type: "text", id: "dob", size: "8", name: "dob",  }
        %label{ for: "gender_id",  }
          Gender: 
          %select{ atts[:gender_id], tabindex: "#{i += 1}", name: "gender_id",  }
            %option{  value: "", disabled: "disabled", name: "gender_id",  }Choose one:
            %option{ atts[:gender_id_1], value: "1", id: "gender_id_1", name: "gender_id",  }Male
            %option{ atts[:gender_id_2], value: "2", id: "gender_id_2", name: "gender_id",  }Female
        %label{ for: "teas",  }
          Favourite tea:
          %select{ atts[:teas], tabindex: "#{i += 1}", name: "teas",  }
            %option{  value: "", disabled: "disabled", name: "teas",  }Choose one:
            %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
            %option{ atts[:teas_breakfast], value: "breakfast", id: "teas_breakfast", name: "teas",  }Breakfast
            %option{ atts[:teas_earl_grey], value: "earl grey", id: "teas_earl_grey", name: "teas",  }Earl grey
            %option{ atts[:teas_oolong], value: "oolong", id: "teas_oolong", name: "teas",  }Oolong
            %option{ atts[:teas_sencha], value: "sencha", id: "teas_sencha", name: "teas",  }Sencha
        %label{ for: "occupation",  }
          Occupation: 
          %input{ atts[:occupation], tabindex: "#{i += 1}", type: "text", id: "occupation", size: "60", name: "occupation",  }
        %label{ for: "phone_landline",  }
          Phone (landline): 
          %input{ atts[:phone_landline], tabindex: "#{i += 1}", type: "text", id: "phone_landline", size: "20", name: "phone_landline",  }
        %label{ for: "phone_mobile",  }
          Phone (mobile): 
          %input{ atts[:phone_mobile], tabindex: "#{i += 1}", type: "text", id: "phone_mobile", size: "20", name: "phone_mobile",  }
        %input{ atts[:Save_Save], tabindex: "#{i += 1}", type: "submit", id: "Save_Save", value: "Save",  }

and that outputs:

    puts Haml::Engine.new( Campo.output( form ) ).render
    
    <form action='/my/form/update/' method='POST' name='myform'>
      <fieldset>
        <legend>Your details</legend>
        <label for='full_name'>
          Full name:
          <input id='full_name' name='full_name' size='60' tabindex='1' type='text' />
        </label>
          Date of birth:
          <input id='dob' name='dob' size='8' tabindex='2' type='text' />
        </label>
        <label for='gender_id'>
          Gender:
          <select name='gender_id' tabindex='3'>
            <option disabled='disabled' name='gender_id' value=''>Choose one:</option>
            <option id='gender_id_1' name='gender_id' value='1'>Male</option>
            <option id='gender_id_2' name='gender_id' value='2'>Female</option>
          </select>
        </label>
        <label for='teas'>
          Favourite tea:
          <select name='teas' tabindex='4'>
            <option disabled='disabled' name='teas' value=''>Choose one:</option>
            <option id='teas_ceylon' name='teas' value='ceylon'>Ceylon</option>
            <option id='teas_breakfast' name='teas' value='breakfast'>Breakfast</option>
            <option id='teas_earl_grey' name='teas' value='earl grey'>Earl grey</option>
            <option id='teas_oolong' name='teas' value='oolong'>Oolong</option>
            <option id='teas_sencha' name='teas' value='sencha'>Sencha</option>
          </select>
        </label>
        <label for='occupation'>
          Occupation:
          <input id='occupation' name='occupation' size='60' tabindex='5' type='text' />
        </label>
        <label for='phone_landline'>
          Phone (landline):
          <input id='phone_landline' name='phone_landline' size='20' tabindex='6' type='text' />
        </label>
        <label for='phone_mobile'>
          Phone (mobile):
          <input id='phone_mobile' name='phone_mobile' size='20' tabindex='7' type='text' />
        </label>
        <input id='Save_Save' tabindex='8' type='submit' value='Save' />
      </fieldset>
    </form>

## Haml attributes ##

Back to the dynamic attributes mentioned earlier. What does this mean? You can pass in a local to dynamically alter the form based on server side logic.

These get added to the top when calling `Campo.output`, to provide sane defaults:

    - atts = {} if atts.nil?
    - atts.default = {} if atts.default.nil?
    - inners = {} if inners.nil?
    - inners.default = "" if inners.default.nil?

Note: if you don't want these added, you can do:

    Campo.output :partial, your_tag
    

In the select tag (below), notice how each tag gets a local variable added to the front. You can either fill that variable with a hash pair, or an empty hash gets passed and nothing happens.

Here's some Campo code for a select tag with options:

    form = Campo.form "best_bands", action: "/best/bands/" do |form|
      form.select("bands").option("Suede").option("Blur").option("Oasis").option("Echobelly").option("Pulp").option("Supergrass").with_default.labelled("Favourite band:")
    end
    
or

    form = Campo.form "best_bands", action: "/best/bands/"
    form.select("bands") do |s|
      s.with_default
      s.option("Suede")
      s.option("Blur")
      s.option("Oasis")
      s.option("Echobelly")
      s.option("Pulp")
      s.option("Supergrass")
    end.labelled("Favourite band:")
    
or an array of arrays:

    form = Campo.form "best_bands", action: "/best/bands/"
    form.select( "bands", opts: [ 
      ["Suede"],
      ["Blur"],
      ["Oasis"],
      ["Echobelly"],
      ["Pulp"],
      ["Supergrass"],
    ] ).with_default.labelled("Favourite band:")

(or mix and match blocks, .new, arrays and hashes)  

 
Generate the haml:
    
    Campo.output form #

And the Haml generated:

    %form{ atts[:best_bands], method: "POST", action: "/best/bands/", name: "best_bands",  }
      %label{ for: "bands",  }
        Favourite band:
        %select{ atts[:bands], tabindex: "#{i += 1}", name: "bands",  }
          %option{  value: "", disabled: "disabled", name: "bands",  }Choose one:
          %option{ atts[:bands_suede], value: "Suede", id: "bands_suede", name: "bands",  }Suede
          %option{ atts[:bands_blur], value: "Blur", id: "bands_blur", name: "bands",  }Blur
          %option{ atts[:bands_oasis], value: "Oasis", id: "bands_oasis", name: "bands",  }Oasis
          %option{ atts[:bands_echobelly], value: "Echobelly", id: "bands_echobelly", name: "bands",  }Echobelly
          %option{ atts[:bands_pulp], value: "Pulp", id: "bands_pulp", name: "bands",  }Pulp
          %option{ atts[:bands_supergrass], value: "Supergrass", id: "bands_supergrass", name: "bands",  }Supergrass


If you wanted to select "Blur" dynamically (and you should, but I'd accept Suede) you might do:

    atts[:bands_blur] = {selected: "selected"}

and pass it in to the form when the view is rendered, and the tag would change from:

    <option id='bands_blur' name='bands' value='Blur'>Blur</option>

to:

    <option selected='selected' id='bands_blur' name='bands' value='Blur'>Blur</option>

You can do this with any kind of attribute you wish to add. For example:


    atts[:bands_blur] = {not_worth_listening_to: "selected"}
    
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
    - atts.default = {} if atts.default.nil?
    - inners = {} if inners.nil?
    - inners.default = "" if inners.default.nil?
    - i = 0 # for tabindex
    
    %form{ atts[:selective_example], method: "POST", name: "selective_example",  }
      %select{ atts[:teas], tabindex: "#{i += 1}", name: "teas",  }
        %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
        %option{ atts[:teas_english_breakfast], value: "english_breakfast", selected: "selected", id: "teas_english_breakfast", name: "teas",  }English breakfast
        %option{ atts[:teas_earl_grey], value: "earl_grey", id: "teas_earl_grey", name: "teas",  }Earl grey
        
## Pass a hash ##

    opts = {
      "ceylon"=>"Ceylon",
      "english_breakfast"=>"English Breakfast",
      "earl_grey"=>"Earl Grey"
    }
    # the keys can be symbols too, it makes no difference to the output
    
    form = Campo.form "simple_hash_example"
    form.select "teas", opts: opts
    
    Campo.output :partial, form
    
Output:
    
    %form{ atts[:simple_hash_example], method: "POST", name: "simple_hash_example",  }
      %select{ atts[:teas], tabindex: "#{i += 1}", name: "teas",  }
        %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
        %option{ atts[:teas_english_breakfast], value: "english_breakfast", id: "teas_english_breakfast", name: "teas",  }English Breakfast
        %option{ atts[:teas_earl_grey], value: "earl_grey", id: "teas_earl_grey", name: "teas",  }Earl Grey

With an array for the value:

    opts = {
      "ceylon"=>["Ceylon"], 
      "english_breakfast"=>["English Breakfast", :selected], 
      "earl_grey"=>["Earl Grey"]
    }
    
    form = Campo.form "hash_with_array_example"
    form.select "teas", opts: opts
    
    Campo.output :partial, form

Output:
    
    %form{ atts[:hash_with_array_example], method: "POST", name: "hash_with_array_example",  }
      %select{ atts[:teas], tabindex: "#{i += 1}", name: "teas",  }
        %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
        %option{ atts[:teas_english_breakfast], value: "english_breakfast", selected: "selected", id: "teas_english_breakfast", name: "teas",  }English Breakfast
        %option{ atts[:teas_earl_grey], value: "earl_grey", id: "teas_earl_grey", name: "teas",  }Earl Grey

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

It's really just a literal:


    form = Campo.form "favourite_teas", action: %Q!"uri("/fav/teas/")! do |form|
      form.select("teas").with_default.option("ceylon").option("breakfast").option("earl grey").labelled("Favourite tea:") 
      form.literal %Q<%p= "I like tea!">
    end
    Campo.output form
  

    %form{ atts[:favourite_teas], method: "POST", action: uri("/fav/teas/"), name: "favourite_teas",  }
      %label{ for: "teas",  }
        Favourite tea:
        %select{ atts[:teas], tabindex: "#{i += 1}", name: "teas",  }
          %option{  value: "", disabled: "disabled", name: "teas",  }Choose one:
          %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
          %option{ atts[:teas_breakfast], value: "breakfast", id: "teas_breakfast", name: "teas",  }Breakfast
          %option{ atts[:teas_earl_grey], value: "earl grey", id: "teas_earl_grey", name: "teas",  }Earl grey
      %p= "I like tea!"
      
    puts Haml::Engine.new( Campo.output form ).render
    
    <form action='/fav/teas/' method='POST' name='favourite_teas'>
      <label for='teas'>
        Favourite tea:
        <select name='teas' tabindex='1'>
          <option disabled='disabled' name='teas' value=''>Choose one:</option>
          <option id='teas_ceylon' name='teas' value='ceylon'>Ceylon</option>
          <option id='teas_breakfast' name='teas' value='breakfast'>Breakfast</option>
          <option id='teas_earl_grey' name='teas' value='earl grey'>Earl grey</option>
        </select>
      </label>
      <p>I like tea!</p>
    </form>
    
You can use literals to wrap forms in divs too:
    
    doc = Campo.literal ".centred.form" do |wrapper|
      wrapper << form # the form defined already above
    end
    
    puts Campo.output doc
    
    .centred.form
      %form{ atts[:favourite_teas], method: "POST", action: uri("/fav/teas/"), name: "favourite_teas",  }
        %label{ for: "teas",  }
          Favourite tea:
          %select{ atts[:teas], tabindex: "#{i += 1}", name: "teas",  }
            %option{  value: "", disabled: "disabled", name: "teas",  }Choose one:
            %option{ atts[:teas_ceylon], value: "ceylon", id: "teas_ceylon", name: "teas",  }Ceylon
            %option{ atts[:teas_breakfast], value: "breakfast", id: "teas_breakfast", name: "teas",  }Breakfast
            %option{ atts[:teas_earl_grey], value: "earl grey", id: "teas_earl_grey", name: "teas",  }Earl grey
        %p= "I like tea!"
        
## tabindex ##

Each field gets `tabindex: "#{i += 1}"` added to its attributes. This will generate a tabindex easily for you.

Note: I'm considering making this an instance variable so that it can be passed through easily to nested partials, but I need to test it first.

## Blocks ##

Most fields will accept a block, so you can nest whatever you like. Generally I just use this for forms, fieldsets and selects (and those have specs) but if you want to try something new, do it! Let me know if it breaks.

    form = Campo.literal "%div" do |div| 
      div << Campo.form( "nested" ) do |form|
        form.fieldset do |f|
          f.select "blurg" do |s|
            s.option "oopsie"
            s.option "daisies"
          end.labelled "splat"
          f.text "blah"
        end
      end
    end
    
## Licence ##

This is under the MIT Licence.

Copyright (c) 2011 Iain Barnett

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

In other words, be good.    

