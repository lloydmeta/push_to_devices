name             "mongodb-10gen"
maintainer       "Higanworks LLC."
maintainer_email "sawanoboriyu@higanworks.com"
license          "MIT"
description      "Installs/Configures mongodb-10gen"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.7"
depends          "apt"
depends          "mongodb-10gen" # workaround for TravisCI
supports         "ubuntu"
supports         "debian"
