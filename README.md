Every tag push to [github](https://github.com/nothub/pandoc-notes) builds and publishes pdf documents as github [release](https://github.com/nothub/pandoc-notes/releases/latest) utilizing the [Eisvogel](https://github.com/Wandmalfarbe/pandoc-latex-template) pandoc template.

A local build requires: `pandoc` `texlive-full`  
The github ci build uses: [danteev/texlive](https://github.com/dante-ev/docker-texlive) docker container

```
$ ./panote -n test
creating notes directory: /home/hub/projects/pandoc-notes/test

$ ./panote        
building /home/hub/projects/pandoc-notes/notes/example
building /home/hub/projects/pandoc-notes/notes/test

$ ./panote -h
Usage: panote [-h] [-v] [-n name] [-b name]

Available options:
-h    Print this help and exit
-v    Enable verbose output
-n    Initialize new notes directory
-b    Compile only specified notes
```
