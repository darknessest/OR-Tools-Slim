# OR-Tools-Slim

### Description

*Slim* version of OR-Tools image based on alpine 3.15.

For OR-Tools building the stable branch of official repo is used.

Yes, Dockerfile looks awful, but you do what you gotta do the get 
this sleek 280MB Docker image.

### Side note

Building may end with an error if number of threads is not 1. If you encounter 
any problems change a number in this line.

```shell
cmake --build build -v -j4
```

------
Any contributions are welcome.