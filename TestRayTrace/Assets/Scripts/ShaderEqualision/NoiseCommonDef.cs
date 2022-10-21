using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static MathHelper.XMathFunc;
using MathHelper;
using static MathHelper.Vec;

namespace ShaderEqualision
{
    public static class NoiseCommonDef
    {
        private static float noise_texBase(in Vector3 x)
        {
            Vector3 p = floor(x);
            Vector3 f = frac(x);
            f = Vec.Mul(Vec.Mul(f,f) ,(Vector3.one * 3.0f - 2.0f * f));
            Vector2 uv = p.xy() + new Vector2(37.0f, 17.0f) * p.z + f.xy();
            var tex = ShaderToyTool.Instance.shiftNoiseTex;
            uv = (uv + 0.5f*Vector2.one) / 256;
            Vector2 rg = tex.GetPixelBilinear(uv.x,uv.y).yx();//shiftNoiseTex.SampleLevel(noise_linear_repeat_sampler, (uv + 0.5) / 256, 0).yx;
            return lerp(rg.x, rg.y, f.z);
        }

        private static float noise(in Vector3 x)
        {
            return noise_texBase(x);
            //return noise_computational(x);
        }

        public static float fbm4(in Vector3 p)
        {
            float n = 0.0f;
            n += 1.000f * noise(p * 1.0f);
            n += 0.500f * noise(p * 2.0f);
            n += 0.250f * noise(p * 4.0f);
            n += 0.125f * noise(p * 8.0f);
            return n;
        }

        public static float fbm4_01(in Vector3 p)
        {
            return fbm4(p)/(1.0f+0.5f+0.25f+0.125f);
        }
    }
}
