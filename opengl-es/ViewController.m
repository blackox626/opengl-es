//
//  ViewController.m
//  opengl-es
//
//  Created by blackox626 on 2020/8/11.
//  Copyright © 2020 vdian. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import "Shader.h"
#import "TextureUtil.h"

typedef struct {
    GLKVector3 positionCoord; // 定点坐标 (X, Y, Z) 【-1.0，1.0】
    GLKVector2 textureCoord; // 纹理坐标 (U, V) 【0，1】
} SenceVertex;

@interface ViewController () {
    GLfloat changeValue;
    GLuint texture1ID;
    GLuint texture2ID;
    
    GLuint vertexBuffer;
    
    GLuint positionSlot;
    GLuint texture1Slot;
    GLuint texture2Slot;
    GLuint textureCoordsSlot;
}

@property (nonatomic, assign) SenceVertex *vertices; // 顶点数组
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic,strong) Shader *shader;
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
    
    [self initShader];
    [self createTexture];
    [self bind];
//    int i = 0;
//    while (i< 1000000) {
//        [self render];
//        i++;
//
//        sleep(2);
//    }
    
    
    self.startTimeInterval = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                           forMode:NSRunLoopCommonModes];

    
//    // 删除顶点缓存
//    glDeleteBuffers(1, &vertexBuffer);
//    vertexBuffer = 0;
}

- (void)initVertices {
    // 创建顶点数组
    self.vertices = malloc(sizeof(SenceVertex) * 4); // 4 个顶点
    
    self.vertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}}; // 左上角
    self.vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}}; // 左下角
    self.vertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}}; // 右上角
    self.vertices[3] = (SenceVertex){{1, -1, 0},{1, 0}}; // 右下角
}

- (void)initContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
}

- (void)initShader {
    // 设置视口尺寸
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    // 编译链接 shader
    Shader *shader = [[Shader alloc] init:@"glsl"];
    [shader use];
    
    self.shader = shader;
}

- (void)createTexture {
    // 读取纹理
    texture1ID = [TextureUtil createTextureWithImageName:@"sample.png"];
    texture2ID = [TextureUtil createTextureWithImageName:@"awesomeface.png"];
}

- (void)bind {
    GLuint program = self.shader.programId;
    
    // 获取 shader 中的参数，然后传数据进去
    positionSlot = glGetAttribLocation(program, "Position");
    texture1Slot = glGetUniformLocation(program, "Texture1");  // 注意 Uniform 类型的获取方式
    texture2Slot = glGetUniformLocation(program, "Texture2");
    textureCoordsSlot = glGetAttribLocation(program, "TextureCoords");
    
    // 创建顶点缓存
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    
    // 设置顶点数据
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    // 设置纹理数据
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
}

- (void)render {
    GLuint program = self.shader.programId;
    
    changeValue += self.displayLink.timestamp - self.startTimeInterval;

    GLfloat elValue = sinf(changeValue);
    
    //当调用glClear函数，清除颜色缓冲之后，整个颜色缓冲都会被填充为glClearColor里所设置的颜色。在这里，我们将屏幕设置白色。
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    // 将纹理 ID 传给着色器程序
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture1ID);
    glUniform1i(texture1Slot, 0);  // 将 textureSlot 赋值为 0，而 0 与 GL_TEXTURE0 对应，这里如果写 1，上面也要改成 GL_TEXTURE1
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture2ID);
    glUniform1i(texture2Slot, 1);  // 将 textureSlot 赋值为 0，而 0 与 GL_TEXTURE0 对应，这里如果写 1，上面也要改成 GL_TEXTURE1
    
    
//    GLKMatrix4 transformMatrix;
//    // 初始化为单位矩阵，不对图形产生任何变换
//    transformMatrix = GLKMatrix4Identity;
//    transformMatrix = GLKMatrix4MakeTranslation(1.0, 0.0, 0.0);
    
    // 旋转
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(elValue,0.0, 0.0, 1.0);

    // 缩放
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(elValue, elValue, 1.0);
    
    GLKMatrix4 transformMatrix = GLKMatrix4Multiply(rotationMatrix , scaleMatrix);
//    GLKMatrix4 transformMatrix = GLKMatrix4Identity;
    GLuint transformUniformLocation = glGetUniformLocation(program, "transform");
    glUniformMatrix4fv(transformUniformLocation, 1, GL_FALSE, transformMatrix.m);
    
    // 开始绘制
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // 将绑定的渲染缓存呈现到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

// 绑定图像要输出的 layer
- (void)bindRenderLayer:(CALayer <EAGLDrawable> *)layer {
    GLuint renderBuffer; // 渲染缓存
    GLuint frameBuffer;  // 帧缓存
    
    // 绑定渲染缓存要输出的 layer
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    // 将渲染缓存绑定到帧缓存上
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              renderBuffer);
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
