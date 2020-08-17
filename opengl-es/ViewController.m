//
//  ViewController.m
//  opengl-es
//
//  Created by blackox626 on 2020/8/11.
//  Copyright © 2020 vdian. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import "Shader.h"
#import "TextureUtil.h"

typedef struct {
    GLKVector3 positionCoord; // 定点坐标 (X, Y, Z) 【-1.0，1.0】
    GLKVector2 textureCoord; // 纹理坐标 (U, V) 【0，1】
} SenceVertex;

@interface ViewController () {
    GLuint texture1ID;
    GLuint texture2ID;
    
    GLuint vertexBuffer;
    GLuint vertexArray;
    
    GLuint lightVertexArray;
    
    GLuint positionSlot;
    GLuint texture1Slot;
    GLuint texture2Slot;
    GLuint textureCoordsSlot;
}

@property (nonatomic, assign) SenceVertex *vertices; // 顶点数组

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic,strong) Shader *shader;
@property (nonatomic,strong) Shader *lightShader;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSTimeInterval startTimeInterval; // 开始的时间戳

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initVertices];
    [self initContext];
    
    
    // 创建一个展示纹理的层
    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    layer.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width * 1.5);
    layer.contentsScale = [[UIScreen mainScreen] scale];  // 设置缩放比例，不设置的话，纹理会失真
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    [self.view.layer addSublayer:layer];
    
    // 绑定纹理输出的层
    [self bindRenderLayer:layer];
    
    glEnable(GL_DEPTH_TEST);
    //glDepthFunc(GL_LESS);
    
    [self initShader];
    //[self createTexture];
    [self bind];
    
//    self.startTimeInterval = 0;
//    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
//    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    [self render];
    
//    // 删除顶点缓存
//    glDeleteBuffers(1, &vertexBuffer);
//    vertexBuffer = 0;
}

- (void)initVertices {
    // 创建顶点数组
    self.vertices = malloc(sizeof(SenceVertex) * 36);
    
    //后
    self.vertices[0] = (SenceVertex){{-0.5, 0.5, -0.5}, {0, 1}}; // 左上角
    self.vertices[1] = (SenceVertex){{-0.5, -0.5, -0.5}, {0, 0}}; // 左下角
    self.vertices[2] = (SenceVertex){{0.5, -0.5, -0.5},{1, 0}}; // 右下角
    self.vertices[3] = (SenceVertex){{0.5, -0.5, -0.5},{1, 0}}; // 右下角
    self.vertices[4] = (SenceVertex){{0.5, 0.5, -0.5}, {1, 1}}; // 右上角
    self.vertices[5] = (SenceVertex){{-0.5, 0.5, -0.5}, {0, 1}}; // 左上角
    
    //前
    self.vertices[6] = (SenceVertex){{-0.5, 0.5, 0.5}, {0, 1}}; // 左上角
    self.vertices[7] = (SenceVertex){{-0.5, -0.5, 0.5}, {0, 0}}; // 左下角
    self.vertices[8] = (SenceVertex){{0.5, -0.5, 0.5},{1, 0}}; // 右下角
    self.vertices[9] = (SenceVertex){{0.5, -0.5, 0.5},{1, 0}}; // 右下角
    self.vertices[10] = (SenceVertex){{0.5, 0.5, 0.5}, {1, 1}}; // 右上角
    self.vertices[11] = (SenceVertex){{-0.5, 0.5, 0.5}, {0, 1}}; // 左上角

    //左
    self.vertices[12] = (SenceVertex){{-0.5,0.5, 0.5}, {0, 1}}; // 左上角
    self.vertices[13] = (SenceVertex){{-0.5,-0.5, 0.5}, {0, 0}}; // 左下角
    self.vertices[14] = (SenceVertex){{-0.5,-0.5, -0.5},{1, 0}}; // 右下角
    self.vertices[15] = (SenceVertex){{-0.5,-0.5, -0.5},{1, 0}}; // 右下角
    self.vertices[16] = (SenceVertex){{-0.5,0.5, -0.5}, {1, 1}}; // 右上角
    self.vertices[17] = (SenceVertex){{-0.5,0.5, 0.5}, {0, 1}}; // 左上角

    //右
    self.vertices[18] = (SenceVertex){{0.5,0.5, 0.5}, {0, 1}}; // 左上角
    self.vertices[19] = (SenceVertex){{0.5,-0.5, 0.5}, {0, 0}}; // 左下角
    self.vertices[20] = (SenceVertex){{0.5,-0.5, -0.5},{1, 0}}; // 右下角
    self.vertices[21] = (SenceVertex){{0.5,-0.5, -0.5},{1, 0}}; // 右下角
    self.vertices[22] = (SenceVertex){{0.5,0.5, -0.5}, {1, 1}}; // 右上角
    self.vertices[23] = (SenceVertex){{0.5,0.5, 0.5}, {0, 1}}; // 左上角

    //下
    self.vertices[24] = (SenceVertex){{-0.5,-0.5, -0.5}, {0, 1}}; // 左上角
    self.vertices[25] = (SenceVertex){{-0.5,-0.5, 0.5}, {0, 0}}; // 左下角
    self.vertices[26] = (SenceVertex){{0.5,-0.5, 0.5},{1, 0}}; // 右下角
    self.vertices[27] = (SenceVertex){{0.5,-0.5, 0.5},{1, 0}}; // 右下角
    self.vertices[28] = (SenceVertex){{0.5,-0.5, -0.5}, {1, 1}}; // 右上角
    self.vertices[29] = (SenceVertex){{-0.5,-0.5, -0.5}, {0, 1}}; // 左上角

    //上
    self.vertices[30] = (SenceVertex){{-0.5,0.5, -0.5}, {0, 1}}; // 左上角
    self.vertices[31] = (SenceVertex){{-0.5,0.5, 0.5}, {0, 0}}; // 左下角
    self.vertices[32] = (SenceVertex){{0.5,0.5, 0.5},{1, 0}}; // 右下角
    self.vertices[33] = (SenceVertex){{0.5,0.5, 0.5},{1, 0}}; // 右下角
    self.vertices[34] = (SenceVertex){{0.5,0.5, -0.5}, {1, 1}}; // 右上角
    self.vertices[35] = (SenceVertex){{-0.5,0.5, -0.5}, {0, 1}}; // 左上角

    
//    self.cubePos = malloc(sizeof(GLKVector3) * 10);
//    self.cubePos[0] = (GLKVector3){0.0f,  0.0f,  0.0f};
//    self.cubePos[1] = (GLKVector3){2.0f,  5.0f, -15.0f};
//    self.cubePos[2] = (GLKVector3){-1.5f, -2.2f, -2.5f};
//    self.cubePos[3] = (GLKVector3){-3.8f, -2.0f, -12.3f};
//    self.cubePos[4] = (GLKVector3){ 2.4f, -0.4f, -3.5f};
//    self.cubePos[5] = (GLKVector3){-1.7f,  3.0f, -7.5f};
//    self.cubePos[6] = (GLKVector3){1.3f, -2.0f, -2.5f};
//    self.cubePos[7] = (GLKVector3){1.5f,  2.0f, -2.5f};
//    self.cubePos[8] = (GLKVector3){1.5f,  0.2f, -1.5f};
//    self.cubePos[9] = (GLKVector3){-1.3f,  1.0f, -1.5f};
//
//    pos = (GLKVector3){0.0f,  0.0f,  3.0f};
//    front = (GLKVector3){0.0f,  0.0f,  -1.0f};
//    up = (GLKVector3){0.0f,  1.0f,  0.0f};
}

