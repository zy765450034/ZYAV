//
//  DefaultShader.metal
//  MetalTest
//
//  Created by Tom Ward on 24/07/2015.
//  Copyright (c) 2015 Tom Ward. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    simd::float4 position [[position]];
    simd::float2 uv;
} VertexOutput;

vertex VertexOutput VertexShader(
    constant float2*    verts [[buffer(0)]],
    constant float2*    uvs   [[buffer(1)]],
    const uint          index [[vertex_id]])
{
    VertexOutput out;
    out.position = float4(verts[index].xy, 0.0, 1.0);
    out.uv = uvs[index].xy;
    return out;
}

fragment float4 FragmentShader(
    VertexOutput                input [[stage_in]],
    texture2d<float>            texture [[texture(0)]] )
{
    constexpr sampler s(coord::normalized, address::repeat, filter::linear);
    
    return texture.sample(s, input.uv);
}
