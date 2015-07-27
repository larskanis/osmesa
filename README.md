[![Build Status](https://travis-ci.org/larskanis/osmesa.svg?branch=master)](https://travis-ci.org/larskanis/osmesa)

# OSMesa - Off-screen Rendering

Mesa's off-screen rendering interface is used for rendering into user-allocated Ruby string.
That is, the GL_FRONT colorbuffer is actually a buffer in main memory, rather than a window on your display.
There are no window system or operating system dependencies.
One potential application is to use Mesa as an off-line, batch-style renderer.

The OSMesa API provides two basic functions for making off-screen renderings: OSMesa::Context.new() and OSMesa::Context#MakeCurrent().
See [API-docs](http://www.rubydoc.info/gems/osmesa) for more information about the API functions.


## Installation

Install osmesa library and header files:

* on Ubuntu/Debian:
```
$ sudo apt-get install libosmesa6-dev
```    
* on Windows: No need to install dependencies - the binary gem includes everything

Install the gem:
```
$ gem install osmesa
```

## Usage Example

Use OSMesa to create an offline rendering buffer and use the opengl gem to render a red line.
The raw RGBA image buffer is written to a PNG image file with the help of the chunky_png gem:

    require 'osmesa'
    require 'opengl'
    require 'chunky_png'

    width, height = 100, 70
    ctx = OSMesa::Context.new(OSMesa::RGBA, nil)
    buffer = "rgba" * width * height
    ctx.MakeCurrent(buffer, GL::GL_UNSIGNED_BYTE, width, height)

    GL.implementation = OSMesa::Implementation.open
    GL.MatrixMode(GL::GL_MODELVIEW)
    GL.LoadIdentity()

    GL.Clear(GL::GL_COLOR_BUFFER_BIT)

    GL.Color4ub(0xff, 0x00, 0x00, 0xff)
    GL.Begin(GL::GL_LINES)
    GL.Vertex(0.5, 0.5)
    GL.Vertex(-0.5, -0.5)
    GL.End

    GL.Flush()

    png = ChunkyPNG::Image.from_rgba_stream(width, height, buffer)
    png.save('test.png')

## Contributing

1. Fork it ( http://github.com/larskanis/osmesa/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
