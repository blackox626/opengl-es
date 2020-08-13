/* 
  glsl.vsh
  opengl-es

  Created by blackox626 on 2020/8/11.
  Copyright © 2020 vdian. All rights reserved.
*/

/*
 顶点着色器 是一个可编程的处理单元，执行顶点变换、纹理坐标变换、光照、材质等顶点的相关操作，每顶点执行一次。替代了传统渲染管线中顶点变换、光照以及纹理坐标的处理。
*/

attribute vec4 Position;
attribute vec2 TextureCoords;
varying vec2 TextureCoordsVarying;

//uniform mat4 transform;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main (void) {
    gl_Position = projection * view * model * Position;
    TextureCoordsVarying = TextureCoords;
    //TextureCoordsVarying = vec2(TextureCoords.x, 1.0 - TextureCoords.y);
}
