#ifndef SPLINECOMMONDEF_HLSL
#define SPLINECOMMONDEF_HLSL

#define DEFAULT_SPLINE_CAP_THICKNESS 0.01
#include "../SDFGame/SDFCommonDef.hlsl"
#include "../Transform/TransformCommonDef.hlsl"

struct SplineProjInfo
{
    //-1:not valid
    //0:head
    //1:body
    //2:tail
    int flag;
    float dis;
    float3 projPnt; 
    float3 extra;//extra info
};

void Init(out SplineProjInfo info)
{
    info.flag = -1;
    info.dis = -1;
    info.projPnt = float3(0, 0, 0);
    info.extra = float3(0, 0, 0);
}

void UpdateInfo(inout SplineProjInfo info, SplineProjInfo x)
{
    if (info.flag < 0)
    {
        if (x.flag >= 0)
        {
            info = x;
        }
    }
    else if (x.flag == 1 && x.dis < info.dis)
    {
        info = x;
    }
}

float SDFBoxedSpline(float3 p, in Transform trans, in float2 box, 
    in SplineProjInfo bodyInfo,
    in SplineProjInfo headInfo,
    in SplineProjInfo tailInfo)
{
    p = WorldToLocal(trans, p);
    float re = 1000000;
    if (bodyInfo.flag == 1)
    {
        float d1 = SDFBox(float2(bodyInfo.dis, p.y), float2(0, 0), box);
        re = min(re, d1);
    }

    if (headInfo.flag == 0)
    {
        float3 u = headInfo.extra;
        float3 v = float3(0, 1, 0);
        float3 w = cross(u, v);
        float d2 = SDFBoxByUVW(p, u, v, w, headInfo.projPnt, float3(DEFAULT_SPLINE_CAP_THICKNESS, box.y, box.x));
        re = min(re, d2);
    }

    if (tailInfo.flag == 2)
    {
        float3 u = tailInfo.extra; 
        float3 v = float3(0, 1, 0);
        float3 w = cross(u, v);
        float d3 = SDFBoxByUVW(p, u, v, w, tailInfo.projPnt, float3(DEFAULT_SPLINE_CAP_THICKNESS, box.y, box.x));
        re = min(re, d3);
    }
    return re;
}
#endif