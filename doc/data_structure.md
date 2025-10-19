## Activity Log Data Structure

### File Format

The default output format is [streaming JSON](https://en.wikipedia.org/wiki/JSON_streaming)

In this format each line of the output file is a single json record 
describing a single activity. I chose this format because it allows the activity
log to be written (and read) in small chunks, which is advantageous for 
large amounts of data. Using "standard" json would usually require 
parsing the complete file in one go.

### Activity Attributes

There were some ambiguities with the documentation. I chose a set of attributes
that made sense given the context (it's pretty easy to change them). 
I also chose naming convention to make the meaning clearer (although I realize 
that you would probably have your own names in place)

All logged activities share the following common attributes:

| attribute            | type   | description                           |
|----------------------|--------|---------------------------------------|
| activity_type | string | tag for type of activity (eg. "process_start") |
| timestamp            | float  | unix timestamp (with fractional part) |
| username             | string | user name of user owning the process  |
| caller_process_cmdline | string | command line of running process       |
| caller_process_name  | string | process name                          |
| caller_process_id    | integer | process id of running process         |

In addition each activity adds it's own set of custom attributes as follow:

### Process Start

| attribute              | type    | description                          |
|------------------------|---------|--------------------------------------|
| activity_type          | string  | hard-coded to "process_start"        |
| started_process_cmdline | string  | command line of process to start     |
| started_process_id     | integer | id of the started process  |

### File Activities

There are three file activities
* Create a File
* Modify a File
* Delete a File

| attribute           | type    | description                              |
|---------------------|---------|------------------------------------------|
| activity_type       | string  | hard-coded to "file_acitivity"           |
| activity_descriptor | string  | one of "create", "modified" or "deleted" |
| file_path           | string | string | file path of file         |

**note:** This implementation modifies files by appending to them. This is not
the only modification you might want. 
For example a file can be modified by `touching` the directory entry

### Network Connection (and Transmission)

| attribute           | type    | description                                                               |
|---------------------|---------|---------------------------------------------------------------------------|
| activity_type       | string  | hard-coded to "network_connect"                                           |
| source_address |string| The address to use as the source                                          |
| source_port |integer| The port the request should originate from                                |
| destination_address |string| address to connect to <br/>(host names will be converted to ip addresses) |
| destination_port |integer| port the connection will be made to                                       |
| protocol |string| transmission protocol to use ("tcp" or "udp")                             |
| data_size |integer| amount of data to send                                                    |

**notes:**

* For TCP connections it is possible to connect without 
  sending data by setting data_size to 0.
  (UDP is connectionless and always requires data to be sent)
* If no source port and ip is set they will be asssigned by the network
  stack and set appropriately
* They can be set before running the command for TCP connections however the 
  default UDP client used by Ruby does not allow setting them for UDP.
* I do not track the created process name as I am not forking a 
  command to send data
