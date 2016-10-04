#! /bin/sh

image_name=$1
dest_dir=$2

if [ $# -ne 2 ]; then
  echo "Usage: $0 image_name dest_dir"
  exit 1
fi

if [ ! -d ${dest_dir} ]; then
  echo "error: ${dest_dir} is not directory"
  exit 1
fi

docker run --rm --workdir /home/debian/build --user debian --entrypoint /bin/sh \
 "${image_name}" -c "tar cf - --exclude=nginx-1.11.4 *.deb" \
 | tar xf - -C "${dest_dir}"

