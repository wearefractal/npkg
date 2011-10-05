**npkg is a utility that generates cross-platform installation packages for NodeJS applications**

## Installation

To install node-package, use [npm](http://github.com/isaacs/npm):

    $ npm install -g npkg

## Usage

    $ npkg <input folder containing your package.json and app> <output folder (optional)>

Simple as that. If you did everything properly you will now be greeted with an epic success

![Output](http://i.imgur.com/No0dq.png)

## Configuration

npkg parses configuration out of your package.json file for the installer.

![It looks like this](http://i.imgur.com/dDDkx.png)


If you have a LICENSE file they will have to accept it to proceed with the installation

![Like this](http://i.imgur.com/Va7Wq.png)


If you have an app.png (Unix) and app.ico (Windows) they will be presented with an option to place desktop icons.

![Like this](http://i.imgur.com/i9pMb.png)


If they are on Unix, NodeJS is downloaded and bundled at the end of the installation

![Like this](http://i.imgur.com/O8pDG.png)

Success!

![SUCCESS](http://i.imgur.com/IjBUo.png)

## Dependencies

For developers: tar, Java, Python

For consumers: Java

## LICENSE

(MIT License)

Copyright (c) 2011 Fractal <contact@wearefractal.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

