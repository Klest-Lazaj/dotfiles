return {
  black = 0xff0d1117,
  white = 0xffe6edf3,
  red = 0xffff7b72,
  green = 0xff3fb950,
  blue = 0xff58a6ff,
  yellow = 0xffd29922,
  orange = 0xffffa657,
  magenta = 0xffbc8cff,
  grey = 0xff8b949e,
  transparent = 0x00000000,

  bar = {
    bg = 0xf00d1117,
    border = 0xff161b22,
  },
  popup = {
    bg = 0xc0161b22,
    border = 0xff30363d
  },
  bg1 = 0xff161b22,
  bg2 = 0xff21262d,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
