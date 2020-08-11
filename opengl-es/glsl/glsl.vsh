/* 
  glsl.vsh
  opengl-es

  Created by blackox626 on 2020/8/11.
  Copyright © 2020 vdian. All rights reserved.
*/

attribute vec4 Position;
attribute vec2 TextureCoords;
varying vec2 TextureCoordsVarying;

uniform mat4 transform;

void main (void) {
    gl_Position = transform * Position;
    TextureCoordsVarying = TextureCoords;
    //TextureCoordsVarying = vec2(TextureCoords.x, 1.0 - TextureCoords.y);
}
