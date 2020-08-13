/* 
  glsl.fsh
  opengl-es

  Created by blackox626 on 2020/8/11.
  Copyright © 2020 vdian. All rights reserved.
*/

/*
 片元着色器 是一个处理片元值及其相关联数据的可编程单元，片元着色器可执行纹理的访问、颜色的汇总、雾化等操作，每片元执行一次。
 计算像素最后的颜色输出
*/

precision mediump float;

uniform sampler2D Texture1;
uniform sampler2D Texture2;

varying vec2 TextureCoordsVarying;

void main (void) {
    //vec4 mask = texture2D(Texture, TextureCoordsVarying);
    //gl_FragColor = vec4(mask.rgb, 1.0);
    gl_FragColor = mix(texture2D(Texture1, TextureCoordsVarying),texture2D(Texture2, TextureCoordsVarying),0.2);
}
