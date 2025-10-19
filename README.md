## EDR Test App

Although there were several moments where I had to pull stunts only 
worthy of James Bond, I have completed the mission you assigned to me
and delivered the package. Please make sure to burn this documentation 
after reading lest it fall into the wrong hands 🔥

This app simulates activity to be processed by EDR 
(Endpoint Detection and Response) agents. 
It will generate the requested activities as well as generate a log 
of events for comparison with the output from the EDR agents.

### Getting Started

* Make sure that `ruby` and `bundler` are installed.
  (This was tested with Ruby 3.4.7)
* Install the required gems using  
`bundle install`
* run the app with a script file (yaml or json are supported)  
  `./edr-test  --script sample-script.yaml`
* run the app in interactive mode  
  `./edr-test`
* There are some additional options that you can view by running  
`./edr-test --help`

### Using the app

Hopefully it's pretty obvious
1. When prompted to choose a command, type the number of the command. 
   At this point you can press `ENTER` to exit the program
2. Once you choose a command you will be prompted to enter a value for each
   attribute. You can press `ENTER` to use the default 
   (or nil ifthere is no default)
3. Once you have entered all the attributes they will be checked for validty
   And the command will be executed

### Architecture

Although my undersrtanding was that this was a UI driven app, fore-front
in my mind while designing and coding it was that it would make sense to
be able to generate activity using some kind of script file so that tests
could be repeated.

Because of this you will see that I have created some boilerplate 
(incomplete and untested) code for a Script based Runner.

I also wanted flexibility in the format and destination of the activity log. 
For example, I assume that a real world app would need to transmit it over 
the wire or through a message quueue. You will see I created a few different,
configurable activity loggers inclduing one for debugging to the display.

For commands, I separated out the code for Activities into a concern. 
This allowed me to create Commands that did not generate activity but
might be useful to run from a script (I implemented a simple `Wait` command)

### Activity Log Data Structure

There Was quite a bit of ambiguity here so I created what seemed logical to 
me based on what I know of the domain. I also tried to use names which made
their meaning clearer.

I chose to use [streaming JSON](https://en.wikipedia.org/wiki/JSON_streaming)
as the default output format. Basically each line in
the file is a complete json hash representing a single entry. This allows it to 
write, read and process large amounts of data  wthout the overhead of trying to
parse a whole file

* More extensive documentation of the data structure is [here](doc/data_structure.md)

### Testing

it's standard rspec!
```
bundle install
rspec
```

### Development

To get a console with everything loaded run  
`irb -r ./envrionment`
