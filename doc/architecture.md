## Architecture and Design Decisions

This document describes the architecture and design decisions that I made. 
It also includes compromises I made as well as parts of the program that may
need to be further thought through.

The output data structure is documented [here](doc/data_structure.md)

### Architctural Decisions

There were two main architectural areas that I needed to decide on how 
I would implement them. The **Command Structure** and the **Command Runners**.
Although my understanding was to write an app to allow someone to generate
EDR activity I made my decisions based on the assumption that, at some point,
it would make sense to be able to generate events from some kind of script file.

### Command Structure

I considered three implementations for this
1. Use a PORO or the Ruby `Data` object
2. Building off `ActiveModel`
3. Having a metadata store describing a command's parameters 
   with a generic `Command` object.

This was a fairly easy decision to make. 
- Using PORO objects would have required implementing a lot of extra functionality. 
- Usign metadata would have been the most flexible, allowing changes to be made 
  just by editing a database or yaml file.
  But there would have been a lot of code to deal with that metadata and 
  linking it to code that performed the action would have required some kind of
  command object anyway,

`ActiveModel` provided a lot of what I needed to make this simple including 
supporting attribues, validation, asssignment and serialization out of the
box. That saved me a lot of coding. 

I also landed up using a lot of features from`ActiveSupport`, 
for example humanizing names, checking presence, etc.
I also orgiinally thought that I would need a dictionary to provide custom naming
and was about to skip that "feature" when I realized I could just 
use `ActiveSupport::Inflector` for "free".

When I was almost complete I realized that (if this was to be run from a script file) 
it would likely be useful to have commands that don't trigger activity (for example
I created a `Wait` command). To do this I removed the activity related code from
the base class and moved it to a concern that could be included only in
"activity" commands.

### Command Runners

I wanted the flexibility to change the input style easily as well as
the ability to use a custom output format (in the real world I assume output miqht
be sent over a tcp or udp connection or via message queue)

My original architecture was "perfect". I had separate classes for 
running a command, reading input from user and fetching attributes for
commands. They all needed to be sub-classed for interactive use or scripts.
There was also a context object to hold the various objects being
passed around! 

However I quickly realized that, with a few subclasses, the code was getting 
huge and hard to understand so I combined those objects together which left me
with two sub-classes and allowed me to get rid of the context object.

In the current implementation the architecture consists of the following main 
objects:
* A list of `Commands`
* A `Runner` (either an interactive runner or a script runner)
* An `ActivityLog` which can be customized to change the format and destination
  where activity is sent.

### Notes

* I chose to use unix time with a fractional part for the timestamps. 
  This would provide accuracy as well as freeddom from time zone issues

* I made the decision not to create a forked process for network communication

* I also chose not to use custom libraries (Http, FTP) and instead created
  a generic socket connection

* Paths are used and logged as entered. Depending on the application it would
  probably make sense to use absolute paths

* This code should run on Windows but it might need care taken for handling of
  Windows different path format.

* Logging the process name seems redundant. This can be derived largely from 
  the command line

* Ruby messes with both the process name and command line and they are not reliable

* I made some assumptions with files (what happens if you create a file that
  already exists, modify or delete a non-existant file)

* The modify file activity is simplistic. It appends data to the file but there
  might be other activity that needs to be simulated (truncation, touching)

### Things I would change if I had a month

* Improve command selection using arrows for navigation

* Integrate `readline` for going back to previous commands

* Improve reusing previous values (for example I create a file and delete it)

* There is lots of room for improving error handling
