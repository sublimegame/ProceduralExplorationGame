#version ogre_glsl_ver_330

//----------------------------------------------------------
#define float2 vec2
#define float3 vec3
#define float4 vec4

#define int2 ivec2
#define int3 ivec3
#define int4 ivec4

#define uint2 uvec2
#define uint3 uvec3
#define uint4 uvec4

#define float2x2 mat2
#define float3x3 mat3
#define float4x4 mat4

#define ushort uint

#define toFloat3x3( x ) mat3( x )
#define buildFloat3x3( row0, row1, row2 ) mat3( row0, row1, row2 )

#define mul( x, y ) ((x) * (y))
#define saturate(x) clamp( (x), 0.0, 1.0 )
#define lerp mix
#define rsqrt inversesqrt
#define INLINE

#define sizeForTexture( x ) textureSize( x , 0 )

#define finalDrawId drawId
#define PARAMS_ARG_DECL
#define PARAMS_ARG

#define readUniform( x ) x
#define returnFinalColour( x ) fragColour = ( x )

#define outVs_Position gl_Position
#define OGRE_Sample( tex, sampler, uv ) texture( vkSampler2D(tex, sampler), uv )
#define OGRE_SampleLevel( tex, sampler, uv, lod ) textureLod( tex, uv.xy, lod )
#define OGRE_SampleArray2D( tex, sampler, uv, arrayIdx ) texture( tex, vec3( uv, arrayIdx ) )
#define OGRE_SampleArray2DLevel( tex, sampler, uv, arrayIdx, lod ) textureLod( tex, vec3( uv, arrayIdx ), lod )
#define OGRE_SampleGrad( tex, sampler, uv, ddx, ddy ) textureGrad( tex, uv, ddx, ddy )
#define OGRE_SampleArray2DGrad( tex, sampler, uv, arrayIdx, ddx, ddy ) textureGrad( tex, vec3( uv, arrayIdx ), ddx, ddy )
#define OGRE_ddx( val ) dFdx( val )
#define OGRE_ddy( val ) dFdy( val )
//----------------------------------------------------------

vulkan_layout( location = 0 )
out vec4 fragColour;

vulkan_layout( location = 0 )
in block
{
    vec2 uv0;
} inPs;

vulkan_layout( ogre_t0 ) uniform texture2D Image;
vulkan_layout( ogre_t1 ) uniform texture2D Depth;

vulkan( layout( ogre_s0 ) uniform sampler samplerState; )
vulkan( layout( ogre_s1 ) uniform sampler DepthSampler; )

vulkan( layout( ogre_P0 ) uniform params { )
    uniform float near;
    uniform float far;
    uniform float edgeThreshold;
vulkan( }; )

void main()
{
    float2 texelSize = sizeForTexture(Depth);
    float stepX = 1.0 / texelSize.x;
    float stepY = 1.0 / texelSize.y;

    // Sample depth values
    float dCenter = OGRE_Sample( Depth, DepthSampler, inPs.uv0).x;
    float dLeft      = OGRE_Sample( Depth, DepthSampler, inPs.uv0 + float2(-stepX, 0)).x;
    float dRight     = OGRE_Sample( Depth, DepthSampler, inPs.uv0 + float2(stepX, 0)).x;
    float dTop       = OGRE_Sample( Depth, DepthSampler, inPs.uv0 + float2(0, -stepY)).x;
    float dBottom    = OGRE_Sample( Depth, DepthSampler, inPs.uv0 + float2(0, stepY)).x;

    const float epsilon = 1e-4; // Small bias to prevent artifacts
    float edge = 0.0;
    edge += abs(dCenter - dLeft) > epsilon ? abs(dCenter - dLeft) : 0.0;
    edge += abs(dCenter - dRight) > epsilon ? abs(dCenter - dRight) : 0.0;
    edge += abs(dCenter - dTop) > epsilon ? abs(dCenter - dTop) : 0.0;
    edge += abs(dCenter - dBottom) > epsilon ? abs(dCenter - dBottom) : 0.0;
    edge *= 50;

    float edgeFactor = step(readUniform(edgeThreshold), edge);

    returnFinalColour(mix(OGRE_Sample( Image, samplerState, inPs.uv0 ) , float4(0, 0, 0, 1.0), edgeFactor));
}
