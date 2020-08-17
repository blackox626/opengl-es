/* 
  glsl.fsh
  opengl-es

  Created by blackox626 on 2020/8/11.
  Copyright © 2020 vdian. All rights reserved.
*/

precision mediump float;

uniform vec3 objectColor;
uniform vec3 lightColor;

void main (void) {
    //vec4 mask = texture2D(Texture, TextureCoordsVarying);
    //gl_FragColor = vec4(mask.rgb, 1.0);
//    gl_FragColor = mix(texture2D(Texture1, TextureCoordsVarying),texture2D(Texture2, TextureCoordsVarying),0.2);
//    gl_FragColor = texture2D(Texture1, TextureCoordsVarying);
    gl_FragColor = vec4(lightColor * objectColor, 1.0);
}
