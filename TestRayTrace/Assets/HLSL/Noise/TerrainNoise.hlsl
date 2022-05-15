#ifndef TERRAINNOISE_HLSL
#define TERRAINNOISE_HLSL
#include "NoiseCommonDef.hlsl"
//Auto Generated by CosFBM
Texture2D CosFBM_height;
Texture2D CosFBM_grad;

float CosFBM(float2 p)
{
    float3 hBound = float3(300, 50, 300);
    float2 ndc = p / hBound.xz;
    float2 uv = (1 + ndc) * 0.5;
    float hr = CosFBM_height.SampleLevel(noise_linear_repeat_sampler, uv, 0).r;
    hr = 2 * (hr - 0.5);
    return hr * hBound.y;
}

float CosFBM_Dxy(float2 p)
{
    float3 hBound = float3(300, 50, 300);
    float2 ndc = p / hBound.xz;
    float2 uv = (1 + ndc) * 0.5;
    float2 packedDir = CosFBM_grad.SampleLevel(noise_linear_repeat_sampler, uv, 0).xy;
    return normalize(packedDir * 2 - 1);
}

float2 CosFBM_DisSquareGrad(float2 p, float3 target)
{
    return 2 * (p - target.xz) + 2 * (CosFBM(p) - target.y) * CosFBM_Dxy(p);
}

float3 CosFBM_NearestPoint(float3 target, int loopNum, float step)
{
    float2 p = target.xz;
    for (int i = 0; i < loopNum; i++)
    {
        p -= CosFBM_DisSquareGrad(p, target) * step;
    }
    return float3(p.x, CosFBM(p), p.y);
}

#endif