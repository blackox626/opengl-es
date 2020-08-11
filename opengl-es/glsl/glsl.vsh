/* 
  glsl.vsh
  opengl-es

  Created by blackox626 on 2020/8/11.
  Copyright © 2020 vdian. All rights reserved.
*/

attribute vec4 Position;
attribute vec2 TextureCoords;
varying vec2 TextureCoordsVarying;

void main (void) {
    gl_Position = Position;
    TextureCoordsVarying = TextureCoords;
}
