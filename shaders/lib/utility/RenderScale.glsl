#if (RENDER_SCALE_1000X != 1000) || SR_ENABLE
    #define scaleTexelPos(texelPos) ivec2(vec2(texelPos) * renderScale)
    #define scaleScreenUv(uv) ((uv) * renderScale)
#else
    #define scaleTexelPos(texelPos) texelPos
    #define scaleScreenUv(uv) uv
#endif
