# File data reader
Provides file statistical data. Number of symbols, uppercase letters, lowercase letters, word count.
Writen in intel 8086 turbo assembler.

## Usage
All options are listed under:
```
$ FSTATS.EXE /?
```


## Building

You will need dosbox or any other dos environment and turbo assembler 16 bit intel 8086 in order to compile

```
$ git clone https://github.com/ricardascubukinas/fstats.git
$ dosbox
$ MOUNT C /"CLONED_FOLDER_PATH"/fstats/ 
$ C:
$ TASM FSTATS
$ TLINK FSTATS
$ FSTATS.EXE /?
```
