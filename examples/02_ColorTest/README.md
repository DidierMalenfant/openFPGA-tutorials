# Color Test

This core displays a color gradient square. It is based on the [color test](https://projectf.io/posts/fpga-graphics/) section of Will Green's [Project F](https://projectf.io) blog.

Compared to the basic template, the project separates the display part of the core into its own module. This `display` module is written in SystemVerilog (`.sv`) instead of plain Verilog in order to use its more advanced features like the `logic` type. The display is also full screen on the pocket at 400x360 @ 50hz.

### Code analysis

The `display` module generates the video signals pretty much the same way that the basic template does. Everything takes place inside the `always` block:
```
@(posedge pixel_clock or negedge reset_n) begin
...
end
```
This is a sequential/synchronous block, which means signals inside this block are only updated when `pixel_clock` goes high or `reset_n` goes low. `reset_n` is the Pocket's global reset signal so everything should initialize when this signal goes low. We do this in the first half of the `always` block:
```
if (~reset_n) begin
...
end
```
As mentioned above, the block is only called when `pixel_clock` goes high or `reset_n` goes low so this `if` statements figures out which case it is in. If `reset_n` is low then it's because it just became low and we are effectively resetting everything. Otherwise, it must be because `pixel_clock` went high and therefore we are just advancing to the next pixel.

It is a good naming convention to use `_n` to indicate a signal that is active when low.

For each pixel clock rising edge, we advance our `x` and `y` coordinates and reset them when they reach the limits. The values are designed so that `x` and `y` are both 0 at the top-left corner of the screen.

You may notice that `video_rgb` seems to be set twice inside the block. This is a common mis-conception when coming from a procedural programming background. In Verilog, each line does **NOT** happen sequentially but rather it all more or less happens at the same time. In this case, the following line:
```
video_rgb <= { 8'd0, 8'd0, 8'd0 };
```
ends up acting as a catch-all state if `video_rgb` is not set by anything else in the block.

If `x` and `y` are less than 256, then `video_rgb` is set to:
```
video_rgb <= { { x[7:4], 4'd0 }, { y[7:4], 4'd0 }, 8'd64 };
```

This uses the `{ }` operator to group bits together into one 24-bit value. `{ x[7:4], 4'd0 }` grabs the top most 4 bits of the `x` position and sets the lowest 4 bits to 0 which produces an 8-bit red value. `y` is used similarly to produce an 8-bit green value and blue is hard-coded to 64.

The reset of the visible pixels are hard coded to an rgb value of [ 0, 16, 48 ].

Finally, remember that assignments in a sequential should always be non-blocking (`<=`).
