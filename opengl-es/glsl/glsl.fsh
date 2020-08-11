/* 
  glsl.fsh
  opengl-es

  Created by blackox626 on 2020/8/11.
  Copyright © 2020 vdian. All rights reserved.
*/

precision mediump float;

uniform sampler2D Texture;
varying vec2 TextureCoordsVarying;
varying vec3 OurColor;

void main (void) {
    //vec4 mask = texture2D(Texture, TextureCoordsVarying);
    //gl_FragColor = vec4(mask.rgb, 1.0);
    gl_FragColor = texture2D(Texture, TextureCoordsVarying) * vec4(OurColor, 1.0);
}