- (void)initContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
}

- (void)initShader {
    // 设置视口尺寸
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    // 编译链接 shader
    self.shader = [[Shader alloc] init:@"glsl"];
    self.lightShader = [[Shader alloc ] init:@"glsl" fname:@"light"];
}

- (void)createTexture {
    // 读取纹理
    texture1ID = [TextureUtil createTextureWithImageName:@"sample.png"];
    texture2ID = [TextureUtil createTextureWithImageName:@"awesomeface.png"];
}

- (void)bind {
    [self.shader use];
    
    GLuint program = self.shader.programId;
    
    // 获取 shader 中的参数，然后传数据进去
    positionSlot = glGetAttribLocation(program, "Position");
//    texture1Slot = glGetUniformLocation(program, "Texture1");  // 注意 Uniform 类型的获取方式
//    texture2Slot = glGetUniformLocation(program, "Texture2");
//    textureCoordsSlot = glGetAttribLocation(program, "TextureCoords");
    
    GLuint objectColorSlot = glGetUniformLocation(program, "objectColor");
    GLuint lightColorSlot = glGetUniformLocation(program, "lightColor");
    
    GLKVector3 objectColor = GLKVector3Make(1.0f, 0.5f, 0.31f);
    GLKVector3 lightColor = GLKVector3Make(1.0f, 1.0f, 1.0f);
    
    glUniform3fv(objectColorSlot, 1, objectColor.v);
    glUniform3fv(lightColorSlot, 1, lightColor.v);
    
    
    // 创建顶点数组 VAO
    glGenVertexArrays(1,&vertexArray);
    
    // 创建顶点缓存 VBO
    glGenBuffers(1, &vertexBuffer);
    
    glBindVertexArray(vertexArray);
    
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 36;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    
    // 设置顶点数据
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
        
    glGenVertexArrays(1,&lightVertexArray);
    glBindVertexArray(lightVertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    
    [self.lightShader use];
    
    GLuint lightprogram = self.lightShader.programId;
    
    // 获取 shader 中的参数，然后传数据进去
    GLuint lightpositionSlot = glGetAttribLocation(lightprogram, "Position");
    // 设置顶点数据
    glEnableVertexAttribArray(lightpositionSlot);
    glVertexAttribPointer(lightpositionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    // 设置纹理数据
//    glEnableVertexAttribArray(textureCoordsSlot);
//    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
}

- (void)render {
    [self.shader use];
    GLuint program = self.shader.programId;
    
    //当调用glClear函数，清除颜色缓冲之后，整个颜色缓冲都会被填充为glClearColor里所设置的颜色。在这里，我们将屏幕设置白色。
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    //glClear(GL_COLOR_BUFFER_BIT);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
//    // 将纹理 ID 传给着色器程序
//    glActiveTexture(GL_TEXTURE0);
//    glBindTexture(GL_TEXTURE_2D, texture1ID);
//    glUniform1i(texture1Slot, 0);  // 将 textureSlot 赋值为 0，而 0 与 GL_TEXTURE0 对应，这里如果写 1，上面也要改成 GL_TEXTURE1
//
//    glActiveTexture(GL_TEXTURE1);
//    glBindTexture(GL_TEXTURE_2D, texture2ID);
//    glUniform1i(texture2Slot, 1);  // 将 textureSlot 赋值为 0，而 0 与 GL_TEXTURE0 对应，这里如果写 1，上面也要改成 GL_TEXTURE1
    
    
//    GLKMatrix4 transformMatrix;
//    // 初始化为单位矩阵，不对图形产生任何变换
//    transformMatrix = GLKMatrix4Identity;
//    transformMatrix = GLKMatrix4MakeTranslation(1.0, 0.0, 0.0);
    
    GLfloat changeValue = self.displayLink.timestamp - self.startTimeInterval;
    
    // model
//    GLKMatrix4 model = GLKMatrix4MakeRotation(changeValue*GLKMathDegreesToRadians(50.0),0.5,1.0,0.0);
//    GLKMatrix4 model = GLKMatrix4Identity;
    // view
//    GLKMatrix4 view = GLKMatrix4MakeTranslation(0, 0, -4);
//    GLKMatrix4 view = GLKMatrix4Identity;
    

//    GLKVector3 center = GLKVector3Add(pos, front);
//
    GLKMatrix4 view = GLKMatrix4MakeLookAt(2, 1, 5, 0, 0, 0, 0, 1, 0);


    // projection
    GLKMatrix4 projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0), 2.0/3.0, 0.1, 100.0);
//    GLKMatrix4 projection = GLKMatrix4Identity;
    
//    GLuint modelUniformLocation = glGetUniformLocation(program, "model");
//    glUniformMatrix4fv(modelUniformLocation, 1, GL_FALSE, model.m);
    
    GLuint viewUniformLocation = glGetUniformLocation(program, "view");
    glUniformMatrix4fv(viewUniformLocation, 1, GL_FALSE, view.m);
    
    GLuint projectionUniformLocation = glGetUniformLocation(program, "projection");
    glUniformMatrix4fv(projectionUniformLocation, 1, GL_FALSE, projection.m);
    
    GLKMatrix4 model = GLKMatrix4Identity;
    
    GLuint modelUniformLocation = glGetUniformLocation(program, "model");
    glUniformMatrix4fv(modelUniformLocation, 1, GL_FALSE, model.m);
    
    
    glBindVertexArray(vertexArray);
    // 开始绘制
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    
    [self.lightShader use];
    
    GLuint lightprogram = self.lightShader.programId;
    
    GLuint lightviewUniformLocation = glGetUniformLocation(lightprogram, "view");
    glUniformMatrix4fv(lightviewUniformLocation, 1, GL_FALSE, view.m);
    
    GLuint lightprojectionUniformLocation = glGetUniformLocation(lightprogram, "projection");
    glUniformMatrix4fv(lightprojectionUniformLocation, 1, GL_FALSE, projection.m);
    
    GLKMatrix4 translation = GLKMatrix4MakeTranslation(1.2, 1.0, 2.0);
    
    GLKMatrix4 scale = GLKMatrix4MakeScale(0.2, 0.2, 0.2);

    GLKMatrix4 lightModel = GLKMatrix4Multiply(translation,scale);
    
    GLuint lightmodelUniformLocation = glGetUniformLocation(lightprogram, "model");
    glUniformMatrix4fv(lightmodelUniformLocation, 1, GL_FALSE, lightModel.m);
    
    glBindVertexArray(lightVertexArray);
    // 开始绘制
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    // 将绑定的渲染缓存呈现到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

// 绑定图像要输出的 layer
- (void)bindRenderLayer:(CALayer <EAGLDrawable> *)layer {
    GLuint renderBuffer; // 渲染缓存
    GLuint frameBuffer;  // 帧缓存
    
    GLuint depthRenderBuffer;
    
    // 绑定渲染缓存要输出的 layer
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    // Setup depth render buffer
    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    // Create a depth buffer that has the same size as the color buffer.
    glGenRenderbuffers(1, &depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    
    
    // 将渲染缓存绑定到帧缓存上
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              renderBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER,
                              depthRenderBuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    
//
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
//                              GL_STENCIL_ATTACHMENT,
//                              GL_RENDERBUFFER,
//                              depthRenderBuffer);
}

// 获取渲染缓存宽度
- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    
    return backingWidth;
}

// 获取渲染缓存高度
- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    return backingHeight;
}

@end

#pragma clang diagnostic pop
