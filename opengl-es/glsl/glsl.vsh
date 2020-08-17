/* 
  glsl.vsh
  opengl-es

  Created by blackox626 on 2020/8/11.
  Copyright © 2020 vdian. All rights reserved.
*/

attribute vec4 Position;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main (void) {
    gl_Position = projection * view * model * Position;
}
