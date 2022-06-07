# $1 input file
# $2 ffmpeg arguments
# $3 output file
#!/bin/bash
docker run -it --rm -v "$(pwd)":/usr/src/myapp -w /usr/src/myapp ffmpeg:latest ffmpeg -i "$1" "$2" "$3"