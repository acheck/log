# Log
___
Logging module with the minimum necessary functionality.

#### Installation
The [log](https://github.com/mzujev/log/log.lua) file should be dropped in to an existing project and required by it.
```lua
    log = require "log"
``` 

### Usage
The ***Log*** module provides 6 functions, each function displays all its arguments to the console and also outputs them to the log file, if one is set.

- ***log.trace(...)***
- ***log.debug(...)***
- ***log.info(...)***
- ***log.warn(...)***
- ***log.error(...)***
- ***log.fatal(...)***

### Options for Log object
***Log*** object provide some variables for setting additional options.

- ***log.color*** - Indicates that we will use color output in the terminal(default is `true`)
- ***log.file*** - Path to log file(default is `nil` no log file)
- ***log.level*** - Default and minimum log level, it can also be as numerical values according to the simbolic level(default is set to `trace`)

### Copyright
See [Copyright.txt](https://github.com/mzujev/log/Copyright.txt) file for details
