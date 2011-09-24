**npkg is a utility that generates cross-platform installation packages for NodeJS applications**

## Installation
    
To install node-package, use [npm](http://github.com/isaacs/npm):

    $ npm install -g npkg

## Usage

    $ npkg -i <folder containing your package.json and app> -o <folder you want installers saved to>

Simple as that. If you did everything properly you will now be greeted with an epic success
![Output](http://i.imgur.com/XfK3A.png)

-o is optional and defaults to <input directory>/build/

## Configuration

npkg parses configuration out of your package.json file for the installer
![It looks like this](http://i.imgur.com/WepNn.png)

If you have a LICENSE file in the same folder, you will also force an agreement
![Like this](http://i.imgur.com/7USV8.png)

After they select the installation location, (hopefully) they will be presented with this
![SUCCESS](http://i.imgur.com/419l7.png)

## Dependencies

For developers:
tar, Java, and Python.

For consumers:
Java. If we want to shake Java we have to write native installers for every type of OS. Send me a message if you come up with a better idea, Java FTL.

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
