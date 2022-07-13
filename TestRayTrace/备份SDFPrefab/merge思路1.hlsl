float d = re;
float2 box = float2(0.05, 0.1);
Transform trans;
Init(trans);
trans.pos = float3(0.25, 0.1, 0.15);
trans.rotEuler = float3(0, 180, 180);
float2 spline[9];
spline[0] = float2(-0.05, 0);
spline[1] = float2(0.1, 0);
spline[2] = float2(0.4, 0);
spline[3] = float2(0.5, 0);
spline[4] = float2(0.5, -0.2);
spline[5] = float2(0.5, -0.35);
spline[6] = float2(0.36, -0.35);
spline[7] = float2(0.13, -0.3499999);
spline[8] = float2(0, -0.35);
FUNC_SDFBoxedQuadBezier(d, p, spline, 9, trans, box)
re = min(re,d);

float d = re;
float2 box = float2(0.05, 0.1);
Transform trans;
Init(trans);
trans.pos = float3(0.25, 0.1, 0.85);
trans.rotEuler = float3(0, 0, 0);
float2 spline[9];
spline[0] = float2(-0.05, 0);
spline[1] = float2(0.1, 0);
spline[2] = float2(0.4, 0);
spline[3] = float2(0.5, 0);
spline[4] = float2(0.5, -0.2);
spline[5] = float2(0.5, -0.35);
spline[6] = float2(0.36, -0.35);
spline[7] = float2(0.13, -0.3499999);
spline[8] = float2(0, -0.35);
FUNC_SDFBoxedQuadBezier(d, p, spline, 9, trans, box)
re = min(re,d);

re = min(re, 0 + SDFBox(p, float3(0.284, 0.1, 0.5), float3(0.05, 0.1, 0.35), float3(0, 0, 0)));

//sdf merge
//1.先对所有mergedObjects给id
//2.对于所有spline（逐行处理逻辑）：
//2.1 将d换成d_[id]
//2.2 删除re=min(re,d)
//2.3 其他变量的删重
//3.对于所有box,换成d_[id]=SDFBox...
//4.re = min(re,d_[id])所有代码